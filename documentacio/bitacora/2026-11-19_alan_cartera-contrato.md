# 19/11/2026 — Alan — El contrato de la cartera (bits, misiones y pase)

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración:** por apuntar (se pregunta al cerrar); es de la misma
sesión que `2026-11-19_alan_skins-fusion-y-detalles.md`.

## Qué se ha hecho

Alan: «Adam ha estado con Claude planeando lo del pase de batalla, así que
ve a mirarlo para aplicarlo; también quiero el prompt para crear lo de la
moneda». El plan está en la issue #16, en el comentario de Adam del 19/11
(«idea nueva»: misiones diarias y semanales, la moneda «bits» y el pase),
aprobado por él. Claude lo leyó, le dio a Alan ideas nuevas para el pase y
el prompt del asset de la moneda (`lote_bits.zip`, para Claude en el chat), y
propuso hacerlo en cinco fases, un PR cada una. Alan: «sí, empieza».

**Fase 1, el contrato** (rama `alan/cartera-contrato`):
- `documentacio/plan_tienda.md` (nuevo): las decisiones (las de la #16 que
  siguen, las de Adam y las de Alan), los números para empezar, qué guarda
  `user://cartera.cfg`, lo que usan los demás de la cartera, sus señales, lo
  que se pide a Adam y las cinco fases.
- `globales/cartera.gd` (nuevo, sin `class_name`): el esqueleto con las
  funciones y las señales del contrato, que devuelven vacío o lo de siempre.
- `globales/transicion.gd` (de Adam, con su sí): crea la cartera al
  arrancar, después de la red.
- `herramientas/simular_partidas.gd` (de Adam, con su sí): `_apartar_cartera`,
  como la cuenta, para que las partidas simuladas no den nada cuando la
  cartera escuche el bus.
- `reparto.md` y `contexto.md`: la cartera es de Alan y cómo se usa.

## Decisiones de Alan (19/11)

De las ideas que se le dieron para el pase, eligió:
- misiones de personaje (una semanal, de un personaje concreto, con más
  puntos);
- cambiar una misión diaria al día, gratis;
- doble en cooperativo (los puntos del pase en red valen el doble);
- logros permanentes con su título;
- colores de la interfaz y del CRT como premio (son de Adam: se le piden);
- una racha suave de bits por jugar días seguidos, sin castigo.

No quiso el «pase sin final» (premios más allá del nivel 30).

## Decisiones técnicas y por qué

- **Las señales de la cartera son del nodo, no del bus:** solo las escuchan
  las pantallas de Alan, así que no hace falta tocar `bus_eventos.gd`, que es
  un fichero de paso.
- **Un fichero aparte** (`user://cartera.cfg`): el de las opciones es de Adam
  y lo reescriben también las versiones antiguas.
- **Lo que se lleva puesto** (título, marco, estela...) irá en las opciones,
  como la skin: así se sube a la cuenta y viaja en red.

## Métodos de test

`/validar`: import y arranque sin errores, 16 clases (no hace falta subir
`EJECUTABLE_MINIMO`), y el simulador igual que siempre (minuto 10 → derrota
en 600 s; minuto 15 → victoria en 1055 s), ya con la cartera creada y
apartada.

## Estado al cerrar

Un commit en `alan/cartera-contrato`, sin subir.

## Siguiente paso

- La fase 2: bits y misiones, con la pestaña MISIONES; la moneda, cuando
  llegue `lote_bits.zip`.
- Que Adam revise el contrato (y el #30).
