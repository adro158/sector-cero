# Flujo de trabajo — Sector Cero

Cómo trabajamos con Git y cómo se publica una versión. Estaba en el `README.md`;
se trasladó aquí el 02/10/2026 para que la portada del repositorio sea más fácil
de leer.

## Ejecutar desde el código

1. Instala [Godot 4.7.2](https://godotengine.org/download) (versión estándar,
   no la de .NET).
2. Clona el repositorio:
   `git clone https://github.com/adro158/sector-cero`
3. En Godot, *Importar* y elige `projecte/project.godot`.
4. Pulsa F5.

## Publicar una versión

Las releases las crea una GitHub Action
(`.github/workflows/publicar_release.yml`) al subir una etiqueta:

```
git tag v0.6
git push origin v0.6
```

La Action pone la versión de la etiqueta en el juego, exporta Windows y Linux,
y publica la release con el juego completo (`.zip`), el contenido para el botón
ACTUALIZAR (`sector_cero_windows.pck` y `sector_cero_linux.pck`) y
`version.json`. También exporta la versión web y la publica en GitHub Pages
(rama `gh-pages`): https://adro158.github.io/sector-cero/ tiene siempre la
última versión, con controles táctiles en el móvil.

Si una versión cambia algo de `project.godot` (autoloads, controles, ventana)
o añade un `class_name` nuevo, y el contenido no puede funcionar sin ello, hay
que subir `EJECUTABLE_MINIMO` en `projecte/globales/version.gd` a esa versión:
eso no viaja en el `.pck`. Entonces el botón ACTUALIZAR descarga el juego
completo y cambia el ejecutable solo (`globales/instalador_juego.gd`).

Para exportar a mano hacen falta las plantillas de exportación de Godot 4.7.2.
Desde la carpeta `projecte/`:

```
Godot --headless --path . --export-release "Windows Desktop" ../build/windows/SectorCero.exe
Godot --headless --path . --export-release "Linux" ../build/linux/SectorCero.x86_64
```

## Estructura del repositorio

- `projecte/` — proyecto de Godot 4.7.2
- `documentacio/` — memoria y documentación entregable

Los nombres `projecte/` y `documentacio/` están en catalán porque el enunciado
los exige literalmente así. Todo lo demás está en castellano.

Dentro de `projecte/`:

- `globales/` — autoloads: actualizador, bus de eventos, guardado, audio,
  transiciones y filtro CRT, y la versión del juego
- `escenas/` — escenas del juego: arena, jugabilidad, interfaz y menú
- `recursos/` — clases de Resource y los `.tres` de datos (armas, mejoras,
  enemigos, afijos, personajes y oleadas)
- `medios/` — audio, shaders, texturas y sprites
- `herramientas/` — scripts que no forman parte del juego: generan iconos y
  audio, simulan partidas para el balance y miden el rendimiento

## Mensajes de commit

```
<tipo>(<ámbito>): <descripción en imperativo y minúscula>
```

Tipos: `feat` (funcionalidad nueva), `fix` (corrección de un error),
`refactor` (cambio interno sin cambiar el comportamiento), `chore`
(configuración, estructura), `docs` (documentación), `assets` (modelos,
texturas, sonido).

Los tipos se mantienen en inglés porque son etiquetas estándar reconocibles en
cualquier repositorio; la descripción va en castellano.

Ámbitos: `jugador`, `enemigos`, `armas`, `progresion`, `oleadas`, `interfaz`,
`audio`, `guardado`, `arena`, `efectos`, `godot`.

Ejemplos:

```
feat(jugador): añadir movimiento relativo a la cámara con aceleración
fix(enemigos): corregir la fuerza de separación con muchas unidades
chore(godot): registrar autoloads y mapa de input
assets(arena): añadir texturas de suelo y paredes
```

Un commit es una unidad de trabajo con sentido propio. Ni un commit por fichero,
ni un commit semanal con todo mezclado.

## Ramas y Pull Requests (desde el 05/11/2026)

Hasta el 05/11 había dos ramas fijas: Adam trabajaba directamente en `main` y
Alan en `feature/alan-arena-hud`, que Adam fusionaba al empezar cada clase.
Al pasar los dos a Claude Code se cambió a ramas por tarea y Pull Requests,
para poder trabajar a la vez en cosas grandes (como el multijugador) sin
pisarse.

**Nadie sube a `main` directamente.** Cada tarea:

1. **Rama nueva** desde `main` al día, con el nombre de quien la hace:

   ```
   git switch main
   git pull --ff-only
   git switch -c adam/cuentas
   ```

2. **Commits** en esa rama, con la convención de arriba. Antes, `git status`:
   Godot reescribe a veces ficheros al abrir el proyecto. Si sale uno que no
   has tocado, se descarta con `git restore <fichero>`.
3. **Subirla y abrir el PR**:

   ```
   git push -u origin adam/cuentas
   gh pr create --base main
   ```

4. **La Action `comprobar.yml`** importa, arranca y juega dos partidas en cada
   PR. Si sale en rojo, se arregla en la misma rama.
5. **El otro lo revisa** (o su Claude, con `/code-review`).
6. **Lo fusiona quien lo abrió**, con la comprobación en verde:

   ```
   gh pr merge --squash --delete-branch
   ```

Si `main` avanza mientras tu rama está abierta, tráetelo:
`git switch <rama>` y `git merge main`.

**`main` está protegida en GitHub** (desde el 05/11, con el sí de Adam): no
se puede subir a ella ni con permisos de administrador, solo entrar con un
PR, y el PR no se puede fusionar sin la comprobación `comprobar` en verde.
No pide aprobaciones: la revisión del otro (paso 5) es un acuerdo, para que
uno pueda fusionar cuando el otro no esté. Las etiquetas de las versiones
(`/publicar`) y la rama `gh-pages` no están protegidas: publicar sigue igual.
Se cambia en GitHub, Settings → Branches.

Las tareas se apuntan como **issues** de GitHub, asignadas a quien las hace.

## Las reglas que importan

1. **`main` siempre tiene que poder ejecutarse.** Es la versión que se entrega:
   por eso todo entra por un PR comprobado.
2. **Cada sistema tiene un dueño** (`documentacio/equipo/reparto.md`). Si
   necesitas cambiar algo de otro, se pide con una issue o un comentario.
3. **Los ficheros de paso** (`project.godot`, `juego.tscn`,
   `raiz_juego.tscn`, `bus_eventos.gd`, `CLAUDE.md`) van en PR pequeños y
   aparte, que se fusionan antes que el resto.
4. **Ramas cortas.** Cuanto más tiempo pasa una rama sin juntarse con `main`,
   más duele hacerlo: mejor varios PR pequeños que uno enorme.
5. **Las versiones las publica una sola persona** (Adam), desde `main`.

## Sobre la autoría

Los commits guardan quién los escribió, y eso no cambia aunque los suba o los
fusione el otro. En el historial siempre queda registrado qué hizo cada uno.

## Regla de oro con las escenas

Los ficheros `.tscn` se fusionan mal en Git. Nunca editamos la misma escena a la
vez. La arquitectura ya lo evita: cada uno tiene sus escenas y la comunicación
pasa por el `BusEventos` y por nombres de grupo, no por referencias directas
entre nodos.
