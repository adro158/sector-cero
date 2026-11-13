# 13/11/2026 — Adam — El panel del equipo (C) con sprites

**Participantes:** Adam (con Claude Code), en el instituto. **Duración y
horas acumuladas:** las apunta `/cerrar`, con las de la sesión entera
(este día también llevó el multijugador, el arreglo de las opciones en la
pausa y la versión en el ranking, en sus ramas).

## Qué se ha hecho

Adam trajo un zip con las piezas del panel del equipo (hechas con Claude en
el chat) y un encargo: pasar el panel de la C de una caja con texto a una
ficha de sprites por personaje. Se trabajó en `adam/panel-equipo`, desde
`main`.

- **Los dibujos** (`medios/interfaz/equipo_*.png`, en grises para
  teñirlos): la ficha en tres estados, el marco del retrato, la luz del
  activo (4 fotogramas), el glitch del caído (3), ocho iconos, la cabecera y
  las barras finas con su destello (6). Se importan como los del lote 9.
- **`panel_equipo.gd`, reescrito con `_draw`**, a partir de la referencia
  del zip:
  - la ficha de 9 trozos según su estado, teñida del color del personaje
    (el caído, con `TEXTO_SUAVE`)
  - el retrato pequeño (`retrato_mini_*`, el del ranking) dentro de su
    marco; el activo con la luz que da vueltas y el caído en gris con la
    grieta y el glitch en rojo
  - el icono del estado, el nombre y ACTIVO, LISTO o CAÍDO
  - la vida (de rojo a verde) y la ulti (dorada; llena, LISTA con el
    destello)
  - la herramienta y su resistencia, con el escudo y el número en rojo
    desde el 40 %
  - lo de dentro, como antes: `ver_equipo` (C o Select), procesa en pausa,
    escucha `equipo_cambiado` y `ulti_cambiada` y lee la resistencia del
    nodo del malware
- **Sobre la referencia, dos cosas más:**
  - la cabecera dice `[Select]` con el mando (`Entrada.con_mando`): con
    `_draw` no vale `segun_mando`, que es para etiquetas
  - el nombre de la herramienta encoge hasta caber (`_texto_que_quepa`):
    «Análisis heurístico» y «Firewall perimetral» pisaban el escudo de la
    resistencia

## Decisiones y por qué

- **`_draw` y no nodos** (plan aceptado por Adam): son unas quince piezas
  por ficha y dos animaciones; con nodos sería más largo de explicar. Como
  la barra del equipo y el F3.
- **El tamaño de la referencia** (Adam, ventana de preguntas): 232 × unos
  218 px, un poco más alto que el panel pequeño del 05/11 (unos 245 × 165),
  porque en la partida cabe bien a la derecha.
- **Mismo tamaño con «Texto grande»** (Adam): con `_draw` las medidas son
  en píxeles; así quedan enteros, como en la barra del equipo y el F3.

## Métodos de test

- `/validar`: import (tres veces, por los PNG nuevos), `--quit-after` sin
  errores, la partida del simulador desde el minuto 10 con el resultado de
  siempre (carga `juego.tscn`) y siguen 16 clases.
- Capturas con ventana con un script temporal fuera del repo (a partir de
  `referencia/prueba_equipo.gd`): al empezar (uno activo y dos listos); la
  ulti del activo llena; la resistencia contra su herramienta al 45 %; con
  mando (`[Select]`), y el activo cayendo de verdad, con la ventana de
  elegir quién sigue y el panel enseñándolo caído en la pausa. `user://`
  copiado antes y dejado como estaba.
- No cambia el equilibrio: no hace falta medir con el simulador.

## Estado al cerrar

Tres commits en `adam/panel-equipo` (`assets`, `feat(interfaz)` y `docs`),
sin subir. No se suben las vistas previas del zip, `referencia/`,
`herramienta/`, `LEEME.txt` ni el prompt.

## Siguiente paso

- Al decir Adam «ya he acabado»: `/cerrar`, push de la rama y su PR.
- Que Adam lo vea jugando.
