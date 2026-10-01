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

## Propiedad de ficheros: precisiones a GEMINI.md

Desde el 30/09/2026 Alan solo lleva el audio (`globales/gestor_audio.gd` y
`medios/audio/`). Todo lo demás de `projecte/`, incluida la interfaz, los menús,
la arena y el arte, es de Adam.

- En `documentacio/`, Adam mantiene `bitacora.md`, `planificacion.md`,
  `requisitos_y_estado.md` y `primer_seguiment.md`. `enunciat.md` es el texto del
  profesor y no se edita. El resto de la carpeta es de Alan.
- Cambiar o quitar una señal del bus afecta al audio de Alan: se le avisa y se
  actualiza `GEMINI.md`. Añadir una señal nueva no le rompe nada.
- Nunca editar ficheros de Alan. Si algo suyo debe cambiar, decírselo a Adam para
  que se lo pida.

## Prioridad

Primero los requisitos mínimos del enunciado y el MVP de la propuesta. Las
ampliaciones (jefe, élites, evoluciones, más armas) solo si sobra tiempo.

## Estilo, además de lo de GEMINI.md

Adam defiende el código ante un tribunal que puede pedirle explicar o modificar
cualquier línea. Ante la duda, la versión más fácil de explicar.

## Entorno y validación

Lo de este apartado describe la máquina del **instituto**. Adam también trabaja
desde casa, donde la ruta de Godot, el sistema operativo y la GPU pueden ser
distintos: si no sabes en cuál estás, pregúntaselo antes de lanzar Godot y no
asumas estas rutas.

- VM de VirtualBox con GPU virtualizada (OpenGL 4.1 por Mesa SVGA3D). Los FPS
  medidos aquí no son fiables: nunca rediseñar por rendimiento con estos números.
- Godot: `C:\Users\Adam\Desktop\Godot_v4.7.2-stable_win64.exe` (no está en el PATH).
- Comprobar la API de Godot 4.7.2 antes de usarla.
- Nada se da por bueno sin ejecutarlo en headless:
  1. `--headless --path projecte --import` → errores de análisis
  2. `--headless --path projecte --quit-after N` → errores en ejecución
  3. Instrumentación temporal (autoload que escucha el bus, o script
     `extends SceneTree` con `_initialize()`), borrada antes del commit
- Si falla por una clase global nueva o por rutas antiguas: reimportar; si no
  basta, borrar `projecte/.godot/`.
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
- Al empezar la sesión, si Adam lo pide, fusionar `origin/feature/alan-arena-hud`
  en `main` y validar en headless antes de subir nada.
- Commitear solo ficheros de Adam. Si `git status` muestra ficheros de Alan
  modificados sin que se hayan tocado (Godot los reescribe al abrir), avisar a
  Adam en vez de commitearlos.
- No hacer push sin que Adam lo diga. Al cerrar la sesión, preguntarle si quiere
  subir: sin push, lo hecho aquí no llega al otro sitio (instituto o casa).

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

Después, commit.
