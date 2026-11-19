# 19/11/2026 — Alan — La cartera: bits, misiones, pase, tienda y perfil

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración:** por apuntar (se pregunta al cerrar); es de la misma
sesión que `2026-11-19_alan_cartera-contrato.md`.

## Qué se ha hecho

Alan: «sigue con todo hasta que acabes todo y después te pasaré el asset de
la moneda». Después del contrato (fase 1), las fases 2 a 5 de
`plan_tienda.md`, cada una en su rama, encima de la anterior:

2. **`alan/cartera-misiones`**: los bits de cada partida, las misiones (3
   diarias y 3 semanales, una de personaje, sorteadas con la fecha), el
   cambio de una diaria al día, la racha, la pestaña MISIONES (las pestañas
   de la ventana SKINS ya cambian) y lo ganado en la pantalla final.
3. **`alan/cartera-pase`**: el pase de 30 niveles con sus premios (bits,
   paquetes, títulos, marcos, estelas, temas y las skins S y S+), que se dan
   solos, y los 7 logros con su título; las pestañas PASE y LOGROS.
4. **`alan/cartera-tienda`**: la tienda (C 300, B 600, A 1200 bits), los
   paquetes cifrados (C 60 %, B 30 %, A 10 %; gratis del pase o por 250
   bits), la pestaña TIENDA, el armario que solo deja poner las que se
   tienen y el modo demostración (`cartera=demo`).
5. **`alan/cartera-premios`**: el perfil (título, marco, estela, icono y
   tema), la pestaña PERFIL, la estela detrás del jugador, la placa en red
   con el marco y el título, el icono y el título en la sala, el título en el
   menú y el tinte del tema en el filtro CRT.

## Decisiones técnicas y por qué

- **Ficheros pequeños**: `cartera.gd` guarda el estado y lo que usan los
  demás; el resto va en scripts sin nodo (`misiones.gd`, `pase_batalla.gd`,
  `logros.gd`, `tienda.gd`, `premios.gd`, `recompensa.gd`, `cobro.gd`). Así
  ninguno pasa de ~200 líneas y cada uno se explica solo.
- **Contar sin tocar la partida**: `contador_partida.gd` escucha el bus y
  empieza de cero cuando entra una `RaizJuego` en el árbol.
- **El azar, propio**: un `RandomNumberGenerator` para los paquetes y una
  semilla con la fecha para las misiones; el global lo fija el simulador, que
  así da lo mismo de siempre.
- **Lo de Adam**, en commits aparte en cada fase, para que lo revise.
- **Los iconos** son los retratos de las skins que se tienen (sin arte
  nuevo) y **los temas** tiñen el CRT (los colores de la interfaz son
  constantes en todo el juego). Más diferencias, en `plan_tienda.md`,
  «Estado».

## Problemas y solución

- `cartera.gd` pasaba de ~200 líneas en las fases 3 y 4: lo de la racha y los
  bits de la partida a `recompensa.gd`, y el cobro del final a `cobro.gd`.
- Las 10 000 tiradas de la prueba tardaban minutos: cada una buscaba los
  personajes en disco. `tienda.gd` los tiene cargados con `preload`.
- `Premios.color()` fallaba con los títulos (son solo texto): ahora devuelve
  el «si no».
- La estela no se veía: con `z_index` por debajo de 0 quedaba bajo la arena;
  y andando despacio se recogía como si estuviera quieto. Ahora va detrás del
  jugador (`show_behind_parent`) y solo se recoge si no se mueve.
- El tema ámbar al 45 % quedaba verdoso sobre el cian del juego: al 70 %.

## Métodos de test

- `/validar` en cada fase: import y arranque sin errores, 16 clases, y el
  simulador igual (minuto 10 → derrota en 600 s; minuto 15 → victoria en
  1055 s).
- Prueba de la cartera en headless (copia `user://cartera.cfg` y lo deja
  como estaba), 37 comprobaciones: los números de una partida, el sorteo del
  mismo día y el lunes, cambiar una misión, cobrar una misión, la racha, el
  pase y sus premios (también una skin repetida, que da 300 bits), los
  logros, la tienda, los paquetes (2000 tiradas: 60/30/10) y que una skin sin
  tener no se ponga.
- El perfil en red con dos copias: cada una recibe el del otro y ve su estela
  con su color, y una skin puesta sin tenerla no viaja.
- Capturas con ventana y CRT (`capturas_cartera/`, fuera del repositorio):
  las seis pestañas, lo ganado en la pantalla final, la estela de fuego en la
  partida y el tema ámbar.

## Estado al cerrar

Las cinco ramas, sin subir.

## Siguiente paso

- El asset de la moneda (`lote_bits.zip`): el icono junto a los bits.
- «Ya he acabado»: subir las cinco ramas con sus PR (en orden) y avisar a
  Adam; luego, que Adam haga la versión nueva.
