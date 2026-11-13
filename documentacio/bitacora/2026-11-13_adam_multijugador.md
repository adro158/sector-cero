# 13/11/2026 — Adam — Supabase despierto y el multijugador (parte de Adam)

**Participantes:** Adam (con Claude Code), en el instituto. **Duración y
horas acumuladas:** por apuntar (Adam las dirá; las últimas apuntadas son
50 h, 06/11, sin las del 05/11). Este día también llevó el arreglo de las
opciones en la pausa con la versión en el ranking (PR #8) y el panel del
equipo con sprites (`2026-11-13_adam_panel-equipo.md`).

## Qué se ha hecho

- **«Estoy en clase»:** `main` con la v1.16 (de casa, 06/11) y el plan del
  multijugador. Fusionados los PR de Adam (#5, la publicación de la v1.16) y
  de Alan (#6, su ficha). Alan tiene en `alan/red` la prueba de conexión con
  ENet, sin PR. Validado: la VM tuvo que importar tres veces las imágenes
  nuevas de la v1.16.
- **Supabase estaba pausado** (8 días sin uso): nadie podía entrar en su
  cuenta. Claude lo reactivó con el conector (Adam dijo que sí) y, a
  petición de Adam, una Action lo despierta los lunes y los jueves
  (`despertar_supabase.yml`, PR #7, fusionado y probada a mano).
- **El cierre al cambiar opciones en la pausa:** encontrado y arreglado en
  su rama (PR #8). Detalle en `requisitos_y_estado.md`, «Pendiente
  técnico».
- **El multijugador, la parte de Adam** (`documentacio/plan_multijugador.md`,
  donde está apuntado punto por punto), en `adam/varios-jugadores`:
  1. **Varios jugadores en la partida** (`jugadores.gd`): la horda, las
     oleadas, los fragmentos, los premios, el hielo, los élites y los dos
     jefes buscan al jugador más cercano y sus golpes llegan a todos.
  2. **El equipo compartido** (`jugador/equipo.gd`): uno por partida; cada
     jugador lleva uno libre, cambia solo a uno libre y, si cae el suyo,
     pasa al libre que quede.
  3. **Cada uno elige su mejora** y la partida espera a todos
     (`sistema_niveles.gd`, `elegir()`).
  4. **El espectador:** sin personaje no se mueve ni dispara ni se ve, su
     cámara sigue a otro, y vuelve con un personaje al empezar la fase 2.
  7. **Más vida con más jugadores** (×1,6 con dos, ×2,2 con tres), sin
     medir.
- **El contrato de la red** (PR #9, `adam/contrato-red`): las seis señales
  del bus para la red de Alan.

## Decisiones de Adam (ventana de preguntas, 13/11)

En red no se pausa; más vida para los enemigos con más jugadores; las
partidas en red no van al ranking; si se va un cliente su personaje queda
libre y si se va el anfitrión se acaba para todos.

## Decisiones técnicas y por qué

- **Con un jugador, lo mismo que antes:** cada paso se comprobó con el
  simulador desde el minuto 10, el 15 y una partida entera (derrota en
  1142 s con 5743 eliminados, 15 cambios, 4 caídas, 3 evoluciones), igual
  con el código nuevo que con el de `main`. Las oleadas salen alrededor de
  cada jugador por turnos y no al azar, para no gastar números del azar.
- **El equipo, en la raíz con `set_meta`:** sin tocar la escena (fichero de
  paso).
- **El grupo `en_partida`** para contar jugadores: de `jugador` se sale al
  quedarse mirando y los enemigos nuevos saldrían más flojos.

## Métodos de test

- El simulador, como arriba, en cada paso (también 16 clases e import y
  arranque sin errores).
- Una partida con un segundo jugador quieto a 600 px (script temporal fuera
  del repo): sin errores, la horda se reparte, el 2 empieza con el Mago y
  pasa al Segador al caer, la partida espera su mejora (su Heurística
  agresiva le sube su daño a ×1,12 y no el del 1), se queda mirando sin
  personaje y vuelve con el Mago a media vida al revivir los caídos; con
  dos, un bit corrupto nuevo sale con 32 de vida en vez de 20.

## Estado al cerrar

Doce commits en `adam/varios-jugadores`. Falta de la parte de Adam: las
partículas y la cámara con varios, la barra del equipo, el panel «esperando
a los demás», el cofre para quien lo recoge, mandar el estado por la red
(punto 5, depende de `red.gd`), la interfaz en red (punto 6) y medir la
vida con varios bots.

## Publicada la v1.17 (al final de la sesión)

Adam: «súbelo todo al GitHub y haz la nueva versión para jugar». Fusionados
con la comprobación en verde: #8 (el arreglo de las opciones y la versión
en el ranking), #9 (el contrato de la red; Adam lo pidió sin esperar la
revisión de Alan), #10 (el panel del equipo) y #11 (esta rama, con `main`
traído: un choque en `requisitos_y_estado.md`, la nota vieja del texto
grande contra la de «Arreglado», resuelto con la de `main`). Antes de
fusionar #11, la rama junta todo y se validó entera (simulador, la prueba
del texto grande por el menú y la de dos jugadores). `project.godot` igual
que en la v1.16 y 16 clases: no se sube `EJECUTABLE_MINIMO`. Novedades en
`novedades/v1.17.txt`.

## Siguiente paso

- Que Alan revise el contrato y siga con `red.gd`, o que Adam decida otro
  reparto.
- El punto 5, en cuanto haya `red.gd`.
