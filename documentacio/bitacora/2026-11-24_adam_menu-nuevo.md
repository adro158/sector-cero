# 24/11/2026 — Adam — Scripts de red partidos, partida guardada y el menú nuevo

**Participantes:** Adam (con Claude Code). **Duración:** 2 h (Adam: «cada
sesión que hago del proyecto son 2 horas»). **Horas acumuladas:** 61 h.

## Qué se ha hecho

En varias ramas, de la primera a la última:

1. **`adam/partir-red`:** `partida_red.gd` (260 → 199 líneas), `sala_red.gd`
   (246 → ~190) y `red.gd` (255 → 218). Los trozos fueron a
   `envio_estado_red.gd`, `pausa_red.gd`, `piezas_sala_red.gd` y
   `anfitrion_red.gd`. También `requisitos_y_estado.md` al día, porque se
   había quedado en la v1.17.
2. **El #30 de Alan, fusionado** porque no puede venir a clase. La issue
   **#34** le dice todo lo que le toca al volver.
3. **`adam/menu-sonido-animacion`:** un tic al pasar por los botones
   (`encima.wav`, generado con `generar_audio.gd`) y las ventanas que entran
   creciendo desde el 90 %. A Adam le gustó. También un primer menú de 4
   botones con las piezas de siempre, que se ha descartado: es este mismo.
4. **`adam/partida-guardada`** (sobre la anterior) y
   **`adam/contrato-guardar`** (la señal `guardar_partida_pedido` del bus,
   que es fichero de paso): GUARDAR Y SALIR en la pausa y CONTINUAR en
   JUGAR. Se guarda el minuto, el nivel, las mejoras, el equipo, la
   resistencia y los eliminados (`partida_guardada.gd`), en `user://` y en
   la tabla nueva `partida_guardada` de Supabase, creada con el conector
   (SQL en `plan_cuentas.md`). Hay que rehacerla encima del menú nuevo.
5. **`adam/menu-nuevo`** (desde `main`, con el sonido y la animación traídos
   con `cherry-pick`), con las piezas del `lote_menu.zip`, como en su
   maqueta:
   - cuatro botones grandes (JUGAR, COLECCIÓN, PERFIL y OPCIONES), la
     cuenta (abre `panel_cuenta.gd`) y SALIR en las esquinas
   - los personajes en sus peanas, con el cartel al pasar el ratón o el foco
   - **JUGAR** (`ventana_jugar.gd`): tarjetas para el modo y la dificultad
     (`tarjeta_menu.gd`, sustituyen a `selector_dificultad.gd`), «¿Cómo se
     juega?» y EMPEZAR
   - **PERFIL** (`panel_perfil.gd`, sustituye a `panel_ranking.gd`): la
     cuenta, los récords y las pestañas PARTIDAS y RANKING
   - **OPCIONES** con la pestaña Versión (`pestana_version.gd`), solo en el
     menú
   - **las novedades** (`tarjeta_novedades.gd`)
   - el marco nuevo en todas las ventanas (`ventana_centrada()`)

## Decisiones (de Adam, con «sigue» al plan)

- **Lo que no existe no sale:** la misión de hoy, su barra y el aviso con
  número de COLECCIÓN dependen de las misiones y el pase de Alan. Los PNG
  se suben igual. Lo de COLECCIÓN va en la issue **#35** para Alan: la
  banda del título, la pestaña MISIONES y de dónde sacar la misión y el
  aviso.
- **Las novedades:** la Action copia `documentacio/novedades/<versión>.txt`
  a `projecte/novedades.txt` y `export_presets.cfg` lo incluye en el `.pck`,
  porque un `.txt` no se exporta solo. NUEVO sale hasta que se pulsa la
  tarjeta o se empieza una partida (la opción `novedades_vistas`). En
  desarrollo no hay fichero y la tarjeta no sale. `projecte/novedades.txt`
  está en `.gitignore`.
- **Los colores, como en la maqueta:** JUGAR y EMPEZAR en verde, MEDIA en
  amarillo.
- **La versión, en OPCIONES solo en el menú:** la pausa también usa
  OPCIONES, y en mitad de una partida no pinta instalar versiones.
- **El marco en todas las ventanas:** con título, la banda sobre el borde
  (JUGAR, PERFIL, OPCIONES, reglas, versiones y sala). La cuenta (que cambia
  de título), la pausa y las de la partida se quedan con el título dentro.

## Problemas y solución

- **El botón SALIR se salía por la esquina** con el preset de anclaje, porque
  Godot aún no sabe lo que mide. Se coloca creciendo hacia dentro desde la
  esquina (`_poner_en_esquina`).
- **Capturas en negro y una línea que no salía:** la máquina virtual se
  cerró de golpe (código 5) y la caché de shaders quedó a medias. Se borró
  (de paso, también las de otros proyectos de Godot de este ordenador, que
  se regeneran solas) y, con la caché caliente, salen bien.
- **La entrada animada de una ventana borrada a medias** daba un error en el
  simulador. Ahora mira que la ventana siga existiendo.
- **Una prueba dejó las novedades como vistas** en las opciones de Adam.
  La prueba ahora lo deshace al acabar.

## Métodos de test

- **`/validar`:** importa y arranca sin errores, siguen 16 clases y el
  simulador desde el minuto 10 da lo mismo (600 s, 71 eliminados).
- **Capturas con ventana** (en `capturas_menu/`, sin commitear): el menú, un
  personaje con su cartel, un botón con el foco del mando, JUGAR con una
  tarjeta elegida, PERFIL con cada pestaña, OPCIONES en Versión y la pausa
  con el marco nuevo.
- **EMPEZAR lleva a `juego.tscn`.**
- **Partida guardada:** se guarda, se continúa y se compara. Las reglas de
  la tabla, probadas en una transacción deshecha.

## Estado al cerrar y siguiente paso

- `adam/menu-nuevo`: commits sin subir; el PR, al decir «ya he acabado».
- Después, rehacer `adam/partida-guardada` encima: CONTINUAR como tarjeta en
  JUGAR. Y subir `adam/partir-red` y `adam/contrato-guardar` con sus PR.
- Faltan partir `estilo_interfaz.gd` (ya pasaba de las 200 líneas) y jugarlo
  a mano con el mando y en táctil.
