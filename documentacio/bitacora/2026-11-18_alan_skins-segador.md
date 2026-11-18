# 18/11/2026 — Alan — Las skins del Segador: los tres con skins

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración y horas:** las de la sesión del 18/11, apuntadas en
`2026-11-18_alan_skins-en-el-juego.md` (2 h hoy, 4 h acumuladas).

## Qué se ha hecho

Alan trajo `lote_skins_completo.zip` («aquí tienes todos»): las 33 skins de
los tres personajes, con un prompt escrito antes de lo del 17 y 18/11.
Claude lo comprobó: las del Mago y el Espadachín son idénticas a las que ya
estaban (Git no las ve cambiadas) y lo nuevo es el Segador, con sus 11
skins (10 PNG cada una, del tamaño del original). Alan dijo que sí al plan.

- **La rama** `alan/skins-espadachin` pasa a llamarse
  `alan/skins-espadachin-segador` (no estaba subida): un solo PR para el
  Espadachín, el Segador y el apartado SKINS, que se fusiona después del
  #22.
- `assets(skins)`: los 110 PNG en `medios/sprites/skins/segador/`.
- `feat(skins)`: las 11 skins en `recursos/skins/segador/` (Ceniza, Ártico,
  Pantano, Obsidiana, Cobre oxidado, Hueso, Ransomware, Kernel Panic,
  Espectro, Fuego fatuo y Luna de sangre) y su lista en `segador.tres`.
  Sin código: el armario ya tenía la pestaña.
- `docs`: créditos, documentación técnica, manual, estado y esta entrada.

## Lo que el prompt pedía y ya estaba hecho

El prompt del lote decía no commitear el parche de Adam y proponerle la
skin en red sin programarla. Las dos cosas ya estaban decididas y hechas
con su sí (issue #23): las listas de skins, `_aplicar()` sobre la v1.21
(`aspecto_de`) y la skin de cada jugador en red, que es exactamente lo que
proponía el prompt (`"skins"` en cada jugador de la sala, en su
`CambioPersonaje`, y la opción guardada sin red). Se siguió lo decidido.

## Métodos de test

- `/validar`: import y arranque sin errores, 16 clases (no hace falta subir
  `EJECUTABLE_MINIMO`), simulador desde el minuto 10 igual que siempre.
- `prueba_skins.gd` del lote (pasada y borrada), con un cambio: llama a
  `armario.abrir()`, que desde el 18/11 es `mostrar()` (el armario es una
  pestaña de la ventana SKINS). Resultado: los tres con 11 skins «bien»,
  el armario con 12 en cada pestaña, en partida el Mago con Singularidad,
  el Espadachín con Supernova y el Segador con Luna de sangre, 0 errores.
- Capturas con ventana y CRT (script temporal, borrado; en
  `capturas_skins/completo/`, fuera del repositorio): el Mago y el Segador
  con el original y una skin de C, B, A, S y S+ andando, atacando, atacando
  corriendo, quieto y evolucionado (las del Espadachín, de la entrada
  anterior); las tres pestañas del armario; y la partida con el Segador en
  Luna de sangre, con su retrato en el panel del equipo y la barra. Los
  efectos de las S y las S+ (Espectro, Hacker, Luna de sangre,
  Singularidad) se siguen viendo con el CRT.

## Estado al cerrar

Alan: «ya he acabado». Subidas `alan/skins-contrato` (PR #21), `alan/skins`
(PR #22) y `alan/skins-espadachin-segador` con su PR, que se fusiona
después del #22; en la #23, un comentario para Adam con lo tocado de sus
ficheros.

## Siguiente paso

- «Ya he acabado»: subir `alan/skins` (PR #22) y
  `alan/skins-espadachin-segador` con su PR, y comentar en la #23.
- Decidir el pase de batalla.
