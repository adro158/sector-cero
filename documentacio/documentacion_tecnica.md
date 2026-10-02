# Documentación técnica — Sector Cero

**Autores:** Adam y Alan · **Motor:** Godot 4.7.2 (GDScript) · **Plataforma:**
Windows y Linux

## 1. El proyecto

Sector Cero es un *survivors-like* en 2D con vista cenital. El jugador es un
proceso antivirus dentro de un ordenador infectado. Solo controla el
movimiento: su herramienta ataca sola. El malware llega en oleadas cada vez más
densas, suelta fragmentos de datos que dan experiencia y, al subir de nivel, el
jugador elige una de tres mejoras. A los 10 minutos llega el jefe final y
derrotarlo es la victoria.

**El elemento diferencial es la resistencia adaptativa:** el malware se hace
resistente a la herramienta que más daño le hace, igual que el malware real
evoluciona contra los antivirus más usados. Para seguir haciéndole daño hay que
cambiar de personaje, porque cada uno lleva una herramienta distinta.

## 2. Arquitectura

### Escenas

```
menu_principal.tscn            Pantalla inicial (reglas, récord, opciones)
juego.tscn                     La partida, que solo junta tres piezas:
├── Arena                      Suelo infinito y punto de aparición
├── RaizJuego                  Toda la jugabilidad
│   ├── Jugador                Movimiento, salud, armas, cambio de personaje
│   ├── BitCorrupto, PaquetePerdido, ProcesoColgado, Troyano, Ransomware
│   │                          Un gestor por tipo de horda
│   ├── PoolGemas, PoolProyectiles, PoolParticulas, PoolNumeros
│   ├── ResistenciaMalware     El elemento diferencial
│   ├── Jefe, Elite1..3        Ocultos hasta que el director los activa
│   ├── DirectorOleadas        Apariciones, élites y llegada del jefe
│   └── SistemaNiveles         Experiencia, niveles, mejoras y evoluciones
└── Interfaz/HUD               HUD, panel de mejoras, pausa, opciones y resultados
```

Además hay seis **autoloads**, nodos que viven fuera de las escenas y
sobreviven a los cambios de escena: `Actualizador` (carga la actualización
descargada; tiene que ser el primero), `BusEventos`, `GestorGuardado`,
`GestorAudio`, `Transicion` (fundido a negro entre escenas) y `EfectoCRT`
(filtro de pantalla).

### Cómo se comunican las piezas

**Un bus de eventos como frontera.** `BusEventos` es un autoload que solo
declara señales: salud, experiencia, subida de nivel, mejora elegida, enemigo
muerto, fin de partida, pausa, aparición de élites y jefe, etc. La jugabilidad
las emite y la interfaz, el audio y la persistencia las escuchan. Ninguno de
ellos conoce a los demás: el audio, por ejemplo, no lo llama nadie. Esto nació
del reparto inicial entre dos personas (cada uno trabajaba en sus escenas sin
abrir las del otro) y se ha mantenido porque hace el código más fácil de
cambiar.

**Grupos en lugar de rutas a nodos.** Lo que tiene que encontrar a otro nodo lo
busca por grupo (`jugador`, `objetivos`, `elites`...), no por su ruta en el
árbol. Así se puede reorganizar una escena sin romper otra.

**Señales locales para lo que no sale de la jugabilidad.** El aviso de daño a
un enemigo se dispara decenas de veces por segundo y solo lo usan los números
de daño, así que es una señal del propio gestor y no del bus.

**Un mismo contrato para todo lo que recibe daño.** Los gestores de la horda,
los élites y el jefe están en el grupo `objetivos` y tienen los mismos dos
métodos: `danar_en_area(centro, radio, daño)` y `mas_cercano(desde, radio)`.
Las armas, los proyectiles y los números de daño recorren ese grupo sin saber
qué es cada objetivo.

### Datos separados del código

Cada arma, mejora, tipo de enemigo, afijo de élite, personaje y la
configuración de las oleadas es un **Resource** (`.tres`) con su clase de datos
(`DatosArma`, `DatosMejora`...). Añadir un arma o un afijo es crear un fichero,
no tocar código, y el balance se ajusta sin abrir ninguna escena.

