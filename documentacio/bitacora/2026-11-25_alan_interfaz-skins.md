# 25/11/2026 — Alan — La interfaz de skins: apertura de paquetes y pase en pista

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración:** 2 h (las dijo Alan al cerrar). **Horas acumuladas:** 14 h:
las 12 de `2026-11-23_alan_bits.md` más estas 2.

## Qué se ha hecho

**Primero, el cierre que quedó a medias el 24/11.** Está en la bitácora de
los bits:
- se trajo `main` a las seis ramas de la cartera;
- se subieron con sus PR, del #40 al #45, encadenados;
- se avisó a Adam en el #40. La comprobación del #40 está en verde.

**Después, el lote de la interfaz de skins.** Alan pidió el 23/11 que abrir
un paquete tuviera animación y que el pase se viera mejor. Claude, en el
chat, hizo el lote `lote_interfaz_skins.zip` (35 PNG en
`medios/sprites/cartera/`) con el prompt que se le dio. El 24/11 se dejó
preparado, y hoy Alan dijo «Ahora haz lo del lote de skins». Va en la rama
`alan/interfaz-skins`, encima de `alan/bits`. Los ficheros son todos de
Alan:

- **`piezas_cartera.gd`:** funciones estáticas para usar el lote:
  - recortar un fotograma de una hoja;
  - dibujar a x2 sin suavizar;
  - el marco de carta (9-slice) teñido por categoría;
  - las chapitas, los iconos de premio y de pestaña, y el fondo;
  - `Animada`, un `TextureRect` que pasa los fotogramas de una hoja en
    bucle o una vez.

  Los colores de categoría pasan aquí desde el armario.
- **`apertura_paquete.gd`:** la animación al pulsar ABRIR, con los tiempos
  del `LEEME` del lote:
  1. la carga, con las grietas del color de la categoría desde el fotograma
     5 y un temblor de 1-3 px;
  2. el estallido, con una sacudida de 4 px;
  3. los rayos teñidos;
  4. la carta;
  5. las chispas (3 en una C, 5 en una B y 8 en una A).

  Una C dura unos 2 s y una A unos 2,6 s. Un clic, Enter o Esc saltan al
  final, y en el final cierran.
- **`carta_revelada.gd`:** la carta. El marco de su categoría con el
  retrato se descifra de arriba abajo en 4 pasos, con una línea de datos
  cian en el borde. Lleva el personaje en su placa y la chapita NUEVA o
  REPETIDA. Debajo, el nombre se descifra letra a letra entre caracteres al
  azar, con «categoría X · ¡NUEVA!» o los bits devueltos.
- **`pista_pase.gd`:** el pase como pista horizontal, con:
  - las casillas en tres estados (bloqueada, siguiente y conseguida), con
    el icono del premio o el retrato de la skin;
  - las especiales de S y S+, y la del 30;
  - el conector 9-slice a x2;
  - el candado y el check.

  Se mueve con la rueda y con las flechas de los lados, y se centra en el
  siguiente nivel.
- **`pestana_pase.gd`:** la cabecera con «TEMPORADA 1», la barra
  (`TextureProgressBar` 9-slice a x2) y la pista. Si se ha subido de nivel
  desde la última vez, sale el destello en la casilla nueva.
- **`pestana_tienda.gd`**, como en el montaje del lote:
  - a la izquierda, el paquete latiendo, las chapitas con su %, ABRIR y si
    hay gratis;
  - a la derecha, las cartas del personaje elegido, con el marco y la
    chapita de su categoría.
- **El resto de pestañas:**
  - el armario lleva el marco de carta, las chapitas y el candado grande en
    las que no se tienen;
  - la ventana, el fondo de circuito y los iconos de las pestañas;
  - las misiones, el icono de diaria o semanal y el sello de «hecha»;
  - los logros, la medalla.
- **`cartera.gd` y `pase_batalla.gd`:** `ver_pase(nivel)` y `visto` en el
  estado del pase. Se guarda el último nivel enseñado, para que el destello
  salga una vez aunque se suba jugando. Al cambiar de temporada vuelve a 0.

## Decisiones técnicas y por qué

- **Las piezas, en `piezas_cartera.gd` y no en `EstiloInterfaz`,** que es de
  Adam. Así no se toca nada suyo.
- **La apertura, en su `CanvasLayer` (capa 100).** Con `top_level` salía
  detrás de la ventana. La capa la pone por encima de todo y por debajo del
  CRT (110).
