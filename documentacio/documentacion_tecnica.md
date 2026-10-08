# Documentación técnica — Sector Cero

**Autores:** Adam y Alan · **Motor:** Godot 4.7.2 (GDScript) · **Plataformas:**
Windows y Linux

Este documento explica cómo está hecho el juego por dentro. Cómo llegamos hasta
aquí, con capturas de cada etapa, está en la
[historia del proyecto](historia_del_proyecto.md), y el detalle de cada sesión
en la [bitácora](bitacora.md).

## 1. El juego en pocas palabras

Sector Cero es un *survivors-like* en 2D con vista desde arriba. Eres un
proceso antivirus dentro de un ordenador infectado: solo te mueves y tu
herramienta ataca sola. El malware llega en oleadas cada vez más densas, suelta
fragmentos de datos que dan experiencia y, al subir de nivel, eliges una de tres
mejoras. A los 10 minutos llega el jefe final; derrotarlo es ganar.

**Lo que lo hace distinto es la resistencia adaptativa:** el malware se vuelve
resistente a la herramienta que más daño le hace, como el malware real con los
antivirus más usados. Para seguir haciéndole daño hay que cambiar de personaje,
porque cada uno lleva una herramienta distinta.

## 2. Cómo está organizado

### Las escenas

```
menu_principal.tscn          Menú: reglas, ranking, opciones y récord
juego.tscn                   La partida, que junta tres piezas:
├── Arena                    El suelo infinito
├── RaizJuego                Toda la jugabilidad
│   ├── Jugador              Movimiento, salud, armas y cambio de personaje
│   ├── Un gestor por tipo de enemigo (cinco)
│   ├── Pools de gemas, proyectiles, partículas y números de daño
│   ├── ResistenciaMalware   El elemento diferencial
│   ├── Jefe y tres élites   Ocultos hasta que el director los activa
│   ├── DirectorOleadas      Qué aparece, cuándo y dónde
│   └── SistemaNiveles       Experiencia, niveles y mejoras
└── Interfaz/HUD             HUD, mejoras, pausa, ficha del enemigo y final
```

Además hay seis **autoloads**, nodos que existen siempre aunque cambie la
escena: `Actualizador` (busca versiones nuevas), `BusEventos`, `GestorGuardado`
(récords, ranking y opciones), `GestorAudio`, `Transicion` (fundidos a negro) y
`EfectoCRT` (el filtro de monitor antiguo).

### Cómo se hablan las piezas

**Un bus de eventos.** `BusEventos` es un nodo que solo declara señales: la vida
del jugador ha cambiado, se ha subido de nivel, ha muerto un enemigo, ha
terminado la partida... La jugabilidad las emite y la interfaz, el audio y el
guardado las escuchan, sin conocerse entre ellos. Nació para que dos personas
pudieran trabajar sin tocar los ficheros del otro y lo mantuvimos porque hace el
código fácil de cambiar: el audio, por ejemplo, no lo llama nadie, escucha.

**Grupos en vez de rutas.** Cuando un nodo necesita a otro lo busca por su grupo
(`jugador`, `objetivos`, `elites`...) y no por su posición en el árbol. Así se
puede reorganizar una escena sin romper otra.

**Un mismo contrato para todo lo que recibe daño.** Los gestores de la horda,
los élites y el jefe están en el grupo `objetivos` y tienen los mismos métodos:
`danar_en_area`, `mas_cercano` y, para la ficha del enemigo, `ficha_en` y
`ficha`. Las armas recorren el grupo sin saber qué es cada uno.

### Los datos, fuera del código

Cada arma, mejora, tipo de enemigo, afijo de élite y personaje, y la
configuración de las oleadas, es un **recurso** (`.tres`) con su clase de datos.
Añadir un enemigo o una mejora es crear un fichero, y el equilibrio se cambia
sin abrir ninguna escena.

Una regla importante: **las mejoras nunca modifican el `.tres`**. Godot comparte
los recursos cargados y los guarda en memoria; si una mejora sumara un 12 % de
daño al recurso del arma, se quedaría para la siguiente partida. Por eso las
mejoras son multiplicadores en el nodo al que afectan.

## 3. Las piezas principales

