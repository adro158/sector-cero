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
`version.json`.

Si una versión cambia algo de `project.godot` (autoloads, controles, ventana) o
añade un `class_name` nuevo, hay que subir `EJECUTABLE_MINIMO` en
`projecte/globales/version.gd` a esa versión: eso no viaja en el `.pck` y el
juego pedirá descargar el ejecutable entero.

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

## Ramas

Hay un único repositorio con dos ramas fijas que no se borran nunca:

- `main` — donde trabaja Adam. Es la versión del juego que se entrega.
- `feature/alan-arena-hud` — donde trabaja Alan.

Como cada uno tiene sus propios ficheros, las dos ramas casi nunca chocan.

**Al empezar la clase**, cada uno se baja lo que subió el otro.

Adam:

```
git switch main
git pull
git merge origin/feature/alan-arena-hud
```

Alan:

```
git switch feature/alan-arena-hud
git pull
git merge origin/main
```

Adam comprueba que el juego arranca después de fusionar. Si lo de Alan rompe
algo, no se sube: se avisa para que lo arregle en su rama.

**Al terminar la clase**, cada uno commitea sus ficheros y sube su rama:

```
git status
git add <tus ficheros>
git commit -m "tipo(ámbito): descripción"
git push
```

Antes del commit, mirar `git status`: Godot reescribe a veces ficheros al abrir
el proyecto. Si sale modificado un fichero del otro que no has tocado, se
descarta con `git restore <fichero>`.

**Para ver en qué punto estáis**, este comando dibuja el historial de las dos
ramas:

```
git log --graph --oneline --all
```

## Las tres reglas que importan

1. **`main` siempre tiene que poder ejecutarse.** Es la versión que se entrega:
   si entra algo roto, el otro se lo baja y se queda bloqueado.
2. **Cada uno commitea solo sus ficheros.** `projecte/escenas/juego.tscn` y
   `projecte/project.godot` son de Adam: si Alan necesita cambiarlos, se lo pide.
3. **Sincronizar en cada clase.** Bajar lo del otro al empezar y subir lo propio
   al terminar. Cuanto más tiempo pasan las ramas sin juntarse, más duele
   hacerlo.

## Sobre la autoría

Los commits guardan quién los escribió, y eso no cambia aunque los suba o los
fusione el otro. En el historial siempre queda registrado qué hizo cada uno.

## Regla de oro con las escenas

Los ficheros `.tscn` se fusionan mal en Git. Nunca editamos la misma escena a la
vez. La arquitectura ya lo evita: cada uno tiene sus escenas y la comunicación
pasa por el `BusEventos` y por nombres de grupo, no por referencias directas
entre nodos.
