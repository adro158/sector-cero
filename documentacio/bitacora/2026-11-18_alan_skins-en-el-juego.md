# 18/11/2026 — Alan — Las skins en el juego (y en red)

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración:** por apuntar (se pregunta al cerrar). **Horas
acumuladas:** las 2 h de la entrada anterior (`2026-11-17_alan_skins.md`)
más las de hoy.

## Qué se ha hecho

Alan: «me ha dicho Adam que puedes hacerlo». Es el sí de Adam a la issue
#23: los cambios de las skins en sus ficheros, que el 17/11 se le pidieron
con un parche, los hace Alan en `alan/skins` y Adam los revisa en el PR.

1. **`main` traído a las dos ramas** (`alan/skins-contrato` y
   `alan/skins`): ya tenía la red de Adam (v1.18 a v1.21). Un choque en
   `requisitos_y_estado.md` (las dos secciones nuevas, se quedan las dos) y
   otro en `menu_principal.gd` al volver a poner el parche (la sala de red y
   el armario, los dos).
2. **La skin en el juego** (`feat(skins)`):
   - `mago.tres` lista sus 11 skins;
   - `cambio_personaje.gd`: `aspecto_de(personaje)`, de donde salen las
     hojas en `_aplicar`; sin red, la skin de la opción de este ordenador;
   - `equipo.gd`: `estado()` da el `aspecto` de cada personaje (el de quien
     lo lleva o, libre, el de aquí), y de ahí salen los retratos de la barra
     del equipo, el panel (C) y la ventana de caída; el resumen final, de la
     opción;
   - el menú: los personajes con su skin, como botones que abren el armario.
3. **La skin en red** (`feat(red)`): cada jugador manda sus skins en el
   saludo de la sala, van en la lista (`{id, nombre, personaje, skins}`),
   `preparar_red.gd` se las pone a los jugadores de los demás
   (`poner_skins`) y la ficha del compañero enseña su retrato.
4. **Documentos:** el jugador de la sala en `plan_multijugador.md`, `red.gd`
   y `contexto.md`; `reparto.md` y el estado.

## Decisiones técnicas y por qué

- **La skin va con el jugador, no con el personaje:** si el Mago lo lleva
  otro, se ve con la del otro. Por eso el aspecto lo da `CambioPersonaje`,
  que es «el jugador», y el HUD lo lee del estado del equipo en vez de
  mirar la opción.
- **No viajan texturas, solo números:** todos tienen los mismos PNG porque
  la sala solo deja entrar a la misma versión. Un número que no existe da
  la original: no puede romper nada.
- **Un cliente de otra versión** no manda skins: se le rechaza igual por la
  versión, y aun así `red.gd` no se rompe (sin cuarto elemento, `{}`).

## Métodos de test

- `/validar` sobre el `main` nuevo: import y arranque sin errores, 16
  clases, simulador igual (minuto 10 → derrota en 600 s; minuto 15 →
  victoria en 1055 s).
- `prueba_skins.gd` del lote (pasada y borrada): 0 errores.
- **Prueba en red con dos copias** (script temporal, borrado): el anfitrión
  con `{"Mago": 12}` y el cliente con `{"Mago": 8}`, solo en memoria. El
  anfitrión ve al Mago del cliente con la 8 (la del cliente, no la suya) y
  a su Espadachín con el original; el cliente se ve con la 8 y ve al
  Espadachín del anfitrión. 0 errores en los dos.
- Sin capturas nuevas: el dibujo es el del 17/11; lo nuevo es de dónde sale
  el aspecto, comprobado con las pruebas.

## Estado al cerrar

`alan/skins` con dos commits más (`feat(skins)`, `feat(red)`) y los
documentos; `alan/skins-contrato` con `main` traído.

## Siguiente paso

- Que Adam revise el #21 y el #22 y fusionarlos (primero el #21).
- Los lotes del Espadachín y el Segador.