Una regla importante: **las mejoras nunca modifican el `.tres`**. Godot comparte
y guarda en caché los recursos cargados: sumar un 20 % de daño al recurso del
arma lo dejaría pegado para la siguiente partida. Las mejoras son
multiplicadores en el nodo al que afectan (el gestor de armas, el jugador, la
resistencia del malware, el cambio de personaje o el pool de gemas), y las
evoluciones se guardan en el nodo de cambio de personaje.

## 3. Organización del código

```
projecte/
├── globales/       Autoloads
├── escenas/        Escenas y sus scripts: arena, jugabilidad, interfaz, menú
├── recursos/       Clases de datos y sus .tres
├── medios/         Audio, shaders y texturas del suelo
└── herramientas/   Scripts que no forman parte del juego
```

- Todo en castellano (variables, funciones, señales, comentarios), salvo la API
  de Godot. Los comentarios explican el porqué, no el qué.
- Cada script hace una cosa y ronda o queda por debajo de las 200 líneas.
- Las herramientas (`generar_sprites.gd`, `generar_audio.gd`,
  `simular_partidas.gd`, `medir_rendimiento.gd`) se ejecutan desde la línea de
  comandos y se excluyen del ejecutable exportado.

## 4. Mecánicas y sistemas

**La horda: un enemigo no es un nodo.** Un nodo por enemigo serían cientos de
nodos procesándose y cientos de llamadas de dibujado. Cada tipo de enemigo es
un gestor con arrays de tamaño fijo (posiciones, vidas, destellos) y un único
`MultiMeshInstance2D` que los dibuja todos de una vez. El *pool* es el propio
array: al morir un enemigo, el último vivo ocupa su hueco, así que los vivos
siempre son las primeras posiciones y crear o destruir uno es mover un contador.

**La embestida del troyano, sin nodos.** El troyano persigue como los demás y,
a menos de 220 px del jugador, se para 0,4 s parpadeando en rojo y embiste en
línea recta al triple de su velocidad durante 0,6 s; después tarda 2,5 s en
poder repetirlo. Es la misma máquina de estados que el jefe (perseguir, aviso,
embestida), pero el jefe es un nodo y guarda su estado en variables, y un
troyano no: su estado, su cronómetro y su dirección van en tres arrays de
tamaño fijo más, con el mismo índice que su posición, y se mueven con él cuando
ocupa el hueco de otro. Ese código está en su propio script
(`embestida_horda.gd`) y el gestor solo lo crea para los tipos que embisten
(un campo `embiste` en sus datos), así el gestor no crece y los demás tipos no
pagan nada. El aviso llega al shader de la horda como un segundo dato por
enemigo (`INSTANCE_CUSTOM.g`), igual que el destello.

**Rejilla espacial.** Para separar a los enemigos entre sí, cada uno tendría que
compararse con todos los demás (coste cuadrático). La rejilla divide el mapa en
celdas y solo se consultan las celdas cercanas. Con 500 enemigos, la física
bajó de 19,17 ms a 4,36 ms por fotograma (el presupuesto a 60 FPS son
16,67 ms). La usan también las armas para encontrar a quién golpear.

**Armas y personajes.** Hay dos tipos de arma: de área (Firewall y Escáner,
golpean todo lo que hay en un radio) y de proyectil (Ping, salta de un enemigo
a otro). Los proyectiles usan el mismo patrón de arrays y MultiMesh que la
horda; su sprite apunta a la derecha y cada uno se gira con el ángulo de su
dirección, así que al rebotar se gira solo. Las gemas también son un MultiMesh,
con un sprite en grises que cada gema tiñe con un color propio de la instancia
(`use_colors`) según lo que vale: cian, verde o dorado. Cada personaje lleva una herramienta y solo dispara la del activo. Se
cambia con Q, con 10 s de espera entre cambios (la mejora Cambio en caliente
la acorta un 20 % cada vez, hasta un mínimo de 4 s: sin espera se podría
cambiar sin parar y la resistencia no obligaría a decidir nada).

**Resistencia adaptativa.** Cada arma avisa del daño que hace de verdad. Cada
20 s, el malware mira cuál le ha hecho más daño y gana un 10 % de resistencia
contra ella (máximo 50 %); contra las demás pierde un 5 %. Se ve en los números
de daño y en el anillo del arma, que se tiñen de rojo en la misma proporción.
La mejora **Actualizar firmas** es la otra respuesta del jugador, además de
cambiar de personaje: cada vez que se elige, ese 10 % de cada análisis se
multiplica por 0,7 (un 7 %, luego un 4,9 %...), así que el malware tarda más
en adaptarse a todas las herramientas.

