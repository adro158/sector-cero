# 17/11/2026 — Adam — Revisión de la red, tareas para Alan y la v1.18

**Participantes:** Adam (con Claude Code), en el instituto («Estoy en el
insti, sigue con lo que te quedaste ayer»). **Duración:** por apuntar: no
se preguntó al cerrar; se suman en la próxima entrada. **Horas
acumuladas:** 53 h hasta el 16/11, más las de hoy.

## Qué se ha hecho

1. **Revisión a fondo del PR #14** (la red del multijugador) con un flujo
   de agentes: cuatro revisores por áreas (la red, las regresiones con un
   jugador, lo que se dibuja en los clientes y el estilo) y un verificador
   que intentaba refutar cada hallazgo. **23 fallos confirmados** (7
   descartados), todos arreglados y probados. Una **segunda revisión**,
   solo de los arreglos, encontró **5 más**, también arreglados. El detalle
   está en `plan_multijugador.md` («Revisión del 17/11»). Los más graves:
   - Si un cliente se iba siendo el último por elegir mejora (o con su
     ruleta abierta), el anfitrión se quedaba en pausa para siempre.
   - Al morir Kernel Panic, en los clientes `vaciar()` daba por muerta a
     toda la horda (allí sus vidas son 0): cientos de muertes falsas, con
     sus sonidos, y la ulti llena de golpe.
   - En la fase 2, cada cliente repartía él los personajes de los que
     miraban y, con tres jugadores, podía salir cruzado para siempre.
   - Las ultis y las mejoras aplicadas no llegaban a los clientes: ni el
     rayo, el giro o la tormenta de los demás, ni las evoluciones.
2. **Para Alan, en GitHub:**
   - La **issue #15**, puesta al día: revisar el PR #14 y probar el juego
     en red con dos ordenadores, con una lista de qué mirar.
   - La **issue #16**, nueva: el **plan de skins, monedas, tienda, gacha y
     pase de batalla**. Lo pidió Adam: «Alan tiene assets nuevos de skins
     de los personajes, queremos crear un gacha con una tienda donde poder
     comprar las skins y también un pase de batalla donde desbloquearlas».
     Lo escribió un segundo flujo de agentes: tres miraron el código
     (personajes y sprites, guardado y cuentas, interfaz) y uno escribió el
     plan. Lleva 18 decisiones con su recomendación, el formato exacto de
     las hojas de sprites (comprobado en los PNG), la arquitectura sin
     clases globales nuevas, nueve fases con sus pruebas, lo que habrá que
     pedir a Adam y el prompt de arranque para el Claude de Alan.
3. **`contexto.md`** (fichero de paso, en su PR pequeño `adam/contexto-red`):
   la clave `en_red` de `partida_terminada`, que en red el menú de pausa no
   pausa y que el F1 no se abre.
4. **La v1.18**, con el multijugador en red: novedades en
   `documentacio/novedades/v1.18.txt`. Adam pidió «quiero que hagas la
   nueva versión para jugar».

## Decisiones técnicas y por qué

- **Las ultis en red:** la carga va en el estado (la cuenta el anfitrión);
  el cliente pide la suya con la dirección a la que apunta, y el anfitrión
  avisa de cada una que lanza (suceso «ulti», con el personaje). Así el rayo
  que se ve es el que pega.
- **Las mejoras en el cliente:** el anfitrión avisa de cada mejora aplicada
  (suceso «mejora») y el cliente la aplica también, para que se vean la
  evolución, el alcance y la velocidad. No cambia nada de la partida del
  anfitrión.
- **El F1 no se abre en red:** pausaría la partida de todos, y saltar de
  minuto recarga la escena y saca a todos de la red.
- **Con el menú de pausa abierto en red**, el jugador de ese ordenador se
  queda quieto: el menú no pausa, y las flechas o el mando lo movían.
- **`sucesos_red.gd`:** lo que pasa una vez y tiene que llegar sale de
  `partida_red.gd`, que volvía a pasar de 200 líneas.
- **El código de sala** no usa las redes de VirtualBox (192.168.56.x y
  10.0.2.x) si hay otra: en un PC con VirtualBox llevaba a una red a la que
  nadie llega. Ojo: la VM del instituto está detrás de la NAT de VirtualBox
  y no puede crear salas a las que lleguen otros ordenadores; la prueba con
  dos ordenadores tiene que hacerse desde PCs de verdad.

## Uso de IA y métodos de test

- Tres flujos de agentes: la revisión (5 agentes), el plan de Alan (4) y la
  segunda revisión (3). Ninguno lanzó Godot.
- Una prueba nueva con tres copias del juego conectadas (anfitrión, cliente
  e intruso): golpes en el cliente, la ulti pedida y vista, la del
  anfitrión, la mejora aplicada en el cliente, el menú de pausa, la fase 2
  sin muertes falsas, el cliente que se va sin elegir (sin pausa eterna) y
  el intruso con la partida empezada («La partida ya ha empezado»).
- Repetidas todas las pruebas de red de los días anteriores.
- El simulador, igual que siempre después de cada tanda: desde el minuto 10
  (600 s), desde el 15 (1055 s) y la partida entera (1142 s, 5743
  eliminados). Siguen 16 clases.

## Estado al cerrar y siguiente paso

- El PR #14 y el de `contexto.md`, fusionados, y la v1.18 publicada (si
  la comprobación de la Action está en verde).
- **Siguiente:** probar el juego en red entre dos ordenadores de verdad
  (issue #15) y que Alan empiece la fase 0 de la issue #16. Pendiente menor:
  `red.gd` (234 líneas) y `sala_red.gd` (217), y las barras de vida del
  ransomware en los clientes.
