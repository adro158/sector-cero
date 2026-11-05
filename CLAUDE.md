# Sector Cero — instrucciones para Claude Code

Este repositorio lo trabajan **dos personas, Adam y Alan, cada una con su
Claude Code**. Lo de aquí vale para los dos.

@documentacio/equipo/contexto.md

Lo de arriba es el juego por dentro: arquitectura, BusEventos, grupos,
MultiMesh, idioma y estilo. Lo que sigue es cómo se trabaja.

## Con quién trabajas

En cada ordenador hay un `CLAUDE.local.md` (no se sube a GitHub) con una línea
que dice quién es la persona y carga su ficha:

```
Soy Adam. @documentacio/equipo/adam.md
```

La ficha (`documentacio/equipo/adam.md` o `alan.md`) dice sus máquinas, de qué
sistemas es dueño y sus costumbres. **Si no hay `CLAUDE.local.md`, pregunta si
eres de Adam o de Alan y créalo** (en la raíz del repo) antes de nada.

## Trabajo en equipo (desde el 05/11/2026)

Todo el detalle, en `documentacio/flujo_de_trabajo.md`. Lo esencial:

- **`main` siempre funciona y nadie sube a ella directamente.** Cada tarea va
  en su rama, con el nombre de quien la hace: `adam/cuentas`, `alan/red-lobby`.
  Entra en `main` con un **Pull Request**.
- **Cada PR lo comprueba una GitHub Action** (`.github/workflows/comprobar.yml`):
  import en headless, arranque y una partida del simulador. Con la comprobación
  en rojo no se fusiona.
- **El PR lo mira el otro** (o su Claude, con `/code-review`) antes de
  fusionar. Lo fusiona quien lo abrió.
- **Cada sistema tiene dueño** (`documentacio/equipo/reparto.md`). No se
  editan ficheros de un sistema ajeno: se pide con una issue o un comentario.
- **Ficheros de paso**: `projecte/project.godot`, `escenas/juego.tscn`,
  `escenas/jugabilidad/raiz_juego.tscn` y `globales/bus_eventos.gd` los toca
  todo el mundo y se fusionan mal. Los cambios en ellos van en **un PR
  pequeño y aparte**, que se fusiona antes que el resto.
- **Primero el contrato**: si una tarea necesita señales nuevas en el bus, se
  añaden (y se apuntan en `contexto.md`) en ese PR pequeño. Así cada uno
  programa contra ellas sin esperar al otro.
- **Las tareas son issues de GitHub**, asignadas a quien las hace. Al empezar,
  mira `gh issue list` y `gh pr list` para saber qué hay en marcha.
- **Bitácora: un fichero por sesión** en `documentacio/bitacora/`
  (`AAAA-MM-DD_persona_tema.md`). `documentacio/bitacora.md` es la historia
  hasta la sesión 21 y ya no se toca.

## Comandos del equipo (skills de `.claude/skills/`)

- `/dia-nuevo` — al empezar: ponerse al día con `main`, PRs, issues y la
  bitácora, validar y dar el informe de arranque.
- `/validar` — las comprobaciones en headless de siempre.
- `/cerrar` — al acabar: bitácora de la sesión, commit, push de la rama y su PR.
- `/publicar` — subir una versión (solo quien la ficha del equipo diga).

Las frases de cada persona («es un día nuevo», «ya he acabado»...) llaman a
estos comandos; están en su ficha.

## Al empezar cada sesión

Cada chat nuevo empieza sin memoria: todo el contexto vive en el repositorio.
Antes de nada (o con `/dia-nuevo`):

1. Las últimas entradas de `documentacio/bitacora/` y, si hace falta historia,
   `documentacio/bitacora.md`.
2. `documentacio/requisitos_y_estado.md`: qué pide el profesor, qué está hecho
   y qué falta. El enunciado original es `documentacio/enunciat.md` (fuente de
   verdad); no se edita nunca.
3. `documentacio/planificacion.md` y `documentacio/equipo/reparto.md`.
4. `git fetch --prune`, `git log --oneline origin/main -10`, `gh pr list` y
   `gh issue list`.

Ignorar `projecte/.godot/`: es caché regenerable.

## Prioridad

Desde el 01/10/2026 están hechos los requisitos mínimos, el MVP y las
ampliaciones (jefe, élites, evoluciones, mapa infinito). Lo que se añade ahora
lo piden Adam o Alan; el vídeo y el ensayo de la defensa van al final de todo,
con el juego acabado (decisión de Adam, 05/11).

## Estilo, además de lo de contexto.md

Adam y Alan defienden el código ante un tribunal que puede pedirles explicar o
modificar cualquier línea. Ante la duda, la versión más fácil de explicar.

## Entorno y validación

Las rutas de cada máquina están en la ficha de cada persona. Si no sabes en cuál
estás, pregúntalo antes de lanzar Godot.

- Godot 4.7.2 (no está en el PATH: la ruta, en la ficha).
- En PowerShell, los argumentos con comas van entre comillas
  (`'capturas=60,150'`); si no, PowerShell los parte en varios.
- Comprobar la API de Godot 4.7.2 antes de usarla.
- Nada se da por bueno sin ejecutarlo en headless (`/validar`):
  1. `--headless --path projecte --import` → errores de análisis
  2. `--headless --path projecte --quit-after N` → errores en ejecución. Solo
     carga el menú: para los scripts de la partida, cargar también
     `escenas/juego.tscn` (por ejemplo, una partida del simulador)
  3. Instrumentación temporal (autoload que escucha el bus, o script
     `extends SceneTree` con `_initialize()`), fuera del repo o borrada antes
     del commit
