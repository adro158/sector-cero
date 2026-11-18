# 16/11/2026 — Adam — La tercera tanda de la partida en red

**Participantes:** Adam (con Claude Code). Hoy lunes Adam no tenía la
asignatura del proyecto. **Duración:** 1 h (la dijo Adam).
**Horas acumuladas:** 53 h de las 60 sugeridas (88 %): las 52 de la última
entrada (13/11) más esta. Las del 05/11 siguen sin apuntar.

## Qué se ha hecho (rama `adam/red`, PR #14)

Adam empezó con «Tengo 1 hora para que puedas hacer algo» y luego fue
diciendo «sigue» con cada parte. Once commits, cada uno probado con dos
copias del juego conectadas en este ordenador y con el simulador:

1. **Pausa, espectador y final:** en red no se pausa (el menú sale y la
   partida sigue); el final llega a todos con «fin» y no cuenta para el
   ranking, los récords ni la cuenta (`en_red`); en red no hay REINTENTAR;
   el que se queda sin personaje se ve mirando también en su pantalla;
   salir de la partida es salir de la red.
2. **Los élites** en los clientes: aparecen con su aviso, pierden la misma
   vida y mueren igual (el explosivo estalla), sin perseguir ni recibir
   golpes (`solo_dibujar`).
3. **Kernel Panic:** aparece, pone sus poses, se enfurece a la vez y, al
   morir, el cliente también pasa a la fase 2.
4. **NÚCLEO CERO:** aparece, se transforma, se queda aturdido y muere; la
   victoria llega solo del anfitrión (si no, salían dos pantallas finales).
5. **Los ataques de los jefes:** la jaula, la ráfaga, los cinco ataques de
   NÚCLEO CERO con sus portales, su escudo con las anclas (y el aviso del
   HUD de las que quedan) y el hielo. Todo con `datos_red()` y
   `poner_desde_red()` en cada nodo, en la lista `RAIZ` de `estado_red.gd`.
6. **Arreglo de las anclas:** miraban el personaje del anfitrión, así que el
   de otro ordenador solo rompía las del personaje que llevara el
   anfitrión. Ahora cada golpe dice qué jugador lo da
   (`danar_en_area(..., quien)`). De paso: `gestor_armas.gd` cogía «el
   primer jugador del grupo», y las armas de los demás salían del jugador
   local y su robo de vida le curaba a él.
7. **Arreglo de las mejoras con el anfitrión mirando:** la red mandaba las
   opciones al oír `jugador_subio_nivel`, que no salta si el anfitrión no
   elige, y la partida se quedaba en pausa para siempre. Ahora escucha
   `opciones_sorteadas`, una señal del sistema de niveles (no del bus).
8. **Los premios y la ruleta:** el corazón y el cofre se ven en los
   clientes, y el premio del cofre es de quien lo recoge (antes, siempre
   del anfitrión): si es de otro ordenador, la red le manda su ruleta.
9. **La caída:** en el cliente el personaje se deshace como en el
   anfitrión y el siguiente entra con el escudo. Y la caída en red se
   decide por los miembros del equipo, no por los jugadores en pie (con el
   anfitrión mirando, con tres jugadores, se pausaba y le preguntaba a él).
10. **Las muertes y los números de daño:** el anfitrión los manda con cada
    estado (con tope) y el cliente avisa las muertes por el bus (efectos,
    avisos, carga de la ulti) sin soltar otra vez fragmentos ni premios.
11. **Partidos los scripts de red**, que pasaban del límite de ~200 líneas:
    `preparar_red.gd` (crear a los jugadores y lo que solo se dibuja),
    `reglas_sala.gd` (quién entra y qué personaje lleva) y la conversión del
    final en `estado_red.gd`. `partida_red.gd` pasa de 267 a 205 líneas y
    `red.gd` de 237 a 219. Sin `class_name` nuevos: siguen 16 clases.

## Decisiones técnicas y por qué

- **Un mismo patrón para todo lo que se ve en los clientes:** cada nodo
  tiene `solo_dibujar`, `datos_red()` y `poner_desde_red()`. En los
  clientes no persigue, no ataca ni recibe golpes: la partida es la del
  anfitrión. Es fácil de explicar y de añadir a un nodo nuevo.
- **Sin tocar el bus** (es un fichero de paso): las señales nuevas
  (`opciones_sorteadas`, `ruleta_sorteada`) son del sistema de niveles.
- **Quién pega va en el golpe** y no en una variable aparte: el ancla mira
  el personaje que lleva ese jugador en ese momento, que es la regla de
  siempre. Con un jugador da exactamente lo mismo.
- **Las muertes del cliente pasan por el bus** como si fueran suyas: así
  salen solos el dibujo, las partículas, los avisos y la carga de la ulti.
  Los fragmentos y los premios no se sueltan dos veces porque llegan en el
  estado.

## Problemas y solución

- En las pruebas, un golpe a veces no hacía nada: el personaje estaba en el
  medio segundo de invulnerabilidad tras otro golpe, o en la protección al
  entrar. Era de la prueba, no del juego: se pega hasta que cae.
- Una copia de una prueba anterior se quedaba con el puerto 7777 y la
  siguiente no conectaba: esperar a que se cierren antes de repetir.

## Uso de IA y métodos de test

- Claude Code programó y probó cada parte; Adam decidió el orden.
- Scripts temporales fuera del repo (`extends SceneTree`) con dos copias
  conectadas por `127.0.0.1`: élites, jefes, ataques, anclas, mejoras con
  el anfitrión mirando, premios y ruleta, caídas y efectos.
- El simulador en cada cambio, idéntico a siempre: desde el minuto 10
  (derrota en 600 s, nivel 13), desde el 15 (victoria en 1055 s) y, cuando
  se tocaron las armas, los cofres o los efectos, la partida entera (1142 s,
  5743 eliminados, 18 cofres, 22 ultis).

## Estado al cerrar

Todo lo apuntado de la partida en red funciona en dos copias del mismo
ordenador. Subido a `adam/red` (PR #14), sin fusionar.

## Siguiente paso

- **Probarlo entre dos ordenadores de verdad** (issue #15, Alan o Adam).
- Medir la vida de los enemigos con varios jugadores.
- La carga de la ulti en los clientes se cuenta con las muertes que llegan:
  si se pierde algún estado puede ir un poco por detrás de la del anfitrión.
- Revisar el PR #14 (Alan o `/code-review`) y fusionarlo.