**Progresión.** Los enemigos sueltan gemas que se atraen al acercarse. Al subir
de nivel el juego se pausa y se ofrecen tres de las ocho mejoras: cinco suben
el ataque o la defensa (daño, cadencia, alcance, velocidad e integridad) y tres
actúan sobre otros sistemas (Actualizar firmas, sobre la resistencia; Cambio en
caliente, sobre la espera entre personajes; y Caché ampliada, que agranda un
30 % el radio en el que las gemas vuelan hacia el jugador). Si se suben varios
niveles de golpe quedan en cola y se eligen de uno en uno. Elegir tres veces
una mejora concreta ofrece la **evolución** de una herramienta, que es otro
recurso de arma, así que el malware empieza sin resistencia contra ella.

**Director de oleadas.** La dificultad sale de pocos números: el intervalo
entre apariciones se interpola de 1 s a 0,1 s a lo largo de 10 minutos y cada
tipo de enemigo declara en qué segundo empieza a salir (bit corrupto desde el
principio, paquete perdido desde el 0:45, proceso colgado desde el 2:00,
troyano desde el 4:00 y ransomware desde el 6:00). En cada aparición el tipo se
elige al azar entre los disponibles. Un tipo puede limitar además cuántos hay
vivos a la vez (`maximo_vivos`): el ransomware, como mucho 8. Sin ese límite
salían unos 250 por partida, lentos y con mucha vida, que se acumulaban detrás
del jugador. Cada minuto desde el
1:30 activa un **élite** con uno o dos **afijos** sorteados (blindado,
replicante, aura lenta y explosivo): con cuatro afijos salen diez élites
distintos sin diseñarlos uno a uno. A los 10 minutos deja de salir horda y llega
el **jefe**, que embiste en línea recta tras un aviso rojo.

**Mapa infinito.** El suelo es un rectángulo más grande que la pantalla que se
recoloca bajo la cámara en cada fotograma. Su shader dibuja la placa base según
la posición en el mundo, así que el dibujo no se mueve y parece un suelo fijo
que no se acaba. Los enemigos que se quedan muy atrás reaparecen al otro lado
del jugador.

**El suelo de placa base.** El shader divide el mundo en casillas de 256x256 y
cada una elige con un número al azar, siempre el mismo para esa casilla, uno de
los 12 dibujos de un atlas. Los 12 tienen las pistas que tocan el borde en las
mismas posiciones, así que encajan sin costuras en cualquier orden. Dos
texturas más llevan datos en vez de dibujo: una máscara marca las pistas con
datos y cuánto camino llevan en cada punto, y el shader hace avanzar por ellas
un pulso de luz; la otra marca los LEDs, las aspas de los ventiladores y el
brillo de los chips. El avance de los pulsos lo suma `arena.gd` y se lo pasa al
shader, en lugar de usar el reloj del shader, para poder cambiar su velocidad
sin que salten de sitio: van más rápido según pasan los minutos y, cuando
aparece el jefe, los pulsos y el brillo se vuelven rojos. La arena trabaja con
una copia del material, porque si cambiara el del fichero el rojo se quedaría
en la partida siguiente.

**Persistencia.** `GestorGuardado` guarda en un `ConfigFile` dentro de `user://`
la mejor partida (tiempo, nivel y eliminados), el número de partidas y de
victorias y las opciones (volumen de música y efectos, pantalla completa y
filtro CRT). El menú muestra el récord y la pantalla final avisa si se ha
batido.

**Actualizaciones desde el juego.** Al abrir el menú, el autoload
`Actualizador` pregunta a la API de GitHub cuál es la última release. Si es más
nueva, aparece el botón ACTUALIZAR, que descarga solo el `.pck` (el contenido
del juego, alrededor de 1 MB, frente a los 110 MB del ejecutable) en `user://`
y reinicia el juego. Al arrancar, el `Actualizador`, que es el primer autoload,
carga ese `.pck` encima del original con `ProjectSettings.load_resource_pack`,
antes de que se cargue nada más. Las releases las publica una GitHub Action al
subir una etiqueta de versión. Lo que Godot lee antes de cualquier script
(`project.godot` y la lista de clases) no viaja en el `.pck`: si cambia, la
release lo indica y el juego pide descargar el ejecutable entero.