**La horda: un enemigo no es un nodo.** Con un nodo por enemigo, cientos de
enemigos serían cientos de nodos procesándose y dibujándose por separado. Cada
tipo de enemigo es un gestor con listas de tamaño fijo (posiciones, vidas,
destellos...) y un solo `MultiMeshInstance2D` que los dibuja todos de una vez.
Cuando un enemigo muere, el último de la lista ocupa su hueco: los vivos siempre
están al principio y crear o destruir uno es mover un contador.

**La rejilla espacial.** Para que los enemigos no se amontonen, cada uno tendría
que compararse con todos los demás, y eso crece con el cuadrado. La rejilla
divide el mapa en celdas y solo se miran las cercanas: con 500 enemigos, el
cálculo bajó de 19 ms a 4 ms por fotograma (el límite a 60 FPS son 16,7 ms). Las
armas la usan también para encontrar a quién golpear.

**Sin animación, con shaders.** Un MultiMesh dibuja el mismo sprite para todos
los enemigos de un tipo, así que no pueden tener animación dibujada. La vida se
la da un shader: el destello blanco al recibir un golpe, un *glitch* que los
hace saltar como una imagen corrupta y el parpadeo rojo del troyano antes de
embestir. Cada enemigo le pasa al shader sus propios datos (`INSTANCE_CUSTOM`).

**El troyano embiste sin ser un nodo.** Persigue y, cerca del jugador, se para,
parpadea y embiste en línea recta, igual que el jefe. Pero el jefe guarda su
estado en variables y un troyano es solo una posición en una lista; su estado,
su cronómetro y su dirección van en tres listas más que se mueven con él. Ese
código está aparte (`embestida_horda.gd`) y solo lo usan los tipos que
embisten.

**Personajes y herramientas.** Hay dos tipos de arma: de área (el Firewall del
Espadachín golpea alrededor y el Escáner del Segador da un pulso amplio y
lento) y de proyectil (el Ping del Mago salta de un enemigo a otro). Solo
dispara la del personaje activo y se cambia con E (siguiente) o Q (anterior),
con 10 s de espera. Los tres hacen un daño por segundo parecido; los diferencia
dónde pegan. Cada uno tiene su vida (Espadachín 120, Segador 100, Mago 90): el
nodo `Salud` del jugador es siempre la del activo, y el equipo
(`cambio_personaje.gd`) guarda la de los demás, que se curan 1,5 por segundo
mientras esperan. Si cae el activo y quedan otros, el juego se pausa y se elige
quién sigue (`personaje_caido` y `personaje_elegido`), y entra con 2 s sin
recibir daño; la partida se pierde al caer los tres. Con C se ve la vida de
todos.

**Las ultis.** Cada personaje carga la suya matando mientras juega (180
enemigos; un élite cuenta por 10) y la lanza con R: el Mago, un rayo morado
hacia el enemigo más cercano; el Espadachín, un giro con seis hojas de luz; el
Segador, un rayo sobre su guadaña y diez mini rayos alrededor. Pegan con el
mismo `danar_en_area` que las armas, a todo el grupo `objetivos`, y escalan con
las mejoras de daño, pero no cuentan para la resistencia del malware: no son
una herramienta. El rayo es una fila de círculos seguidos, sin solaparse, para
que cada enemigo del camino reciba un golpe por pasada. Los efectos se dibujan
con `_draw` (líneas, polígonos y arcos), sin sprites.

**El menú de desarrollador (F1).** Para probar cualquier parte del juego sin
jugar hasta ella: saltar a un minuto, darse mejoras, subir de nivel, ser
invencible, llenar las ultis, sacar el jefe, un élite o los premios, revivir al
equipo, limpiar la horda y acelerar el juego. Está en todas las versiones; por
eso la partida en la que se abre no cuenta para los récords ni el ranking. Vive
en la escena de la partida, como el panel técnico (F3), y usa la jugabilidad
directamente.

**La resistencia adaptativa.** Cada arma avisa del daño que hace. Cada 20 s, el
malware mira cuál le ha hecho más y gana un 10 % de resistencia contra ella
(máximo 50 %); contra las demás pierde un 5 %. Se ve en los números de daño y en
el anillo del arma, que se vuelven rojos. El jugador tiene dos respuestas:
cambiar de personaje o elegir la mejora Actualizar firmas, que frena la
adaptación.

