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
se sube de nivel y se eligen mejoras. Partida de 10 minutos más un jefe final.

Elementos propios: el malware se hace resistente a la herramienta que más daño
le hace (resistencia adaptativa), tres personajes con una herramienta cada uno
que se intercambian en plena partida, evoluciones de las herramientas, élites
con afijos al azar y un mapa infinito.

Estética: geométrica y de neón sobre fondo oscuro, con post-proceso de CRT y
tipografía monoespaciada.

- Motor: **Godot 4.7.2**, GDScript, **2D**
- Renderizador: **Compatibility** (OpenGL), no Forward+
- Plataforma objetivo: PC (Windows/Linux)

## Reparto de trabajo

Son dos personas y **cada una tiene sus ficheros**.

**Adam** — todo `projecte/`: jugabilidad (jugador, enemigos, élites, jefe,
armas, experiencia, oleadas), interfaz y menús, persistencia, audio, arena,
efectos y arte.

**Alan** — sin ficheros en `projecte/` desde el 01/10/2026. Lo que lleve a
partir de ahora está pendiente de acordar.

Historia del reparto: hasta el 30/09/2026 Alan llevaba la interfaz, la
persistencia, la arena, el arte y el audio; ese día la interfaz, la
persistencia, la arena y el arte pasaron a Adam, y el 01/10/2026 también el
audio, que estaba sin empezar y es un requisito mínimo. Lo que Alan hizo (la
primera arena, el shader de la rejilla, el primer HUD, el módulo RAM) sigue
siendo suyo en el historial de Git.

### Ficheros de Alan

- `documentacio/assets.md` y `documentacio/propuesta.md`

### Regla dura

**No editar ficheros del otro.** Si algo del otro necesita cambiar, se pide, no
se toca.

Motivo: los ficheros `.tscn` de Godot se fusionan muy mal en Git. Nunca se edita
la misma escena a la vez.

## La frontera entre sistemas

Los sistemas no se llaman directamente entre ellos. La comunicación pasa por
dos sitios.

### 1. El autoload `BusEventos`

```gdscript
signal salud_jugador_cambiada(actual: float, maxima: float)
signal experiencia_ganada(cantidad: int)
signal experiencia_cambiada(actual: int, necesaria: int, nivel: int)
signal tiempo_partida(segundos: float, duracion: float)
signal personaje_cambiado(actual: DatosPersonaje, arma: DatosArma, siguiente: DatosPersonaje, espera: float)
signal arma_evolucionada(arma: DatosArma)
signal jugador_subio_nivel(opciones: Array[DatosMejora])
signal mejora_seleccionada(mejora: DatosMejora)
signal enemigo_muerto(posicion: Vector2, tipo_enemigo: String)
signal herramienta_usada(arma: DatosArma)
signal jefe_aparecio
signal elite_aparecio(descripcion: String)
signal elite_exploto(posicion: Vector2)
signal partida_terminada(estadisticas: Dictionary)
signal juego_pausado(en_pausa: bool)
```

La interfaz **escucha** casi todas y **emite** dos: `mejora_seleccionada` (cuando
el jugador pulsa una de las tres tarjetas al subir de nivel) y `juego_pausado`
(desde el menú de pausa).

Detalles que la interfaz tiene que respetar:

- **Subir de nivel.** La jugabilidad pausa el juego antes de emitir
  `jugador_subio_nivel` y lo reanuda al recibir `mejora_seleccionada`. El panel
  de mejoras necesita `process_mode = Always` para funcionar en pausa, debe
  emitir `mejora_seleccionada` con una de las `opciones` recibidas y mostrar sus
  `nombre` y `descripcion`. Si se suben varios niveles de golpe, la señal vuelve
  a llegar justo después de cada elección. Si hay una evolución disponible,
  llega la primera.
- **Pausa.** El menú de pausa emite `juego_pausado(true/false)` y es la
  jugabilidad quien pausa el árbol. Se ignora mientras se elige mejora o tras el
  fin de partida. La acción de input es `pausar` (Esc, P y Start del mando).
- **Fin de partida.** `partida_terminada` llega con el juego ya pausado. Claves
  del diccionario: `victoria` (bool), `tiempo` (float, en segundos), `nivel`
  (int), `eliminados` (int). Al cumplirse `duracion_partida`
  (`recursos/oleadas/datos/config_principal.tres`, 10 minutos) deja de
  aparecer horda y llega el jefe final; se gana al derrotarlo.

Nunca referenciar nodos de otro sistema por `NodePath`: se emite la señal.

**El audio** (`GestorAudio`) no lo llama nadie: escucha el bus y los cambios de
escena y decide qué suena. **La persistencia** (`GestorGuardado`) escucha
`partida_terminada` para los récords y guarda las opciones.

Autoloads registrados: `BusEventos`, `GestorGuardado`, `GestorAudio`,
`Transicion` (fundido entre escenas) y `EfectoCRT` (filtro de pantalla).

### 2. Nombres de grupo

- `aparicion_jugador` — un `Marker2D` en la escena de la arena: dónde aparece el
  jugador. El mapa es infinito: la arena ya no declara límites.
- `jugador` — el jugador.
- `objetivos` — todo lo que recibe daño de las armas: los tres gestores de la
  horda, los élites y el jefe. Todos tienen `danar_en_area` y `mas_cercano`.
- `gestor_enemigos` — los tres gestores de la horda.
- `elites` — los élites, ocultos hasta que el director los activa.

El código los busca con `get_tree().get_first_node_in_group(...)`, así que solo
importa el nombre del grupo, no dónde estén colocados.

## Restricción técnica que afecta al arte

Los enemigos de horda se dibujan con `MultiMeshInstance2D` para poder tener
cientos en pantalla con una sola llamada de dibujado por tipo. Eso implica que
**todas las instancias de un tipo comparten una textura y un material**: un
solo sprite por tipo de enemigo, sin fotogramas de animación, todos del mismo
tamaño. El movimiento visual lo pone un shader (`medios/shaders/horda.gdshader`:
destello al recibir daño y glitch), no una animación dibujada.

Los élites y el jefe sí son nodos normales y pueden llevar animación, porque hay
pocos a la vez.

La lista original de assets está en `documentacio/assets.md` y la procedencia de
los que se usan, en `documentacio/creditos.md`.

### Aviso para los shaders

En este proyecto (Godot 4.7.2, renderizador Compatibility) un número escrito en
un shader con un cero justo detrás del punto llega mal: `0.05` se comporta como
`0.5`, y `0.005` como `0.05`. `0.10` o `0.25` salen bien. Para valores así hay
que escribirlos como división (`1.0 / 20.0`) o pasarlos como parámetros del
material desde la escena.

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
