# Bitácora de desarrollo — Sector Cero

Registro por sesión de trabajo. Este documento **no es un entregable en sí mismo**:
es la materia prima con la que se redactan después la documentación técnica
(3-5 páginas) y los informes de seguimiento. Por eso cada entrada recoge
exactamente los apartados que esos documentos piden: decisiones técnicas y su
porqué, problemas encontrados, soluciones aplicadas y uso de IA.

Se actualiza al terminar cada sesión de trabajo, antes de hacer el commit.

---

## Sesión 1 — 18/09/2026

**Duración:** 2 h · **Fita:** 1 (Idea i prototip) · **Participantes:** Adam

### Qué se ha hecho

- Creación del repositorio Git con la estructura obligatoria del enunciado
  (`README.md`, `projecte/`, `documentacio/`) y publicación en GitHub.
- Invitación de Alan como colaborador con permiso de escritura.
- Definición de la arquitectura completa: escenas, scripts, autoloads y Resources,
  con el reparto de responsabilidades entre los dos.
- Creación del árbol de carpetas y de los scripts esqueleto de todos los sistemas.
- Configuración del proyecto de Godot: registro de los cuatro autoloads y mapa de
  input (movimiento con teclado, flechas y mando).
- Montaje de las cuatro escenas base.

### Decisiones técnicas y por qué

**Crear el repositorio antes que el proyecto de Godot.** Godot genera la carpeta
de caché `.godot/` en cuanto abre el proyecto por primera vez. Teniendo el
`.gitignore` ya en el primer commit, esa carpeta queda ignorada desde el minuto
cero y no hay riesgo de subirla por descuido.

**Escenas separadas por responsable, unidas por una escena raíz mínima.** Los
ficheros `.tscn` se fusionan muy mal en Git. La escena principal solo instancia la
parte de cada uno, de modo que nadie tiene que abrir el fichero del otro.

**Acoplamiento por nombre de grupo, no por `NodePath`.** El código busca el punto
de aparición y los límites de la arena con
`get_tree().get_first_node_in_group(...)`. Así cada uno puede reorganizar su
escena sin romper la del otro; el contrato es solo el nombre del grupo.

**Un autoload `BusEventos` como única frontera.** Se añadió la señal
`mejora_seleccionada` a la lista prevista porque faltaba el camino de vuelta
desde la interfaz hacia la jugabilidad al elegir una mejora al subir de nivel.

**Uso de `physical_keycode` en lugar de `keycode`.** El código físico se refiere a
la posición de la tecla, no a la letra impresa, de modo que la disposición WASD
funciona también en teclados AZERTY o QWERTZ sin configuración adicional.

### Problemas encontrados y cómo se resolvieron

**La GPU no estaba disponible.** Al ejecutar el juego por primera vez, Godot no
encontró Vulkan, cayó a Direct3D 12 y acabó usando *Microsoft Basic Render
Driver*, que renderiza por software con la CPU. La causa: el desarrollo ocurre
dentro de una máquina virtual de VirtualBox sin aceleración 3D activada.

Impacto: cualquier medición de rendimiento resultaba inútil, lo cual es grave en
un proyecto cuyo objetivo es sostener 300+ enemigos a 60 FPS. Se documentó y se
pospuso la solución a la sesión siguiente.

### Uso de IA

Claude (Claude Code) se usó para generar la estructura de carpetas, los scripts
esqueleto, el fichero `project.godot` y las escenas base, así como para razonar la
arquitectura y el reparto de ficheros. Toda la configuración generada se validó
ejecutando Godot en modo headless antes de darla por buena.

### Estado al cerrar

El proyecto arranca y muestra la escena principal sin errores. El jugador aún no
se mueve.

---

## Sesión 2 — 22/09/2026

**Duración:** 2 h · **Fita:** 1 (Idea i prototip) · **Participantes:** Adam

**Horas acumuladas:** 4 h de las 60 sugeridas (6,7 %)

### Qué se ha hecho