**Progresión.** Las gemas de experiencia se tiñen según lo que valen y caducan
a los 30 s. Cada nivel cuesta un 50 % más que el anterior. Al subir, el juego se
pausa y se ofrecen tres de las ocho mejoras; si se suben varios niveles de golpe
quedan en cola. Elegir tres veces una mejora concreta ofrece la **evolución** de
una herramienta, que es otro recurso de arma, así que el malware empieza sin
resistencia contra ella.

**El director de oleadas.** La dificultad sale de pocos números: el tiempo
entre apariciones baja de 0,5 s a 0,05 s en 10 minutos, cada tipo de enemigo
dice a partir de qué minuto sale y cada enemigo aparece con un 4 % más de vida
por cada nivel del jugador y, desde el minuto 3, con un 15 % más por cada
minuto de partida: el principio es suave y a mitad de partida cuesta más matar.
Un tipo puede limitar cuántos hay a la vez: sin ese límite, el ransomware se
acumulaba por cientos. Cada minuto llega un **élite**
con uno o dos afijos al azar (blindado, replicante, aura lenta, explosivo). Al
morir deja un corazón, que cura la mitad de la vida, y un cofre. El cofre va a
la misma cola que las subidas de nivel, que distingue "nivel" y "cofre" para
que cada uno salga con su panel, y abre una **ruleta** de 8 sectores con las
mejoras (y una evolución si hay alguna disponible). El premio se sortea antes de
girar; el disco frena con un `Tween` hasta -45·k grados más unas vueltas, que
deja el sector k bajo la flecha. A los 10 minutos deja de salir horda, la que
queda huye (se aleja del jugador y se desvanece en 1,2 s, sin dar experiencia)
y llega el **jefe**. Además de embestir, el jefe tiene un tercer estado: cada
15 s se para, late en morado mientras crece un anillo y saca un círculo de 12 a
24 enemigos, más cuanto menos vida le queda; los crean los gestores de la
horda, como hace el élite replicante.

**El mapa infinito.** El suelo es un rectángulo más grande que la pantalla que
se coloca bajo la cámara en cada fotograma, y su shader dibuja según la posición
en el mundo, no en el rectángulo: el dibujo se queda quieto y parece un suelo que
no se acaba. El suelo divide el mundo en casillas de 256 píxeles y cada una
elige uno de 12 dibujos de placa base que encajan entre sí. Dos texturas más
llevan datos en vez de dibujo, y con ellas el shader anima pulsos de luz por las
pistas, LEDs y ventiladores.

**Interfaz.** Un estilo común (`EstiloInterfaz`) para que todas las pantallas
se vean iguales. La **ficha del enemigo** pasa el click de la pantalla al mundo
y pregunta a todos los objetivos cuál está debajo; para seguir a un enemigo de
la horda, que cambia de posición en la lista cuando muere otro, cada uno lleva
un número único.

**Guardado y actualizaciones.** `GestorGuardado` guarda en un fichero de texto
de Godot (`ConfigFile`) los récords, el ranking de las 10 mejores partidas y
las opciones. Al arrancar y después cada 5 minutos, el `Actualizador` pregunta
a GitHub si hay una versión nueva; si la hay, sale un aviso en cualquier
pantalla, también en plena partida. El botón ACTUALIZAR descarga solo el
contenido del juego (1 MB en lugar de 110) y lo carga al arrancar, antes que
nada. Si una versión necesitara un ejecutable nuevo (por ejemplo, por un
autoload más), el mismo botón descarga el juego completo, pone el ejecutable
nuevo en lugar del viejo y reinicia (`instalador_juego.gd`). Ese código va con
el contenido y no en el `Actualizador`, porque el `Actualizador` ya está en
marcha antes de cargar ninguna actualización: así funciona también en
ejecutables antiguos.
Con el botón VERSIONES del menú, el mismo instalador pone cualquier release,
también una anterior, para jugar versiones viejas. Las teclas nuevas (Q, E y R)
están en `project.godot`, que no viaja con la actualización pequeña: si a un
ejecutable antiguo le faltan, `teclas_antiguas.gd` las añade al empezar la
partida.

**Audio.** Todos los sonidos los genera un script que suma ondas simples, como
los chips de sonido antiguos: 17 efectos y 3 músicas. `GestorAudio` escucha el
bus y decide qué suena.

