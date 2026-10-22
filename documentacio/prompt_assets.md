# Prompt para pedir assets nuevos a Claude (chat)

Lo preparó Claude Code el 20/10/2026 (sesión 16) a petición de Adam. Se pega
tal cual en un chat nuevo de Claude (claude.ai). Va por lotes: cada lote llega
en su zip, y se integra en el juego con Claude Code como el del jefe final
(`jefe_final.zip`): primero el plan, después el código.

No incluye los assets de las evoluciones visibles en los personajes: esos los
está haciendo Adam por su cuenta.

---

```text
Hola. Necesito pixel art para mi videojuego, Sector Cero. Lo hacemos dos
alumnos para una asignatura y lo defendemos ante un tribunal. Ya me hiciste en
otro chat el suelo, la horda animada, las ultis, la explosión del rootkit y el
jefe final NÚCLEO CERO: sigue el mismo estilo y el mismo método.

EL JUEGO
Survivors-like 2D con vista cenital, dentro de un ordenador infectado. Eres un
antivirus: te mueves y tu herramienta ataca sola a oleadas de malware. Tres
personajes que se cambian en plena partida: el Mago (Ping, proyectiles que
rebotan), el Espadachín (Firewall, golpe en área alrededor, roba vida) y el
Segador (Escáner, un pulso en área grande cada 2,5 s). A los 10 minutos llega
un jefe (un mago oscuro con corona, capa y bastón, hoja de 8 direcciones); al
matarlo, la placa base queda destrozada (fase 2) y a los 15 minutos llega
NÚCLEO CERO, de tres formas.

ESTILO
- Pixel art de neón sobre fondo oscuro, con contorno oscuro de 1 px, sombreado
  y algo de brillo. Sin antialiasing: el juego lo dibuja con filtro nearest.
- Colores del juego: fondo #08101A, neón #00D9F2, texto #D9E6F2, verde
  victoria #4DFF99, rojo derrota #FF4D66. Mago #BF73FF, Espadachín #66FF80,
  Segador #FF5959, jefe #BF4DFF. Dorado para el rootkit y NÚCLEO CERO.
- Pantalla de 1280x720. Tamaños de referencia: la horda mide de 20 a 44 px,
  los personajes son fotogramas de 64x72 (hojas de 6x8, 8 direcciones), el
  jefe 128x144 (12x8), el élite rootkit 48x48, NÚCLEO CERO 192x192, los
  iconos de las mejoras 16x16.

CÓMO TRABAJAR
- Dibújalo con scripts de Python (numpy y Pillow), píxel a píxel, como antes.
- PNG con fondo transparente. Las animaciones en tiras horizontales de
  fotogramas del mismo tamaño. Dime de cada una: tamaño del fotograma,
  número de fotogramas, segundos por fotograma, dónde va el centro y si va
  por encima o por debajo del jugador.
- Lo que se tiñe en el juego (por ejemplo, según el personaje), en grises.
- Antes de cada lote, dime en dos líneas qué vas a dibujar y espera mi sí.

CADA LOTE, EN UN ZIP
- Los PNG en la misma ruta que tendrán en el proyecto (projecte/medios/
  sprites/<carpeta>/...).
- Vistas previas: una hoja PNG con todo el lote ampliado x2 y, para lo
  animado, un GIF.
- LEEME.txt: qué es cada fichero y cómo se usa.
- PROMPT_CLAUDE_CODE.md: el encargo para integrarlo, que yo pego en Claude
  Code. Que le pida un plan corto antes de programar y que espere mi sí, que
  siga el CLAUDE.md del repositorio, que valide en headless y con capturas, y
  que apunte en creditos.md que lo hiciste tú, con IA.
- herramienta/: los scripts de Python (no se suben al repositorio).

LOS LOTES, POR ORDEN
1. JEFE DEL MINUTO 10, ATAQUES NUEVOS (projecte/medios/sprites/jefe/)
   - Pisotón con jaula: se para, golpea el suelo y crea un círculo de unos 180
     px de radio del que no se puede salir durante unos segundos. Hace falta
     el aviso (el anillo que se cierra, 6 fotogramas), la barrera de la jaula
     en bucle (4 fotogramas, que se vea que es un muro de datos) y cómo se
     rompe al acabar (5 fotogramas). 384x384.
   - Ráfaga de datos: el proyectil que dispara en círculo (16x16, 4
     fotogramas, se puede girar hacia donde va).
   - Rabia (por debajo del 25 % de vida): un aura detrás del jefe (192x192, 4
     fotogramas en bucle).
   - Onda del pisotón al golpear el suelo (384x384, 6 fotogramas).
2. ANCLAS DEL ESCUDO DE NÚCLEO CERO, UNA POR HERRAMIENTA
   (projecte/medios/sprites/jefe_final/). Ahora el ancla es un candado rojo
   de 48x56 con 5 fotogramas (0-3 brillando, 4 rota) y una cadena de 16x10
   (2 fotogramas). Cada ancla solo se rompe con la herramienta de un
   personaje: haz tres versiones, con su color y su emblema (cristal morado
   del Mago, espada verde del Espadachín, guadaña roja del Segador), con la
   misma distribución de fotogramas, y la cadena de cada color.
3. EFECTOS DE LAS HERRAMIENTAS (projecte/medios/sprites/herramientas/).
   Ahora el alcance de las armas de área es un círculo dibujado por código.
   - Firewall (Espadachín): el golpe en área de 110 px de radio (125 con la
     evolución), 6 fotogramas, 256x256, verde.
   - Escáner (Segador): el pulso de 150 px de radio, un barrido de radar, 8
     fotogramas, 320x320, rojo.
   - Ping (Mago): el destello al impactar o rebotar, 24x24, 4 fotogramas.
   - Robo de vida del Espadachín: la chispa verde que va del enemigo al
     personaje (8x8, 4 fotogramas).
4. RESPUESTA EN LA PARTIDA (projecte/medios/sprites/efectos/)
   - Subir de nivel: anillo o columna de luz alrededor del personaje, 128x128,
     8 fotogramas.
   - Cambio de personaje: entrada con glitch, 96x96, 6 fotogramas, en grises.
   - Curarse (el corazón de los élites): destello verde, 96x96, 6 fotogramas.
   - Muerte de la horda: desintegración en píxeles, 48x48, 6 fotogramas, en
     grises.
5. ÉLITES (projecte/recursos/enemigos/sprites/)
   - Animación del rootkit en reposo: tira de 4 fotogramas de 48x48 cuyo
     fotograma 0 sea el rootkit.png de ahora.
   - Un efecto encima del élite por cada afijo: Blindado (placas de
     armadura), Replicante (copias fantasma) y Aura lenta (anillo helado de
     unos 140 px de radio). El Explosivo ya lo tiene. 4 fotogramas cada uno.
6. INTERFAZ Y LANZADOR (projecte/medios/interfaz/)
   - Logo "SECTOR CERO" en pixel art, con algo de glitch, 512x128.
   - Retratos de los tres personajes, 64x64, para el panel del equipo.
   - Los 11 iconos de las mejoras rehechos a 16x16 con el mismo estilo (ahora
     8 son muy simples, dibujados por código): Daño, Cadencia, Alcance,
     Velocidad, Vida, Actualizar firmas, Cambio en caliente, Caché ampliada y
     las tres herramientas (Ping, Firewall, Escáner). Y 4 iconos de 16x16
     para los afijos de los élites.
   - Arte para la cabecera del lanzador: 960x260, con los tres personajes y
     NÚCLEO CERO al fondo.

Empieza por el lote 1. Antes, dime en dos líneas qué vas a dibujar.
```

