# Sector Cero — instrucciones para Claude

@GEMINI.md

Lo de arriba es el contexto compartido con Alan: qué es el juego, reparto de
ficheros, BusEventos, grupos, MultiMesh, idioma y estilo. Lo que sigue son normas
solo para Claude. Quien trabaja contigo es Adam.

## Al empezar cada sesión

Adam trabaja desde dos sitios (instituto y casa) y cada chat nuevo empieza sin
memoria. Todo el contexto vive en este repositorio: léelo entero antes de nada.

1. Leer `documentacio/bitacora.md` entera: decisiones con su porqué, problemas
   resueltos, métodos de test y en qué punto se quedó.
2. Leer `documentacio/requisitos_y_estado.md`: qué pide el profesor, qué está
   hecho, qué falta y las decisiones vigentes. El texto original del enunciado
   está en `documentacio/enunciat.md` (fuente de verdad) y la plantilla del primer
   informe en `documentacio/primer_seguiment.md`: leerlos cuando la tarea toque
   requisitos, entregables o el informe.
3. Leer `documentacio/planificacion.md` (reparto de fitas y casillas).
4. Contrastarlo todo con `git log --graph --oneline --all` y `git status`. Si hay
   commits que la bitácora no recoge, decírselo a Adam.
5. Convención de commits y flujo de Git: `README.md`.

Después, si Adam no ha pedido otra cosa concreta, darle un informe corto de
arranque: qué piden, qué está hecho, qué falta (por prioridad), el siguiente
paso y cualquier discrepancia entre bitácora, planificación y Git.

Ignorar `projecte/.godot/`: es caché regenerable.

## Frases clave de Adam

Estas dos frases son órdenes completas: Adam no tiene que explicar nada más.

### "Es un día nuevo" (o "empezamos", "nueva sesión")

Bajar lo de Adam y lo de Alan y ponerse al día:

1. `git status`: si hay cambios sin commitear, avisar a Adam antes de seguir.
2. `git switch main`, `git pull origin main` (lo de Adam, por si trabajó en el otro
   sitio) y `git fetch origin`.
3. Mirar qué ha subido Alan: `git log main..origin/feature/alan-arena-hud --stat`.
4. Fusionar su rama en `main`: `git merge origin/feature/alan-arena-hud`. Si hay
   conflictos, en los ficheros de Adam (`juego.tscn`, `project.godot`, y en general
   todo lo que no sea el audio) se queda la versión de `main`: los cambios ahí
   son reescrituras no intencionadas de Godot. En los de Alan se queda la suya.
5. Validar en headless (ver "Entorno y validación"). Si lo de Alan rompe algo,
   **no se sube**: se avisa a Adam para que Alan lo arregle en su rama.
6. No hacer push en este paso: lo fusionado subirá con el cierre de la sesión.
7. Seguir con la lectura de arriba y dar el informe de arranque, incluyendo qué
   ha aportado Alan.

### "Ya he acabado" (o "no me queda más tiempo de clase", "cierra la sesión")

Dejar todo guardado y **subido a GitHub, sin preguntar**:

1. Hacer todo lo de "Al cerrar cada sesión" (bitácora, planificación,
   `requisitos_y_estado.md`).
2. `git status` y commit **solo de los ficheros de Adam**, con la convención del
   README. Si Godot ha reescrito ficheros de Alan, no se commitean: avisar.
3. `git push origin main`. Esta frase autoriza ese push.
4. Comprobar con `git status` y `git log` que no queda nada sin subir, y decírselo
   a Adam en una línea.

**Nunca**, al cerrar: tocar ni commitear ficheros de Alan, hacer push a
`feature/alan-arena-hud` ni fusionarla. Lo de Alan solo se baja al empezar.

## Propiedad de ficheros: precisiones a GEMINI.md

Desde el 01/10/2026 todo `projecte/` es de Adam, también el audio
(`globales/gestor_audio.gd` y `medios/audio/`), que pasó de Alan a Adam porque
estaba sin empezar y es un requisito mínimo. Lo que lleve Alan a partir de
ahora está pendiente de acordar.

- En `documentacio/`, Alan tiene `assets.md` y `propuesta.md`. `enunciat.md` es
  el texto del profesor y no se edita. Todo lo demás es de Adam: `bitacora.md`,
  `planificacion.md`, `requisitos_y_estado.md`, `primer_seguiment.md`, los
  entregables (`documentacion_tecnica.md`, `manual_usuario.md`, `creditos.md`,
  el informe del seguimiento, el guion de la presentación) y `capturas/`.
- Al cambiar o quitar una señal del bus, actualizar la lista de `GEMINI.md`.
- Nunca editar ficheros de Alan. Si algo suyo debe cambiar, decírselo a Adam para
  que se lo pida.

## Prioridad

Desde el 01/10/2026 están hechos los requisitos mínimos, el MVP y las
ampliaciones (jefe, élites, evoluciones, mapa infinito). No añadir más
contenido sin que Adam lo pida: el tiempo que queda es para la entrega (vídeo,
release, defensa), pulir y corregir lo que salga al probar.

## Estilo, además de lo de GEMINI.md

Adam defiende el código ante un tribunal que puede pedirle explicar o modificar
cualquier línea. Ante la duda, la versión más fácil de explicar.

## Entorno y validación

Adam trabaja desde dos máquinas. Si no sabes en cuál estás, pregúntaselo antes
de lanzar Godot.

- **Instituto:** VM de VirtualBox con GPU virtualizada (OpenGL 4.1 por Mesa
  SVGA3D). Los FPS medidos allí no son fiables: nunca rediseñar por rendimiento
  con esos números. El clon está en la carpeta de trabajo de la sesión.
