# Sector Cero — instrucciones para Claude

@GEMINI.md

Lo de arriba es el contexto compartido con Alan: qué es el juego, reparto de
ficheros, BusEventos, grupos, MultiMesh, idioma y estilo. Lo que sigue son normas
solo para Claude. Quien trabaja contigo es Adam.

## Al empezar cada sesión

1. Leer `documentacio/bitacora.md` entera: decisiones con su porqué, problemas
   resueltos, métodos de test y en qué punto se quedó.
2. Contrastarla con `git log --graph --oneline --all` y `git status`. Si hay
   commits que la bitácora no recoge, decírselo a Adam.
3. Convención de commits y flujo de Git: `README.md`.

Ignorar `projecte/.godot/`: es caché regenerable.

## Propiedad de ficheros: precisiones a GEMINI.md

Decididas por Adam el 24/09/2026:

- En `documentacio/`, Adam mantiene `bitacora.md` y `planificacion.md`. El resto
  de la carpeta es de Alan.
- `globales/bus_eventos.gd`, `globales/estado_juego.gd`, `escenas/juego.tscn` y
  `project.godot` son de Adam. Cambiar una señal del bus o un grupo es cambiar el
  contrato: se acuerda antes con Alan y se actualiza `GEMINI.md`.
- Nunca editar ficheros de Alan. Si algo suyo debe cambiar, decírselo a Adam para
  que se lo pida.

## Prioridad

Primero los requisitos mínimos del enunciado y el MVP de la propuesta. Las
ampliaciones (jefe, élites, evoluciones, más armas) solo si sobra tiempo.

## Estilo, además de lo de GEMINI.md

Adam defiende el código ante un tribunal que puede pedirle explicar o modificar
cualquier línea. Ante la duda, la versión más fácil de explicar.

## Entorno y validación

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

## Git

- Adam trabaja directamente en `main`. Alan, en su rama fija
  `feature/alan-arena-hud`. No se crean ramas por tarea.
- Al empezar la sesión, si Adam lo pide, fusionar `origin/feature/alan-arena-hud`
  en `main` y validar en headless antes de subir nada.
- Commitear solo ficheros de Adam. Si `git status` muestra ficheros de Alan
  modificados sin que se hayan tocado (Godot los reescribe al abrir), avisar a
  Adam en vez de commitearlos.
- No hacer push sin que Adam lo diga.

## Al cerrar cada sesión

Entrada nueva en `bitacora.md` con el formato de las anteriores: qué se ha hecho,
decisiones técnicas y por qué, cambios de rumbo, problemas y solución, uso de IA,
métodos de test, estado al cerrar y siguiente paso. Preguntar a Adam las horas de
la sesión y actualizar las acumuladas. Después, commit.