- **Lo que va a x2 con 9-slice** (el conector y la barra) se escala dentro
  de un `Control` normal. Los contenedores ponen la escala a 1 al colocar a
  sus hijos.
- **Las chapitas y el candado,** hijos del retrato o del botón, que no son
  contenedores y los dejan donde se ponen.
- **El resultado va antes que la animación:** la animación no decide nada.
  Si se cierra el juego a mitad, la skin ya está guardada.
- **`apertura_paquete.gd` pasaba de 200 líneas,** así que la carta se separó
  en `carta_revelada.gd`.

## Problemas y solución

- **La apertura salía en la esquina y medía 0×0.** `set_anchors_preset`
  dentro de `_ready` conserva el tamaño que ya tenía el nodo. Se cambió por
  `set_anchors_and_offsets_preset`.
- **`var pulsado := ...` no compilaba:** no se puede inferir el tipo de una
  expresión con `evento.pressed`. Ahora es `var pulsado: bool`.

## Uso de IA

Los PNG los hizo Claude en el chat, con IA (scripts de Python píxel a
píxel), por encargo de Alan (`creditos.md`). El código, Claude Code. Los
extras del lote no se suben: `vista_previa/`, `herramienta/`, `LEEME.txt` y
el prompt.

## Métodos de test

- **`/validar`:** import y arranque sin errores (solo el aviso conocido del
  audio al salir), 16 clases, y el simulador desde el minuto 10 igual que
  `main` (derrota a los 600 s, nivel 13, 71 eliminados).
- **Capturas con ventana y CRT, con `cartera=demo`** (no toca la cartera de
  verdad), en `capturas_interfaz/`, fuera del repositorio:
  - las seis pestañas;
  - el pase con el destello, y el final de la pista con el 30;
  - la apertura de una C, una B (repetida) y una A, en la carga, el
    estallido, la revelación y el final.

  El script de captura, temporal, se borró.

## Estado al cerrar

Commits en `alan/interfaz-skins`, subida con su PR encima del #45. Alan
pidió también publicar la versión nueva: no se puede todavía, porque la
cartera (#40 a #45) no tiene la revisión de Adam ni está en `main`, y
`main` está igual que la v1.23. La línea de `reparto.md` (`medios/sprites/cartera/` en la
fila de la cartera) va en esta rama.

## Siguiente paso

- **Alan prueba la apertura y el pase jugando.** Con `cartera=demo` hay bits
  para abrir paquetes.
- **Adam revisa los PR #40 a #45 y el de esta rama.** Se fusionan en orden
  y, con todo en `main`, se publica la **v1.24** (`/publicar`, con sus
  novedades: la cartera, la moneda y la interfaz de skins).

## Publicada la v1.24 (25/11)

Adam dio el visto bueno a Alan, en persona, a los PR #40 a #46. Queda
apuntado en el #40. Alan pidió publicar.

- **Novedades:** `documentacio/novedades/v1.24.txt`, en el #46: los bits,
  las skins que hay que conseguir, las misiones, el pase, los logros, la
  tienda con la apertura de paquetes, el perfil y lo ganado en la pantalla
  final.
- **Fusión, en orden y con squash, del #40 al #46.** Antes de cada uno, el
  PR pasó a `main`, se trajo `main` a su rama y se esperó la comprobación en
  verde. Las ramas se borraron al final: borrar la base de un PR abierto
  podría cerrarlo.
  - **Un problema:** al traer `main` con `-X ours`, en `alan/bits` se coló
    una línea vieja de `ventana_skins.gd` y la comprobación del #45 falló.
  - **La solución:** se quitó la línea y, para lo que quedaba, se usó
    `-s ours`. Es correcto porque `main` solo tenía los squash de los PR
    anteriores, que cada rama ya llevaba.
  - **Comprobado:** `main` quedó exactamente igual que la rama de cada PR
    fusionado.
- **`/validar` en `main` (c921de4):** sin errores, 16 clases y el simulador
  igual. `project.godot` no cambia desde la v1.23, así que no hace falta
  subir `EJECUTABLE_MINIMO`.
- **Aviso a Adam** con el número, en el #46. Después, `git tag v1.24` y
  `git push origin v1.24`.
- **La release:** la Action «Publicar release» acabó bien (run 45659078629).
  La release «Sector Cero v1.24» tiene sus 7 ficheros (los cuatro `.pck`,
  el instalador de Windows, el zip del lanzador de Linux y `version.json`).
