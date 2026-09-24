# Sector Cero

Proyecto académico para la asignatura "Demostra el teu talent": una experiencia
interactiva que demuestra nuestras capacidades como desarrolladores de
videojuegos.

## Descripción

Un "survivors-like" en 2D con vista cenital, ambientado dentro de un ordenador
infectado. Encarnas un proceso antivirus que defiende el sector de arranque de
oleadas de malware: bits corruptos, paquetes perdidos, gusanos y procesos
colgados.

El jugador solo controla el movimiento; las armas atacan solas. Los enemigos
sueltan fragmentos de datos que dan experiencia, se sube de nivel y se eligen
mejoras. Partida cronometrada de 10-15 minutos que termina con un jefe final.

Estética: geométrica y de neón sobre fondo oscuro, con post-proceso de CRT y
tipografía monoespaciada.

## Equipo

- **Adam** — núcleo de jugabilidad (movimiento, cámara, enemigos, armas, daño,
  experiencia y niveles, director de oleadas)
- **Alan** — interfaz y menús, persistencia, audio, escena de la arena e
  iluminación, recursos artísticos, partículas, shaders, documentación y testeo

## Estructura del repositorio

- `projecte/` — proyecto de Godot 4.7.2
- `documentacio/` — memoria y documentación entregable

Los nombres `projecte/` y `documentacio/` están en catalán porque el enunciado
los exige literalmente así. Todo lo demás está en castellano.

### Dentro de `projecte/`

- `globales/` — autoloads: bus de eventos, estado del juego, audio y guardado
- `escenas/` — escenas del juego, separadas por responsable
- `recursos/` — clases de Resource y los `.tres` de datos (armas, mejoras,
  enemigos, oleadas)
- `medios/` — sprites, texturas, audio y shaders

## Motor

Godot 4.7.2 (GDScript). Plataforma objetivo: PC (Windows/Linux).
Renderizador: **Compatibility** (OpenGL), no Forward+.

## Flujo de trabajo

### Mensajes de commit

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
`audio`, `guardado`, `arena`, `godot`.

Ejemplos:

```
feat(jugador): añadir movimiento relativo a la cámara con aceleración
fix(enemigos): corregir la fuerza de separación con muchas unidades
chore(godot): registrar autoloads y mapa de input
assets(arena): añadir texturas de suelo y paredes
```

Un commit es una unidad de trabajo con sentido propio. Ni un commit por fichero,
ni un commit semanal con todo mezclado.

### Ramas

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

**Al cerrar cada fita**, Adam la marca en el historial con una etiqueta:

```
git tag fita-2
git push --tags
```

**Para ver en qué punto estáis**, este comando dibuja el historial de las dos
ramas:

```
git log --graph --oneline --all
```

### Las tres reglas que importan

1. **`main` siempre tiene que poder ejecutarse.** Es la versión que se entrega:
   si entra algo roto, el otro se lo baja y se queda bloqueado.
2. **Cada uno commitea solo sus ficheros.** `projecte/escenas/juego.tscn` y
   `projecte/project.godot` son de Adam: si Alan necesita cambiarlos, se lo pide.
3. **Sincronizar en cada clase.** Bajar lo del otro al empezar y subir lo propio
   al terminar. Cuanto más tiempo pasan las ramas sin juntarse, más duele
   hacerlo.

### Sobre la autoría

Los commits guardan quién los escribió, y eso no cambia aunque los suba o los
fusione el otro. En el historial siempre queda registrado qué hizo cada uno.

### Regla de oro con las escenas

Los ficheros `.tscn` se fusionan mal en Git. Nunca editamos la misma escena a la
vez. La arquitectura ya lo evita: cada uno tiene sus escenas y la comunicación
pasa por el `BusEventos` y por nombres de grupo, no por referencias directas
entre nodos.