## 4. Problemas y cómo los resolvimos

**Golpes que no hacían daño.** La rejilla se reconstruía antes de quitar a los
muertos; al quitar uno, el último cambiaba de posición en la lista y la rejilla
seguía apuntando a la antigua, así que ese enemigo no recibía daño durante un
fotograma. No daba ningún error. Lo encontramos con una prueba que, la primera
vez, tampoco lo detectaba porque miraba un fotograma tarde; aprendimos a
comprobar que una prueba falla cuando debe fallar.

**Un juego imposible, tres veces.** El simulador mostró que el bot moría antes
del minuto (se arregló con regeneración de vida), que con el mapa infinito no
encontraba al jefe y, en la última sesión, que con todos los cambios que
pedimos tras jugarlo no ganaba ninguna partida. Esa vez probamos nueve
variantes y la clave era la vida extra por nivel: con un 4 % en lugar de un 8 %
y algo más de daño, gana 6 de cada 10.

**Números que llegaban mal a los shaders.** En este proyecto, `0.05` escrito en
un shader llega como `0.5`. Lo comprobamos con un shader que pinta valores
conocidos; esos números se escriben como divisiones (`1.0 / 20.0`).

**La horda se veía más oscura de lo que era.** Al probar el parpadeo rojo del
troyano salía marrón. Dibujando el mismo sprite de tres formas y comparando
píxel a píxel vimos que nuestro shader aplicaba la textura dos veces. Después
de arreglarlo, la horda se ve con sus colores reales.

**Sin tarjeta gráfica en el instituto.** La máquina virtual dibujaba con el
procesador. Activamos la aceleración 3D, elegimos el renderizador
Compatibility, que funciona casi en cualquier ordenador, y medimos el
rendimiento en un PC con una tarjeta de verdad.

## 5. Pruebas y rendimiento

- **Ejecución sin ventana** tras cada cambio, para ver errores de código y de
  ejecución.
- **Scripts de prueba** que provocan una situación y comprueban el resultado:
  la embestida del troyano fotograma a fotograma, las mejoras eligiéndolas de
  verdad, el ranking con una copia del fichero de guardado, clicks de ratón
  simulados para la ficha del enemigo...
- **Capturas con ventana** para todo lo visual, como las de la
  [historia](historia_del_proyecto.md).
- **Simulador de partidas** (`simular_partidas.gd`): un bot juega partidas
  enteras con la misma "suerte" cada vez, así que un cambio de equilibrio se
  compara antes y después. El objetivo actual es que gane 2-3 de cada 5; hoy
  gana 6 de 10.
- **Medida de rendimiento** (`medir_rendimiento.gd`) en una RTX 5070:

| Enemigos | FPS | Tiempo de física por fotograma |
|---|---|---|
| 300 | 1549 | 2,0 ms |
| 600 | 1301 | 4,5 ms |
| 1200 | 733 | 9,3 ms |

El objetivo de la propuesta era 300 enemigos a 60 FPS. El coste crece casi en
línea recta con el número de enemigos gracias a la rejilla.

## 6. Herramientas, assets e inteligencia artificial

- **Godot 4.7.2**, **Git y GitHub**, y una **GitHub Action** que exporta y
  publica cada versión al subir una etiqueta.
- **Gráficos hechos con IA** a partir de nuestras ideas (Claude, y Gemini para
  la idea de los personajes); ocho iconos los dibuja un script. El
  detalle está en [créditos](creditos.md).
- **Audio** generado por un script. No hay ningún asset de terceros.
- **Claude** (Anthropic) escribió la mayor parte del código a partir de lo que
  le pedíamos y con nuestras normas (castellano, scripts cortos, comentarios
  del porqué, la versión más fácil de explicar). Las ideas, las decisiones y
  las pruebas de juego son nuestras. Está contado en la
  [historia](historia_del_proyecto.md#cómo-hemos-usado-la-inteligencia-artificial).

## 7. Qué mejoraríamos con más tiempo

- Pixel art propio para los personajes y el jefe.
- Un jefe intermedio y más variedad de élites.
- Que la resistencia del malware se vea directamente en el HUD.
- Controles configurables y un ranking compartido en línea.
