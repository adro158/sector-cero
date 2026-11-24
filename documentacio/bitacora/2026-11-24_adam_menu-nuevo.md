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

## Después: la partida guardada encima y la v1.23

Adam: «Si rehazlo. Y una vez este hecho haz la nueva version para jugarlo y
deja todo apuntado para que alan pueda aplicar bien lo que tiene que hacer
el con la nueva version».

- La partida guardada se trae a `adam/menu-nuevo` (los ficheros de la rama
  vieja, que solo tocaban la pausa y la partida) y CONTINUAR pasa a ser una
  tarjeta arriba de JUGAR, con el resumen (minuto, nivel y dificultad). Sale
  después de abrir la ventana, porque la de la cuenta llega de Supabase.
- Repetida la prueba de guardar y seguir sobre el menú nuevo: todo igual.
- El contrato (`guardar_partida_pedido`, PR #36) entra primero, como fichero
  de paso; después el menú (PR #37) y la v1.23.
- Lo que tiene que hacer Alan con la v1.23, en las issues #34 y #35.

## Estado al cerrar y siguiente paso

- En `main` y publicado en la v1.23: el menú nuevo y la partida guardada.
- Pendiente: `adam/partir-red` (su PR, con los conflictos del menú en
  `sala_red.gd`), partir `estilo_interfaz.gd`, jugarlo con el mando y en
  táctil, y probar la partida guardada en la nube con una cuenta.

## Después de la v1.23: la web y el móvil (rama `adam/arreglos-web-movil`)

Adam probó la v1.23 desde la web y el móvil: «si juego desde la aplicacion
web e inicio mi cuenta no me tiene ni las partidas que tengo a medias ni las
skins guardadas ni nada», letras desplazadas hacia abajo en la dificultad, la
pantalla completa que no hace nada, y en táctil «no me deja elegir a que
personaje cambiar, y no hay tecla para ver el equipo». Decisión de Adam: se
deja arreglado, **sin publicar**; la versión siguiente sale cuando Alan acabe
lo suyo.

- **La cuenta en la web no bajaba nada.** Los registros de Supabase dicen que
  el servidor sí mandaba las opciones, las partidas y la partida guardada
  (`content_range` 0-0, 0-2). Supabase comprime con gzip y deja ver al
  navegador la cabecera `Content-Encoding`; el navegador ya lo descomprime y
  Godot lo intentaba otra vez y fallaba (`RESULT_BODY_DECOMPRESS_FAILED`, que
  `cuenta.gd` tomaba como «sin respuesta»). El login sí iba porque esa parte
  de Supabase no deja ver esa cabecera. Arreglo: `accept_gzip = false` en la
  web (`cuenta.gd`). En el escritorio no pasaba.
- **Las letras desplazadas:** en la web no hay Consolas y la letra que queda
  (Open Sans) ocupa más; las tarjetas de JUGAR tenían el alto fijo y el texto
  se salía por abajo. Ahora miden lo que tienen dentro cada vez que cambia
  (`tarjeta_menu.gd` y, por lo mismo, `tarjeta_novedades.gd`).
- **La pantalla completa en la web:** el navegador solo la deja poner justo
  después de un toque, y Safari del iPhone no la deja nunca a una página. Al
  arrancar en la web la opción vuelve a «no» (la página siempre empieza en su
  ventana, y la casilla decía que sí sin estarlo), y donde el navegador no
  sabe ponerla la casilla no sale. Para el iPhone, la etiqueta
  `apple-mobile-web-app-capable`: añadida a la pantalla de inicio, se abre sin
  las barras de Safari.
- **Un fallo escondido:** `JavaScriptBridge.eval` devuelve los booleanos de
  JavaScript como número; comparar con `true` daba error (ya pasaba con
  `?tactil` en `control_tactil.gd`).
- **Táctil:** tocar el retrato de un lado en la barra del equipo pasa a ese
  personaje (lo mismo que Q y E; `barra_equipo.gd` dice qué retrato se ha
  tocado, con el grupo nuevo `barra_equipo`), y un botón del equipo (el panel
  de la C) debajo del de pausa.

### Métodos de test

- La web exportada aquí, servida en `localhost` y abierta en el navegador
  con tamaño de móvil (812x375): las tarjetas de dificultad, las novedades,
  OPCIONES y los botones táctiles en la partida (`?tactil`), con capturas.
- Un script en headless: tocar el retrato izquierdo da -1, el derecho 1, el
  centro y fuera 0; `personaje_anterior` cambia de personaje y `ver_equipo`
  abre el panel.
- `/validar` y el simulador (minuto 10: 600 s, 71 eliminados, como antes).
- **Sin probar:** la pantalla completa (el navegador de pruebas no la deja ni
  con un toque de verdad) y la cuenta en la web con una cuenta real: se
  comprueban en el móvil cuando salga la versión.
