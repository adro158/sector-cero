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
│   ├── BitCorrupto, PaquetePerdido, ProcesoColgado   Un gestor por tipo de horda
│   ├── PoolGemas, PoolProyectiles, PoolParticulas, PoolNumeros
│   ├── ResistenciaMalware     El elemento diferencial
│   ├── Jefe, Elite1..3        Ocultos hasta que el director los activa
│   ├── DirectorOleadas        Apariciones, élites y llegada del jefe
│   └── SistemaNiveles         Experiencia, niveles, mejoras y evoluciones
└── Interfaz/HUD               HUD, panel de mejoras, pausa, opciones y resultados
```

Además hay cinco **autoloads**, nodos que viven fuera de las escenas y
sobreviven a los cambios de escena: `BusEventos`, `GestorGuardado`,
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
multiplicadores en el gestor de armas, y las evoluciones se guardan en el nodo
de cambio de personaje.

## 3. Organización del código

```
projecte/
├── globales/       Autoloads
├── escenas/        Escenas y sus scripts: arena, jugabilidad, interfaz, menú
├── recursos/       Clases de datos y sus .tres
├── medios/         Audio y shaders
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

**Rejilla espacial.** Para separar a los enemigos entre sí, cada uno tendría que
compararse con todos los demás (coste cuadrático). La rejilla divide el mapa en
celdas y solo se consultan las celdas cercanas. Con 500 enemigos, la física
bajó de 19,17 ms a 4,36 ms por fotograma (el presupuesto a 60 FPS son
16,67 ms). La usan también las armas para encontrar a quién golpear.

**Armas y personajes.** Hay dos tipos de arma: de área (Firewall y Escáner,
golpean todo lo que hay en un radio) y de proyectil (Ping, salta de un enemigo
a otro). Los proyectiles usan el mismo patrón de arrays y MultiMesh que la
horda. Cada personaje lleva una herramienta y solo dispara la del activo. Se
cambia con Q, con 10 s de espera entre cambios.

**Resistencia adaptativa.** Cada arma avisa del daño que hace de verdad. Cada
20 s, el malware mira cuál le ha hecho más daño y gana un 10 % de resistencia
contra ella (máximo 50 %); contra las demás pierde un 5 %. Se ve en los números
de daño y en el anillo del arma, que se tiñen de rojo en la misma proporción.

**Progresión.** Los enemigos sueltan gemas que se atraen al acercarse. Al subir
de nivel el juego se pausa y se ofrecen tres mejoras. Si se suben varios
niveles de golpe quedan en cola y se eligen de uno en uno. Elegir tres veces
una mejora concreta ofrece la **evolución** de una herramienta, que es otro
recurso de arma, así que el malware empieza sin resistencia contra ella.

**Director de oleadas.** La dificultad sale de pocos números: el intervalo
entre apariciones se interpola de 1 s a 0,15 s a lo largo de 10 minutos y cada
tipo de enemigo declara en qué segundo empieza a salir. Cada minuto desde el
1:30 activa un **élite** con uno o dos **afijos** sorteados (blindado,
replicante, aura lenta y explosivo): con cuatro afijos salen diez élites
distintos sin diseñarlos uno a uno. A los 10 minutos deja de salir horda y llega
el **jefe**, que embiste en línea recta tras un aviso rojo.

**Mapa infinito.** El suelo es un rectángulo más grande que la pantalla que se
recoloca bajo la cámara en cada fotograma. Su shader dibuja la placa base según
la posición en el mundo, así que el dibujo no se mueve y parece un suelo fijo
que no se acaba. Los enemigos que se quedan muy atrás reaparecen al otro lado
del jugador.

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
destello blanco del enemigo golpeado y glitch de la horda por shader (sustituye
a la animación, que un MultiMesh no permite), tinte y sacudida de cámara al
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
  evoluciones sin tocar los `.tres`, etc.
- **Capturas con ventana** de cada pantalla, generadas por un script que juega
  solo.
- **Simulador de partidas** (`simular_partidas.gd`): un bot juega partidas
  completas con semillas fijas, así el mismo comando repite las mismas partidas
  y se puede comparar el antes y el después de un cambio de balance. Con el
  mapa infinito el juego se había vuelto fácil (5 victorias de 5 sin peligro)
  y el jefe, con una sola herramienta activa, duraba más de 4 minutos. Tras
  ajustar la vida del jefe y de los élites, la densidad final de la horda, la
  regeneración y el afijo aura lenta (que dejaba al jugador más lento que el
  enemigo básico y lo mataba sin remedio), el resultado es de **4 victorias de
  5**, con combates contra el jefe de 30 s a 3 minutos.
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
- **Gráficos:** la horda, el élite y los iconos los dibuja un script propio a
  partir de formas simples. El suelo, el glitch y el CRT son shaders propios.
  Los personajes y el jefe se hicieron con IA a partir de un ejemplo del
  profesor (idea con Gemini, hojas de sprites con Claude) y se recolorearon con
  scripts propios.
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
ella Claude creó las cuatro hojas de sprites.

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
