# Contexto del proyecto — Sector Cero

Este fichero describe el proyecto para un asistente de IA. Si usas Gemini CLI se
carga solo; si usas Gemini web, pega su contenido al empezar la conversación.

## Qué es

Proyecto académico para la asignatura "Demostra el teu talent": hay que
demostrar capacidades como desarrolladores de videojuegos ante un tribunal que
simula ser un grupo de inversores. Se valora más un proyecto pequeño, coherente y
pulido que uno ambicioso e incompleto.

**Sector Cero** es un "survivors-like" en 2D con vista cenital, ambientado dentro
de un ordenador infectado. El jugador es un proceso antivirus que defiende el
sector de arranque de oleadas de malware. Solo se controla el movimiento; las
armas atacan solas. Los enemigos sueltan fragmentos de datos que dan experiencia,
se sube de nivel y se eligen mejoras. Partida de 10-15 minutos con un jefe final.

Estética: geométrica y de neón sobre fondo oscuro, con post-proceso de CRT y
tipografía monoespaciada.

- Motor: **Godot 4.7.2**, GDScript, **2D**
- Renderizador: **Compatibility** (OpenGL), no Forward+
- Plataforma objetivo: PC (Windows/Linux)

## Reparto de trabajo

Son dos personas y **cada una tiene sus ficheros**.

**Adam** — núcleo de jugabilidad: movimiento del jugador, cámara, sistema de
enemigos (spawning, steering, render con MultiMesh, colisiones), object pooling,
armas y daño, experiencia y niveles, director de oleadas.

**Alan** — interfaz y menús, persistencia, audio, escena de la arena y su
iluminación, recursos artísticos, partículas, shaders de pulido, documentación y
testeo.

### Ficheros de Alan

- `projecte/globales/gestor_audio.gd`
- `projecte/globales/gestor_guardado.gd`
- `projecte/escenas/menu_principal/`
- `projecte/escenas/interfaz/`
- `projecte/escenas/arena/`
- `projecte/medios/` (sprites, texturas, audio, shaders)
- `documentacio/`

### Regla dura

**No editar ficheros del otro.** Todo lo que está en
`projecte/escenas/jugabilidad/` y `projecte/recursos/` es de Adam. Si algo de ahí
necesita cambiar, se pide, no se toca.

Motivo: los ficheros `.tscn` de Godot se fusionan muy mal en Git. Nunca se edita
la misma escena a la vez.

## La frontera entre las dos partes

No nos llamamos directamente entre sistemas. La comunicación pasa por dos sitios.

### 1. El autoload `BusEventos`

```gdscript
signal salud_jugador_cambiada(actual: float, maxima: float)
signal experiencia_ganada(cantidad: int)
signal jugador_subio_nivel(opciones: Array[DatosMejora])
signal mejora_seleccionada(mejora: DatosMejora)
signal enemigo_muerto(posicion: Vector2, tipo_enemigo: String)
signal partida_terminada(estadisticas: Dictionary)
signal juego_pausado(en_pausa: bool)
```

La interfaz **escucha** casi todas y **emite** dos: `mejora_seleccionada` (cuando
el jugador pulsa una de las tres tarjetas al subir de nivel) y `juego_pausado`
(desde el menú de pausa).

Nunca referenciar nodos de la otra persona por `NodePath`: se emite la señal.

Otros autoloads registrados: `EstadoJuego`, `GestorAudio`, `GestorGuardado`.

### 2. Nombres de grupo en la escena de la arena

La escena de la arena que haga Alan debe contener:

- Un `Marker2D` en el grupo **`aparicion_jugador`** — dónde aparece el jugador
- Un `Area2D` con `CollisionShape2D` en el grupo **`limites_arena`** — la zona
  jugable

El código de Adam los busca con `get_tree().get_first_node_in_group(...)`, así
que solo importa el nombre del grupo, no dónde estén colocados.

Hay un ejemplo montado en `projecte/escenas/jugabilidad/arena_pruebas.tscn`.

## Restricción técnica que afecta al arte

Los enemigos de horda se dibujan con `MultiMeshInstance2D` para poder tener 300+
en pantalla a 60 FPS con una sola llamada de dibujado. Eso implica que **todas
las instancias de un tipo comparten una textura y un material**: un solo sprite
por tipo de enemigo, sin fotogramas de animación, todos del mismo tamaño. El
movimiento visual lo pone un shader, no una animación dibujada.

Los élites y el jefe sí son nodos normales y pueden llevar animación, porque hay
pocos a la vez.

La lista completa de assets está en `documentacio/assets.md`.

## Idioma

**Todo en castellano**: nombres de variables, funciones, clases, señales, grupos,
comentarios, mensajes de commit y documentación.

Excepciones:

- `projecte/` y `documentacio/` siguen en catalán porque el enunciado los exige
- Los tipos de commit (`feat`, `fix`, `chore`, `docs`, `refactor`, `assets`)
- Términos sin traducción asentada: `shader`, `pool`, `sprite`
- La API de Godot, que es inglesa: `_ready`, `move_and_slide`, `Vector2`

## Estilo de código

- Simple y legible por encima de listo. En la defensa el tribunal puede preguntar
  por cualquier fragmento y hay que saber explicarlo, modificarlo y justificarlo
- Sin patrones sofisticados ni abstracciones prematuras
- Scripts por debajo de ~200 líneas
- Comentarios solo donde aporten el *porqué*, no el *qué*
- Verificar la API de Godot 4.7.2 antes de usarla; no asumir que algo de
  versiones anteriores sigue igual

## Flujo de trabajo

Convención de commits y ramas: está en el `README.md` de la raíz.

Resumen: `tipo(ámbito): descripción en imperativo`. Hay dos ramas fijas que no
se borran: Adam trabaja en `main`, que siempre tiene que poder ejecutarse, y
Alan trabaja siempre en `feature/alan-arena-hud`. No se crean ramas por tarea.

- Al empezar la clase, Alan trae lo último de Adam a su rama:
  `git switch feature/alan-arena-hud`, `git pull`, `git merge origin/main`.
- Al terminar la clase, commit solo de sus propios ficheros y `git push`. Antes,
  revisar `git status`: si Godot ha reescrito algún fichero de Adam al abrir el
  proyecto, se descarta con `git restore <fichero>`.
- Adam fusiona la rama de Alan en `main` al empezar cada clase.
- `projecte/escenas/juego.tscn` y `projecte/project.godot` son de Adam. Si Alan
  necesita cambiarlos (instanciar su HUD, cambiar la escena inicial, añadir la
  tecla de pausa), se lo pide a Adam.