- Si falla por una clase global nueva o por rutas antiguas: reimportar; si no
  basta, borrar `projecte/.godot/`.
- Aviso conocido y aceptado: al cerrar Godot con la música sonando sale
  `ObjectDB instances were leaked` y `resources still in use`
  (AudioStreamPlaybackWAV). Es del motor y no afecta al jugador. Cualquier otro
  error al salir sí hay que investigarlo.
- Los shaders no se compilan en headless: cualquier cambio de shader se
  comprueba con ventana y con una captura del viewport.
- Las partidas simuladas, las pruebas y las capturas desconectan
  `GestorGuardado` del bus (diferido, porque en `_initialize` los autoloads aún
  no han hecho su `_ready`) para no ensuciar los récords del jugador. Si una
  prueba cambia opciones o cuentas, copia antes los ficheros de `user://` y los
  deja como estaban.
- Rendimiento: `projecte/herramientas/medir_rendimiento.gd`, con ventana y en
  una máquina con GPU de verdad.
- Las cuentas (Supabase) se prueban contra un servidor local que imita su API,
  con el argumento `supabase=http://localhost:...` (solo en depuración).

## Versiones y actualizaciones

- Una release se publica subiendo una etiqueta (`git tag v1.15` y
  `git push origin v1.15`) **desde `main`**: la GitHub Action
  `.github/workflows/publicar_release.yml` exporta y la publica. Subir etiquetas
  es publicar: solo cuando lo pida quien publica (ficha del equipo), con `/publicar`.
- Antes de la etiqueta, escribir `documentacio/novedades/<versión>.txt`: es lo
  que enseña el lanzador.
- En el código, `Version.ACTUAL` y `config/version` de `project.godot` valen
  `"desarrollo"`: la Action los sustituye por la etiqueta. No cambiarlos a mano.
- `Actualizador` tiene que ser el primer autoload y no puede nombrar la clase
  `Version`. Un cambio en `actualizador.gd` solo llega con un ejecutable nuevo,
  pero eso **no** obliga a subir `EJECUTABLE_MINIMO`: solo hay que subirlo si el
  contenido nuevo no puede funcionar con el actualizador viejo (error del 06/10,
  bitácora).
- Si un cambio toca `project.godot` (autoloads, input, ventana) o añade un
  `class_name`, subir `EJECUTABLE_MINIMO` en `globales/version.gd` a la versión
  que se va a publicar: el `.pck` de actualización no lleva esas cosas. Salvo
  que el contenido sepa arreglárselas: las teclas que faltan se añaden al
  empezar (`teclas_antiguas.gd`), y los scripts nuevos que no necesitan ser
  globales se cargan con `preload` y sin `class_name`, o los crea `Transicion`
  al arrancar (como `entrada.gd` y `cuenta.gd`). Se comprueba en
  `.godot/global_script_class_cache.cfg`: el número de clases no debe cambiar
  (16 el 05/11).
- **Desde la v1.5, el lanzador** (`lanzador/`, otro proyecto de Godot): el
  instalador de Windows pone el lanzador y el juego sin contenido; al elegir una
  versión, el lanzador baja su `.pck` y lo copia como `juego/SectorCero.pck`.
  Abierto desde el lanzador (`--desde-lanzador`), el juego no busca
  actualizaciones ni enseña ACTUALIZAR ni VERSIONES. Las versiones antiguas no
  se recompilan: todas son de Godot 4.7.2. El zip del lanzador de Linux no puede
  acabar en `_linux.zip`. Desde la v1.8 no se publica el juego suelto.
- Tras cualquier cambio de balance, medirlo con el simulador
  (`projecte/herramientas/simular_partidas.gd`, instrucciones en su cabecera).
  Las semillas son fijas: el mismo comando da las mismas partidas. Si se sigue
  cambiando código mientras corre, medir en una copia aparte
  (`git worktree add <carpeta> <commit>`).
- Build: `--headless --path projecte --export-release "Windows Desktop"
  ../build/windows/SectorCero.exe` (igual con "Linux").

## Al cerrar cada sesión (`/cerrar`)

- Un fichero nuevo en `documentacio/bitacora/` con: qué se ha hecho,
  decisiones técnicas y por qué, cambios de rumbo, problemas y solución, uso de
  IA, métodos de test, estado al cerrar, siguiente paso y las horas (preguntar a
  la persona; las acumuladas, sumando las de la última entrada).
- Marcar lo que toque en `planificacion.md` y poner al día
  `requisitos_y_estado.md` (en la misma rama).
- Todo lo decidido en la conversación, con su porqué, tiene que quedar escrito:
  lo que solo está en el chat se pierde al abrir uno nuevo.
- Commit en la rama de la tarea, `git push -u origin <rama>` y el PR abierto o
  puesto al día (`gh pr create` / `gh pr view`). No se fusiona sin la
  comprobación en verde.

## Cuándo usar subagentes (decídelo tú)

Antes de empezar cualquier tarea, valora en una frase si compensa repartirla.
Los subagentes gastan mucho límite de uso, así que por defecto NO los uses.

NO uses subagentes cuando la tarea toca un solo archivo o sistema, es un cambio
pequeño, las partes dependen unas de otras o hay que tocar el mismo archivo
desde varios sitios (escena .tscn, project.godot...).

SÍ, cuando la tarea tiene 3 o más partes independientes y lo bastante grandes,
para buscar por todo el repo sin llenar el contexto o para revisar el código
por áreas en paralelo. Cada subagente recibe un encargo autocontenido; nunca
dos editando el mismo archivo; al terminar, revisa tú el resultado. Si dudas,
no los uses y pregunta.
