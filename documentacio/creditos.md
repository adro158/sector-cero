# Créditos y procedencia de los assets — Sector Cero

El enunciado pide indicar la procedencia de los assets externos y respetar sus
licencias. Este fichero recoge **todo** lo que usa el juego, sea propio o no.

## Resumen

| Asset | Procedencia | Licencia |
|---|---|---|
| Código (GDScript) | Propio (Adam y Alan), escrito con ayuda de Claude | Del proyecto |
| Shaders (suelo, horda, CRT) | Propios, escritos con ayuda de Claude | Del proyecto |
| Sprites de la horda (5 tipos) y del élite | Hechos con IA (Claude) | Ver más abajo |
| Texturas del suelo de placa base | Hechas con IA (Claude) | Ver más abajo |
| Iconos de las mejoras (los 11) | Hechos con IA (Claude) | Ver más abajo |
| Sprites del fragmento de datos y del proyectil del Ping | Hechos con IA (Claude) | Ver más abajo |
| Corazón, cofre y ruleta del premio de los élites | Hechos con IA (Claude) | Ver más abajo |
| Sprites de las ultis (rayo, torbellino y tormenta) | Hechos con IA (Claude) | Ver más abajo |
| Tiras de animación de la horda (5 tipos) | Hechas con IA (Claude) | Ver más abajo |
| Explosión del rootkit (aviso, anillo, explosión y quemadura) | Hechos con IA (Claude) | Ver más abajo |
| Suelo dañado de la fase 2 | Hecho con IA (Claude) | Ver más abajo |
| Jefe final NÚCLEO CERO (formas, transformación, muerte, ataques, escudo, hielo y barra de vida) | Hechos con IA (Claude) | Ver más abajo |
| Ataques nuevos del jefe del minuto 10 (pisotón, jaula, ráfaga y rabia) | Hechos con IA (Claude) | Ver más abajo |
| Aparición, furia, muerte y barra de vida de Kernel Panic, el jefe del minuto 10 | Hechos con IA (Claude, con un script de Python) | Ver más abajo |
| Anclas y cadenas del escudo de NÚCLEO CERO, una por personaje | Hechas con IA (Claude) | Ver más abajo |
| Ataques de los tres personajes (normal y evolucionado) y tajo en cono del Firewall | Hechos con IA (Claude, con un script de Python) | Ver más abajo |
| Efectos de las herramientas (golpes, pulsos, anillos de alcance, impacto del Ping y chispa del robo de vida) | Hechos con IA (Claude) | Ver más abajo |
| Efectos de subir de nivel, cambio de personaje, curarse y muerte de la horda | Hechos con IA (Claude) | Ver más abajo |
| Rootkit animado y efectos de los afijos de los élites | Hechos con IA (Claude) | Ver más abajo |
| Logo, retratos de los personajes, iconos de los afijos y cabecera del lanzador | Hechos con IA (Claude) | Ver más abajo |
| Hojas de atacar corriendo de los tres personajes y ataque del Mago con el bastón | Hechas con IA (Claude, con un script de Python) | Ver más abajo |
| Efectos de la partida (caída, derrota, golpe, escudo, evolución, partícula, muerte del élite, mecha, invocación, barras de vida, mira del Mago, Ping y fragmentos animados) | Hechos con IA (Claude, con un script de Python) | Ver más abajo |
| Icono del juego (`.exe`, ventana y web) | Hecho con IA (Claude) | Ver más abajo |
| Sprites del jugador (3 personajes, también con el arma evolucionada) y del jefe | Hechos con IA (Gemini para la idea, Claude para las hojas de sprites) a partir de un ejemplo del profesor | Ver más abajo |
| Música y efectos de sonido | Propios, sintetizados por código | Del proyecto |
| Tipografía | Fuente monoespaciada del sistema (Consolas, Cascadia Mono, DejaVu Sans Mono o Liberation Mono) | No se distribuye con el juego |
| Motor | Godot Engine 4.7.2 | MIT |

