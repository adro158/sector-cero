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

Hay un único repositorio. Cada uno trabaja en su propia rama y se fusiona a
`main` cada día o dos. Así los dos podemos avanzar a la vez sin pisarnos.

**Al empezar a trabajar**, traer lo que haya subido el otro y crear la rama del
día:

```
git switch main
git pull
git switch -c feature/<ámbito>-<descripción-corta>
```

Por ejemplo `feature/jugador-proyectiles` o `feature/interfaz-hud`.

**Mientras trabajas**, commits normales en tu rama. No molestan a nadie porque
`main` no se entera.

```
git add <ficheros>
git commit -m "feat(ámbito): descripción"
```

**Para subir la rama** la primera vez:

```
git push -u origin feature/<ámbito>-<descripción-corta>
```

**Cuando la funcionalidad ya va**, primero se trae `main` a tu rama y se
resuelven ahí los conflictos, si los hay. Nunca al revés: así `main` nunca queda
a medias.

```
git switch main
git pull
git switch feature/<tu-rama>
git merge main
```

**Y por último se fusiona hacia `main`** con `--no-ff`, para que el historial
muestre la funcionalidad agrupada en lugar de una fila de commits sueltos:

```
git switch main
git merge --no-ff feature/<tu-rama>
git push
```

Después, la rama ya fusionada se puede borrar con
`git branch -d feature/<tu-rama>`.

**Para ver en qué punto estáis**, este comando dibuja el historial de las dos
ramas:

```
git log --graph --oneline --all
```

### Las tres reglas que importan

1. **`main` siempre tiene que poder ejecutarse.** Es la versión buena: si
   alguien fusiona algo roto, el otro se lo baja y se queda bloqueado.
2. **Los conflictos se resuelven en tu rama, nunca en `main`.** Por eso se trae
   `main` hacia tu rama antes de fusionar, y no al revés.
3. **Fusionar cada día o dos.** Cuanto más tiempo vive una rama separada, más
   diverge y más duele juntarla.

### Sobre la autoría

Los commits guardan quién los escribió, y eso no cambia aunque los suba o los
fusione el otro. En el historial siempre queda registrado qué hizo cada uno.

### Regla de oro con las escenas

Los ficheros `.tscn` se fusionan mal en Git. Nunca editamos la misma escena a la
vez. La arquitectura ya lo evita: cada uno tiene sus escenas y la comunicación
pasa por el `BusEventos` y por nombres de grupo, no por referencias directas
entre nodos.
