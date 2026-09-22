# Vampire Survivors 2D

Proyecto académico para la asignatura "Demostra el teu talent": una experiencia
interactiva que demuestra nuestras capacidades como desarrolladores de
videojuegos.

## Descripción

Un "survivors-like" en 2D con vista cenital. El jugador solo
controla el movimiento; las armas atacan solas. Oleadas de enemigos que persiguen
al jugador, sueltan gemas de experiencia, se sube de nivel y se eligen mejoras.
Partida cronometrada de 10-15 minutos con un jefe final.

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

- `main` siempre debe poder ejecutarse. No se trabaja directamente sobre ella.
- Cada funcionalidad va en su rama: `feature/<ámbito>-<descripción-corta>`,
  por ejemplo `feature/jugador-movimiento` o `feature/interfaz-hud`.
- Cada uno trabaja solo en sus propias ramas.
- Antes de fusionar: traer `main` a tu rama, resolver los conflictos **ahí**, y
  después fusionar hacia `main` con `--no-ff` para que el historial muestre la
  funcionalidad agrupada.
- Fusionar hacia `main` cada día o dos, nunca una vez por semana.

### Regla de oro con las escenas

Los ficheros `.tscn` se fusionan mal en Git. Nunca editamos la misma escena a la
vez. La arquitectura ya lo evita: cada uno tiene sus escenas y la comunicación
pasa por el `BusEventos` y por nombres de grupo, no por referencias directas
entre nodos.
