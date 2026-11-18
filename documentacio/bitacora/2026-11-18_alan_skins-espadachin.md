# 18/11/2026 — Alan — Las skins del Espadachín y el apartado SKINS

**Participantes:** Alan (con Claude Code), en el instituto (VM con Windows
10). **Duración:** por apuntar (se pregunta al cerrar), junto con la de
`2026-11-18_alan_skins-en-el-juego.md`, que es de la misma sesión.

## Qué se ha hecho

Alan trajo `lote_skins_espadachin.zip` (11 skins del Espadachín hechas con
Claude en el chat) y pidió además «un apartado de skins en el juego»; el pase
de batalla, sin hacer: «no sé de momento cómo se va a hacer, pregúntame y
dame opciones». Claude comprobó el lote (las 11 con sus 10 PNG del tamaño del
original, incluida la de atacar corriendo de 1536x576), propuso el plan con
tres preguntas y Alan dijo que sí.

Rama `alan/skins-espadachin`, sobre `alan/skins` (su PR aún no está
fusionado):
1. `assets(skins)`: los 110 PNG en `medios/sprites/skins/espadachin/`.
2. `feat(skins)`: las 11 skins en `recursos/skins/espadachin/` y su lista en
   `espadachin.tres`. Sin código: el sistema del Mago ya sirve.
3. `feat(skins)`, el apartado:
   - `escenas/skins/ventana_skins.gd`: la ventana SKINS, con las pestañas
     ARMARIO, PASE y TIENDA; las dos últimas, apagadas con «pronto».
   - `armario.gd` pasa a ser el contenido de la pestaña ARMARIO.
   - El botón SKINS en el menú, después de EN RED. Para que la fila quepa en
     1280 px, REGLAS, RANKING, OPCIONES y SALIR pasan de 160 a 140 px.
     Pulsar un personaje sigue abriendo las skins.
4. `docs`: créditos, documentación técnica (también las 24 columnas de
   atacar corriendo), manual, estado y esta entrada.

## Decisiones de Alan

- **`espadachin.tres` se commitea** como `mago.tres`, aunque el prompt del
  lote decía pedírselo a Adam: Adam ya dijo que sí a tocar sus ficheros
  para las skins (issue #23).
- **El apartado, un botón SKINS en el menú** con pestañas (de las tres
  opciones: botón con pestañas, el aviso «pulsa un personaje» o una pestaña
  en Opciones).
- **El pase de batalla, más tarde.** Las opciones que se le dieron:
  1. *Por partidas jugadas:* puntos por minuto aguantado y por ganar,
     15 niveles, skins en los niveles 5, 10 y 15. Lo más fácil y funciona
     sin cuenta; se guarda en el ordenador, así que se puede trucar.
  2. *Por retos:* «elimina 1000 malware», «gana con el Mago en difícil»...
     Más divertido, más código y hay que pensar la lista de retos.
  3. *Mezcla:* la 1 de base y unos pocos retos con puntos extra.
  4. *En la cuenta (Supabase):* lo calcula el servidor con las partidas
     subidas; sin trampas, pero es SQL de Adam y sin cuenta no hay pase.
  También queda por decidir qué skins se consiguen en el pase (por ejemplo
  las S y S+) y cuáles siguen libres para todos.

## Métodos de test

- `/validar`: import y arranque sin errores, 16 clases (no hace falta subir
  `EJECUTABLE_MINIMO`), simulador desde el minuto 10 igual que siempre
  (derrota en 600 s, nivel 13, 22 eliminados).
- `prueba_skins.gd` del lote (pasada y borrada): las 11 del Espadachín
  «bien», «en partida, el Espadachín lleva Supernova» y 0 errores.
- Capturas con ventana y CRT (script temporal, borrado; en
  `capturas_skins/espadachin/`, fuera del repositorio): el Espadachín con el
  original y una skin de C, B, A, S y S+ andando, atacando, atacando
  corriendo, quieto y evolucionado; el menú con el botón SKINS; la ventana
  SKINS en la pestaña del Espadachín; y la partida con Supernova, con su
  retrato en el panel del equipo y en la barra. Los efectos de Holograma y
  Supernova se siguen viendo con el CRT.

## Estado al cerrar

Cuatro commits en `alan/skins-espadachin` (después, `alan/skins-espadachin-segador`), sin subir.

## Siguiente paso

- «Ya he acabado»: subir `alan/skins` (PR #22) y `alan/skins-espadachin`
  (su PR, que se fusiona después del #22) y avisar a Adam en la #23.
- El lote del Segador.
- Decidir el pase de batalla con Adam.