- Resolución del problema de GPU de la sesión anterior.
- Definición de la convención de mensajes de commit y del flujo de ramas,
  documentada en el `README.md`.
- Commit y publicación de todo el esqueleto pendiente.
- Traducción completa del proyecto al castellano.
- Conversión del proyecto de 3D a 2D.
- Implementación del movimiento del jugador.
- Cambio de temática y de nombre del proyecto.
- Lista de assets para Alan y documento de contexto para su asistente de IA.
- Lectura y análisis del enunciado completo.
- Documentación de trabajo: esta bitácora, la planificación de las 6 fitas y la
  propuesta de la Fase 1.
- **Fita 2 completa por la parte de jugabilidad**: horda de enemigos con
  MultiMesh y reciclaje, rejilla espacial y separación, daño por contacto y fin
  de partida, armas data-driven, gemas de experiencia, niveles y mejoras, tres
  tipos de enemigo, director de oleadas con dificultad creciente, desbloqueo de
  armas al subir de nivel y panel de depuración.

### Decisiones técnicas y por qué

**Cambio de 3D a 2D.** Reduce sustancialmente el alcance: desaparecen la
iluminación tridimensional, los modelos y la cámara en perspectiva. La
arquitectura no se resiente, porque `MultiMeshInstance2D` ofrece exactamente la
misma ventaja que su equivalente 3D (una sola llamada de dibujado por tipo de
enemigo) y la rejilla espacial es más simple con `Vector2`. El enunciado prioriza
explícitamente un proyecto pequeño y acabado sobre uno ambicioso e incompleto.

**Fijar el renderizador a Compatibility (OpenGL).** Forward+ requiere Vulkan o
Direct3D 12, y el entorno no ofrece ninguno de los dos. Fijarlo explícitamente
evita que el juego arranque mostrando errores y garantiza que lo que se desarrolla
es exactamente lo que se exporta. Como efecto secundario positivo, el build final
funcionará en máquinas más modestas.

**Eliminación del script de seguimiento de cámara.** `Camera2D` ya incorpora
suavizado de posición y límites de encuadre. Escribir ese comportamiento a mano
habría sido reimplementar algo que el motor resuelve con dos propiedades.

**Uso de `Input.get_vector()` para el movimiento.** Normaliza el vector
resultante, lo que evita el error habitual de que el movimiento en diagonal sea
más rápido que el movimiento recto, y aplica la zona muerta del mando sin código
adicional. El cálculo va en `_physics_process` y no en `_process` porque
`move_and_slide()` es física y debe ejecutarse a paso fijo.

**Añadido un `.gitattributes`.** Normaliza los finales de línea a LF. Sin esto, si
los dos integrantes trabajan en sistemas operativos distintos, aparecen
diferencias fantasma en ficheros que nadie ha tocado, precisamente en los `.tscn`,
que es donde menos conviene.

**Un enemigo de horda no es un nodo, es una posición en un array.** Un nodo por
enemigo implicaría cientos de nodos procesándose y cientos de llamadas de dibujado.
En su lugar hay arrays de posiciones y vidas de tamaño fijo, y un único
`MultiMeshInstance2D` que los dibuja todos en una sola llamada. El *object
pooling* no es un sistema aparte: el pool **es** el array, y crear o destruir un
enemigo se reduce a mover un contador.

**Al morir un enemigo, el último vivo ocupa su hueco.** Desplazar el resto del
array costaría cientos de copias. Como el orden de los enemigos es irrelevante,
traer el último al hueco cuesta una sola asignación y mantiene a los vivos
compactados al principio, lo que a su vez permite dibujarlos con
`visible_instance_count` sin esconder ninguno individualmente. Los recorridos que
eliminan van hacia atrás, porque el elemento que llega al hueco ya se ha
comprobado.

**Rejilla espacial para las consultas de proximidad.** Separar a cada enemigo de
sus vecinos comparándolo con todos los demás es cuadrático. La rejilla divide el
mapa en celdas y solo se consultan las que cubren el radio pedido. Medido con 500
enemigos: **4,36 ms de física por fotograma con rejilla frente a 19,17 ms sin
ella**, cuando el presupuesto para 60 FPS es de 16,67 ms.