## Detalle

### Código

Todo el código de `projecte/` es propio. Se ha escrito con la ayuda de Claude
(Anthropic) como asistente de programación. El uso de la IA está detallado en
la documentación técnica y, sesión a sesión, en la bitácora.

### Gráficos generados por código

Hasta el 21/10/2026, `projecte/herramientas/generar_sprites.gd` dibujaba píxel
a píxel, con formas simples y un contorno de neón, los iconos de las cinco
primeras mejoras y de las tres herramientas; hasta el 02/10/2026, también los
sprites de la horda y del élite. Todos se sustituyeron por los redibujados con
IA (siguiente apartado) y el script se quitó para que no los machaque. Sigue
en el historial de Git.

El glitch de la horda, el parpadeo del troyano y el filtro CRT no son imágenes:
son shaders (`medios/shaders/`). El suelo combina un shader
(`escenas/arena/suelo.gdshader`) con las texturas del apartado siguiente.

### Sprites, iconos y suelo hechos con Claude

Adam encargó a **Claude** (Anthropic), en una conversación aparte, el arte
nuevo de la sesión del 02/10/2026. Claude lo dibujó con scripts de Python
(píxel a píxel, con NumPy y Pillow) y Adam lo integró en el proyecto. Los
scripts no forman parte del repositorio.

- **Enemigos redibujados** (`recursos/enemigos/sprites/`): bit corrupto,
  paquete perdido, proceso colgado y el élite Rootkit, con el mismo nombre,
  tamaño y color principal que los antiguos, pero con sombreado, contorno y
  más expresión.
- **Enemigos nuevos**: el ransomware (candado rojo con cadenas, 44x44) y el
  troyano (caballo de ajedrez verde con trampilla, 32x32).
- **Iconos de tres mejoras** (`recursos/mejoras/iconos/`): Actualizar firmas
  (escudo con check), Cambio en caliente (flechas) y Caché ampliada (imán).
  El 21/10/2026 se rehicieron los once con el mismo estilo (lote 6).
- **Suelo de placa base** (`medios/texturas/`): `suelo_placa.png`, un atlas de
  12 baldosas de 256x256 que encajan sin costuras (pistas, vías, chips, CPU,
  GPU, memorias, ranuras, disipadores y ventiladores);
  `suelo_placa_mascara.png`, que marca por dónde corren los pulsos de datos, y
  `suelo_placa_efectos.png`, que marca los LEDs, las aspas de los ventiladores
  y el brillo de los chips. Con ellas vinieron el shader del suelo y el script
  de la arena que lo anima.
- **Experiencia y Ping** (`medios/sprites/`, el mismo día y de la misma
  forma): `fragmento_datos.png` (12x12), un cristal de datos en grises que el
  juego tiñe según lo que vale, y `proyectil_ping.png` (24x12), un rayo de
  energía con estela que el juego gira hacia donde va. El 06/10/2026 se
  sustituyó por la misma forma en morado, el color del Mago. El 24/10/2026
  los dos se quitaron: son el primer fotograma de sus tiras animadas del
  lote 8.
- **Premio de los élites** (`medios/sprites/`, 06/10/2026, de la misma forma):
  `corazon.png` (20x20), `cofre.png` (4 fotogramas de 32x32, de cerrado a
  abierto), `ruleta_rueda.png` (96x96, el disco de 8 sectores) y
  `ruleta_marco_a.png` y `ruleta_marco_b.png` (112x112, el marco con las
  bombillas encendidas de dos formas para que parpadeen).
- **Ultis** (`medios/sprites/ultis/`, 13/10/2026, de la misma forma): el
  rayo de datos del Mago (`ulti_rayo_origen`, `_tramo` y `_punta`), el
  torbellino del Espadachín (`ulti_torbellino`, 6 fotogramas que giran 10
  grados cada uno) y la tormenta del Segador (`ulti_tormenta_rayo`,
  `_impacto`, `_mini` y `_chispa`). Con ellos vino el código de dibujo
  (`escenas/jugabilidad/jugador/dibujo_ultis.gd`) con el que se grabaron los
  GIF de muestra.