**Audio.** Todo el audio se genera con un script propio que suma ondas simples,
como un chip de sonido antiguo: 17 efectos y 3 músicas en bucle. `GestorAudio`
escucha el bus y los cambios de escena. Un efecto no puede repetirse antes de
50 ms: con decenas de muertes a la vez, sonar en todas sería solo ruido.

**Feedback.** Números de daño, partículas de colores (también con MultiMesh),
destello blanco del enemigo golpeado, parpadeo rojo del troyano antes de
embestir y glitch de la horda por shader (sustituyen a la animación, que un
MultiMesh no permite), tinte y sacudida de cámara al
recibir daño, avisos en el HUD, filtro CRT y fundidos entre escenas.

## 5. Problemas y soluciones

**El más difícil: índices caducados en la rejilla espacial.** La rejilla se
reconstruía antes de retirar a los muertos. Al retirar uno, el último vivo
cambiaba de índice y la rejilla seguía apuntando al antiguo, así que durante un
fotograma ese enemigo no recibía daño. No daba ningún error: solo golpes que no
bajaban la vida. Se encontró con una prueba que la primera vez tampoco lo
detectaba (miraba un fotograma tarde) y se corrigió el orden: primero retirar,
después reconstruir.

**La partida era imposible.** El simulador de partidas mostró que el bot moría
siempre antes del minuto. Se probaron variantes con datos: bajar el daño por
contacto y las apariciones no bastaba; lo que funcionó fue añadir regeneración
de vida.

**Un fallo del motor con los números en los shaders.** En este proyecto
`0.05` escrito en un shader llega como `0.5`. Se comprobó con un shader mínimo
que pinta valores conocidos. La solución es escribirlos como división
(`1.0 / 20.0`).

**La horda se veía más oscura que sus sprites.** Se descubrió al probar el
parpadeo del troyano: el rojo salía marrón. Midiendo píxel a píxel el mismo
PNG dibujado de tres formas (un `Sprite2D`, un MultiMesh con el shader por
defecto y la horda) solo la horda salía distinta: cada canal, al cuadrado. En
Godot 4 el `COLOR` que recibe el shader ya trae la textura, y el nuestro la
volvía a multiplicar. Ahora usa ese `COLOR` directamente.

**Recursos que se descargaban solos.** Al cambiar valores de balance en memoria
desde una herramienta, no surtían efecto: si nada referencia un recurso, Godot
lo descarga y la escena lo vuelve a leer del disco. Se guardan en una variable.

**Sin GPU en la máquina virtual del instituto.** Godot caía a renderizado por
software. Se activó la aceleración 3D de VirtualBox y se fijó el renderizador
Compatibility, que funciona con OpenGL. Los FPS medidos allí no son fiables y
el rendimiento se ha medido en un PC con GPU real.

**Aviso del motor al cerrar.** Si el juego se cierra con la música sonando,
Godot avisa de una fuga del reproductor de audio. Se comprobó que es del motor
(sale con cualquier sonido sin terminar) y no afecta al jugador.

## 6. Testing y rendimiento

- **Ejecución en headless** (sin ventana) para detectar errores de análisis y de
  ejecución tras cada cambio.
- **Scripts de prueba temporales** que provocan una situación y comprueban el
  resultado: récords guardados en disco, cola de niveles, los cuatro afijos, las
  evoluciones sin tocar los `.tres`, la embestida del troyano fotograma a
  fotograma, las tres mejoras nuevas por el camino real (subir de nivel y
  elegir), etc.
- **Capturas con ventana** de cada pantalla, generadas por un script que juega
  solo.
- **Simulador de partidas** (`simular_partidas.gd`): un bot juega partidas
  completas con semillas fijas, así el mismo comando repite las mismas partidas
  y se puede comparar el antes y el después de un cambio de balance. Con el
  mapa infinito el juego se había vuelto fácil (5 victorias de 5 sin peligro)
  y el jefe, con una sola herramienta activa, duraba más de 4 minutos. Tras
  ajustar la vida del jefe y de los élites, la densidad final de la horda, la
  regeneración y el afijo aura lenta (que dejaba al jugador más lento que el
  enemigo básico y lo mataba sin remedio), el resultado fue de **4 victorias de
  5**, con combates contra el jefe de 30 s a 3 minutos.

  Con el troyano, el ransomware y las tres mejoras nuevas, el simulador volvió
  a decidir el balance (10 partidas por variante). El ransomware sin límite
  bajaba al bot de 4 a 1 victoria de 5, y de ahí el máximo de 8 a la vez. Con
  los dos enemigos nuevos el bot seguía en 7 de 10, pero con las mejoras nuevas
  caía a 2 de 10: elegía al azar y, con ocho mejoras, tres de ellas sin daño,
  le tocaban menos de ataque y muchas menos evoluciones (de 14 a 5 en 10
  partidas). Un jugador no elige así,
  así que ahora el bot coge la evolución si sale y, si no, una de ataque si la
  hay. Con ese bot, el juego pasa de **9 victorias de 10** antes del contenido
  nuevo a **8 de 10** después.
