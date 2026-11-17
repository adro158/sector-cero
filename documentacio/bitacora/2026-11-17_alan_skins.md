# 17/11/2026 — Alan — Las skins del Mago y el armario

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración y horas acumuladas:** por apuntar (se preguntan al cerrar).
Esta sesión también llevó la revisión del PR #14 de Adam (la red), que está
comentada en el propio PR.

## Qué se ha hecho

Alan trajo `lote_skins_mago.zip` (11 skins del Mago hechas con Claude en el
chat) y su encargo: «montar las skins de los personajes, empezando por las
del Mago», con un plan antes de programar. Claude comprobó el lote (las 11
skins con sus 10 PNG, todos con las medidas del original), propuso el plan y
Alan dijo que sí.

1. **PR de contrato** (`alan/skins-contrato`):
   - `recursos/skins/datos_skin.gd` (nuevo, de Alan, sin `class_name`): una
     skin con su número, nombre, categoría, frase, las 8 hojas y los dos
     retratos, con los mismos nombres que en `DatosPersonaje`, y
     `elegida(personaje)`, la que lleva puesta en este ordenador.
   - `DatosPersonaje` (de Adam): la lista `skins` y `skin(numero)`, que da la
     skin o el propio personaje.
   - `GestorGuardado` (de Adam): la opción `"skins"` (`{"Mago": 12}`).
   - `reparto.md` y `contexto.md`: las skins son de Alan
     (`recursos/skins/`, `medios/sprites/skins/`, `escenas/skins/`) y lo que
     se pide a Adam.
2. **`alan/skins`** (sobre el contrato):
   - `assets`: los 110 PNG en `medios/sprites/skins/mago/`.
   - `feat`: las 11 skins en `recursos/skins/mago/` y el armario
     (`escenas/skins/armario.gd` y `vista_skin.gd`).
   - `docs`: créditos, documentación técnica, manual, estado y esta entrada.
3. **El parche para Adam**, probado aquí y sin commit (va en una issue):
   - `mago.tres`: la lista de sus 11 skins;
   - `cambio_personaje.gd` (`_aplicar`): las hojas de la skin;
   - los retratos de la skin en `barra_equipo.gd`, `panel_equipo.gd` (el
     mini), `panel_caida.gd` y `resumen_final.gd`;
   - `personajes_menu.gd`: los personajes del menú, con su skin y como
     botones que abren el armario; `menu_principal.gd` crea el armario.

## Decisiones (de Alan) y por qué

- **La forma del lote y no la de la #16:** número de skin, opción
  `"skins"` y `DatosPersonaje.skin()`, en vez de ids de texto, un catálogo y
  `user://cartera.cfg`. Los assets están hechos para ella, ya venía probada y
  es más fácil de explicar; la tienda, el gacha y el pase se montan después
  encima (la cartera solo tendría que apuntar qué números tiene cada uno).
  Comprobado: Supabase guarda las opciones como JSON libre, así que la
  opción nueva se sube sin tocar el SQL.
- **Lo de Adam, pedido y no hecho:** la regla dura de `contexto.md`. Solo
  `DatosPersonaje` y `GestorGuardado` van en el PR de contrato, como pedía
  el encargo.
- **El armario se abre pulsando un personaje del menú:** la fila de botones
  ya no tiene sitio (issue #16, D14). Los personajes pasan a ser botones
  planos, así que también va con el mando.
- **Ranking sin skin:** guardar el número en cada partida para un dibujo de
  32 px no compensa por ahora.

## Problemas y solución

- **El simulador no compilaba** con `skin_elegida()` en `DatosPersonaje`:
  con `--script`, las clases globales que usa el script se compilan antes
  que los autoloads, y `GestorGuardado` no existe todavía. Se pasó a
  `datos_skin.gd` (sin `class_name`), que se carga más tarde. Por lo mismo,
  los scripts de prueba cargan los personajes con `load()` y no con
  `preload()`, como ya hacía el simulador.
- **La lista del armario salía en una columna:** dentro de un
  `ScrollContainer` el `HFlowContainer` no tenía ancho; con
  `SIZE_EXPAND_FILL` en la lista y en cada fila, sale en filas.
- **La fuente pixel separaba las íes** del nombre de la skin a 22: se puso a
  18, que usa la fuente normal.
- **Ventana en la VM:** no hay OpenGL 3.3, pero Godot pasa solo a ANGLE
  (Direct3D 11 por software) y las capturas salen bien.

## Uso de IA

Las skins las dibujó Claude en el chat con scripts de Python a partir de los
sprites originales (créditos). Claude Code comprobó el lote, escribió el
plan, el código, las pruebas y los documentos; Alan decidió el plan.

## Métodos de test

- `/validar` en el contrato y en `alan/skins` (con y sin el parche de Adam):
  import y arranque sin errores (solo el aviso conocido del audio), 16
  clases, y el simulador igual que siempre: minuto 10 → derrota en 600 s
  (nivel 13, 22 eliminados), minuto 15 → victoria en 1055 s (nivel 16, 428),
  y la partida entera, derrota en 1142 s con 5743 eliminados.
- `prueba_skins.gd` de la referencia del lote (copiada a `projecte/`,
  pasada y borrada): las 11 skins con sus 10 imágenes del tamaño del
  original y, en partida con `{"Mago": 12}` en memoria, el Mago con las
  hojas de Singularidad. 0 errores.
- Capturas con ventana y el filtro CRT (script temporal, borrado): el Mago
  con una skin de cada categoría (andar, atacar, quieto y evolucionado), el
  armario, y en la partida el jugador, el panel del equipo, la barra y la
  ventana de caída con el retrato de la skin. Los efectos de la S y la S+ se
  siguen viendo con el CRT.

## Estado al cerrar

Tres commits en `alan/skins` (sobre el de `alan/skins-contrato`), sin
subir. El parche para Adam, en `../parche_adam_skins.diff` (fuera del
repositorio), aplicado en local sin commit.

## Siguiente paso

- «Ya he acabado» → subir las dos ramas, abrir sus dos PR (primero el de
  contrato) y la issue para Adam con el parche.
- Los lotes del Espadachín y el Segador: sus PNG, sus `.tres` y su lista.
- La skin en red, cuando `adam/red` esté en `main`.