- **Horda animada** (`recursos/enemigos/sprites/*_anim.png`, 14/10/2026, de
  la misma forma): una tira de 4 fotogramas por tipo, del mismo tamaño que su
  sprite, cuyo primer fotograma es el sprite de siempre. El bit corrupto
  estira los pinchos y muerde, el paquete perdido bate las alas, el proceso
  colgado gira los ojos de "cargando", el troyano trota y el ransomware da
  tirones al arco y mueve las cadenas.
- **Explosión del rootkit** (`medios/sprites/explosion/`, 15/10/2026, de la
  misma forma): `rootkit_sobrecarga.png` (6 fotogramas de 64x64: el rootkit
  agrietándose y al rojo), `rootkit_zona.png` (4 fotogramas de 304x304: el
  anillo de peligro que gira), `rootkit_explosion.png` (12 fotogramas de
  288x288: destello, bola de fuego, onda, trozos, brasas y humo) y
  `rootkit_quemadura.png` (128x128: la marca que queda en el suelo). Con ellos
  vino el código de referencia del aviso y de `explosiones_elite.gd`.
- **Suelo dañado de la fase 2** (`medios/texturas/suelo_danado*.png` y
  `escenas/arena/suelo_danado.tres`, 16/10/2026, de la misma forma): las
  mismas 12 baldosas del suelo de placa base, destrozadas (placa quemada,
  grietas al rojo, pistas cortadas, chips reventados, condensadores
  hinchados, cráteres con brasas y chispazos), con su máscara de pulsos y su
  textura de efectos. Con ellas vino el cambio del shader del suelo
  (chispazos, humo y velocidad del brillo).
- **Jefe final NÚCLEO CERO** (`medios/sprites/jefe_final/`, 16/10/2026, de la
  misma forma): las tres formas (rootkit gigante, núcleo armado y amalgama,
  6 fotogramas de 192x192 cada una), la transformación y la muerte, los
  avisos de sus ataques (línea, zona y diana), el portal, el escudo de
  candado con su rotura, las anclas y la cadena, el cristal y la zona de
  hielo, y el marco y el relleno de su barra de vida. Con ellos vino una demo
  de cómo se dibuja cada sprite, que sirvió de referencia.
- **Ataques nuevos del jefe del minuto 10** (`medios/sprites/jefe/`,
  21/10/2026, de la misma forma; lote 1 de los assets nuevos): el aviso del
  pisotón (un anillo rojo que se cierra), la onda del golpe, la jaula de datos
  y su rotura (tiras de 384x384), el aura de llamas de la rabia (192x192) y
  el proyectil de la ráfaga (16x16). Con ellos vino una demo de cómo se
  dibuja cada uno, que sirvió de referencia.
- **Kernel Panic, el jefe del minuto 10** (`medios/sprites/jefe/`,
  22/10/2026): la columna de datos en la que aparece (10 fotogramas de
  288x528), la onda roja con rayos de la furia (8 de 320x320) y su muerte
  (12 de 320x320, se agrieta, un destello y una explosión morada). Los dibujó
  Claude con un script de Python (Pillow), píxel a píxel y con los colores
  del jefe. El marco y el relleno de su barra de vida son los de NÚCLEO CERO
  recoloreados en morado, con su nombre escrito encima con la misma letra.
- **Ataques de los personajes** (lote 7, 22/10/2026): las hojas de ataque
  de los tres personajes, normal y con el arma evolucionada
  (`escenas/jugabilidad/jugador/*_ataque.png`, 4 x 8 fotogramas de 64x72), y
  el tajo en cono del Firewall y del Firewall perimetral con sus contornos
  (`medios/sprites/herramientas/firewall_*tajo.png` y `*_cono.png`). Los
  dibujó Claude con un script de Python (numpy y Pillow) a partir de las
  hojas de andar: el arma se separa del cuerpo (comparando la hoja normal
  con la evolucionada, que tienen el mismo cuerpo), se mueve píxel a píxel y
  se le añaden los brillos y la estela. Los personajes siguen siendo los de
  sus hojas originales.