- **Medida de rendimiento** (`medir_rendimiento.gd`), en una NVIDIA GeForce
  RTX 5070, sin sincronización vertical. La física es la mediana de lo que
  tarda cada paso; el presupuesto a 60 FPS son 16,67 ms:

| Enemigos | FPS | Física por paso | Peor paso |
|---|---|---|---|
| 100 | 1854 | 0,70 ms | 0,81 ms |
| 300 | 1549 | 2,02 ms | 2,35 ms |
| 600 | 1301 | 4,54 ms | 4,71 ms |
| 1200 | 733 | 9,27 ms | 10,51 ms |

  El objetivo de la propuesta (300 enemigos a 60 FPS) se cumple con mucho
  margen. El coste crece de forma casi lineal con el número de enemigos gracias
  a la rejilla espacial; sin ella crecería con el cuadrado.

## 7. Herramientas y assets

- **Godot 4.7.2** con el renderizador Compatibility, **Git y GitHub**, y
  **GitHub Actions** para exportar y publicar cada versión.
- **Gráficos:** los sprites de la horda y del élite, de los fragmentos de
  datos y del proyectil del Ping, tres iconos de mejora y las texturas del
  suelo los dibujó Claude con scripts de Python, en una
  conversación aparte; los demás iconos los dibuja un script propio a partir de
  formas simples. El suelo, la horda y el CRT tienen shaders propios. Los
  personajes y el jefe se hicieron con IA a partir de un ejemplo del profesor
  (idea con Gemini, hojas de sprites con Claude) y se recolorearon con scripts
  propios.
- **Audio:** sintetizado con un script propio.
- **Tipografía:** la monoespaciada del sistema.

El detalle de cada asset está en `creditos.md`.

## 8. Uso de la inteligencia artificial

Hemos usado **Claude** (Anthropic) como asistente de programación durante todo
el proyecto:

- **Programar:** ha escrito la mayor parte del código a partir de lo que le
  pedíamos, siguiendo las normas del proyecto (castellano, scripts cortos,
  comentarios del porqué).
- **Diseñar:** ha propuesto alternativas (la temática, la rejilla, la forma de
  los afijos) y nosotros hemos decidido. Las decisiones están en la bitácora con
  su motivo.
- **Detectar errores:** ha revisado el código y encontrado fallos como el de la
  rejilla o la cadencia que podía llegar a cero.
- **Probar:** ha escrito las pruebas en headless, el simulador de partidas y la
  medida de rendimiento.
- **Documentar:** ha redactado borradores de la bitácora y de esta
  documentación.

Para los sprites de los personajes y del jefe, el profesor compartió como
ejemplo unos sprites de nigromantes hechos con Claude; Adam generó con
**Gemini** una ilustración parecida con la temática del juego, y a partir de
ella Claude creó las cuatro hojas de sprites. Más adelante, en una conversación
aparte, Adam encargó a Claude el arte del resto: los enemigos redibujados, el
troyano y el ransomware, tres iconos de mejora y el suelo de placa base con su
shader. Después se integró en el proyecto y se probó como todo lo demás.

Nada se ha dado por bueno sin ejecutarlo. Como el tribunal puede preguntar por
cualquier línea, hemos pedido siempre la versión más fácil de explicar y hemos
repasado el código para poder defenderlo.

## 9. Qué mejoraríamos con más tiempo

- Pixel art propio para los personajes y el jefe, en lugar de los generados
  con IA.
- Más tipos de horda (el gusano que se divide, el *popup* en enjambre) y un
  jefe intermedio.
- Que la resistencia del malware se vea directamente en el HUD, no solo en los
  colores de los números y del anillo.
- Opciones de controles remapeables.
