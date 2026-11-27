# 27/11/2026 — Alan — Las misiones diarias que no se renovaban

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración:** por apuntar (se pregunta al cerrar). **Horas
acumuladas:** las 14 de `2026-11-25_alan_interfaz-skins.md` más las de hoy.

## Qué se ha hecho

Un compañero que prueba la v1.24 le dijo a Alan que las misiones diarias no
parecían actualizarse. Era verdad.

**El fallo.** Al cambiar de día, `Misiones.renovar()` sorteaba las diarias
nuevas, pero solo borraba el progreso y el «hecha» de las que **ya no
estaban**. Si una diaria volvía a salir al día siguiente, se quedaba con lo
de ayer: ya hecha, sin poder cumplirse otra vez. Como son 3 de 9, pasa casi
cada día; por ejemplo, «Lanza 5 ultis» sale el 27 y el 28/11. A las
semanales les pasaba lo mismo de una semana a otra.

**El arreglo** (en `globales/misiones.gd`, que es de Alan). Al cambiar de
día, `_olvidar(fichero, "diaria")` borra el progreso y las «hechas» de
**todas** las diarias. Al cambiar de semana, `_olvidar(fichero, "semanal")`
hace lo mismo con todas las semanales, incluida la de personaje. Las
semanales no se tocan al cambiar solo de día.

## Decisiones técnicas y por qué

- **Se borra por tipo y no por id.** Una misión del día nuevo empieza
  siempre de cero, salga o no la misma.
- **Lo que ya está mal en el fichero de un jugador** se arregla solo con el
  siguiente cambio de día. No hace falta tocar `cartera.cfg`.

## Métodos de test

- **Antes de arreglar,** se miró si el problema era el sorteo. La semilla
  es `hash()` de la fecha, que da números casi seguidos. Se midieron 90
  días: 16 repiten dos diarias con el día anterior, cuando lo esperable son
  unos 20, y cada misión sale un tercio de los días. El sorteo está bien y
  no se ha cambiado.
- **Una prueba temporal** (`extends SceneTree`, borrada después) reproduce
  el fallo: el 27 se hace «Lanza 5 ultis», y el 28 salía 5/5 y hecha.

  Con el arreglo:
  - el 28 sale 0/5;
  - una semanal conserva su progreso al cambiar de día (1/3);
  - el lunes siguiente, las semanales empiezan de cero.
- **`/validar`:** import y arranque sin errores (solo el aviso conocido del
  audio), 16 clases y el simulador desde el minuto 10 igual que siempre.

## Estado al cerrar

Commit en la rama `alan/misiones-diarias`, sin subir.

## Siguiente paso

- **Subir la rama con su PR** («ya he acabado»).
- **Publicarlo** en la versión siguiente, con la novedad «Arreglado: las
  misiones diarias que se repetían al día siguiente salían ya hechas».
