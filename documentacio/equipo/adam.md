# Ficha de Adam

La carga el `CLAUDE.local.md` de los ordenadores de Adam:

```
Soy Adam. @documentacio/equipo/adam.md
```

## Cómo trabajar con Adam

- Respóndele en castellano y en tono informal. Si pide algo corto, que sea
  corto.
- Es dueño de casi todo el juego (`reparto.md`) y quien **publica las
  versiones** (`/publicar`).
- Trabaja desde dos sitios (instituto y casa): todo lo que se decida tiene que
  quedar en el repositorio, en commits y en la bitácora.

## Sus frases clave

Son órdenes completas: no tiene que explicar nada más.

- **«Es un día nuevo»** (o «empezamos», «estoy en clase», «estoy en el insti»)
  → `/dia-nuevo`.
- **«Estoy en casa»** (o «mira lo que hay y pruébalo») → `/dia-nuevo` y,
  como en casa hay GPU de verdad, probar con ventana: capturas de lo cambiado,
  el simulador y `medir_rendimiento.gd`. Lo que haya que jugar a mano, dárselo
  como una lista corta paso a paso.
- **«Ya he acabado»** (o «cierra la sesión», «no me queda más tiempo») →
  `/cerrar`, **sin preguntar**: esta frase autoriza el push de su rama y abrir o
  poner al día el PR. Pregunta las horas de la sesión.
- **«Publica la vX»** → `/publicar`.

## Sus máquinas

- **Instituto:** VM de VirtualBox con GPU virtualizada (OpenGL 4.1 por Mesa
  SVGA3D). Los FPS medidos allí no son fiables: nunca rediseñar por
  rendimiento con esos números. `git` está en el PATH. No hay Python.
- **Casa:** Windows 11 con una NVIDIA GeForce RTX 5070 (aquí sí se puede medir
  el rendimiento). El clon está en `C:\Users\Adam\Desktop\proyecto\sector-cero`.
  `git` no está en el PATH: se usa el de GitHub Desktop,
  `C:\Users\Adam\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe`
  (la carpeta `app-3.6.6` cambia al actualizarse GitHub Desktop). `gh`,
  desde el 06/11, en `C:\Program Files\GitHub CLI\gh.exe`, con la cuenta de
  Adam; necesita `git` en el PATH, así que antes de usarlo se añaden las dos
  carpetas al PATH de la sesión. En su
  monitor de 240 Hz el driver de NVIDIA no respeta el vsync (sesión 19).
- **Nube** (Claude Code en claude.ai/code): un contenedor Linux que trabaja en
  su propia rama `claude/...`. Godot no viene instalado: se baja el de Linux de
  la release oficial de 4.7.2. Con ventana, `xvfb-run` y `--rendering-driver
  opengl3`, esperando fotogramas con `--fixed-fps 60`. Sin audio.
- Godot, en las dos de Windows:
  `C:\Users\Adam\Desktop\Godot_v4.7.2-stable_win64.exe` (no está en el PATH).