- **Anclas del escudo por personaje** (`medios/sprites/jefe_final/`,
  21/10/2026, de la misma forma; lote 2): las mismas anclas y cadenas del
  escudo de NÚCLEO CERO, una por personaje, con su color y su emblema en el
  candado (un cristal el Mago, una espada el Espadachín y una guadaña el
  Segador). Con ellas vino el cambio del dibujo, que sirvió de referencia.
- **Efectos de las herramientas** (`medios/sprites/herramientas/`,
  21/10/2026, de la misma forma; lote 3): el golpe del Firewall y del
  Firewall perimetral (rejilla de hexágonos y llamas), el pulso de radar del
  Escáner y del Análisis heurístico, el anillo de alcance de cada uno en
  grises, el destello del impacto del Ping y la chispa del robo de vida. Con
  ellos vino el cambio probado del dibujo, que sirvió de referencia. El golpe
  y el anillo del Firewall y del Firewall perimetral se quitaron el 22/10:
  desde el cono, los sustituyen el tajo y el contorno del lote 7.
- **Respuesta de la partida** (`medios/sprites/efectos/`, 21/10/2026, de la
  misma forma; lote 4): la columna de luz de subir de nivel, el rayo con
  glitch del cambio de personaje y la muerte de la horda (los dos en grises,
  para teñirlos en el juego) y el brillo verde de curarse. Con ellos vino un
  nodo de prueba que sirvió de referencia.
- **Élites** (`recursos/enemigos/sprites/`, 21/10/2026, de la misma forma;
  lote 5): el rootkit en reposo (`rootkit_anim.png`, cuyo primer fotograma es
  `rootkit.png`) y, en grises para teñirlos, las placas del Blindado, las
  copias fantasma del Replicante y el anillo helado del Aura lenta. Con ellos
  vino el cambio probado del élite, que sirvió de referencia.
- **Interfaz y lanzador** (21/10/2026, de la misma forma; lote 6): el logo
  de SECTOR CERO con la O tachada como el icono, y su tira de glitch
  (`medios/interfaz/`); los retratos de los tres personajes, su busto a x2
  con un marco de su color (`medios/interfaz/`); los once iconos de mejora
  rehechos con el mismo estilo (`recursos/mejoras/iconos/`); un icono por
  afijo de los élites (`recursos/enemigos/afijos/iconos/`), y la cabecera del
  lanzador (`lanzador/cabecera.png`): la placa base, NÚCLEO CERO al fondo,
  los tres personajes y el logo. Con ellos vino el cambio probado, que sirvió
  de referencia.
- **Efectos de la partida** (`medios/sprites/efectos/` y
  `medios/sprites/herramientas/`, 24/10/2026, de la misma forma; lote 8): lo
  que aún se dibujaba con código o no tenía efecto. Del personaje, la caída
  (la silueta común de los tres se rompe en franjas de glitch y se deshace en
  píxeles), la derrota (igual, más lenta, y se apaga como una tele vieja), el
  golpe, el escudo de hexágonos y la evolución de la herramienta, todos en
  grises para teñirlos con su color. Además, la chispa de las partículas, la
  muerte del élite (el rootkit partiéndose en trozos), la mecha del
  Explosivo, el círculo de runas de la invocación de Kernel Panic, el marco y
  los rellenos de las barras de vida, el rayo de la ulti lista, los
  fragmentos de datos animados y su destello al recogerlos, la mira del rayo
  del Mago (el tramo con flechas, la diana y el ratón del click) y el Ping
  animado y el de inundación. Los dibujó Claude con un script de Python
  (numpy y Pillow). Con ellos vino el cambio probado de las barras, las
  partículas y la mecha, que sirvió de referencia.
