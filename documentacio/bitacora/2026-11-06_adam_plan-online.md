# 06/11/2026 — Adam — El plan del multijugador

**Participantes:** Adam (con Claude Code), en casa, al final de la sesión de
la pantalla final (`2026-11-06_adam_final-y-ranking.md`). **Duración:**
incluida en sus 2 h.

## Qué se ha hecho

Adam: «quiero que dejes todo para hacer el online planeado; planeado lo digo
porque también quiero que Alan haga su parte del online, así que divide el
trabajo en dos». Claude le preguntó lo que cambia el diseño (ventana de
preguntas) y escribió `documentacio/plan_multijugador.md`: las decisiones,
cómo funciona, el contrato entre la red y el juego, el reparto, el orden y
los riesgos. Va en un PR pequeño y aparte (`adam/plan-online`), como pide
`flujo_de_trabajo.md` para los contratos, con `equipo/reparto.md` y
`requisitos_y_estado.md` al día.

## Decisiones de Adam (con sus palabras)

- **Red:** «quiero que sea en red local, pero no que tengas que poner la IP:
  con que al creador le salga un código y lo pongan los otros jugadores ya
  te puedas unir».
- **Personajes:** de 2 a 3 jugadores, cada uno con uno distinto; «que el otro
  pueda cambiar el personaje y se quede libre el otro personaje, así si uno
  de los dos muere puede utilizar el tercer personaje [...] Si hay 3
  jugadores, pues pueden jugar cada uno un personaje diferente».
- **Mejoras:** experiencia común y cada uno elige la suya (con pausa hasta
  que elijan todos).
- **Caídas:** espectador y vuelve con media vida en la fase 2.

## Decisiones técnicas y por qué

- **Anfitrión que lleva toda la partida** y clientes que solo mandan lo que
  pulsan y dibujan lo que reciben: no se desincroniza y el simulador sigue
  valiendo para el modo de un jugador.
- **`red.gd` lo crea `Transicion`**, como `cuenta.gd`: sin autoload nuevo,
  sin tocar `project.godot` ni subir `EJECUTABLE_MINIMO`.
- **Código de sala con la IP dentro** (propuesta; lo decide Alan al
  probarlo): no depende de que la red deje anunciar partidas.
- **Reparto:** la red y la sala, Alan (`alan/red`); el juego con varios
  jugadores, Adam (`adam/varios-jugadores`). Lo primero de Alan es probar que
  dos ordenadores del instituto se conectan.
- **A confirmar** (propuestas en el plan, sin preguntar todavía): la pausa
  en red, la dificultad con más jugadores, el ranking, el F1, las ultis, las
  desconexiones y la web.

## Estado al cerrar

Plan escrito en `adam/plan-online`, subido. Falta que lo revisen Adam y
Alan y fusionarlo, y crear las issues de cada parte (en casa no hay `gh`:
las tareas están en el plan, en «El reparto»).

## Siguiente paso

- Alan: leer el plan con su Claude y empezar por el punto 1 de la red.
- Adam: confirmar las propuestas y empezar `adam/varios-jugadores`.