- **Casa:** Windows 11 con una NVIDIA GeForce RTX 5070 (GPU real: aquí sí se
  puede medir el rendimiento). El clon está en
  `C:\Users\Adam\Desktop\proyecto\sector-cero`. `git` no está en el PATH: se usa
  el de GitHub Desktop,
  `C:\Users\Adam\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe`
  (la carpeta `app-3.6.6` cambia al actualizarse GitHub Desktop).
- Godot, en las dos: `C:\Users\Adam\Desktop\Godot_v4.7.2-stable_win64.exe` (no
  está en el PATH).
- En PowerShell, los argumentos con comas van entre comillas
  (`'capturas=60,150'`); si no, PowerShell los parte en varios.
- Comprobar la API de Godot 4.7.2 antes de usarla.
- Nada se da por bueno sin ejecutarlo en headless:
  1. `--headless --path projecte --import` → errores de análisis
  2. `--headless --path projecte --quit-after N` → errores en ejecución
  3. Instrumentación temporal (autoload que escucha el bus, o script
     `extends SceneTree` con `_initialize()`), borrada antes del commit
- Si falla por una clase global nueva o por rutas antiguas: reimportar; si no
  basta, borrar `projecte/.godot/`.
- Aviso conocido y aceptado: al cerrar Godot con la música sonando sale
  `ObjectDB instances were leaked` y `resources still in use`
  (AudioStreamPlaybackWAV). Es del motor: aparece con cualquier sonido que no
  haya terminado, aunque se pare justo antes de salir, y desaparece si la
  música se para unos fotogramas antes con audio real. No afecta al jugador.
  Cualquier otro error al salir sí hay que investigarlo.
- Los shaders no se compilan en headless: cualquier cambio de shader se
  comprueba con ventana (en casa) y con una captura del viewport.
- Las partidas simuladas, las pruebas y las capturas desconectan
  `GestorGuardado` del bus (diferido, porque en `_initialize` los autoloads aún
  no han hecho su `_ready`) para no ensuciar los récords del jugador.
- Rendimiento: `projecte/herramientas/medir_rendimiento.gd`, con ventana.

## Versiones y actualizaciones

- Una release se publica subiendo una etiqueta (`git tag v0.3` y
  `git push origin v0.3`): la GitHub Action
  `.github/workflows/publicar_release.yml` exporta y la publica. Subir etiquetas
  es publicar: solo cuando Adam lo pida.
- En el código, `Version.ACTUAL` y `config/version` de `project.godot` valen
  `"desarrollo"`: la Action los sustituye por la etiqueta. No cambiarlos a mano.
- `Actualizador` tiene que ser el primer autoload y no puede nombrar la clase
  `Version` (la cargaría antes de aplicar la actualización).
- Si un cambio toca `project.godot` (autoloads, input, ventana) o añade un
  `class_name`, subir `EJECUTABLE_MINIMO` en `globales/version.gd` a la versión
  que se va a publicar: el `.pck` de actualización no lleva esas cosas. Un
  script auxiliar nuevo que no necesite ser global se carga con `preload` y
  sin `class_name` (como `embestida_horda.gd`), y así no hace falta subirlo.
  Se comprueba en `.godot/global_script_class_cache.cfg`: el número de clases
  no debe cambiar.
- Probado de punta a punta con un servidor local que imita la API de GitHub
  (bitácora, sesión 6).
- Tras cualquier cambio de balance, medirlo con el simulador de partidas
  (`projecte/herramientas/simular_partidas.gd`, instrucciones en su cabecera).
  Las semillas son fijas: el mismo comando da las mismas partidas, así que se
  puede comparar el antes y el después.
- Build: `--headless --path projecte --export-release "Windows Desktop"
  ../build/windows/SectorCero.exe` (igual con "Linux"). La exportación funciona
  en headless aunque el driver gráfico de la VM esté caído.

## Git

- Adam trabaja directamente en `main`. Alan, en su rama fija
  `feature/alan-arena-hud`. No se crean ramas por tarea.
- Al empezar la sesión ("es un día nuevo"), fusionar `origin/feature/alan-arena-hud`
  en `main` y validar en headless, como se detalla en "Frases clave de Adam".
- Commitear solo ficheros de Adam. Si `git status` muestra ficheros de Alan
  modificados sin que se hayan tocado (Godot los reescribe al abrir), avisar a
  Adam en vez de commitearlos.
- El único push permitido es `git push origin main`, y solo cuando Adam cierra la
  sesión con "ya he acabado" o equivalente, o lo pide expresamente. Sin push, lo
  hecho aquí no llega al otro sitio (instituto o casa). Nunca se hace push a
  `feature/alan-arena-hud`.

## Al cerrar cada sesión

Entrada nueva en `bitacora.md` con el formato de las anteriores: qué se ha hecho,
decisiones técnicas y por qué, cambios de rumbo, problemas y solución, uso de IA,
métodos de test, estado al cerrar y siguiente paso. Preguntar a Adam las horas de
la sesión y actualizar las acumuladas.

Además, para que el siguiente chat no pierda nada:

- Marcar las casillas que toquen en `planificacion.md`.
- Actualizar `requisitos_y_estado.md`: estados, lista de pendientes y decisiones
  vigentes si ha cambiado alguna.
- Todo decidido en la conversación con su porqué tiene que quedar escrito en la
  bitácora: lo que solo está en el chat se pierde al abrir uno nuevo.

Después, commit y push a `main`, como indica "Ya he acabado" en "Frases clave de
Adam".