- **Atacar corriendo** (`escenas/jugabilidad/jugador/*_correr_ataque.png`,
  27/10/2026, de la misma forma; lote 11): una hoja por personaje y versión
  (normal y con el arma evolucionada), 6x8 fotogramas de 64x72, en la que
  cada columna es el mismo paso de su hoja de andar, píxel a píxel, con los
  brazos y el arma del golpe. Y el ataque quieto del Mago rehecho: adelanta
  el bastón, el cristal se carga, suelta la bola morada y vuelve. Los dibujó
  Claude con un script de Python (numpy, scipy y Pillow), a partir de los
  mismos scripts con los que se hicieron las hojas de andar. Con ellos vino
  el cambio probado del controlador, que sirvió de referencia.
- **Icono del juego** (`medios/icono/`, 16/10/2026, de la misma forma): el
  encapuchado de los personajes, con los ojos brillando, delante de un cero
  tachado (Ø) de neón; por la túnica le bajan tres circuitos con los colores
  de los tres personajes. `icono.png` (256x256) es el de la ventana en Linux y
  el de la web; `icono.ico` lleva 16, 32, 48, 64, 128 y 256 píxeles, con los
  cuatro pequeños dibujados a mano para que se lean en la barra de tareas, y
  es el del `.exe` y la ventana en Windows.

### Sprites de los personajes y del jefe

Las hojas de animación de los tres personajes jugables (espadachín, mago y
segador) y la del jefe final (`escenas/jugabilidad/jugador/*.png` y
`escenas/jugabilidad/enemigos/jefe_8_direcciones.png`) se hicieron así:

1. **Punto de partida:** unos sprites de nigromantes que el profesor compartió
   en clase como ejemplo, creados con Claude.
2. **Idea:** Adam generó con **Gemini** una ilustración de algo parecido, pero
   con la temática del juego.
3. **Hojas de sprites:** **Claude** (Anthropic) creó a partir de ahí las cuatro
   hojas de ocho direcciones: los tres personajes y el jefe.
4. **Ajuste:** se adaptaron a la paleta del ordenador con scripts propios de
   Godot (quitar el fondo y recolorear; bitácora, sesión 4).
5. **Armas evolucionadas** (22/10/2026): Claude hizo, con los mismos scripts,
   una copia de cada hoja de personaje con el cuerpo idéntico y el arma de su
   evolución (`*_8_direcciones_evolucion.png`): la guadaña del Análisis
   heurístico, el bastón del Ping de inundación y la espada del Firewall
   perimetral.

Se consideran provisionales: si hubiera tiempo, se sustituirían por pixel art
propio.

### Audio sintetizado

`projecte/herramientas/generar_audio.gd` genera todos los sonidos sumando ondas
simples (cuadrada, triángulo, sierra, seno y ruido), como los chips de sonido
de las consolas antiguas: 17 efectos y 3 músicas en bucle (menú, partida y
jefe). Las melodías y progresiones de acordes son propias. Los ficheros
resultantes están en `projecte/medios/audio/`.

### Tipografía

No se incluye ningún fichero de fuente. El juego pide al sistema una fuente
monoespaciada por orden de preferencia: Consolas (Windows), Cascadia Mono,
DejaVu Sans Mono o Liberation Mono (Linux). Si no encuentra ninguna, usa la
monoespaciada por defecto del sistema.

### Motor

[Godot Engine](https://godotengine.org) 4.7.2, con licencia MIT. El ejecutable
exportado incluye el motor.

### Recursos de terceros

El juego no usa ningún asset descargado de terceros: ni sprites, ni sonidos, ni
plugins, ni librerías. El único material ajeno es el ejemplo de sprites del
profesor, que sirvió de referencia y no está incluido en el juego. Lo hecho con
IA está señalado en los apartados anteriores.