**Las gemas no usan la rejilla.** Solo hay que saber qué gemas están cerca del
jugador: una consulta por fotograma, no una por gema. Recorrer la lista es más
simple y cuesta lo mismo. La rejilla existe para el problema cuadrático, no como
solución por defecto.

**El componente de salud no conoce el bus de eventos.** Emite señales locales y es
la raíz de la jugabilidad quien las traslada al `BusEventos`. Así el mismo
componente sirve para el jugador y para el jefe, y quien lo usa decide qué
significan sus avisos.

**Las mejoras se aplican como multiplicadores, nunca modificando el `.tres`.** Los
recursos de Godot están compartidos y en caché: sumar un 20% de daño al recurso
del arma dejaría ese 20% pegado para la siguiente partida. Es un fallo que no da
error, solo comportamiento inexplicable.

**Un gestor de enemigos por cada tipo.** No es una decisión de estilo: un
`MultiMesh` solo puede dibujar una malla con un material, así que mezclar tipos
impediría darles tamaño y aspecto distintos. Como cada gestor lee sus estadísticas
de un `.tres` propio, los tres nodos comparten el mismo script sin un solo
condicional por tipo.

**La dificultad emerge de cuatro números, no de oleadas guionizadas.** El director
interpola el intervalo de aparición entre un valor inicial y uno final, y cada
tipo de enemigo declara en su recurso a partir de qué segundo entra en juego.

**El panel de depuración se alimenta solo del bus.** Además de servir para
testear, demuestra que el contrato acordado con Alan contiene toda la información
que su interfaz necesitará.

### Cambios de rumbo y su justificación

**Idioma: todo al castellano.** Se tradujeron carpetas, ficheros, identificadores,
señales, grupos, acciones de input y documentación. Motivo: facilitar la defensa,
donde hay que explicar y justificar cualquier fragmento del código. Se mantienen
en catalán `projecte/` y `documentacio/` porque el enunciado los exige
literalmente, y en inglés los términos técnicos sin traducción asentada (*shader*,
*pool*, *sprite*) y la API del motor.

**Temática: de vampiros a un ordenador infectado.** La ambientación de vampiros y
zombis se descartó por genérica. *Sector Cero* transcurre dentro de un ordenador
infectado, donde el jugador es un proceso antivirus que defiende el sector de
arranque del malware. La decisión no es solo estética: la restricción del
MultiMesh impide animación esquelética en los enemigos de horda, y las entidades
digitales moviéndose a tirones se leen como estilo deliberado en lugar de como
carencia técnica. Además abarata el arte, que es responsabilidad de Alan.

El repositorio se renombró de `vampire-survivors-3d` a `sector-cero` en
consecuencia.

### Problemas encontrados y cómo se resolvieron

**Renderizado por software (heredado de la sesión 1).** Se activó la aceleración
3D en la configuración de VirtualBox del anfitrión, con el controlador gráfico
VBoxSVGA y la memoria de vídeo al máximo. Resultado: el invitado pasa a exponer
OpenGL 4.1 mediante Mesa SVGA3D. Verificado comparando la salida de arranque de
Godot antes y después.

Queda una limitación conocida: la GPU sigue estando virtualizada, de modo que las
mediciones de FPS obtenidas en este equipo son pesimistas y no concluyentes. El
objetivo de 300+ enemigos deberá validarse en una máquina con GPU real antes de la
defensa.

**Caché de Godot desactualizada tras el renombrado.** Después de traducir rutas y
ficheros, la importación fallaba buscando los autoloads en sus rutas antiguas. La
causa era la caché `.godot/`, que conserva referencias del escaneo anterior. Se
resolvió borrando esa carpeta y reimportando, que es precisamente para lo que
sirve estar ignorada en Git: es regenerable.