## Lote 7: ataques de los personajes (22/10/2026, sesión 18)

Los lotes 1 a 6 ya están hechos e integrados (sesiones 17 y 18). Este lote es
para los cambios en los personajes que pidió Adam (`requisitos_y_estado.md`,
punto 15). Se pega en el mismo chat de los lotes anteriores; si es uno nuevo,
antes se pega el prompt de arriba entero, quitando su último párrafo.

```text
Lote 7: animaciones de ataque de los tres personajes y el golpe nuevo del
Espadachín (projecte/medios/sprites/personajes/). Mismo estilo y método que
los lotes anteriores.

Los personajes tienen ahora solo la animación de andar: hojas de 6x8
fotogramas de 64x72, una fila por dirección y en el mismo orden de
direcciones que su hoja de andar (escenas/jugabilidad/jugador/
antivirus_8_direcciones.png es el Mago, ciberespadachin_8_direcciones.png el
Espadachín y segador_ciber_8_direcciones.png el Segador). Te paso las tres
hojas.

1. SEGADOR: levanta la guadaña y la baja cuando dispara el Escáner (un pulso
   en área cada 2,5 s), para que se vea que ataca. Hoja de 4 fotogramas x 8
   direcciones, 64x72, de unos 0,06 s cada uno. Mismo personaje y paleta
   que su hoja de andar.
2. MAGO: la animación de lanzar las bolas del Ping (adelanta el bastón y
   brilla el cristal morado). Hoja de 4 fotogramas x 8 direcciones, 64x72,
   unos 0,05 s cada uno.
3. ESPADACHÍN: ahora ataca en un cono de 90 grados hacia donde se mueve, no
   en un círculo, y hace más daño cuanto más pegado está el enemigo.
   - Su animación de tajo: 4 fotogramas x 8 direcciones, 64x72, unos 0,05 s
     cada uno.
   - El tajo del Firewall: un cono de 90 grados y 110 px de alcance, que se
     vea más intenso cerca del personaje que en el filo. 6 fotogramas,
     dibujado apuntando a la derecha (el juego lo gira), con el vértice en el
     centro del personaje. Verde #66FF80.
   - El tajo del Firewall perimetral (la evolución): el mismo cono con 150
     px de alcance y el mismo brillo en todo el cono (con la evolución el
     daño ya no depende de la distancia).
   - El marcador del alcance (hoy es un anillo, firewall_anillo.png): el
     contorno del cono, suave, para cada uno de los dos alcances.

Las tres animaciones de ataque se pondrán encima de la de andar un momento
al disparar: que el fotograma 0 sea igual que la postura de andar, para que
no salte. Mira cómo encajan con las evoluciones visibles en los personajes
(las armas evolucionadas ya se ven en el personaje).

Antes de dibujar, dime en dos líneas qué vas a hacer.
```

### O todo desde Claude Code en la nube (decisión de Adam, 22/10)

Claude Code en la nube puede dibujar el lote 7 él mismo, con el mismo método
(Python, numpy y Pillow), meterlo en el juego y probarlo, sin pasar por el
chat ni por un zip. Hay dos condiciones:
- Adam ve los dibujos antes de que entren en el juego: una vista previa en
  `documentacio/capturas/lote7/`.
- Los scripts de Python que dibujan no se suben al repositorio.

El prompt para empezar está en `requisitos_y_estado.md`, punto 15.