**Detección de renombrados confusa en Git.** Al traducir los nombres de fichero,
`git status` emparejó renombrados de forma aparentemente aleatoria (por ejemplo
`audio_manager.gd` con `arma.gd`). La causa es que casi todos los scripts tenían
contenido idéntico (`extends Node`), lo que impide a la heurística de Git
distinguirlos. Es un efecto cosmético en el diff; se verificó fichero por fichero
que el contenido resultante era el correcto.

### Uso de IA

Claude generó la conversión completa a 2D, todo el código de jugabilidad de la
Fita 2, la traducción del proyecto y la documentación. Aportó además el análisis
del enunciado y las propuestas de temática.

Cada cambio se validó ejecutando Godot en headless antes de commitear, y la
medición comparativa de la rejilla espacial se hizo sustituyendo la consulta por
una comparación contra todos los enemigos y midiendo ambas versiones.

**Una suposición implícita en la rejilla.** `indices_cerca()` consultaba siempre
las ocho celdas contiguas, lo cual solo es correcto si el radio de búsqueda cabe
en una celda. Con celdas de 26 píxeles y un arma de 90 de alcance se dejaba fuera
la mayor parte del área. El fallo no estaba en el código nuevo sino en una
suposición del código anterior, que solo se hizo visible al darle un uso distinto.
Ahora el radio es un parámetro explícito.

**Clases globales sin registrar.** Al añadir un `class_name` nuevo, los scripts
que lo usan fallan al cargar hasta que Godot reconstruye su índice de clases. Se
resuelve reimportando el proyecto.

**Sospecha de que el jugador se movía solo.** En una prueba apareció desplazado
contra el muro inferior sin haber tocado nada. Tras comprobarlo con el director de
oleadas desactivado y con él activado, la posición se mantenía en el origen con
velocidad cero en ambos casos. La causa real era que la ventana del juego roba el
foco al abrirse, de modo que las pulsaciones de teclado llegaban al juego. No era
un fallo del código.

**Ordenación del dibujo.** El anillo que muestra el alcance del arma se dibujaba
por debajo del suelo de la arena por llevar `z_index = -1`, lo que lo hacía
invisible.

### Métodos de test empleados

Todo lo implementado se ha verificado ejecutando Godot sin interfaz gráfica
(`--headless`), con tres técnicas:

1. **Importación limpia** para detectar errores de análisis de los scripts.
2. **Arranque de la escena principal** durante un número fijo de fotogramas, para
   detectar errores en tiempo de ejecución.
3. **Instrumentación temporal**: un autoload que se conecta a las señales del
   `BusEventos` y registra lo que ocurre, eliminado siempre antes de commitear.

Ejemplos de comprobaciones concretas: la vida baja de 8 en 8 espaciada por la
invulnerabilidad hasta emitir el fin de partida; la experiencia acumulada a los
150 segundos (451) cuadra exactamente con las muertes de cada tipo por su valor
(191×1 + 106×2 + 12×4); los tipos de enemigo entran en el segundo que declaran; y
la mejora de arma sale una única vez mientras las de porcentaje se repiten.

Para lo visual se ha usado captura de pantalla desde el propio juego, guardando la
imagen del viewport en un fotograma concreto.

### Estado al cerrar

El bucle de juego está completo: te mueves, la horda te persigue y te hace daño,
las armas atacan solas y matan, los enemigos sueltan experiencia, subes de nivel y
eliges mejoras, la dificultad crece y morir termina la partida.

La Fita 1 y la parte de jugabilidad de la Fita 2 quedan cerradas. No hay interfaz
de ningún tipo —es trabajo de la Fita 3— y todo lo visual son formas geométricas
de marcador de posición.

Queda consciente a medias: el juego no se pausa al subir de nivel, porque el panel
que lo reanudaría todavía no existe; y el balance está sin ajustar, que es trabajo
de la Fita 5.

### Siguiente paso

Números de daño flotantes y sistema de proyectiles, que permitirá sustituir la
segunda arma de área por el Ping previsto en la propuesta.
