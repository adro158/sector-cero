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

- **Lote 6, lo que eligió Claude:** en las reglas se quedan los personajes
  con el primer fotograma de su hoja (el retrato a 48 px se deforma); el
  aviso del HUD al aparecer un élite sigue siendo solo texto (llega como una
  cadena por el bus); el lema del lanzador se quita con su fila, porque la
  cabecera ya dice qué es el juego.

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

---

## Sesión 3 — 24/09/2026

**Duración:** 2 h · **Fita:** 2 (Core del projecte) · **Participantes:** Adam

**Horas acumuladas:** 6 h de las 60 sugeridas (10 %)

### Qué se ha hecho

- Integración en `main` de la arena que Alan subió a su rama: escena con los
  grupos del contrato y shader de rejilla de neón para el fondo. La escena
  principal usa ya su arena; la de pruebas se conserva para probar la
  jugabilidad de forma aislada.
- El jugador se mantiene dentro de la zona que marca `limites_arena`.
- Números de daño flotantes.
- Sistema de proyectiles y arma Ping, que salta de un enemigo a otro.
- Recuperación del contexto en una conversación nueva con la IA, porque la
  anterior se perdió al reinstalar la aplicación, y revisión del estado real del
  código frente a esta bitácora.
- Análisis del enunciado completo y de la plantilla del primer seguimiento, con
  la lista de requisitos mínimos que faltan.
- Nuevo flujo de Git con dos ramas fijas, documentado en el `README.md` y en
  `GEMINI.md`, y creación de `CLAUDE.md`.
- Actualización de las casillas de la planificación, que seguían sin marcar.

### Decisiones técnicas y por qué

**Los límites de la arena se aplican por código, no con muros.** La arena de Alan
declara la zona jugable con un `Area2D`, sin colisiones propias, que es lo
acordado: ella declara los límites y la jugabilidad los respeta. El jugador lee
la forma al arrancar y recorta su posición, apartándose su propio radio del
borde para no quedar medio fuera.

**Los números de daño no usan MultiMesh.** Un MultiMesh repite una misma malla y
cada número muestra un texto distinto. Se pintan todos desde un único nodo con
`draw_string`, reutilizando un array fijo igual que los enemigos. Con un arma de
área golpeando a decenas de enemigos, un tope de 150 números evita llenar la
pantalla de texto.

**El aviso de daño es una señal local, no del `BusEventos`.** Se dispara decenas
de veces por segundo y no cruza la frontera con la interfaz. El bus queda para lo
que Alan necesita saber.

**El tipo de ataque es un dato del arma.** `DatosArma` declara si es de área o de
proyectil y el gestor de armas reparte según ese campo. Añadir un arma nueva
sigue siendo crear un `.tres`.

**Los proyectiles reutilizan el patrón de la horda.** Arrays de tamaño fijo, un
`MultiMeshInstance2D` y retirada trayendo el último al hueco. El Ping busca su
siguiente objetivo con la misma rejilla espacial que ya usaban la separación y
el daño. Tras impactar espera 0,08 s antes de poder volver a golpear: sin esa
espera seguiría dentro del mismo enemigo al fotograma siguiente y lo golpearía
sin parar en lugar de saltar al siguiente.

**`CLAUDE.md` importa `GEMINI.md` en lugar de copiarlo.** Así el contrato con
Alan está escrito en un único sitio y no puede quedar desincronizado entre las
dos IA. `CLAUDE.md` solo añade lo propio de Claude: leer esta bitácora al
empezar, validar en headless y el cierre de sesión.

**Propiedad de los ficheros que no tenían dueño.** `bus_eventos.gd`,
`estado_juego.gd`, `juego.tscn` y `project.godot` son de Adam; si Alan necesita
cambiarlos, lo pide. En `documentacio/`, Adam mantiene la bitácora y la
planificación y el resto es de Alan.

**La pausa al subir de nivel la gestionará la jugabilidad.** Se pueden subir
varios niveles en el mismo fotograma, así que habrá una cola de niveles
pendientes y el panel de Alan solo tendrá que funcionar con el juego pausado.
Pendiente de acordarlo con Alan.

### Cambios de rumbo y su justificación

**Prioridad: primero los mínimos.** Tras releer el enunciado se decide cubrir
antes los requisitos mínimos y el MVP, y dejar el jefe, los élites y las
evoluciones para cuando sobre tiempo. El enunciado valora más un proyecto
pequeño y acabado que uno ambicioso a medias.

**Flujo de Git: de ramas por tarea a dos ramas fijas.** Adam trabaja en `main` y
Alan siempre en `feature/alan-arena-hud`. Al empezar cada clase, cada uno fusiona
la rama del otro en la suya, y cada uno solo commitea sus ficheros. Motivo:
crear y borrar una rama por tarea complicaba el trabajo de Alan, y como cada uno
tiene sus ficheros las ramas casi nunca chocan. Al sincronizar en cada clase la
integración sigue siendo continua, y cada fita se marcará con una etiqueta para
que el historial muestre los hitos.

**El Escáner no se ha sustituido.** El Ping se añadió como tercera arma y el
Escáner sigue como pulso de área, aunque su descripción habla de un barrido.
Decisión pendiente.

### Problemas encontrados y cómo se resolvieron

**Pérdida de la conversación con la IA.** Al reinstalar la aplicación se perdió
el chat con el que se había trabajado, y el trabajo de esta sesión no llegó a
anotarse en la bitácora. Se detectó comparando la bitácora con `git log`, y el
contexto se recuperó con la bitácora, `GEMINI.md` y el historial. Para que no
vuelva a pasar se creó `CLAUDE.md`, que cualquier sesión nueva carga sola.

**El editor reescribe `project.godot`.** Al abrir el proyecto, Godot reordena
las secciones del fichero sin cambiar ningún ajuste. Se aceptó el formato
canónico en un commit aparte, para que el cambio no se mezclara con trabajo real.
El nuevo flujo de Git incluye revisar `git status` antes de cada commit por este
motivo.

**Problemas detectados en la revisión, pendientes de corregir:**

- Nadie emite todavía `mejora_seleccionada`, que es la señal del panel de Alan.
  En el juego real no se puede elegir ninguna mejora, así que el Ping y el
  Escáner no se pueden conseguir; solo se han probado con instrumentación.
- La rejilla espacial se construye antes de retirar a los enemigos muertos. Al
  retirar uno, el último vivo cambia de índice y la rejilla sigue apuntando al
  antiguo, así que durante un fotograma ese enemigo no recibe daño y aparece un
  número fantasma.
- La mejora de cadencia resta un porcentaje fijo sin límite. Tras nueve mejoras
  el multiplicador se vuelve negativo y el arma dispara en cada fotograma.

### Uso de IA

Claude generó el límite de la arena, los números de daño flotantes y el sistema
de proyectiles. En la conversación nueva reconstruyó el contexto a partir de la
documentación y de Git, revisó el código y detectó los tres problemas
pendientes, cruzó el enunciado con el estado real del proyecto y redactó los
cambios del `README.md`, `GEMINI.md`, `CLAUDE.md` y esta entrada. Las decisiones
de flujo de Git, propiedad de ficheros y prioridades las tomó Adam.

### Métodos de test empleados

- Límites de la arena: el jugador se detiene en (944, 524) y en (-944, -524),
  que son las esquinas de una zona de 1920×1080 menos su radio.
- Proyectiles: se observan en vuelo con 3, 2, 1 y 0 rebotes restantes, lo que
  confirma que la cadena de saltos llega hasta agotarse.
- Al cerrar la sesión: importación limpia y arranque de la escena principal
  durante 600 fotogramas en headless, sin errores.

### Estado al cerrar

La arena de Alan está integrada, hay tres armas (dos de área y una de
proyectil) y feedback de daño. El juego sigue sin interfaz, sin pausa al subir
de nivel y sin condición de victoria.

### Siguiente paso

Cubrir lo mínimo de la jugabilidad, empezando por lo que desbloquea a Alan:

1. Corregir los índices de la rejilla y poner un límite a la cadencia.
2. Pausa al subir de nivel con cola, y elección provisional de mejoras con las
   teclas 1, 2 y 3 desde el panel de depuración.
3. Que la jugabilidad responda a `juego_pausado`.
4. Victoria al sobrevivir 10 minutos y estadísticas completas en
   `partida_terminada` (tiempo, nivel, eliminados, victoria o derrota).
5. Destello en el jugador al recibir daño.
6. Primera exportación de prueba del build.
7. Elemento diferencial: resistencia adaptativa del malware.

---

## Sesión 4 — 29/09/2026

**Duración:** 2 h · **Fitas:** 2, 3 y 4 · **Participantes:** Adam

**Horas acumuladas:** 8 h de las 60 sugeridas (13,3 %)

### Qué se ha hecho

- Fusión en `main` de la rama de Alan: HUD básico con barra de vida, nivel y un
  panel de mejoras.
- Corrección de los dos fallos detectados en la sesión anterior: índices
  caducados en la rejilla y cadencia que podía llegar a cero.
- Pausa al subir de nivel, con cola cuando se suben varios niveles de golpe.
- Pausa desde el bus (`juego_pausado`) y acción de input `pausar` (Esc, P y
  Start del mando).
- Victoria al sobrevivir 10 minutos y estadísticas completas al terminar la
  partida.
- Respuesta visual al recibir daño: el jugador se tiñe de rojo y la cámara da un
  tirón.
- **Elemento diferencial**: resistencia adaptativa del malware.
- Primer build: plantillas de exportación instaladas y presets para Windows y
  Linux. El ejecutable arranca sin abrir Godot.
- Interfaz provisional (ventana de mejoras con click y teclas, y aviso de pausa)
  mientras la de Alan no funciona con la pausa.
- Personaje: tres versiones en la misma sesión. La definitiva de momento es una
  hoja de ocho direcciones con seis fotogramas de andar cada una, recoloreada a
  la estética del ordenador. Es un sprite provisional.
- Simulador de partidas y primer ajuste de balance.
- Fondo provisional de placa base.

### Decisiones técnicas y por qué

**La pausa al subir de nivel la pone la jugabilidad, no la interfaz.** Así el
panel de mejoras solo tiene que mostrar opciones y avisar de la elegida. Si se
suben varios niveles de golpe, quedan pendientes y se ofrecen de uno en uno: un
panel solo puede mostrar tres tarjetas a la vez. Una elección que llega sin
niveles pendientes se ignora, por si llega desde dos sitios.

**El menú de pausa no puede quitar una pausa que no es suya.** La jugabilidad
ignora `juego_pausado` mientras se elige mejora o tras el fin de partida.

**Un solo reloj de partida.** El tiempo de las estadísticas sale del director de
oleadas, que no avanza en pausa, en lugar de llevar un segundo reloj en la raíz.
Las claves del diccionario de `partida_terminada` (`victoria`, `tiempo`,
`nivel`, `eliminados`) quedan documentadas en el bus y en `GEMINI.md`, porque la
pantalla de resultados de Alan las leerá por nombre.

**La cadencia se multiplica en vez de restarse.** Cada mejora quita un
porcentaje de lo que queda y nunca se llega a cero.

**Diseño de la resistencia adaptativa.** Cada 20 s el malware mira qué arma le
ha hecho más daño en ese ciclo y gana un 10 % de resistencia contra ella, hasta
un 50 %; contra las demás pierde un 5 %. Con una sola arma la resistencia se
acumula; con varias, la más usada va cambiando y ninguna acumula mucha. Así
diversificar al subir de nivel es una decisión real, y la mecánica nace de la
ambientación. Las armas registran el daño que hacen de verdad, ya descontada la
resistencia; los proyectiles lo aplican al impactar, porque puede pasar un
análisis mientras vuelan. Se ve en los números de daño, que se mezclan con rojo
en la misma proporción que la resistencia, y en el anillo de las armas de área.

**Un ejecutable sin ficheros sueltos.** Los presets incrustan el `.pck` en el
ejecutable. La salida va a `build/`, que no se versiona: el build se entrega
aparte.

**La interfaz provisional solo usa el bus.** Igual que tendrá que hacer la de
Alan. Vive en un único script para poder borrarla de golpe cuando la suya esté
lista.

**Ocho direcciones con una hoja y un número.** El ángulo del movimiento se
redondea al octavo de vuelta más cercano y una tabla lo traduce a la fila de la
hoja; mientras se anda, se avanza por las seis columnas. El pixel art se dibuja
con filtro *nearest* para que no se difumine.

**Las imágenes se preparan con scripts de Godot fuera del juego.** Para quitar
el fondo de una ilustración se rellena por inundación desde los bordes, solo lo
conectado con el exterior, para no tocar lo oscuro de dentro del personaje. Para
recolorear la hoja se clasifica cada color por tono, saturación y brillo y se
lleva a su equivalente de la paleta del ordenador, conservando el brillo.

**El balance se decide con datos.** El simulador juega partidas enteras con un
bot y semillas fijas, así que el mismo comando repite las mismas partidas y se
puede comparar el antes y el después. Vive en `projecte/herramientas/` y se
excluye de los builds.

**Un fondo encima de la rejilla, no debajo.** El suelo de Alan es opaco, así que
un fondo detrás solo se vería fuera de la arena. El provisional dibuja pistas
sobre una base transparente, por encima de su rejilla y por debajo del juego.

### Cambios de rumbo y su justificación

**Interfaz provisional y HUD de Alan retirado temporalmente.** Su panel de
mejoras no responde con el juego pausado ni emite `mejora_seleccionada`, y al
elegir con teclas se quedaba en pantalla. El arreglo está en sus ficheros, así
que se le ha pasado el código exacto y, mientras tanto, la interfaz provisional
ocupa su lugar.

**Balance.** Con los valores originales la partida era imposible (ver
problemas). Se redujo a la mitad el daño por contacto, se empezó con una
aparición por segundo en vez de dos y se añadió regeneración de vida.

**Señales nuevas propuestas a Alan.** `experiencia_cambiada`, `tiempo_partida`
y `resistencia_cambiada`. La primera es imprescindible: con
`experiencia_ganada` su HUD no puede saber cuánto falta para el siguiente nivel.
No se añaden hasta que él esté de acuerdo, porque cambian el contrato.

### Problemas encontrados y cómo se resolvieron

**La partida era imposible.** El simulador mostró que el bot moría en todas las
partidas entre los 34 y los 44 segundos. Un solo enemigo quitaba 16 de vida por
segundo mientras tocaba y la vida nunca se recuperaba. Se compararon variantes:
bajar daño y apariciones llevaba la media a unos 4 minutos pero seguía sin
ganar; reforzar el Firewall no mejoraba nada; lo que decidió fue la
regeneración. Resultado final: 2 victorias de 5 y 7,5 minutos de media.

**El driver gráfico de la máquina virtual se cayó.** Tras varias ejecuciones con
ventana, cualquier ventana de Godot se cerraba al arrancar ("VMware: IOCTL
failed", fallo en `vboxgl.dll`), incluso el ejecutable que antes funcionaba. No
era el código: las pruebas sin ventana pasaban. Se resolvió reiniciando la
máquina virtual. Mientras tanto se siguió trabajando en headless, que no usa la
GPU.

**Los shaders pierden el cero de detrás del punto.** En el fondo provisional las
vías salían como círculos enormes. Con un shader mínimo que pinta varios valores
y leyendo el píxel se comprobó que `0.05` y `5e-2` llegan como 0,5, mientras que
`1.0 / 20.0` llega bien. Se escriben esos valores como divisiones y el aviso
queda en `GEMINI.md` para los shaders de Alan.

**Una prueba que no detectaba el fallo que buscaba.** La de la rejilla esperaba
dos fotogramas y en el segundo la rejilla ya se había reconstruido, así que el
código antiguo también pasaba. Se corrigió la espera y se ejecutó contra el
código antiguo y el nuevo: antes el golpe contaba como impacto pero la vida no
bajaba; ahora sí.

**Recursos que se descargaban solos.** El simulador cambiaba valores de balance
en memoria, pero no surtían efecto: al terminar la función nada referenciaba los
recursos, Godot los descargaba y la escena los volvía a leer del disco. Se
resolvió guardándolos en una variable.

**Pruebas que miraban demasiado pronto.** En headless los fotogramas avanzan más
rápido que el tiempo real, y el Firewall solo ataca cada 0,6 s. Las esperas se
hicieron por tiempo o se alargaron.

### Uso de IA

Claude implementó todo el código de la sesión, los scripts para preparar las
imágenes y el simulador, y diagnosticó los problemas anteriores con pruebas
dirigidas. Las decisiones las tomó Adam: la variante de balance, la interfaz
provisional, cómo hacer el fondo, mantener el Escáner y no tocar los ficheros de
Alan. Los dibujos del personaje se generaron con herramientas de IA de imagen y
son provisionales.

### Métodos de test empleados

- **Scripts temporales en headless** para cada cambio: pausa y cola, fin de
  partida, destello, resistencia, las ocho direcciones. Se borran antes del
  commit.
- **Comparación antes y después** ejecutando la misma prueba contra el código
  antiguo, para asegurar que detecta el fallo.
- **Eventos reales de ratón y teclado con ventana** para la interfaz provisional,
  con capturas de pantalla.
- **Simulador de partidas** para el balance.
- **Build exportado** ejecutado fuera del editor.

### Estado al cerrar

La jugabilidad mínima está completa: mecánica, pausa, victoria y derrota,
feedback, elemento diferencial y build. Todo está commiteado en `main`, pero
aún no se ha subido a GitHub.

Pendiente de Alan: su panel de mejoras (código enviado), menú de pausa,
pantallas de inicio y resultados, persistencia y audio. Pendiente de acordar con
él: las tres señales nuevas.

### Siguiente paso

1. Subir los commits para que Alan pueda traerse la pausa y el fin de partida.
2. Preparar el informe del primer seguimiento (2 de octubre).
3. Decidir si el jefe final sale del MVP de la propuesta antes de entregarla.
4. README: cómo ejecutar el juego, controles y tecnologías.

---

## Sesión 5 — 30/09/2026

**Duración:** 2 h · **Fitas:** 3 y 4 · **Participantes:** Adam

**Horas acumuladas:** 10 h de las 60 sugeridas (16,7 %)

### Qué se ha hecho

- Fusión del arreglo del panel de mejoras de Alan y de su módulo RAM.
- Jefe final: aparece a los 10 minutos, deja de salir horda y se gana al
  derrotarlo.
- Sprites para los tres tipos de la horda e iconos para las mejoras.
- Primera release en GitHub (v0.1) con los ejecutables de Windows y Linux,
  para que Alan pueda jugar sin abrir Godot.
- Nuevo reparto: la interfaz, la persistencia, la arena y el arte pasan a
  Adam; Alan se queda el audio.
- Interfaz completa: menú de inicio con las reglas, HUD (nivel, experiencia,
  reloj, cuenta atrás del jefe y columna de mejoras con su nivel), panel de
  mejoras con teclas 1, 2 y 3, menú de pausa, pantalla final de victoria o
  derrota, barra de vida sobre el personaje y panel técnico (F3) rediseñado.
- Cambio de personaje durante la partida (espadachín, mago y segador).
- Acceso directo `.bat` en el escritorio para probar el juego desde el
  proyecto.

### Decisiones técnicas y por qué

**El jefe es un objetivo más para las armas.** Todo lo que puede recibir daño
está en el grupo `objetivos` y tiene `danar_en_area` y `mas_cercano`: los tres
gestores de la horda y el jefe. Las armas, los proyectiles y los números de
daño recorren ese grupo sin saber qué es cada uno, y la resistencia del
malware se aplica igual contra él. El jefe reutiliza el componente `Salud`.

**El jefe se puede esquivar.** Persigue despacio y cada 7 s se tiñe de rojo
durante 0,8 s antes de embestir en línea recta hacia donde estaba el jugador:
el aviso da tiempo a reaccionar.

**La tabla de ocho direcciones se comparte.** `Direcciones8` traduce una
dirección a la fila de la hoja de sprites y la usan el jugador y el jefe, en
lugar de repetir la tabla en los dos.

**Los sprites de la horda y los iconos se generan con un script.** Se dibujan
a partir de formas simples, al tamaño exacto de cada uno para que salgan
nítidos, y el contorno de neón se calcula solo desde la silueta. Retocar uno es
cambiar unos números. Cada tipo de enemigo y cada mejora enlaza su imagen desde
su `.tres`, así que sigue siendo data-driven.

**La interfaz comparte un estilo.** `EstiloInterfaz` reúne los colores neón, la
fuente monoespaciada y el aspecto de paneles y botones, para que todas las
pantallas se vean iguales sin repetir la configuración. Cada pantalla es un
script pequeño y solo usa el bus.

**Dos señales nuevas para el HUD.** `experiencia_cambiada` (sin ella no se
puede dibujar la barra de experiencia, porque `experiencia_ganada` no dice
cuánto falta) y `tiempo_partida`, una vez por segundo.

**Solo dispara el arma del personaje activo.** Así el cambio de personaje es
la respuesta a la resistencia del malware y el elemento diferencial se
convierte en una decisión del jugador. Por eso las armas dejan de salir como
mejoras: llegan con los personajes. Hay 10 s de espera entre cambios para que
no se pulse sin parar.

**Los ejecutables se publican como release.** El de Windows pesa 109 MB y
GitHub no admite ficheros de más de 100 MB en el repositorio; además, meter
binarios en Git haría crecer el historial con cada versión. Comprimido ocupa
36 MB y se adjunta a una release.

### Cambios de rumbo y su justificación

**Reparto de trabajo.** Adam se queda la interfaz, la persistencia, la arena y
el arte; Alan, el audio. Acordado entre los dos: la interfaz estaba muy ligada
a la jugabilidad (pausa, mejoras, fin de partida) y hacerla uno solo evita
esperas y conflictos. Lo que Alan ya hizo sigue siendo suyo en el historial.

**Las armas ya no se desbloquean al subir de nivel**, por el cambio de
personaje.

### Problemas encontrados y cómo se resolvieron

**Los sprites de la horda salían boca abajo.** El `QuadMesh` que dibuja el
`MultiMesh` tiene la textura invertida respecto al 2D. Se detectó en la primera
captura y se corrige dibujando cada instancia con escala vertical -1.

**El módulo RAM rompía la exportación.** Su escena apuntaba a
`modulo_ram.svg.svg`, que no existía. Se corrigió la ruta y la importación.

**Conflictos al fusionar la rama de Alan.** Su rama partía de un `main`
antiguo y Godot le había reescrito `juego.tscn` y `project.godot`. Se conservó
la versión de `main`, porque sus cambios ahí no eran intencionados.

**El panel F3 ocupaba toda la pantalla.** Al anclarlo arriba a la derecha,
Godot mantuvo su borde izquierdo en la posición anterior. Se fijaron los dos
bordes en el mismo punto para que crezca solo lo que mide su texto.

**Un commit mezclado.** El commit de los iconos se llevó por error el borrado
de la interfaz provisional, que ya estaba preparado, y quedaba un estado que no
arrancaba. Como no se había subido, se rehízo solo con los iconos.

### Uso de IA

Claude implementó el jefe, la interfaz, el cambio de personaje, los scripts
que generan los sprites y los iconos, y la release. Las decisiones las tomó
Adam: el nuevo reparto con Alan, la forma del cambio de personaje y cómo
distribuir el ejecutable. Los sprites de los personajes y del jefe son de
herramientas de IA de imagen y son provisionales.

### Métodos de test empleados

- Scripts temporales en headless para el jefe (aparición, daño, estados y
  victoria) y para el cambio de personaje.
- Pruebas con ventana y eventos reales de teclado y ratón por toda la
  interfaz, con captura de cada pantalla.
- Simulador de partidas para la vida del jefe: con 2500 el combate duraba
  35 s; con 5000 dura unos 65 s.
- Ejecutable exportado arrancado fuera del editor.

### Estado al cerrar

El juego tiene su flujo completo: menú, partida, pausa, jefe y pantalla final.
Faltan los requisitos que no son de jugabilidad: audio (Alan) y persistencia.
El cambio de personaje funciona, pero su balance está sin medir: el bot del
simulador aún no cambia de personaje.

### Siguiente paso

1. Mapa infinito, como en Vampire Survivors: el fondo sigue a la cámara y
   desaparecen los límites de la arena.
2. Enseñar al bot del simulador a cambiar de personaje y medir el balance.
3. Informe del primer seguimiento (2 de octubre).
4. Persistencia: récords y configuración.
5. README y release v0.2.

---

## Sesión 6 — 01/10/2026

**Duración:** 2 h · **Fitas:** 3, 4, 5 y 6 · **Participantes:** Adam (desde
casa)

**Horas acumuladas:** 12 h de las 60 sugeridas (20 %)

### Qué se ha hecho

- Clon nuevo del repositorio en el PC de casa
  (`C:\Users\Adam\Desktop\proyecto\sector-cero`). La rama de Alan no traía nada
  nuevo: estaba toda dentro de `main`.
- **Mapa infinito:** el suelo sigue a la cámara y se quitan los límites, la
  arena de pruebas y los dos fondos antiguos.
- **Persistencia:** récords (tiempo, nivel, eliminados, partidas y victorias) y
  opciones (volumen de música y de efectos, pantalla completa y filtro CRT).
  Panel de opciones en el menú y en la pausa, récord en el menú y aviso de
  récord batido en la pantalla final.
- **Fundidos a negro** entre escenas.
- **Audio:** 17 efectos y 3 músicas en bucle (menú, partida y jefe),
  sintetizados por un script propio, y `GestorAudio` escuchando el bus.
- **Feedback visual:** partículas, destello del enemigo golpeado, glitch de la
  horda por shader y filtro CRT a pantalla completa.
- **Élites con afijos procedurales** (blindado, replicante, aura lenta y
  explosivo), con su sprite (Rootkit) y avisos en el HUD de élites, jefe y
  evoluciones.
- **Evoluciones** de las tres herramientas.
- **Bot del simulador** que cambia de personaje, elige evoluciones y va a por el
  jefe, y **reequilibrio** del juego con él.
- **Medida de rendimiento** en GPU real con una herramienta nueva.
- **Builds v0.2** de Windows y Linux exportadas y comprimidas en `build/` (sin
  publicar todavía).
- **Documentación:** README completo con capturas, documentación técnica,
  manual de usuario, créditos, informe del primer seguimiento, guion de la
  presentación con preguntas probables, y `GEMINI.md`, `CLAUDE.md`,
  planificación y estado de requisitos al día.
- Limpieza de código muerto: el autoload vacío `EstadoJuego`, las mejoras de
  desbloquear arma, `anadir_arma` y `actual()`.
- Acceso directo `Jugar Sector Cero.bat` en el escritorio de casa (abre el
  proyecto sin el editor; no está en el repositorio porque lleva rutas de este
  PC).
- Tras probar el juego, Adam pidió dos cambios: las opciones de la pausa salían
  arriba a la izquierda (corregido) y un botón **REGLAS** en el menú con una
  ventana de cuatro pestañas: cómo se juega, personajes y cuándo conviene cada
  uno, mejoras y evoluciones, y enemigos con los afijos. El menú se queda con un
  resumen corto y las reglas completas pasan a esa ventana.
- **Actualización desde el propio juego:** al abrir el menú busca la última
  release en GitHub y, si hay una nueva, el botón ACTUALIZAR descarga solo el
  `.pck` y reinicia el juego. Una GitHub Action exporta y publica la release al
  subir una etiqueta `vX.Y`.

### Decisiones técnicas y por qué

**El audio pasa a Adam y se genera por código.** Era lo único de Alan y estaba
sin empezar, y es un requisito mínimo. Generarlo con un script (ondas cuadrada,
triángulo, sierra, seno y ruido con una envolvente) da un sonido de chip antiguo
que encaja con la estética, es propio y no hay licencias que acreditar. El
script tarda 2 s en generar todo.

**El bucle de la música va en la importación.** `save_to_wav` no guarda los
puntos de bucle, así que se marca `edit/loop_mode=2` en el `.import` de cada
música. Regenerar los WAV no toca los `.import`.

**La persistencia usa `ConfigFile` en `user://`.** Es el formato de Godot para
pares clave-valor, se lee y escribe con una llamada y el fichero es legible.
`res://` no sirve: dentro del ejecutable es de solo lectura.

**Saber si hay récord sin depender del orden de las señales.** La pantalla final
se conecta a `partida_terminada` en diferido, así el gestor de guardado ya ha
anotado la partida cuando ella pregunta qué récords se han batido.

**El mapa infinito es un rectángulo que sigue a la cámara.** Su shader dibuja
con la posición en el mundo (`MODEL_MATRIX * VERTEX`), no con la del
rectángulo, así que el dibujo se queda quieto. Los enemigos que se alejan más de
1200 px se reflejan al otro lado del jugador y las gemas a más de 1800 px se
descartan, para que no llenen su pool.

**Destello y glitch por shader.** El MultiMesh no permite animación. El destello
llega por enemigo como dato propio de la instancia (`INSTANCE_CUSTOM`) y el
glitch es un número al azar por enemigo (`INSTANCE_ID`) y por instante.

**Las partículas reutilizan el patrón de la horda.** Arrays de tamaño fijo y un
MultiMesh, con un color por instancia (`use_colors`).

**Filtro CRT y fundidos como autoloads.** Así están en todas las escenas sin
añadirlos a cada una, y el fundido sobrevive al cambio de escena.

**Élites como nodos ocultos desde el principio.** Igual que el jefe: las armas
buscan sus objetivos al empezar la partida y no verían un nodo creado después.
Hay tres y el director activa uno libre cada minuto desde el 1:30. Los afijos son
recursos `.tres`.

**Las evoluciones no tocan los `.tres`.** La herramienta actual de cada
personaje se guarda en `CambioPersonaje`. La evolución es otro recurso de arma,
así que el malware empieza sin resistencia contra ella. Se ofrece cuando una
mejora concreta se ha elegido tres veces, y sale siempre la primera.

**Las reglas se leen de los datos.** Personajes, enemigos y afijos tienen ahora
un campo `descripcion` en su recurso, y la ventana de reglas recorre esos
recursos y el pool de mejoras. Si se cambia un personaje o se añade un enemigo,
las reglas se actualizan sin tocar la ventana. Solo el jefe, que no tiene
recurso de datos, lleva su texto en el script.

**Cómo se actualiza el juego sin bajar el ejecutable.** Windows no deja
reemplazar un `.exe` mientras está abierto, así que se actualiza solo el
contenido. El ejecutable lleva el juego dentro; la actualización es un `.pck`
que se guarda en `user://` y, al arrancar, el autoload `Actualizador` lo carga
encima con `ProjectSettings.load_resource_pack`. Tiene que ser el primer
autoload, porque solo lo que se carga después sale de la versión nueva, y no
puede nombrar la clase `Version` (Godot la cargaría al compilarlo, antes de
aplicar el parche). Lo que Godot lee antes de cualquier script (`project.godot`
y la lista de `class_name`) no se puede actualizar así: cada release publica en
`version.json` el ejecutable mínimo que necesita y, si el de jugador es más
viejo, el botón abre la página para descargar el juego entero.

**Busca solo, pero no se instala solo** (decisión de Adam, a propuesta de
Claude). La consulta es automática al abrir el menú, pero se actualiza al pulsar
el botón: así no cambia el juego justo antes de una demo ni falla a medias sin
avisar. Mientras descarga, JUGAR se desactiva, porque al terminar se reinicia.

**Una release por etiqueta, no por commit** (decisión de Adam). Muchos commits
no cambian el juego (la bitácora, por ejemplo). Con `git tag v0.3` se decide
qué llega a los jugadores. La versión sale de la etiqueta: la Action la escribe
en `version.gd` y en `project.godot` antes de exportar. En el código vale
"desarrollo", y jugando desde el proyecto no se busca nada.

**Protecciones.** La descarga se guarda con otro nombre y solo se renombra si
llega completa (se comprueba el tamaño). Si el ejecutable es igual o más nuevo
que el parche guardado (porque se descargó el juego entero después), el parche
se borra en lugar de cargarse.

**Un único estilo de botón.** `EstiloInterfaz.boton()` sustituye a las tres
copias de `_boton()` que había en el menú, la pausa y la pantalla final.

### Cambios de rumbo y su justificación

**Reparto: el audio pasa de Alan a Adam** (decisión de Adam). Desde hoy, Alan no
tiene ficheros en `projecte/`. Hay que acordar con él qué parte de la entrega
asume.

**Se hacen las ampliaciones** (élites y evoluciones), que estaban "solo si sobra
tiempo": los mínimos ya estaban cubiertos.

**Dificultad: 3-4 victorias de 5 del bot** (decisión de Adam). Más que las 2 de
5 de la sesión 4, para que la demo ante el tribunal se pueda ganar jugando bien.

**Idioma de la documentación:** castellano, también el informe del seguimiento,
aunque la plantilla esté en catalán (decisión de Adam).

### Problemas encontrados y cómo se resolvieron

**El juego se volvió fácil con el mapa infinito y el jefe, imposible.** Sin
bordes, el bot huía de todo, no mataba (nivel 10 en 10 minutos) y nunca
encontraba al jefe, que es más lento que el jugador: una partida llegó a los
200 minutos de juego. Se arregló el bot (deja entrar a los enemigos en el anillo
del Firewall y va a por el jefe) y se le puso un tiempo máximo contra el jefe.
Mediciones con 5 partidas y semillas fijas:

| Cambio | Victorias |
|---|---|
| Bot cerca de los enemigos, jefe con 5000 de vida | 1 de 5 (4 no acaban) |
| Jefe con 2500 | 1 de 5 (el bot no encuentra al jefe) |
| El bot va a por el jefe | 5 de 5, sin peligro |
| Horda final cada 0,10 s y regeneración 0,35 | 1 de 5 |
| Élite de 700 a 450 de vida, el bot huye de las explosiones | 2 de 5 |
| Aura lenta del 45 % al 25 % | **4 de 5** |

**El aura lenta mataba sin remedio.** Con un 45 % de frenado el jugador quedaba
más lento que el bit corrupto, que se le pegaba y le quitaba 4 de vida cada
medio segundo. Se encontró registrando cada golpe de la partida que moría al
1:51. Regla: el aura nunca puede dejar al jugador más lento que la horda básica.

**El jefe tenía demasiada vida.** Los 5000 se calcularon cuando disparaban todas
las armas; con solo la del personaje activo, el combate pasaba de 4 minutos.

**Una resistencia que no bajaba a cero.** 0,1 − 0,05 − 0,05 no da 0 exacto en
coma flotante y el arma se quedaba en la lista con un 0 %. Se usa
`is_zero_approx`.

**Un tirón de 217 ms que no existía.** La medida de rendimiento marcaba un pico
al empezar. Registrando la hora de cada paso de física se vio que llegaban cada
16 ms sin huecos: el monitor de Godot repite el mismo valor durante el primer
segundo, que incluye la carga de la escena. Se espera 2 s antes de medir y se
da la mediana.

**Aviso de fuga de audio al cerrar.** Godot avisa de que se queda un
`AudioStreamPlaybackWAV` si se cierra con la música sonando. Se comprobó que es
del motor: pasa con cualquier sonido sin terminar, aunque se pare justo antes, y
solo desaparece si se para unos fotogramas antes con audio real. No afecta al
jugador; queda anotado en `CLAUDE.md` como aviso conocido.

**Las pruebas ensuciaban los récords.** Una prueba que emitía
`partida_terminada` escribió en el fichero de récords real del jugador. Las
herramientas desconectan `GestorGuardado` del bus, en diferido porque en
`_initialize` los autoloads todavía no se han conectado.

**Las opciones de la pausa salían arriba a la izquierda.** El panel fijaba sus
anclajes a pantalla completa con `set_anchors_preset`, pero su tamaño seguía en
0×0, así que la ventana se centraba en la esquina. Lo vio Adam al jugar; se
confirmó midiendo el tamaño del panel y se corrigió con
`set_anchors_and_offsets_preset`, que fija anclajes y tamaño a la vez.

**Probar el actualizador sin publicar nada.** Se montó un servidor local en
PowerShell que imita la API de releases de GitHub, se exportó un juego «0.2» y
un parche «0.3» desde una copia del proyecto con la dirección cambiada, y se
comprobó en el registro del juego: encuentra la 0.3, la descarga (del 0 al
100 %), se reinicia y arranca como «Versión 0.3 · al día». También: sin
conexión dice que no ha podido comprobar, un ejecutable más nuevo borra el
parche viejo, y contra la API real (que hoy da 404 porque la v0.1 es una
*prerelease*) dice «al día». Leer como JSON una respuesta vacía daba un error
en la consola: ahora se mira el código antes. Las expresiones `sed` de la
Action se probaron con el `sed` de Git.

**El nombre de dos afijos no cabía** sobre el élite. Se vio en las capturas y
se ensanchó la caja de texto.

**PowerShell partía los argumentos con comas** (`capturas=60,150` llegaba como
tres argumentos). Van entre comillas.

**En casa no había `git` en el PATH ni plantillas de exportación.** Se usa el
`git` de GitHub Desktop y se descargaron las plantillas oficiales de Godot
4.7.2 (solo se instalaron las de Windows y Linux de 64 bits).

### Uso de IA

Claude implementó todo lo de la sesión: mapa infinito, persistencia, opciones,
fundidos, el sintetizador de audio y `GestorAudio`, partículas, shaders, élites,
evoluciones, los cambios del simulador, la medida de rendimiento y la
documentación. Diagnosticó con pruebas dirigidas el aura lenta, el falso tirón y
el aviso de audio. Las decisiones las tomó Adam: hacer él el audio y generarlo
por código, hacer las ampliaciones, el objetivo de dificultad, el idioma de la
documentación y dejar el push y la release para más tarde.

Procedencia de los sprites de los personajes y del jefe, aclarada hoy: el
profesor compartió unos sprites de nigromantes hechos con Claude; Adam generó
con Gemini una ilustración parecida con la temática del juego, y a partir de ella
Claude creó las cuatro hojas de sprites.

### Métodos de test empleados

- Importación y arranque en headless tras cada cambio.
- Scripts temporales (borrados antes de cada commit): récords y opciones en
  disco, transición entre escenas, reproducción de cada sonido y música por
  escena, los cuatro afijos (aura, blindaje, replicante y explosión con su
  daño), evoluciones sin tocar los `.tres`, y la navegación entre pausa y
  opciones con teclas reales (Esc, P y Enter).
- Capturas con ventana de una partida que juega sola, para comprobar los
  shaders, que no se compilan en headless.
- Simulador de partidas: seis tandas de 5 partidas para el balance.
- `medir_rendimiento.gd` en la RTX 5070: 300 enemigos a 1549 FPS (física
  2,02 ms) y 1200 a 733 FPS (física 9,27 ms; peor paso 10,51 ms).
- El ejecutable de Windows exportado arranca sin errores fuera del editor.

### Estado al cerrar

Los 13 requisitos mínimos están cubiertos, y también el MVP y las ampliaciones.
Todo está commiteado en `main` pero **no se ha subido a GitHub** (Adam lo hará
después). La release v0.2 la publicará la GitHub Action al subir la etiqueta
`v0.2`, ya con el actualizador dentro.

### Siguiente paso

1. Subir `main` y publicar la release v0.2 subiendo la etiqueta (`git tag v0.2`
   y `git push origin v0.2`): la Action la exporta y la publica. Comprobar en la
   pestaña Actions de GitHub que termina bien, porque es la primera vez que se
   ejecuta. Los `.zip` que se exportaron a mano se borraron: no llevaban el
   actualizador.
2. Entregar el informe del primer seguimiento (2 de octubre).
3. Vídeo demostrativo (Adam pidió que se le recuerde).
4. Probar el ejecutable en un ordenador sin Godot.
5. Ensayar la defensa con `presentacion.md` y acordar con Alan su parte.

---

## Sesión 7 — 02/10/2026

**Duración:** 2 h · **Fitas:** 4, 5 y 6 · **Participantes:** Adam (desde casa)

**Horas acumuladas:** 14 h de las 60 sugeridas (23 %)

### Qué se ha hecho

- **Lo que quedó fuera de la sesión 6:** al cerrarla se subió `main` y se
  publicó la release v0.2 con la GitHub Action. La primera vez no se lanzó,
  porque la etiqueta llegó en el mismo push que el fichero de la Action; se
  volvió a subir la etiqueta y terminó bien. El ejecutable que exporta la
  Action arranca sin errores.
- **Contenido nuevo que Adam hizo fuera**, con Claude en una conversación
  aparte: tres zips con los dibujos, el suelo y un texto de instrucciones. Se
  integró aquí en cinco bloques, con un commit cada uno:
  - **A. Suelo de placa base animado**: 12 baldosas de pixel art que encajan
    sin costuras, pulsos de datos por las pistas, LEDs, ventiladores y brillo
    en los chips. Los pulsos se aceleran con la partida y se vuelven rojos
    con el jefe.
  - **B. Enemigos redibujados**: los tres de la horda y el élite, con el mismo
    nombre, tamaño y color.
  - **C1. Ransomware**: enemigo de horda lento y muy resistente desde el 6:00,
    como mucho 8 a la vez.
  - **C2. Troyano**: enemigo de horda desde el 4:00 que, al acercarse,
    parpadea en rojo y embiste como el jefe.
  - **C3. Tres mejoras**: Actualizar firmas (el malware se adapta un 30 % más
    despacio), Cambio en caliente (-20 % de espera entre personajes, mínimo
    4 s) y Caché ampliada (+30 % de radio de recogida).
- **Arreglo del shader de la horda**, que oscurecía todos los sprites (ver
  Problemas).
- **Sprites para la experiencia y el Ping** (un cuarto zip, también hecho con
  Claude aparte). Los fragmentos de datos y el proyectil del Ping eran
  cuadrados de color. Ahora el fragmento es un cristal en grises que cada gema
  tiñe según lo que vale (cian de 1 a 2, verde de 3 a 9 y dorado desde 10), y
  el proyectil es un rayo con estela girado hacia donde va.
- **Simulador**: cuenta los enemigos por tipo y su bot elige mejoras como un
  jugador.
- **Documentación**: técnica, manual, créditos, presentación (con las
  preguntas sobre el suelo, el troyano, el ransomware y Actualizar firmas),
  README con capturas nuevas, `GEMINI.md` y `CLAUDE.md`.
- **Encontrado en GitHub:** dos ramas que la bitácora no recoge,
  `demo-movil` (controles táctiles y exportación web para una demo en el
  móvil, dos commits del 01/10 firmados por Claude) y `gh-pages` (esa demo
  publicada en GitHub Pages). No están fusionadas en `main` y no se han
  tocado; se avisó a Adam.

### Decisiones técnicas y por qué

**Solo entra en el repositorio lo que va en el juego.** Los zips no estaban
descomprimidos. Se abrieron aparte y solo se copió su carpeta `projecte/`. Los
textos de instrucciones, las vistas previas y los scripts de Python que
generaron los dibujos se quedan fuera; su procedencia está en `creditos.md`.

**El suelo, entendido para defenderlo.** El shader parte el mundo en casillas
de 256x256 y cada una elige uno de los 12 dibujos con un número al azar fijo
para esa casilla. Las otras dos texturas son datos: la máscara dice qué
píxeles son pistas con datos, cuánto camino llevan y en qué dirección van, y
el shader enciende el punto cuyo camino coincide con el avance; la de efectos
marca LEDs, aspas y brillo. El avance lo suma `arena.gd` y no el reloj del
shader, para cambiar la velocidad sin que los pulsos salten. La arena usa una
copia del material para que el rojo del jefe no pase a la partida siguiente.
Las texturas son opacas, así que la importación por defecto no altera la
máscara (se comprobó).

**`generar_sprites.gd` ya no dibuja enemigos.** Se quitaron las cuatro líneas
que los guardaban y también las funciones que los dibujaban, en lugar de
comentarlas: habrían quedado como código muerto difícil de justificar. Los
dibujos antiguos siguen en el historial de Git.

**Un máximo a la vez por tipo, no pesos** (decisión de Adam). El director
elige el tipo al azar y el ransomware se acumulaba (ver Problemas). Se
probaron dos formas con el simulador: un peso por tipo (con 0,25, 5 de 5
victorias, pero aún 40-75 ransomware al final) y un máximo de vivos a la vez
(con 8, 3 de 5 y siempre 8 en pantalla). Ganó el máximo por ser una sola
comparación (`cabe_otro()`) y la regla más fácil de contar: "nunca hay más de
ocho".

**La embestida del troyano va en su propio script.** El troyano repite la
máquina de estados del jefe (perseguir, aviso y embestida), pero no es un nodo:
su estado, su cronómetro y su dirección van en tres arrays de tamaño fijo con
el mismo índice que su posición, y `_eliminar` los copia al hueco nuevo como
la vida. Meterlo en `gestor_enemigos.gd` lo llevaba a unas 270 líneas; en
`embestida_horda.gd` el gestor se queda en 245 y solo lo crean los tipos con
`embiste = true`. Los valores (220 px, 0,4 s, 0,6 s, el triple de velocidad,
2,5 s) están en `DatosTipoEnemigo`, como el resto de cada tipo. Durante el
aviso se queda quieto y apunta al jugador hasta el último momento, igual que
el jefe. El aviso llega al shader en `INSTANCE_CUSTOM.g`.

**Sin `class_name` en el script nuevo.** Una clase global nueva no viaja en
el `.pck` de actualización y habría obligado a subir `EJECUTABLE_MINIMO`: los
jugadores con la v0.2 tendrían que bajarse el juego entero. Con `preload` no
hace falta; se comprobó que el número de clases globales no cambia.

**Las mejoras nuevas, como las de siempre.** Multiplicadores en el nodo al
que afectan, sin tocar los `.tres`, y un caso más en el `match` de
`sistema_niveles.gd`. Los efectos nuevos van al final del enum, porque los
`.tres` guardan el número. Actualizar firmas multiplica el aumento de
resistencia por 0,7, como la cadencia, para que nunca llegue a cero. Cambio en
caliente tiene un mínimo de 4 s (sin espera se cambiaría sin parar y la
resistencia no obligaría a decidir) y su descripción lo dice. Para encontrar
el pool de gemas se le dio el grupo `pool_gemas`, como `pool_proyectiles`.

**Un sprite en grises teñido por instancia para la experiencia.** En lugar
de tres sprites, uno solo y `use_colors` en el MultiMesh: el color se elige
con dos umbrales exportados y se escribe en cada fotograma junto a la
posición, porque al recoger una gema la última pasa a su hueco y cambia de
índice. El proyectil se gira con `Transform2D(dirección.angle(), ...)` al
volcarlo al MultiMesh, así que al rebotar no hay que hacer nada más. Los dos
llevan la escala vertical -1, como la horda, porque el QuadMesh invierte la
textura.

**El bot del simulador elige mejoras como un jugador** (decisión de Adam). Con
ocho mejoras, tres sin daño, el bot que elegía al azar dejó de parecerse a un
jugador (ver Problemas). Ahora coge la evolución si sale y, si no, una de daño,
cadencia o alcance si la hay. El balance se mide con este bot y con 10
partidas: 5 se quedaron cortas para ver diferencias.

### Cambios de rumbo y su justificación

**Se añade contenido** aunque desde la sesión 6 la prioridad era la entrega:
lo pidió Adam y estaba hecho fuera.

**La referencia de dificultad cambia de bot.** El objetivo sigue siendo 3-4
victorias de 5, pero medido con el bot nuevo. Con él, el juego da 9 de 10
antes del contenido nuevo y 8 de 10 después.

### Problemas encontrados y cómo se resolvieron

**El ransomware se acumulaba.** Con la misma probabilidad que los demás,
salían unos 250 por partida entre el 6:00 y el 10:00, el bot apenas los
mataba y lo seguían en bloque. Se vio gracias al recuento por tipo que se
añadió al simulador. Resultado con 5 partidas: de 4 victorias a 1. Con el
máximo de 8 a la vez: 3 de 5.

**La horda se veía más oscura que sus sprites desde la sesión 6.** Al probar
el parpadeo del troyano, el rojo salía marrón. Se descartó paso a paso: los
números del shader llegaban bien (rectángulos que pintan valores fijos) y
`INSTANCE_CUSTOM` también (un MultiMesh de prueba que lo pinta tal cual). Al
dibujar el mismo PNG con un `Sprite2D`, con un MultiMesh con el shader por
defecto y con la horda, solo la horda salía distinta, con cada canal al
cuadrado. En Godot 4 el `COLOR` de `fragment()` ya trae la textura y el shader
la multiplicaba otra vez. Ahora la horda se ve exactamente como sus PNG y el
aviso sale rojo. Queda anotado en `GEMINI.md`.

**Las mejoras nuevas hundían al bot.** Simulador, 10 partidas por variante y
semillas fijas:

| Variante | Bot al azar | Bot que elige ataque |
|---|---|---|
| Antes del contenido nuevo | 9 | 9 |
| Ransomware (8 a la vez) y troyano | 7 | — |
| Todo, con las tres mejoras | 2 | **8** |
| Todo, con evoluciones a las 2 elecciones | 1 de 8 | — |
| Todo, con la horda final cada 0,13 s | 4 | — |
| Todo, con la horda final cada 0,15 s | 6 | — |
| Todo, con el troyano a 30 de vida | 3 | — |
| Todo, con 25 troyanos como mucho | 2 | — |

Los enemigos nuevos solos dejaban el juego en el objetivo. Con las mejoras, al
bot al azar le tocaban menos de ataque y muchas menos evoluciones (de 14 a 5
en 10 partidas), y perdía por no poder con el jefe. Se le propusieron a Adam
dos salidas: hacer la horda final menos densa o que el bot eligiera como un
jugador. Eligió lo segundo, que no cambia el juego.

**El script de capturas se quedaba esperando.** Buscaba un élite con dos
afijos, pero si los tres élites de un afijo seguían vivos no llegaban más. Ahora
espera 60 s y, si no, usa cualquiera.

**Un commit por bloque con ficheros compartidos.** La escena, las reglas, el
gestor y los datos de enemigo mezclaban cambios de C1, C2 y C3. Se prepararon
en Git versiones intermedias de esos ficheros sin tocar la copia de trabajo, y
cada commit intermedio se extrajo a una carpeta limpia, se importó y se
arrancó para comprobar que `main` arranca en todos.

### Uso de IA

El arte nuevo, el shader del suelo y `arena.gd` los hizo Claude en una
conversación aparte con Adam, que trajo los zips. En esta sesión, Claude
(Claude Code) revisó y probó el suelo, integró los enemigos, programó el
ransomware, la embestida del troyano y las tres mejoras, encontró el fallo del
shader de la horda, midió el balance y actualizó la documentación. Las
decisiones las tomó Adam: el máximo a la vez para el ransomware, el bot que
elige ataque y las horas de la sesión.

### Métodos de test empleados

- Importación y arranque en headless tras cada bloque, y también en cada
  commit intermedio extraído a una carpeta limpia.
- Con ventana: capturas del suelo (al empezar, con el jefe y alejado para ver
  las costuras), de los enemigos nuevos y del parpadeo del troyano. Medidas
  píxel a píxel del shader de la horda.
- Scripts temporales: los parámetros del suelo al pasar el tiempo, con el jefe
  y con la pausa, y que el material del fichero no cambia; la embestida
  (distancias y tiempos de cada estado, el aviso en el shader y que el estado
  viaja al eliminar a otro); las tres mejoras por el camino real (subir de
  nivel y elegir), con sus valores, el mínimo de 4 s, el HUD, las tarjetas y
  la ventana de reglas.
- Simulador de partidas: unas veinte tandas, la tabla de arriba.
- Recuento de clases globales antes y después del troyano.
- Experiencia y Ping, con ventana: gemas de 1, 4 y 10 (cian, verde y dorado,
  leído también del MultiMesh) y un Ping que rebota dos veces entre enemigos
  quietos, con capturas ampliadas en cada dirección (61°, -167° y -19°): la
  cabeza siempre delante.

### Estado al cerrar

Los cinco bloques y el arreglo del shader están en `main`, con la
documentación al día, y subidos a GitHub (Adam lo pidió). También se publicó
la **release v0.3** (etiqueta `v0.3`, a petición de Adam): la Action terminó
bien, `version.json` dice versión 0.3 con ejecutable mínimo 0.2 (quien tenga
la v0.2 se actualiza con el botón) y el ejecutable de Windows que exportó
arranca sin errores.

Después de la v0.3 entraron los sprites de la experiencia y del Ping. Adam los
vio con el `.bat` pero no en el juego descargado: el `.bat` ejecuta el
proyecto tal cual y el juego solo cambia con una release. Se publicó la
**v0.4** con ellos (Action correcta, ejecutable mínimo 0.2 y el ejecutable de
Windows arranca sin errores).

### Siguiente paso

1. Entregar hoy el informe del primer seguimiento. No menciona lo de hoy.
2. Que Adam juegue una partida entera con el contenido nuevo, sobre todo
   contra el troyano y el ransomware, y diga si se siente bien.
3. Probar en un ordenador sin Godot la v0.2 y su botón ACTUALIZAR hacia la
   v0.3, que ya está publicada.
4. Vídeo demostrativo (Adam pidió que se le recuerde).
5. Ensayar la defensa con `presentacion.md` y acordar con Alan su parte.
6. Decidir qué se hace con las ramas `demo-movil` y `gh-pages`.

---

## Sesión 8 — 02/10/2026

**Duración:** 1 h · **Fitas:** 4 y 5 · **Participantes:** Adam y Alan (pruebas
de juego), Adam (con Claude)

**Horas acumuladas:** 15 h de las 60 sugeridas (25 %)

### Qué se ha hecho

Adam y Alan jugaron la v0.4 y trajeron una lista de mejoras. Todas están
hechas:

- **Equilibrio de personajes.** El "amarillo" era el Segador (Escáner), muy
  por encima. Ahora llega a 150 px (antes 200) y pega cada 2,5 s (antes 2,2);
  el Firewall llega a 110 px (antes 90) y el Ping salta una vez más y pega más.
- **Habilidades rebajadas:** mejora de daño del +20 % al +12 %, de alcance del
  +15 % al +10 % y evoluciones más flojas.
- **Los enemigos ganan vida con el nivel del jugador:** un 4 % por nivel.
- **El doble de enemigos**, para que el juego sea más frenético.
- **Cuesta más subir de nivel:** cada nivel pide un 50 % más que el anterior
  (antes un 35 %).
- **Los élites recompensan:** al matarlos curan el 50 % de la vida y regalan
  una mejora.
- **Barras de vida con borde** en élites, jefe y ransomware.
- **Ficha del enemigo al hacer click**, arriba a la derecha, como en el League
  of Legends.
- **La experiencia sin recoger caduca a los 30 s**, parpadeando los tres
  últimos.
- **Ranking** de las 10 mejores partidas con nombre, con su botón en el menú.
- Se publicó la **v0.5** con todo.

### Decisiones técnicas y por qué

Todas las preguntas se hicieron a Adam con opciones; eligió casi siempre la
recomendada.

**Bajar al Segador y subir a los otros** (decisión de Adam), en lugar de
tocar solo uno: así cada personaje tiene su sitio (Firewall cuerpo a cuerpo,
Ping a distancia, Escáner contra grupos) y no se cambia tanto la dificultad.

**La vida por nivel, en los datos del enemigo.** `vida_extra_por_nivel` y
`vida_para_nivel(nivel)` en `DatosTipoEnemigo`, que usan igual la horda y los
élites. El nivel les llega por `experiencia_cambiada`, una señal del bus que ya
existía. El jefe no cambia: está equilibrado aparte. Cada enemigo de horda
guarda además su vida máxima (`_vidas_maximas`), porque depende del nivel al
que apareció; la usan las barras y la ficha.

**La mejora del élite, en la cola de las mejoras.** El sistema de niveles
escucha `enemigo_muerto` y, si es un élite, suma una mejora pendiente sin
subir de nivel. El contador pasó a llamarse `_mejoras_pendientes`. La curación
la hace el propio élite al morir, con `Salud.curar(fraccion)`. El panel
técnico calculaba el nivel contando paneles de mejora; ahora lo lee de
`experiencia_cambiada`.

**Experiencia que caduca a los 30 s** (decisión de Adam, frente a 15 s o a
fusionar gemas). Cada gema guarda los segundos que le quedan; si ya vuela hacia
el jugador no caduca, porque perderla en el último momento parecería un fallo.
El parpadeo baja la transparencia del color de la instancia. También se
olvidan antes al alejarse (1800 → 1200 px).

**Barras con doble borde** en un script compartido (`barra_vida_enemigo.gd`)
que usan el élite, el jefe y el gestor del ransomware. Solo para tipos con
`mostrar_vida`: con el proceso colgado (cientos a la vez) sería ruido. La horda
se dibuja detrás de su gestor (`show_behind_parent`) para que no tape las
barras.

**Ficha del enemigo.** Cada objetivo tiene `ficha_en(punto, radio)` y
`ficha(id)`; la interfaz recorre el grupo `objetivos`, como hacen las armas.
Para seguir a un enemigo de horda, que cambia de índice al morir otro, cada uno
lleva un id único que se copia en `_eliminar`. El panel técnico (F3) bajó a la
esquina inferior para dejar sitio.

**Ranking local con nombre** (decisión de Adam: ni online, que necesitaría
servidor, ni sin nombres). Lista de diccionarios en el mismo `ConfigFile`,
ordenada con `sort_custom`: victorias de la más rápida a la más lenta y
después derrotas de la que más aguantó. El nombre solo se pide si la partida
entra. `partida_terminada` lleva ahora también el personaje.

**Sin `class_name` en los tres scripts nuevos** (barras, ficha y ranking), para
que la v0.5 se instale con el botón ACTUALIZAR. Se comprobó que siguen siendo
16 clases globales.

### Cambios de rumbo y su justificación

**Objetivo de dificultad: de 3-4 a 2-3 victorias de 5** (decisión de Adam),
para que se sienta la presión y se pueda morir.

**De +8 % a +4 % de vida por nivel, y un 25 % más de daño base** (decisión de
Adam tras ver los datos). Con todo lo pedido tal cual, el bot no ganaba nunca.

### Problemas encontrados y cómo se resolvieron

**Todo junto era imposible.** Cuatro cambios que endurecen el juego a la vez
(el doble de enemigos, la vida por nivel, menos niveles y mejoras más flojas)
dejaban al bot en 0 victorias de 10: a los 9 minutos tenía más de mil enemigos
alrededor. Simulador, 10 partidas por variante:

| Variante | Victorias de 10 |
|---|---|
| Todo lo pedido (+8 % por nivel) | 0 |
| Con 1,5 veces los enemigos en lugar del doble | 1 |
| Con +5 % por nivel | 0 |
| Curva del 42 % y mejora de daño del +15 % | 0 |
| Herramientas con un 40 % más de daño | 1 |
| Algo menos de densidad al final | 1 |
| Enemigos con un 40 % menos de vida base | 2 |
| Lo anterior y menos densidad al final | 2 |
| 1,5 veces los enemigos con un 25 % menos de vida | 2 |
| Jugador con 150 de vida y más regeneración | 1 de 4 |
| **+4 % por nivel y herramientas con un 25 % más de daño** | **6** |

Lo que más pesaba era la vida por nivel. Con la última fila el juego queda en
el objetivo y las partidas tienen el doble de eliminados (2500-2900 en las
victorias, antes unos 1400).

**El filtro de seguridad bloqueó un comando** que editaba el manual con
reemplazos en PowerShell (lo tomó por un borrado). Se hizo con el editor.

### Uso de IA

Claude programó todos los cambios, propuso las opciones de cada pregunta,
buscó con el simulador una combinación que cumpliera el objetivo y actualizó la
documentación. Las ideas salieron de la partida de prueba de Adam y Alan y las
decisiones las tomó Adam.

### Métodos de test empleados

- Importación y arranque en headless tras cada cambio, y recuento de clases
  globales.
- Gemas: una gema lejos de un jugador quieto parpadea a partir de los 27 s y
  desaparece a los 30,0 s.
- Élite y vida por nivel: al nivel 5, un bit sale con 26,4 de vida y un élite
  con 594 (los dos ×1,32 con el 8 % que se probó primero); matar al élite cura
  100 de 200, abre el panel sin subir de nivel y al elegir se quita la pausa.
- Ficha, con ventana y clicks de ratón simulados: enseña la vida del ransomware
  pinchado, lo sigue cuando muere otro y cambia de hueco, se cierra al morir
  él, funciona con el élite y se cierra con click derecho. Captura de las
  barras con borde.
- Ranking, con copia de seguridad del fichero de guardado del jugador (se
  restauró después): pide el nombre con el foco puesto, recorta los espacios,
  ordena 12 partidas inventadas y se queda con 10, solo pide nombre si la
  partida entra, y la ventana del menú enseña 10 filas. Capturas de las dos
  pantallas.
- Simulador: once variantes de 10 partidas (tabla de arriba) y la final en el
  repositorio: 6 de 10.

### Estado al cerrar

Todo commiteado y subido a `main`, y publicado como **v0.5**.

### Siguiente paso

1. Que Adam y Alan jueguen la v0.5 y digan si la presión y el equilibrio entre
   personajes se notan como querían.
2. Probar en un ordenador sin Godot la actualización desde la v0.2.
3. Vídeo demostrativo (Adam pidió que se le recuerde).
4. Ensayar la defensa con `presentacion.md`, que tiene las preguntas nuevas.
5. Decidir qué se hace con las ramas `demo-movil` y `gh-pages`.

---

## Sesión 9 — 06/10/2026

**Duración:** 2 h · **Fitas:** 4, 5 y 6 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 17 h de las 60 sugeridas (28 %)

### Qué se ha hecho

Al empezar, Claude bajó de GitHub los 41 commits de Adam de casa (sesiones 6 a
8, releases v0.2 a v0.5 y las ramas `demo-movil` y `gh-pages`). Después:

- **Aviso de versión nueva con el juego abierto.** El juego pregunta a GitHub
  al arrancar y cada 5 minutos, también en plena partida, y avisa arriba en el
  centro con ACTUALIZAR o AHORA NO (`aviso_actualizacion.gd`).
- **El juego en el móvil, fácil de encontrar.** Botón JUGAR AHORA y código QR
  al principio del README, y el enlace en el «About» del repositorio. Los
  controles táctiles de `demo-movil` pasaron a `main` y la Action de las
  releases publica también la web, así que el enlace tiene siempre la última
  versión.
- Se publicó la **v0.6** con lo anterior.
- **ACTUALIZAR ya no manda a GitHub.** Adam lo probó en Windows y en Linux
  con la v0.5 y el botón abría la página de la release. Arreglado para la v0.7
  (ver «Problemas»).
- **Disparo del Ping en morado**, el color del Mago (dibujo de Adam con Claude
  en el chat).
- **Premio de los élites: corazón y cofre con ruleta** (dibujos de Adam con
  Claude en el chat). Al morir, el élite suelta un corazón, que cura el 50 %, y
  un cofre que abre una ruleta de 8 mejoras. Sustituye a la cura instantánea y
  la mejora gratis de la sesión 8.
- **Cada personaje tiene su vida** (Espadachín 120, Segador 100, Mago 90). Los
  que esperan se curan; si cae el activo se elige quién sigue, y se pierde al
  caer los tres.
- **E pasa al siguiente personaje y Q vuelve al anterior; C abre el panel del
  equipo** a la derecha, pequeño, con la vida, la herramienta, la resistencia y
  el estado de cada uno.
- Se publicó la **v0.7** con todo lo de la tarde.

### Decisiones técnicas y por qué

**Las consultas a GitHub, cada 5 minutos.** Sin cuenta, GitHub deja 60 por
hora desde una misma conexión: cada 5 minutos son 12, y caben varios jugadores
en la red del instituto. Las consultas siguientes a la primera son silenciosas
y un corte de red no esconde una actualización ya encontrada.

**Los botones del aviso no cogen el foco**: si lo cogieran, Enter o las
flechas de la partida los pulsarían sin querer.

**La web se publica con cada release y no desde `demo-movil`**: así no hay que
mantener dos ramas y el enlace no se queda atrás. En la web no hay
actualizador (el navegador ya baja la última versión) ni botón SALIR, y se
activó el teclado virtual para escribir el nombre del ranking.

**El instalador del juego completo va con el contenido, no en el
actualizador** (`instalador_juego.gd`). `actualizador.gd` lo carga el
ejecutable antes que cualquier actualización, así que lo que cambie en él no
llega a los ejecutables viejos. El instalador viaja en el `.pck`: un ejecutable
antiguo que recibe la v0.7 ya sabe instalarse el siguiente ejecutable. Descarga
el `.zip` de la release, aparta el ejecutable en marcha (Windows deja
renombrarlo pero no borrarlo), pone el nuevo y reinicia; el viejo se borra al
arrancar. Si algo falla, abre la página como antes.

**El premio, decidido con el prompt de Adam:**
- `premios_elite.gd`, un nodo de la partida que escucha la muerte del élite en
  el bus: el élite no sabe nada de los premios. Sprite2D normales, porque no
  hay más de tres élites.
- El cofre avisa con `cofre_recogido` y la cola del sistema de niveles pasa de
  un contador a una lista de «nivel» y «cofre»: **cada elemento sale con su
  panel**, en orden de llegada, y el cofre nunca se convierte en tres tarjetas
  ni al revés.
- La ruleta (`panel_ruleta.gd`) recibe en `ruleta_abierta` los 8 sectores y el
  premio ya sorteado; el giro solo lo enseña. Contesta con la
  `mejora_seleccionada` de siempre, así que aplicar la mejora, las evoluciones,
  el sonido y la columna del HUD funcionan sin tocarlos. Apunta el nivel en el
  mismo diccionario que el panel de mejoras, antes de emitir.
- Los iconos no giran con el disco: se recolocan cada fotograma en el ángulo de
  su sector más el giro. El disco frena con un `Tween` (EASE_OUT, TRANS_CUBIC,
  3,5 s) hasta -(45·k) - 360·vueltas grados.
- Se acepta con click, Enter o espacio, no sola: así el jugador ve qué le ha
  tocado.
- Va en un solo commit `feat` y no en dos: el cofre sin la ruleta habría dejado
  el juego pausado en el commit intermedio.

**La vida por personaje, decidida con preguntas a Adam** (eligió 120/100/90,
que se curen en el banquillo, pausa para elegir al caer, y C para un panel
pequeño a la derecha):
- El nodo `Salud` del jugador es siempre la vida del activo; el equipo
  (`cambio_personaje.gd`) guarda la de los demás y la intercambia al cambiar.
  Así las barras, el daño de los enemigos y el corazón no cambian.
- Los que esperan recuperan 1,5 por segundo. Memoria redundante sube a los tres.
- Al caer el activo, el juego se pausa (`personaje_caido`), la interfaz
  contesta con `personaje_elegido` y el que entra tiene 2 s sin recibir daño:
  si no, la horda que acaba de matar al primero mataría al segundo al momento.
- `equipo_cambiado` lleva el estado de los tres para la interfaz.
- **El sonido de daño escucha ahora `jugador_danado`.** Antes comparaba la
  vida, y al cambiar a un personaje con menos sonaba como un golpe.

**Q y E sin pedir el ejecutable nuevo.** Están en `project.godot`, que no
viaja en el `.pck`. En los ejecutables viejos, que traen Q para «siguiente», el
equipo corrige las teclas al empezar la partida
(`_configurar_teclas_antiguas`). Así `EJECUTABLE_MINIMO` sigue en 0.2.

### Cambios de rumbo y su justificación

**`EJECUTABLE_MINIMO` vuelve a 0.2.** Por la mañana se subió a 0.6 con la regla
«un cambio en `actualizador.gd` obliga a subirlo». La regla era demasiado
estricta: el contenido no necesitaba nada del actualizador nuevo. Corregida en
`CLAUDE.md`.

**El premio del élite de la sesión 8 (cura y mejora al momento) pasa a corazón
y cofre**, a petición de Adam: ahora hay que ir a por ellos.

### Problemas encontrados y cómo se resolvieron

**ACTUALIZAR abría GitHub.** Con el mínimo en 0.6, los ejecutables v0.5 no
podían usar el `.pck`. Solución: el mínimo vuelve a 0.2, el menú vuelve a pedir
la búsqueda (los ejecutables anteriores a la v0.6 no buscan solos) y el
instalador cubre el caso en que de verdad haga falta un ejecutable nuevo.

**El simulador releía los scripts a mitad de la medida.** Al terminar cada
partida, Godot suelta la escena y la siguiente se carga del disco: editar la
jugabilidad mientras corría habría cambiado las reglas a medias. Las medidas se
hicieron sobre una copia del proyecto.

**El panel del equipo no se actualizaba en pausa** y, al caer un personaje,
seguía enseñándolo vivo. Ahora procesa también en pausa, sin que avance la
cuenta atrás del cambio.

**Al caer un personaje no se avisaba del estado del equipo**, y una prueba
eligió a uno ya caído. Se avisa al caer.

**`Salud` enviaba al arrancar los valores del momento de pedirlo**
(`emit.call_deferred` con argumentos) y no los del momento del aviso: el
equipo pone la vida del primer personaje (120) entre medias, y la barra
habría salido con 100. Ahora envía los valores de cuando avisa.

### Uso de IA

Claude programó todo, propuso las opciones de cada pregunta y redactó la
documentación. Los dibujos del Ping, el corazón, el cofre y la ruleta los hizo
Adam con Claude en el chat, con un prompt que describía cómo meterlos; las
decisiones de diseño (premio, vidas, teclas, panel) las tomó Adam.

### Métodos de test empleados

- Importación y arranque en headless tras cada cambio, y recuento de clases
  globales (16, sin cambios).
- **Actualizador, de punta a punta, con un servidor local que imita la API:**
  - Por la mañana, un ejecutable 0.6 en partida ve la 0.7, la descarga y
    arranca con ella.
  - Por la tarde, un ejecutable construido desde la etiqueta v0.5 recibe la
    0.7 por `.pck`. Con una «0.8» que pide ejecutable nuevo, se lo instala solo
    y arranca como «0.8 · al día».
- **Web en local**, servida por HTTP y con el navegador a tamaño de móvil:
  joystick, pausa al subir de nivel y elegir mejora con un toque.
- **Prueba temporal del premio**, con la partida y el HUD de verdad:
  - Al morir el élite caen el corazón y el cofre, sin cura instantánea, y el
    corazón cura de 30 a 80.
  - El cofre pausa y abre la ruleta, y Enter no acepta mientras gira.
  - La rueda para en -270° con el premio en el sector 6, y se aplica ese.
  - Con un nivel y un cofre en la cola, sale cada uno con su panel y la pausa
    no se puede quitar.
  - Con una evolución disponible, entra en la ruleta.
- **Prueba temporal del equipo:**
  - Vidas 120/90/100 y E y Q en las dos direcciones.
  - La espera bloquea el cambio y no suena daño al cambiar.
  - El banquillo se cura y Memoria redundante sube a los tres.
  - El panel C enseña el estado de cada uno.
  - Al caer el activo hay pausa, la tecla del caído no hace nada y el elegido
    entra protegido.
  - E y Q se saltan a los caídos y la partida acaba al caer los tres.
  - Las teclas se corrigen en un ejecutable viejo.
- **Capturas con ventana:** Ping morado (también el de inundación), corazón y
  cofre en el suelo, cofre abriéndose, ruleta parada con el premio, panel del
  equipo y ventana de personaje caído.
- **Simulador (10 partidas, mismas semillas):**

  | Versión | Victorias | Duración media | Notas |
  |---|---|---|---|
  | Antes de hoy | 6 de 10 | 602 s | |
  | Con el corazón y el cofre | 2 de 10 | 588 s | Sin la cura al momento, cuatro partidas que se ganaban se pierden antes (538-589 s) |
  | Con todo (premios y vida por personaje) | 7 de 10 | 751 s | 48 cofres de 48 élites; solo 4 personajes caídos en 10 partidas. Las 3 derrotas son el bot sin acabar con el jefe en 4 minutos, ninguna por caer los tres |

### Estado al cerrar

Todo commiteado y subido a `main`, y publicado como **v0.7** (la Action exportó
el juego, el `.pck`, `version.json` con ejecutable mínimo 0.2 y la web). El
balance queda por encima del objetivo (7 de 10 frente a 4-6).

Adam jugó la v0.7 al final de la clase y dejó apuntado lo que hay que hacer en
la sesión siguiente (ver «Siguiente paso»). No hubo tiempo de hacerlo hoy.

### Siguiente paso

Encargado por Adam el 06/10 para la sesión siguiente. Cuando diga «hazlo», es
esta lista, en este orden, cada bloque en su commit:

1. **Colores de la experiencia** (apartado C del prompt de
   `premios_ping_y_xp.zip`; los apartados A y B, Ping y premio, ya están
   hechos y sus PNG son idénticos a los del repositorio). Las gemas se
   camuflan con el suelo porque el cian y el verde son los colores de las
   pistas; Adam probó cuatro combinaciones sobre el suelo y eligió la 2. En
   `pool_gemas.gd`:
   - `color_bajo = Color(1.0, 0.92, 0.3)`, amarillo (la gema común)
   - `color_medio = Color(1.0, 0.55, 0.2)`, naranja
   - `color_alto = Color(1.0, 0.35, 0.85)`, magenta (la que más vale)

   No hace falta sprite nuevo: `fragmento_datos.png` es gris y se tiñe por
   instancia, y `raiz_juego.tscn` no sobrescribe los colores (comprobado).
   Cambiar los textos que dicen «cian, verdes o dorados»: `panel_reglas.gd`
   (Experiencia), `manual_usuario.md` y `documentacion_tecnica.md`. Captura con
   ventana de las gemas en partida.
2. **Menos horda cuando llega el jefe.** A los 10 minutos queda demasiada
   oleada en pantalla. Preguntar a Adam si prefiere bajar la densidad en el
   último minuto o que la horda que queda se retire al aparecer el jefe.
3. **El ransomware es demasiado lento**: casi no molesta. Subirle la
   velocidad (`recursos/enemigos/datos/ransomware.tres`).
4. **Un jefe más difícil**, que ahora dura poco:
   - Ataques más fuertes (daño por contacto y de la embestida, quizá más
     vida).
   - **Que invoque oleadas de enemigos** cada cierto tiempo, con un movimiento
     propio antes de cada una, como si los estuviera generando (por ejemplo,
     se para, brilla o late y salen a su alrededor), para que se vea que salen
     de él. Los enemigos los crean los gestores de horda (`aparecer`), como
     hace el replicante.
5. **Medir con el simulador antes y después** (mismas semillas, 10 partidas,
   sobre una copia del proyecto). Hoy da 7 de 10 y el objetivo es 4-6: el
   jefe más duro debería bajarlo. Si sigue alto, proponer a Adam bajar la
   curación del banquillo de 1,5 a 0,5 por segundo.
6. Publicar la v0.8 cuando Adam lo pida.

Después: vídeo demostrativo (Adam pidió que se le recuerde) y ensayo de la
defensa.

---

## Sesión 10 — 08/10/2026

**Duración:** 2 h · **Fitas:** 5 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 19 h de las 60 sugeridas (32 %)

### Qué se ha hecho

Al empezar no había nada nuevo en GitHub ni en la rama de Alan. Adam preguntó
cómo hacer un ranking mundial con Supabase; se le explicó (tabla con reglas de
acceso, clave `anon` pública, pestaña «Mundial», límites contra trampas
evidentes, pausa del plan gratuito tras 7 días sin uso) y lo deja para más
adelante.

El encargo de la sesión 9 y el equilibrio que pidió tras jugar la v0.7:

- **Gemas amarillas, naranjas y magentas** (la opción 2 de la vista previa de
  Adam): el cian y el verde se camuflaban con las pistas del suelo.
- **Ransomware más rápido:** de 70 a 105.
- **La horda huye al llegar el jefe:** se aleja al doble de velocidad durante
  1,2 s, sin hacer daño, se desvanece y desaparece. No da experiencia ni cuenta
  como eliminada.
- **Enemigos más duros a mitad de partida:** desde el minuto 3, un 15 % más de
  vida por minuto, multiplicado por el +4 % por nivel. Horda y élites.
- **Jefe más difícil:** cada 15 s se para, late en morado mientras crece un
  anillo e invoca un círculo de 12 a 24 enemigos (más cuanto menos vida le
  queda); pega 25 por contacto (antes 15) y 40 embistiendo, embiste cada 6 s
  (antes 7) y tiene 4000 de vida (antes 2500).
- **Segador más flojo:** el Escáner pasa de 27,5 a 22 de daño y su evolución de
  35 a 28, con alcance 170 (antes 190).

Y lo que pidió a mitad de la sesión:

- **Ultis con R** (B en el mando, botón ULTI en el móvil). Cada personaje carga
  la suya matando (180 enemigos; un élite cuenta por 10). Mago: rayo morado
  hacia el enemigo más cercano. Espadachín: giro con seis hojas de luz. Segador:
  un rayo sobre la guadaña y diez mini rayos alrededor. La carga se ve bajo la
  vida del personaje, en la línea de abajo y en el panel del equipo (C).
- **Recoger premios, más visual:** el corazón crece, se desvanece y suelta un
  «+N» verde; el cofre salta con un destello dorado y empieza a abrirse antes
  de la ruleta.
- **Menú de desarrollador con F1**, en todas las versiones: ir a un minuto y
  segundo, jefe ya, élite ahora, corazón y cofre aquí, limpiar la horda,
  velocidad x1, x2 o x4, subir de nivel, invencible, llenar las ultis, revivir
  al equipo, cambiar sin espera y darse cualquier mejora o evolución.
- **Menú VERSIONES** para instalar cualquier versión publicada, también una
  anterior, y en Opciones «Avisar de versiones nuevas» para apagar el aviso.
- **Biblioteca de versiones** (tras probar la v0.8, Adam vio que al volver a
  ella todo salía otra vez como INSTALAR): cada versión instalada, y la que
  había antes de cambiar, se guarda en `user://versiones/`. En la ventana
  salen como INSTALADA, con CAMBIAR (al momento, sin descargar) y BORRAR.
- **Las versiones v0.2 a v0.7, republicadas con el botón VERSIONES**, para
  poder cambiar también desde ellas (Adam lo autorizó: «solo añadiendo eso al
  menú»). Se recompilaron desde su etiqueta con
  `herramientas/recompilar_version.sh`, que añade la ventana y el instalador y
  el botón en el menú, y nada más; se sustituyeron sus `.zip` en GitHub (los
  `.pck` no) y se añadió una nota a cada release.

### Decisiones técnicas y por qué

Todas las preguntas se hicieron a Adam con opciones. Eligió las recomendadas
salvo dónde va el menú de desarrollador: lo quiere en todas las versiones, con
F1, aunque cualquiera pueda usarlo.

**El «personaje naranja» era el Segador.** El Escáner pega a todos los que
pilla en su radio: cada mejora de daño y de alcance le rinde más que a las
otras herramientas, por eso se rebaja su base y no las mejoras.

**La horda huye en vez de bajar la densidad del último minuto**: deja claro
que empieza otra fase. Está en el gestor (`huir`): se invierte la dirección y
se baja la transparencia de su `MultiMeshInstance2D`, porque huyen todos los de
ese tipo a la vez. No se emite `enemigo_muerto`: no los ha matado el jugador.

**La vida por minuto en `DatosTipoEnemigo`** (`vida_para(nivel, segundos)`),
junto a la de nivel: la dificultad depende del reloj y es fácil de explicar.
Los segundos llegan por `tiempo_partida`, una señal que ya existía.

**La invocación, tercer estado del jefe** (`INVOCAR`), como el aviso y la
embestida. El aviso da tiempo a apartarse. Los enemigos los crean los gestores
con `aparecer`, como el élite replicante, y solo de los tipos sin límite de
vivos. Señal nueva: `jefe_invoco`, para el sonido.

**Las ultis** (`ultis.gd`, un nodo del jugador):
- Una carga por personaje (decisión de Adam), por lo que se mata mientras ese
  personaje está activo: premia jugar con cada uno.
- Pegan con `danar_en_area` al grupo `objetivos`, como las armas, y escalan con
  las mejoras de daño. No cuentan para la resistencia: no son una herramienta.
- Cada ulti es una lista de golpes con su segundo y su zona; se aplican cuando
  llega su momento. El rayo es una fila de círculos seguidos, sin solaparse,
  para que cada enemigo del camino reciba un golpe por pasada.
- Los efectos se dibujan con `_draw` (líneas, polígonos y arcos), sin sprites.
- La R está en `project.godot`, que no viaja en el `.pck`: la corrección de
  teclas de los ejecutables viejos pasa a `teclas_antiguas.gd` y añade la R si
  falta, como ya hacía con Q y E. Así `EJECUTABLE_MINIMO` sigue en 0.2.

**El menú de desarrollador** vive en la partida (`depuracion/panel_trucos.gd`),
como el panel técnico (F3), y usa la jugabilidad directamente. Como lo puede
usar cualquiera, la partida en la que se abre lleva `trucos: true` en
`partida_terminada` y no cuenta para los récords ni el ranking. Las mejoras que
regala avisan con `mejora_regalada` para que el HUD las apunte. Pausa el juego
sin quitar una pausa que no sea suya.

**El menú de versiones** reutiliza el instalador del juego completo
(`instalador_juego.gd`), que ahora acepta cualquier release. Instala el
ejecutable de esa versión con su contenido. No ofrece las releases de prueba.

**La biblioteca, en el instalador.** Antes de cambiar, el ejecutable en marcha
se copia a `user://versiones/<versión>/` (Windows deja leer un ejecutable en
marcha); el que entra sale de ahí, descargado o no. Cada uno ocupa unos 100 MB:
por eso el botón BORRAR. La ventana se queda con todas las teclas mientras está
abierta: así no hace falta tocar el código del menú de las versiones antiguas,
solo poner el botón.

### Cambios de rumbo y su justificación

**El equilibrio, en tres pasos** (simulador, 10 partidas, mismas semillas):

| Versión | Victorias |
|---|---|
| v0.7 | 7 de 10 |
| Jefe nuevo, horda que huye, vida por minuto (15 %), Segador rebajado | 3 de 10 |
| Lo mismo con un 10 % por minuto | 2 de 10 |
| Con las ultis (120 de carga, daño inicial) | 8 de 10 |
| **Ultis con 180 de carga y un 25-30 % menos de daño** | **6 de 10** |

Lo que más pesó fue el jefe: las derrotas de la segunda fila llegan casi todas
después del minuto 10. Entre el 10 % y el 15 % por minuto no hubo diferencia
clara, y se quedó el 15 %. Las ultis, con los valores de partida, derribaban al
jefe enseguida.

### Problemas encontrados y cómo se resolvieron

**Con la vida por minuto, la horda se acumula** entre el minuto 8 y el 10
(unos 1300 enemigos en pantalla al llegar el jefe, antes unos 950). La huida al
llegar el jefe lo resuelve para el final; queda anotado por si en las pruebas
se hace pesado.

**Una sustitución con `perl` metió un salto de línea real** dentro de una
cadena de las reglas y rompía el script. Se vio al importar y se corrigió.

### Uso de IA

Claude programó los cambios, propuso las opciones, midió el equilibrio con el
simulador y redactó la documentación. Las decisiones de diseño y de
equilibrio las tomó Adam tras jugar la v0.7.

### Métodos de test empleados

- Importación y arranque en headless tras cada cambio.
- Prueba temporal del jefe y la horda: vida por minuto (un bit, 20 de vida
  hasta el 3:00, 29 al 6:00 y 38 al 9:00), huida de 46 enemigos en 1,2 s sin
  contar como eliminados, e invocaciones de 12 y de 21 enemigos (con 1000 de
  4000 de vida).
- Prueba temporal de las ultis y del menú de desarrollador:
  - La ulti se llena con 120 eliminaciones (el valor de entonces) y cada
    personaje tiene la suya.
  - El giro deja 1 de 13 procesos colgados, el rayo 1 de 11 y la tormenta 0
    de 17.
  - F1 pausa y marca la partida con trucos. Saltar a 7:30 deja el siguiente
    élite en el 8:30, y regalar una mejora la aplica y la apunta en el HUD.
  - El corazón cura y suelta su «+N», y el cofre se anima antes de la ruleta.
- Menú de versiones, de punta a punta con un servidor local que imita la API:
  un juego 0.8 lista la 0.8 y la 0.5 (la 0.1, de prueba, no), instala la 0.5
  y arranca con ella.
- Biblioteca, con el mismo servidor y una v0.5 recompilada con el botón:
  desde la 0.8 se instala la 0.5 (descargando); desde la 0.5, la 0.8 sale como
  INSTALADA y se vuelve con CAMBIAR (sin zip en el servidor: sale de la
  biblioteca); y en la 0.8 la 0.5 sale como INSTALADA.
- Las seis versiones recompiladas arrancan sin errores de script.
- Capturas con ventana: gemas de colores, horda huyendo, jefe invocando, las
  tres ultis y el menú de desarrollador.
- Simulador: la tabla de «Cambios de rumbo».

### Estado al cerrar

La sesión se cortó por falta de tiempo antes de cerrarla: esta entrada se
escribió al empezar la sesión 11. La v0.8 quedó publicada (ultis, jefe nuevo,
menú de desarrollador y de versiones) y subido a `main` todo menos la
biblioteca de versiones, que llega con la v0.9. La subida de las releases v0.2
a v0.7 recompiladas se cortó tras la v0.3; se terminó en la sesión 11.

### Siguiente paso

Encargado por Adam al final de la sesión para la siguiente. Cuando diga
«hazlo», es esto:

1. **Las ultis con sprites** (prompt de `ultis_sector_cero.zip`, en Descargas
   del ordenador del instituto; Adam lo descomprime en la raíz del repositorio).
   La lógica no cambia (golpes, daño, radios, tiempos y carga): solo el dibujo.
   - PNG en `projecte/medios/sprites/ultis/`, a 1x, fotogramas en horizontal:
     `ulti_rayo_tramo` (32x80, 4; se repite cada 32 px, centro en y = 40),
     `ulti_rayo_punta` (48x80, 4), `ulti_rayo_origen` (96x96, 4; centrado en el
     origen), `ulti_torbellino` (352x352, 6; cada fotograma gira 10 grados),
     `ulti_tormenta_rayo` (96x448, 4; el impacto es el centro del borde de
     abajo), `ulti_tormenta_impacto` (416x416, 6; onda hasta 200 px),
     `ulti_tormenta_mini` (32x384, 3) y `ulti_tormenta_chispa` (128x128, 5).
   - `referencia/dibujo_ultis.gd` (no se commitea) tiene las funciones
     estáticas `rayo`, `torbellino` y `tormenta` con las que se grabaron los
     GIF: pasarlas a `escenas/jugabilidad/jugador/dibujo_ultis.gd` (preload, sin
     class_name) y llamarlas desde el `_draw` de `ultis.gd`. Borrar `_rayo()` y
     lo que deje de usarse.
   - El nodo `Ultis` de `jugador.tscn`, con `texture_filter = Nearest`.
   - Rayo: sale 22 px más arriba (el pecho) y 40 px por delante, largo 860;
     el grosor se abre en 0,08 s y se cierra en los últimos 0,2 s. Los golpes
     pueden seguir saliendo de `_origen`.
   - Torbellino: el 1,7 de vueltas por segundo, a una constante
     (`GIRO_VUELTAS`).
   - Tormenta: el rayo grande, 0,35 s; la onda, 0,48 s (6 fotogramas de 0,08);
     cada mini rayo en su punto de `_mini` en el segundo 0,3 + i·0,08, con una
     chispa de 0,25 s.
   - Validar, capturas con ventana de las tres ultis (F1, llenar las ultis)
     comparadas con los GIF, una partida del simulador para ver que no hay
     errores, `creditos.md` y `documentacion_tecnica.md`. Commits: uno
     `assets` con los PNG y otro `feat` con el dibujo.
2. **El rayo del Mago se apunta con el ratón:** al pulsar R sale el rayo que se
   va a lanzar siguiendo al ratón, y con el click se lanza (ahora va solo al
   enemigo más cercano). Pensar qué pasa con el mando y en el móvil (sin
   ratón): por ejemplo, que allí siga apuntando solo.
3. Publicar la v0.9 cuando Adam lo pida: lleva la biblioteca de versiones,
   que su v0.8 aún no tiene.
4. Ranking mundial con Supabase (más adelante), vídeo demostrativo y ensayo de
   la defensa.

---

## Sesión 11 — 13/10/2026

**Duración:** 2 h · **Fitas:** 5 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 21 h de las 60 sugeridas (35 %)

### Qué se ha hecho

La sesión 10 se cortó por falta de tiempo a mitad de subir las versiones
antiguas recompiladas. Al empezar:

- **La subida de las v0.2 a v0.7, terminada.** Se había cortado tras la v0.3, y
  la v0.4 había quedado sin descarga del juego completo: al sustituir un
  fichero en GitHub, el anterior se borra antes de subir el nuevo. Se subieron
  la v0.4 a la v0.7, una cada vez, y se añadió la nota a cada release.
- **El script que las recompila**, en el repositorio:
  `projecte/herramientas/recompilar_version.sh`.

Después, el encargo de la sesión 10:

- **Las ultis, dibujadas con sprites** (`medios/sprites/ultis/`, dibujos de
  Adam con Claude en el chat): el rayo de datos del Mago, el torbellino del
  Espadachín y la tormenta del Segador. La lógica no cambia.
- **El rayo del Mago se apunta con el ratón:** con el teclado, R pone a apuntar,
  una línea morada a trazos sigue al ratón y el click lo lanza; el click
  derecho u otra R cancelan sin gastar la carga.

Después, a petición de Adam:

- **El salto de minuto del F1 da el nivel y las mejoras de ese minuto.** Antes
  solo cambiaba el reloj: se llegaba al jefe con nivel 1 y sin mejoras, y así
  no se podía probar. Ahora, al saltar a las 10:00, se llega con nivel 12 y 12
  mejoras (con evoluciones), como en una partida de verdad. Se puede
  desmarcar con una casilla nueva del menú.
- **Publicada la v0.9**, con todo lo de las sesiones 10 y 11.
- **Tres dificultades** (FÁCIL, MEDIA y DIFÍCIL), que se eligen en el menú
  principal. La media es el juego de la v0.9; en media y difícil la horda ya
  no huye cuando llega el jefe, y en fácil sí (decisión de Adam). El ranking y
  la pantalla final enseñan la dificultad de cada partida.
- **Las tarjetas de mejora, más grandes.** Adam vio que el texto del Ping de
  inundación se salía de la tarjeta: las descripciones de las evoluciones son
  las más largas del juego y no cabían en 230x260 (con la fuente de Linux,
  más ancha, tampoco la del Ping). Ahora miden 260x320 y el texto queda
  centrado.
- **La explosión del élite Rootkit, para otra sesión.** Adam pasó al final el
  asset (`explosion_rootkit.zip`: sprites, código de referencia y un
  `PROMPT_CLAUDE_CODE.md` con cómo integrarlo), pero no quedaba tiempo para
  aplicarlo. Está en las Descargas del ordenador del instituto.
- **Publicada la v1.0** con todo lo de la sesión, también en la web. Las
  versiones se comparan número a número (también en los ejecutables de la
  v0.2), así que la 1.0 llega como más nueva que la 0.9.
- **Encargo apuntado para más adelante:** en VERSIONES, descargar una versión
  sin cambiar a ella, y desde todas las versiones. Adam lo pidió tras probar la
  v0.9; está explicado en `CLAUDE.md` y él dirá cuándo hay tiempo.

### Decisiones técnicas y por qué

**El dibujo, en `dibujo_ultis.gd`** (el código con el que Adam grabó los GIF de
muestra): funciones estáticas a las que `ultis.gd` se pasa como lienzo. La
lógica (golpes, carga) y el dibujo quedan en ficheros separados. También va ahí
la mira del apuntado, para que todo lo que se dibuja esté en el mismo sitio. El
nodo `Ultis` usa el filtro nearest para que el pixel art no salga borroso.

**El rayo sale del pecho del Mago** (22 px más arriba) y 40 px por delante,
para que el círculo del origen no le tape. Los golpes siguen saliendo de su
centro: la diferencia es pequeña al lado del radio de 34.

**Apuntar solo con el teclado.** La R del teclado pone a apuntar; la B del mando
y el botón ULTI del móvil, que no tienen ratón, lanzan el rayo solo hacia el
enemigo más cercano, como antes, y el bot del simulador también. El click se
lee en `_input` y no en `_unhandled_input`: la interfaz recibe los clicks antes
que el jugador y, si no, el click izquierdo abriría también la ficha del
enemigo pinchado.

**El nivel y las mejoras de cada minuto salen del simulador.** Para que el
salto sea preciso hacía falta saber qué tiene un jugador en cada minuto. El
simulador ahora anota también las mejoras de cada minuto; se jugaron 10
partidas y la media quedó en una tabla
(`depuracion/progreso_por_minuto.gd`): nivel 2 en el minuto 1, 9 en el 5 y
12 en el 10. Nivel y mejoras van por separado porque cada cofre de élite da
una mejora sin subir de nivel. Las mejoras se eligen como las elige el bot (la
evolución si sale y, si no, una de ataque), entre las mismas opciones que
saldrían en el panel; así el jugador llega igual que las partidas que dan la
tabla. Entre dos minutos se toma lo que queda en medio (a las 7:30, la mitad
entre el 7 y el 8) y, volviendo atrás en el tiempo, no se quita nada. Si
cambia el balance, la tabla se vuelve a medir.

**Las dificultades, en una tabla con tres datos.** `globales/dificultad.gd`
dice, para cada una, cuánto se multiplica la vida de los enemigos (0,7, 1 y
1,2), cuánto el daño que recibe el jugador (0,6, 1 y 1,3) y si la horda huye
al llegar el jefe (solo en fácil). Se eligió así porque son los dos números que
más cambian la partida y se aplican en pocos sitios: la vida, donde aparece
cada enemigo (horda, élite y jefe); el daño, en la salud del jugador, que es
por donde pasan todos los golpes. Sin `class_name` y sin autoload nuevo: con
ellos haría falta un ejecutable nuevo para recibir la actualización. La
elegida se guarda con las opciones, y el simulador la cambia solo en memoria
(`dificultad=facil`) para no tocar las del jugador.

**La media se ha endurecido, y es por la horda que se queda.** Medido con 10
partidas de cada una: fácil, 10 victorias; media, 1; difícil, ninguna (en la
mitad ni llega al jefe). Con la horda huyendo, como en la v0.9, el mismo bot
gana 4 de 10 en media. Se le dijo a Adam para que decida si la media se queda
así o se compensa. Difícil se dejó en 1,2 y 1,3: con 1,3 y 1,4 casi nunca
llegaba al jefe, y con 1,15 y 1,25 llegaba siempre.

**El bot va ahora a por el jefe aunque tenga enemigos cerca.** Antes solo iba
cuando no tenía a nadie alrededor; con la horda presente en el final no llegaba
nunca y todas las partidas acababan por tiempo. Ahora se acerca hasta 120 px
(dentro del alcance del Firewall) apartándose de lo que tiene encima, igual que
con los premios. Con la horda huyendo da 4 de 10 en media en vez de 6: es algo
más torpe contra el jefe, pero sigue dentro del objetivo. Al acabarse el
tiempo, el simulador dice cuánta vida le quedaba al jefe.

**Las 10 partidas, en tres procesos a la vez.** Cada partida simulada tarda
unos 4 minutos. Como cada una empieza con su propia semilla (1000 más su
número), se pueden repartir entre varias copias del proyecto empezando por
otro número y dan las mismas partidas que en serie. El simulador acepta ahora
`desde=6` para eso.

### Problemas encontrados y cómo se resolvieron

**Una release se quedó sin descarga** (la v0.4): `gh release upload --clobber`
borra el fichero viejo antes de subir el nuevo, y la subida se cortó entre las
dos cosas. Se resubió sola; las demás, de una en una, para no pasar del límite
de tiempo de los comandos.

**En las pruebas, el ratón simulado no movía el cursor real**: el juego lee la
posición real del ratón, así que la dirección del rayo de la prueba no era la
del punto simulado. Lo importante se comprobó en las capturas: la mira y el
rayo lanzado siguen la misma dirección.

**El ranking vacío ponía los títulos de las columnas uno debajo de otro.** Se
vio en la captura del ranking al añadirle la columna de la dificultad: con
cero partidas, la tabla pasa a una columna para el mensaje, pero los títulos ya
estaban puestos. Ahora solo se ponen si hay partidas.

**El simulador fallaba en su primer fotograma** al empezar la primera partida
diferida (para poner la dificultad después de que GestorGuardado lea su
fichero): `_paso` ya se ejecutaba sin partida. Ahora espera a que la haya.

### Uso de IA

Claude terminó la subida, integró los sprites a partir del código de
referencia de Adam y programó el apuntado con el ratón. Los sprites y el
código de dibujo los hizo Adam con Claude en el chat; la idea del apuntado es
de Adam. También es suya la del salto con nivel y mejoras: Claude midió la
tabla con el simulador y lo programó. Las tres dificultades y que la horda se
quede en media y difícil son idea de Adam; Claude eligió qué cambia cada una,
midió los valores con el simulador y lo programó.

### Métodos de test empleados

- Importación y arranque en headless.
- Capturas con ventana de las tres ultis a mitad del efecto y de la mira del
  Mago, comparadas con los GIF de Adam.
- Prueba del apuntado: R pone a apuntar sin lanzar, el click izquierdo lanza el
  rayo, el click derecho cancela sin gastar la carga, y el resto de personajes
  lanzan la ulti directamente con R.
- Una partida del simulador: 7 ultis lanzadas, sin errores y con el mismo
  resultado que con el dibujo anterior (el equilibrio no cambia).
- Las releases v0.2 a v0.7 tienen su descarga nueva y su nota.
- 10 partidas del simulador para la tabla del salto: 6 victorias de 10, como
  antes (el equilibrio no cambia).
- Prueba del salto: a las 5:00, nivel 9 y 8 mejoras; a las 10:00 (JEFE YA),
  nivel 12 y 12 mejoras con dos evoluciones; volviendo a las 2:00 no se quita
  nada; no se abre ningún panel y el HUD muestra el nivel y las mejoras.
  Captura con ventana del F1 tras el salto.
- Dificultades: prueba de las tres (multiplicadores, vida de un bit nuevo y
  del jefe, golpe al jugador, huida de la horda y la clave en
  `partida_terminada`), sin tocar las opciones guardadas del jugador.
  Capturas del menú con el selector y del ranking con partidas de cada
  dificultad y una antigua sin ella (sale como MEDIA).
- 10 partidas del simulador por dificultad y dos variantes de difícil, más dos
  comprobaciones: el bot nuevo con la horda huyendo y el bot viejo sin límite
  de tiempo contra el jefe (3 de 10, y en 7 le queda vida tras 10 minutos).
- Captura de las tarjetas con las tres evoluciones antes y después.

### Estado al cerrar

Todo subido a GitHub y publicada la v1.0 (también en la web), con las tres
dificultades. Pendiente de Adam: decidir si la media se queda como está.

### Siguiente paso

1. Jugar la v1.0 y decidir si la media se queda así o se compensa.
2. Descargar versiones sin cambiar a ellas, desde todas las versiones
   (`CLAUDE.md`), cuando Adam diga.
3. La explosión del élite Rootkit con el asset de Adam: descomprimir
   `explosion_rootkit.zip` en la raíz del repo y seguir su
   `PROMPT_CLAUDE_CODE.md` (si la sesión es en casa, pedirle el zip).
4. Ranking mundial con Supabase (más adelante): Adam crea el proyecto y Claude
   le pasa el script SQL y los pasos.
5. Vídeo demostrativo y ensayo de la defensa.

---

## Sesión 12 — 14/10/2026

**Duración:** 2 h · **Fitas:** 5 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 23 h de las 60 sugeridas (38 %)

### Qué se ha hecho

Al empezar no había nada nuevo en GitHub ni en la rama de Alan. Adam pidió
directamente arreglar el menú de versiones, el encargo apuntado en la sesión 11
en `CLAUDE.md`: "sigue sin interactuar bien".

- **INSTALAR solo descarga.** En VERSIONES, INSTALAR descargaba la versión,
  cambiaba el ejecutable y reiniciaba: la versión se abría sola. Ahora solo la
  deja en la biblioteca (`user://versiones/<v>/`), con el porcentaje en su
  fila, y la fila pasa a INSTALADA con CAMBIAR y BORRAR. Se sigue en la
  versión que se tenía.
- **CAMBIAR es lo único que cambia de versión** (el juego se reinicia con
  ella). Mientras cambia, la ventana dice "Cambiando a la vX" en lugar del
  "Descargando la versión X... 0 %" de antes, que no era verdad: no descarga
  nada.
- **BORRAR** vuelve a dejar la fila con INSTALAR; antes la dejaba como
  "BORRADA", sin forma de volver a instalarla sin cerrar la ventana.
- **Las v0.2 a v1.0, vueltas a publicar** con esta ventana, para que funcione
  igual desde todas. Solo cambian los dos scripts del menú de versiones (y el
  botón VERSIONES en las que no lo traían); el resto de cada versión es el de
  su etiqueta. En la v1.0 también los `.pck`, que son lo que descargan las
  demás al pulsar ACTUALIZAR. Cada release lleva una nota con el cambio.

Después, Adam pasó `horda_animada.zip` (dibujos hechos con Claude en el chat,
con un prompt de lo que había que hacer) para pulir animaciones, y pidió
publicar la v1.1 al acabar:

- **La horda, animada.** Cada tipo tiene una tira de 4 fotogramas
  (`recursos/enemigos/sprites/*_anim.png`) cuyo primer fotograma es el sprite
  de siempre, que se queda para la ficha y las reglas. El bit corrupto estira
  los pinchos y muerde, el paquete perdido bate las alas, el proceso colgado
  gira los ojos de "cargando", el troyano trota y el ransomware da tirones.
- **El troyano mira al jugador:** está dibujado mirando a la izquierda y se da
  la vuelta cuando el jugador está a su derecha.
- **Las piernas ya no patinan:** el jugador y el jefe mueven las piernas al
  ritmo al que se mueven de verdad (mejora de velocidad, aura lenta, paredes,
  embestida del jefe).
- **Los élites y el jefe destellan en blanco** al recibir un golpe, como la
  horda: antes no se notaba si se les estaba dando.
- **La barra de experiencia** se llena poco a poco y, al subir de nivel, la
  barra y "NIVEL N" se ponen blancas y la etiqueta da un pequeño salto.
- **Una revisión de todo lo del día** con cinco agentes (ver "Uso de IA"):
  encontró diez defectos reales, que se arreglaron y se probaron (ver
  "Problemas"). Se acabó el tiempo antes de commitear los arreglos, volver a
  publicar las versiones antiguas y publicar la v1.1: quedó para la sesión 13.

### Decisiones técnicas y por qué

**Descargar y cambiar, separados en el instalador.** `instalador_juego.gd`
tiene ahora `descargar_version()`, que solo baja el `.zip` a la biblioteca y
avisa con dos señales propias (`progreso` y `descargada`), y
`instalar_version()`, que es CAMBIAR. La descarga a la biblioteca no toca el
estado del `Actualizador`: si lo pusiera en DESCARGANDO, el menú desactivaría
JUGAR y el texto de la versión diría que se va a reiniciar. Las señales son
del propio instalador, no del bus: solo le interesan a la ventana de
versiones, y el bus es para lo que cruza de la jugabilidad a la interfaz.

**La descarga empieza diferida** (`call_deferred`): así la ventana se conecta
a las señales antes de que empiece. Si la versión ya estuviera, avisaría al
momento y nadie lo oiría.

**Una descarga cada vez.** Mientras descarga, los demás botones y VOLVER se
desactivan: así solo hay un porcentaje que seguir y nada que se pise.

**Cada fila se pinta con una función** (`_poner_botones`), que se vuelve a
llamar al terminar de descargar o al borrar: así la fila siempre enseña lo
que hay en la biblioteca en ese momento.

**El script que vuelve a publicar versiones** se salta añadir el botón en las
que ya lo tienen (desde la v0.8), exporta también los `.pck` y, en modo
prueba, añade al menú un gancho que pulsa en VERSIONES lo que se le pase al
arrancar (`SectorCero.exe -- instalar=v0.5 salir`) y escribe cómo queda cada
fila en el registro del juego. Así se probó el ejecutable de verdad, sin
nadie delante.

**La horda se anima en el shader, sin dejar de ser una llamada de dibujo por
tipo.** Un MultiMesh comparte textura y material entre todos sus enemigos,
pero esa textura puede ser una tira: el shader elige el fotograma de cada uno
con el reloj de la partida y un desfase por enemigo, para que no se muevan a
la vez (al principio eran `TIME` y su `INSTANCE_ID`; la revisión mostró por
qué no, ver "Problemas"). `UV` va de 0 a 1 en el cuadrado del enemigo, así que se
lleva al trozo de la tira que toca: `(UV.x + fotograma) / fotogramas`. El
`COLOR` que llega a `fragment()` ya trae la textura leída con `UV` (el
fotograma 0); por eso se lee la buena y se multiplica por el color del
vértice, guardado en un `varying` en `vertex()`: así el `modulate` de la
huida sigue desvaneciendo la horda. Cada tipo lleva su copia del material,
con sus fotogramas y su velocidad.

**El volteo, en su propio script** (`volteo_horda.gd`), como la embestida:
`gestor_enemigos.gd` ya pasaba de 300 líneas y con el volteo dentro llegaba a
unas 364 (lo señalaba el propio prompt). Un array de tamaño fijo dice hacia
dónde mira cada uno, viaja con él al eliminar a otro y solo cambia si el
jugador está a más de 8 px a un lado, para que no parpadee con el jugador
encima. El volteo es la escala x de su transformación en el MultiMesh.

**El destello de élites y jefe, en un script para su `Sprite2D`**
(`sprite_destello.gd`): un material propio con un shader que mezcla con
blanco, y una cuenta atrás de 0,1 s como la de la horda. Así élites y jefe
solo llaman a `destellar()` y casi no crecen (el élite se queda en 192 líneas).
Va en un shader y no en el `modulate` porque el jefe ya lo usa para su aviso
rojo y su latido morado; se comprobó que, avisando, el golpe lo pone rosado
sin perder el rojo. Cada uno tiene su material: si lo compartieran,
destellarían todos los élites a la vez.

**La barra de experiencia, fuera del HUD** (`panel_experiencia.gd`, como los
demás paneles): el HUD pasa de 169 a 134 líneas. Se llena con un `Tween` y,
al subir de nivel, empieza desde cero con lo que sobró. Al subir de nivel el
juego ya está en pausa cuando llega el aviso, así que sus `Tween` usan
`TWEEN_PAUSE_PROCESS`; la etiqueta crece desde su borde izquierdo para no
salirse del panel. La barra no tiene escalones (`step = 0`): con los de un
punto, el llenado iría a saltos.

**Las piernas, en proporción a la velocidad real:** `velocity.length()` entre
los 240 para los que se ajustaron los 7,7 fotogramas por segundo. Medido: 31,2
px por fotograma de andar sin mejora, con la mejora de velocidad y en el aura
lenta. El jefe, embistiendo, las mueve tantas veces más deprisa como lo es su
embestida (480 frente a 90).

### Problemas encontrados y cómo se resolvieron

**No se podía comprobar en los `.pck` qué ventana llevaban:** los scripts no
se exportan como texto, así que buscar el texto nuevo dentro no lo
encuentra. Se comprobó el código del que salió cada una: los dos scripts
iguales que en `main`, el botón una sola vez, sin el gancho de prueba, el
nombre de verdad y su número de versión.

**En headless, el MultiMesh no guarda nada.** La primera prueba del volteo
leía las transformaciones del MultiMesh y salían todas sin voltear: sin
ventana, el servidor de dibujo es de mentira y devuelve siempre la
identidad. El volteo estaba bien (el array decía lo correcto); se comprobó
con una captura con ventana.

**La medida de rendimiento parecía decir que todo iba el doble de lento.** La
primera medida "después" daba la física al doble que la "antes". Midiendo las
dos versiones una detrás de otra, dos veces, la misma versión variaba más de
una vuelta a otra que entre versiones: era el ruido de la máquina virtual. En
el instituto no se puede medir; queda para casa.

**Al cerrar salían más avisos de memoria que otras veces** (18 objetos y 7
recursos). Con `--verbose` son todos de audio (los sonidos que sonaban al
acabar la partida): el aviso conocido del motor.

**Lo que encontró la revisión, y cómo se arregló.** Todo eran cosas que no
se veían en las pruebas normales:

- *El destello del jefe tapaba el aviso rojo de su embestida* con el Ping
  rebotando contra él (cada rebote lo vuelve a poner blanco), y ese aviso es lo
  que deja esquivarla. Ahora no destella mientras avisa ni mientras invoca.
- *La horda andaba en el sitio con el juego en pausa*: el shader usaba `TIME`,
  que no se para con la pausa. El gestor lleva ahora el reloj de la animación
  (un uniforme `tiempo` que avanza en `_physics_process`, que sí se para).
- *Al morir un enemigo, el que ocupaba su hueco saltaba de fotograma*: el
  desfase salía de `INSTANCE_ID`, que es el hueco en el MultiMesh y cambia al
  mover el último vivo al hueco del muerto. Ahora sale de su id, que viaja con
  él, y llega al shader en el tercer dato de cada enemigo (`INSTANCE_CUSTOM.b`).
- *El troyano se daba la vuelta en plena embestida* al pasar al jugador, y en
  fácil huía de espaldas. Ahora mira hacia donde embiste o hacia donde huye.
- *El salto de "NIVEL N" casi nunca se veía*: la caja que contiene la etiqueta
  le devuelve la escala a 1 cuando cambia de largo el texto de la experiencia,
  antes de que empiece el `Tween`. La escala de salida va en `from()`.
- *Si CAMBIAR fallaba* (carpeta del juego sin permiso de escritura), la
  ventana de versiones se quedaba bloqueada y salía un aviso falso de versión
  nueva. Ahora todo queda como estaba y la ventana lo dice.
- *Una descarga colgada bloqueaba la ventana para siempre*: ahora hay media
  hora de límite.
- *Las descargas a la biblioteca compartían el fichero temporal* con las de
  ACTUALIZAR: ahora cada una usa el suyo, y mientras se actualiza no se instala
  ni se cambia nada.
- *Tras INSTALAR o BORRAR nada tenía el foco* y con el mando no se podía salir:
  el foco vuelve a VOLVER.
- *Un reintento que salía bien dejaba el mensaje de error*: ahora dice que ya
  está instalada.

Los dos hallazgos sobre el largo de `instalador_juego.gd` (246 líneas) se
descartaron: es una norma orientativa que el fichero ya pasaba, y partirlo
obligaría a llevar otro fichero a todas las versiones antiguas.

### Uso de IA

Claude separó la descarga del cambio de versión, preparó el modo de prueba
del script, probó el flujo completo con un servidor local, recompiló y
volvió a publicar las nueve versiones. La idea y cómo tenía que funcionar son
de Adam.

Las tiras de la horda las dibujó Claude en otra conversación con Adam, que
trajo también el cambio probado del shader y los datos y la lista de
arreglos. Claude los integró, sacó el volteo y el panel de experiencia a sus
scripts, hizo el destello con un script para el sprite y lo probó todo. Al
final, como Adam tiene activado ultracode, cuatro agentes revisaron los
cambios del día desde enfoques distintos (shaders, lógica, interfaz y
versiones, y normas del proyecto) y un quinto intentó desmentir cada hallazgo
antes de aceptarlo.

### Métodos de test empleados

- Importación y arranque en headless; las clases globales siguen siendo 16
  (los dos scripts viajan con la actualización pequeña).
- De punta a punta con un servidor local que imita la API de GitHub y dos
  versiones de prueba (la v1.0 y la v0.5 recompiladas), desde una biblioteca
  vacía:
  1. En la 1.0, INSTALAR la 0.5: se descarga, la fila pasa a INSTALADA con
     CAMBIAR y BORRAR, y el ejecutable sigue siendo el de la 1.0.
  2. En la 1.0, CAMBIAR a la 0.5: el ejecutable pasa a ser el de la 0.5 y el
     juego se reinicia; la biblioteca guarda las dos.
  3. En la 0.5, BORRAR la 1.0 (vuelve a INSTALAR) e INSTALARLA otra vez
     (vuelve a INSTALADA), sin salir de la 0.5.
  4. En la 0.5, CAMBIAR a la 1.0: vuelve a la 1.0.
  5. En la 1.0, la 0.5 sale como INSTALADA.
- Las nueve versiones recompiladas arrancan sin errores de script, y se
  comprobó de qué código salió cada una.
- Cada release, con sus `.zip` nuevos del tamaño esperado y su nota.
- Las cinco tiras: 4 fotogramas cuadrados del tamaño del sprite, el primero
  idéntico al sprite y los otros tres distintos.
- Horda: cada tipo con su material, 4 fotogramas y su velocidad, y solo el
  troyano con volteo; capturas con ventana de los cinco tipos en tres
  momentos (cambian de fotograma) y de troyanos a los dos lados del jugador
  (todos lo miran).
- Piernas: la misma distancia por fotograma de andar sin mejora, con la mejora
  de velocidad y en el aura lenta (31,2 px).
- Destello: capturas antes, justo después del golpe y al acabar, de un élite y
  del jefe, también con el jefe avisando en rojo; cada uno con su material.
- Barra: capturas mientras se llena y al subir de nivel con el juego en pausa.
- Una partida con enemigos de los cinco tipos y el élite muriendo, el jefe
  recibiendo golpes y seis subidas de nivel, sin errores.
- Una partida del simulador: el mismo resultado que la misma partida del día
  anterior (las animaciones no cambian el juego), sin errores.
- Rendimiento antes y después en el instituto: iguales dentro del ruido; no
  valen para decidir nada.
- Tras los arreglos de la revisión: el troyano mantiene el lado al pasar al
  jugador embistiendo y vuelve a mirarlo al perseguir; el jefe no destella
  avisando y sí persiguiendo; el reloj de la animación no avanza en pausa. El
  menú de versiones, otra vez de punta a punta con el servidor local, y además
  CAMBIAR con la carpeta sin dejar escribir (se fuerza creando una carpeta con
  el nombre del fichero que intenta escribir): la ventana se desbloquea, VOLVER
  queda activo y dice que no ha podido cambiar.

### Estado al cerrar

La sesión se cortó por falta de tiempo con los arreglos de la revisión hechos
y probados, pero sin commitear, sin volver a publicar las versiones antiguas
y sin publicar la v1.1. Todo eso se hizo en la sesión 13.

### Siguiente paso

Seguir en la sesión 13 (ver abajo).

---

## Sesión 13 — 15/10/2026

**Duración:** 2 h · **Fitas:** 5 y 6 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 25 h de las 60 sugeridas (42 %)

### Qué se ha hecho

Se terminó lo que la sesión 12 dejó a medias. Al empezar no había nada nuevo
en GitHub ni en la rama de Alan.

- **Los arreglos de la revisión, commiteados** (en la sesión 12 quedaron
  hechos y probados, pero sin commit): la horda animada, el troyano, el
  destello del jefe, la barra de experiencia y el menú de versiones.
- **Las v0.2 a v1.0, vueltas a publicar otra vez,** porque el menú de
  versiones ha cambiado con los arreglos y tiene que funcionar igual desde
  todas. Como siempre, solo cambian sus dos scripts; cada release lleva una
  nota con lo que cambia.
- **Publicada la v1.1**, con la horda animada, el destello de élites y jefe,
  las piernas que ya no patinan, la barra de experiencia y el menú de
  versiones arreglado. Los que tienen la v1.0 la reciben con el aviso de
  ACTUALIZAR.
- **`CLAUDE.md`, con cuándo usar subagentes y cómo responder:** un bloque que
  Adam pegó al final de la sesión 12. Se añadió sin la frase que llamaba al
  proyecto "Projecte de DAM (módulo 0492)", porque chocaba con lo que dice el
  repo ("Demostra el teu talent"); se lo preguntó a Adam antes.

Después, Adam preguntó si estaba hecha la explosión del rootkit (no lo
estaba: el 13/10 pasó el asset pero pidió no aplicarlo aún) y si lo demás de
aquel prompt de animaciones estaba hecho (sí: piernas, destello y barra van en
la v1.1). Aclaró que **solo cuenta la entrega final**: las de antes eran subir
el enlace del GitHub para que los profesores vieran cómo iba. Y pidió:

- **La explosión del rootkit, con los sprites de Adam**
  (`medios/sprites/explosion/`, hechos con Claude en el chat). Durante el
  aviso de 0,8 s, el rootkit se agrieta y se pone al rojo temblando cada vez
  más, y un anillo de peligro a trazos, con flechas hacia dentro, gira en el
  borde de la zona que se llena. Al estallar sale una bola de fuego con su
  onda, y en el suelo queda 4 s una quemadura con grietas que brillan. Solo
  cambia el dibujo: el daño, el radio y el aviso son los mismos.
- **Dejarlo todo apuntado y subido** para probarlo en casa en un chat nuevo,
  porque en clase no puede probarlo jugando. No se publica versión: la v1.2,
  con la explosión, cuando Adam lo haya probado.

### Decisiones técnicas y por qué

**Volver a publicar las versiones antiguas, aunque el fallo era raro.** Los
arreglos del menú de versiones (la ventana que se quedaba bloqueada si fallaba
un cambio, el foco con el mando, el fichero temporal compartido) van en dos
scripts que llevan dentro todas las releases. Adam quiere que el menú funcione
igual desde cualquier versión, así que se recompilaron las nueve.

**La explosión, como venía en el prompt de Adam.** El aviso se dibuja en el
`_draw` del élite (`draw_texture_rect_region` con el fotograma de la
sobrecarga según lo que queda de aviso, y el del anillo girando). La
explosión y la quemadura van en un nodo nuevo, `explosiones_elite.gd`, que
escucha `elite_exploto` y guarda cada explosión como `[posición, segundos]`:
no hace falta ninguna señal nueva. Ese nodo va el primero en `RaizJuego`, así
que la quemadura queda encima del suelo y debajo del jugador y de la horda; la
explosión la dibuja su hijo `Fuego` (con `z_index` 4) desde la señal `draw`,
encima de los enemigos y debajo de las chispas y los números. El élite usa el
filtro nearest para el pixel art; el texto de los afijos se sigue leyendo bien
(captura). Con algún nombre más claro que en la referencia (`fotograma` y
`giro` en lugar de `n`). El élite se queda en 201 líneas.

### Problemas encontrados y cómo se resolvieron

La recompilación y la subida salieron a la primera.

**El temblor del rootkit cambiaba las partidas del simulador.** El código de
referencia lo hacía con `randf_range` al dibujar, y eso gasta números del azar
de la partida: con la misma semilla, la partida del simulador salía distinta
(671 s, nivel 15) de la del día anterior (655 s, nivel 16). Con un temblor de
senos, la misma partida vuelve a dar exactamente lo mismo. Así se sabe además
que la explosión no cambia nada del juego.

**En la prueba, la subida de nivel paraba la explosión.** Al matar al élite
el jugador sube de nivel y el juego se pausa para elegir mejora: la cuenta
atrás del aviso se para (como debe) y la prueba esperaba para siempre. La
prueba elige ahora la mejora pulsando la tarjeta. Elegirla directamente por
el bus no servía: el panel no se cerraba y tapaba las capturas.

### Uso de IA

Claude commiteó los arreglos, recompiló y volvió a subir las versiones,
publicó la v1.1 y cerró la bitácora de las sesiones 12 y 13. Adam decidió las
horas y si se añadía el bloque de `CLAUDE.md`. Los sprites de la explosión
y su código de referencia los hizo Adam con Claude en el chat; Claude los
integró, cambió el temblor para no tocar el azar de la partida y lo probó.
Sin subagentes, según el nuevo apartado de `CLAUDE.md`: todo pasaba por los
mismos ficheros.

### Métodos de test empleados

- Importación y arranque en headless antes de commitear; las clases globales
  siguen siendo 16.
- Las nueve versiones recompiladas: los dos scripts iguales que en `main`, el
  botón una sola vez, sin el gancho de prueba, con su nombre y su número de
  versión, y arrancan sin errores de script.
- Cada release, con sus `.zip` del mismo tamaño que los recompilados y su
  nota; la v1.1, con sus ficheros, su `version.json` y la web publicada.
- Explosión del rootkit, con ventana: un élite explosivo y blindado junto al
  jugador (el texto de los afijos se lee bien con el filtro nearest), matarlo
  y capturas del aviso, la explosión y la quemadura (debajo del jugador, del
  corazón y del cofre). Pausando a mitad de la explosión, se queda en el mismo
  instante (0,27 s) y sigue al reanudar; la quemadura desaparece a los 4 s.
- Una partida del simulador: sin errores y, con el temblor de senos, el mismo
  resultado que la misma partida del día anterior.

### Estado al cerrar

Todo subido a GitHub. Publicada la v1.1 (también en la web) y las v0.2 a v1.0
vueltas a publicar con el menú de versiones arreglado; las nueve comprobadas.
La explosión del rootkit está en `main`, probada con capturas, pero sin
publicar: Adam la probará en casa jugando antes de la v1.2.

### Siguiente paso

Todo esto se prueba en casa, en un chat nuevo, con el proyecto de `main`
abierto en Godot (la lista detallada está en `requisitos_y_estado.md`, el
primer punto de lo que queda por hacer):

1. La explosión del rootkit: F1 → ÉLITE AHORA hasta que salga uno EXPLOSIVO,
   matarlo y mirar el aviso, la explosión y la quemadura.
2. Lo de la v1.1: horda animada, troyano, destellos (el jefe no destella
   avisando), piernas con la mejora de velocidad y barra de experiencia.
3. El menú de versiones desde la v1.1 descargada: INSTALAR una antigua sin
   cambiar de versión, CAMBIAR a ella y volver.
4. El rendimiento con `herramientas/medir_rendimiento.gd`, antes de la horda
   animada (etiqueta v1.0) y ahora, con la GPU de verdad.
5. Decidir si la dificultad media se queda así o se compensa.
6. Si todo va bien, publicar la v1.2. Después: vídeo, ensayo de la defensa y
   probar una release en un ordenador sin Godot.

Al final de la clase, Adam pasó dos encargos más, que quedan sin empezar:

- **El menú F1 no es consistente.** Saltando al minuto 10 se llega a nivel 12,
  y jugando él va por el 14 en el minuto 5. Además, al volver al minuto 0 se
  quedan las mejoras. La causa del nivel bajo es que las tablas de
  `progreso_por_minuto.gd` salen del bot, y el bot no va a por los fragmentos
  de datos.
- **Una fase 2 y un jefe final nuevo, NÚCLEO CERO, en el minuto 15.** Al matar
  al jefe de los 10:00, la pantalla se va a negro y el mapa pasa a una placa
  destrozada. El jefe nuevo tiene tres formas y los ataques robados a los
  personajes y a la horda. Los dibujos los hizo Adam con Claude en el chat
  (`jefe_final.zip`, que no está en el repo).

Antes de irse, Adam pidió arreglar ya lo del F1 que se pudiera en 20
minutos. Lo de volver al 0 está hecho: saltar a un minuto recarga la escena
de la partida y después la pone en ese minuto. El salto pendiente se apunta
con `get_tree().root.set_meta()`, porque la raíz del árbol sigue ahí al
recargar. Así cada salto deja lo mismo, venga de donde venga, y se reinician
también la horda, los élites y las resistencias. Se probó en headless con un
script temporal: tras ir a 5:00 queda en nivel 9 con 8 mejoras y tras volver
a 0:00 en nivel 1 con 0. El nivel bajo (las tablas del bot) no cabía en el
tiempo y queda pendiente.

Lo pedido, el plan propuesto y las preguntas para Adam están en
`encargo_fase2.md`. Se quedan esperando a que él diga que sí al plan. Para
retomarlo en casa se añadió a CLAUDE.md la frase clave "Estoy en casa": bajar
lo último, resumir qué está hecho y qué falta, y ponerse a probar.

Al cerrar, Adam pidió publicar ya la v1.2, sin esperar a probarla en casa.
Lleva la explosión del rootkit y el arreglo del F1. No cambian
`project.godot`, `version.gd`, el actualizador, el instalador ni el panel de
versiones, ni hay `class_name` nuevos: `EJECUTABLE_MINIMO` sigue en 0.2 y no
hace falta volver a publicar las versiones anteriores.

---

## Sesión 14 — 16/10/2026 (en casa)

**Duración:** 2 h (la apuntó Adam al día siguiente) · **Fitas:** 5 y 6 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 27 h de las 60 sugeridas (45 %)

### Qué se ha hecho

- **Clon nuevo en casa.** La carpeta del proyecto no estaba en el ordenador
  de casa, así que se volvió a clonar en
  `C:\Users\Adam\Desktop\proyecto\sector-cero` con el `git` de GitHub
  Desktop. Al clonar se vio que se perdió un documento del 02/10 que nunca se
  llegó a subir (`godot_paso_a_paso.md`, el proyecto enseñado en el editor
  con 13 capturas). Se puede rehacer si hace falta.
- **Consejo sobre las versiones** (ver «Decisiones de Adam»).
- **Icono del juego** (dibujado por Claude en otra conversación con Adam): el
  encapuchado delante de un cero tachado de neón, en `medios/icono/`. Va en el
  `.exe` (preset de Windows), en la ventana (`project.godot` y, para el
  `.pck`, `transicion.gd`) y en la web (el favicon sale de `config/icon`).
- **Fase 2 y jefe final NÚCLEO CERO**, con los dibujos que Adam hizo con
  Claude en el chat (`jefe_final.zip`) y el encargo que trajo en clase:
  - Al derrotar al jefe de las 10:00, negro de 3 s con «SECTOR CERO DAÑADO»
    escrito letra a letra (`pantalla_fase.gd`). Detrás, la horda desaparece,
    el suelo pasa a la placa destrozada (chispazos y humo en el shader del
    suelo), la música baja de tono y el HUD avisa.
  - La fase 2 dura 5 minutos (`duracion_fase_2`, en `config_principal.tres`)
    y a las 15:00 llega NÚCLEO CERO: tres formas (rootkit gigante, núcleo
    armado y amalgama) que cambian al 66 % y al 33 % de vida, con su
    transformación, su muerte y la victoria al acabar.
  - Sus ataques: rayo, torbellino y tormenta robados a los personajes (con las
    funciones de dibujo de sus ultis), portales que sacan horda (y un rootkit
    explosivo desde la segunda forma) y cristales que dejan hielo que
    ralentiza. Al cambiar de forma, el escudo de candado: cuatro anclas que
    hay que romper, y después se queda aturdido 2 s.
  - Barra de vida arriba en el centro (`barra_jefe_final.gd`), avisos del HUD
    y sonidos con los efectos que ya había.
  - Menú F1: IR A LA FASE 2, JEFE FINAL YA (15:00) y SIGUIENTE FORMA.
  - El ranking y los récords empiezan de cero, como pidió Adam.
- **El simulador** llega al jefe final: el bot recoge fragmentos cuando no
  hay peligro, va a por las anclas del escudo, se aparta del hielo y sale del
  torbellino. Las tablas del F1 se volvieron a medir hasta el minuto 15.
- **Rendimiento medido en la RTX 5070**, también con la fase 2 y el jefe
  final en pantalla, y la v1.0 (antes de la horda animada) contra lo de hoy.
- **Una revisión de todo lo de hoy** con agentes, y sus arreglos (ver «Uso de
  IA» y «Problemas»).
- **Documentación**: GEMINI.md (qué es, señales, grupos), README, manual,
  documentación técnica, créditos, reglas del menú, `requisitos_y_estado.md`,
  planificación y seis capturas nuevas (`capturas/juego/15` a `20`).
  `encargo_fase2.md` se borra: está hecho y lo decidido queda aquí.
- **Publicada la v1.3** a petición de Adam, sin probarla él antes jugando.

### Decisiones de Adam

**Versiones: una página web con todas, en lugar del menú VERSIONES.** Adam
pidió consejo porque, tras muchas pruebas, cambiar de versión desde el juego
seguía fallando. Las causas que se vieron en el código:

1. Todas las versiones comparten la carpeta de datos (`user://`), también el
   parche `actualizacion.pck`: un ejecutable viejo carga cualquier parche más
   nuevo que encuentre, así que tras un ACTUALIZAR las versiones antiguas
   arrancan con el contenido nuevo.
2. La versión del ejecutable y la del contenido pueden ser distintas, y el
   menú no siempre sabe cuál es «la que se está usando» (el fallo del 15/10:
   en la v1.0 ofrecía INSTALAR la v1.0).
3. El menú que cambia de versión va dentro de cada versión: cada arreglo
   obliga a recompilar y volver a publicar todas las releases.

Se decide publicar en GitHub Pages cada versión en su carpeta
(`/sector-cero/v0.3/`, `/v1.2/`...) con una portada que las liste. Cada una
vive en su dirección, sin instalar ni reiniciar, y no hay que volver a
recompilar releases viejas. El juego de escritorio se queda con ACTUALIZAR y
el botón VERSIONES abrirá esa página. Se descartó un lanzador aparte: más
código que defender, y tendría que borrar el parche compartido antes de abrir
cada versión. Se hace después de la fase 2.

**Fase 2** (respuestas a las preguntas del encargo):

- Matar al primer jefe **no cura**.
- El primer jefe se llama **«JEFE»** a secas (de momento).
- El ranking y los récords **empiezan de cero** con la fase 2: con ella una
  victoria dura más de 15 minutos, y las de antes (unos 11) quedarían siempre
  delante.
- **El balance se hace al final**, con el juego terminado: hasta entonces el
  jefe final lleva los números del encargo.
- Al acabar el día, Adam pidió subirlo todo y **publicar la v1.3**.

### Decisiones técnicas y por qué

**El icono también se pone desde el código.** Godot pone el icono de la
ventana al arrancar leyendo `project.godot`, que va dentro del ejecutable y no
viaja con el `.pck` de actualización. Para que quien actualice con el `.pck`
lo vea en la ventana y la barra de tareas, `Transicion` lo pone en su
`_ready()`: `DisplayServer.set_native_icon()` con el `.ico` en Windows (así
usa los tamaños pequeños dibujados a mano en vez de reescalar el PNG) y
`DisplayServer.set_icon()` con el PNG en Linux; en la web, nada. Va en
`Transicion` porque es un autoload que tienen todos los ejecutables desde la
v0.2 y su script llega con el `.pck`; no podía ir en el `Actualizador`, que
es del ejecutable. El icono del `.exe` en el explorador solo cambia con un
ejecutable nuevo. `EJECUTABLE_MINIMO` sigue en 0.2: las dos líneas nuevas de
`project.godot` solo ponen el icono, y sin ellas el contenido funciona igual.

**El reloj se para en las 10:00 mientras está el jefe.** El encargo decía
que el reloj sigue desde las 10:00 al empezar la fase 2. Al principio se hizo
volviendo el reloj a las 10:00 tras el negro, pero entonces una derrota en la
fase 2 a las 10:30 quedaba en el ranking por debajo de una contra el jefe a
las 11:30, y el récord de tiempo dejaba de tener sentido. Parándolo, la fase
2 dura siempre lo mismo, el jefe final llega a las 15:00 y el tiempo siempre
crece con lo que se avanza.

**La transición, con la pausa del árbol.** La raíz de la partida pausa,
emite `transicion_fase` y espera con temporizadores del árbol, que siguen
corriendo en pausa. A mitad, detrás del negro, vacía la horda (`vaciar()`:
la huida no sirve porque con la pausa no avanza) y el director empieza la
fase 2, que emite `fase_cambiada` antes que el reloj para que el HUD ya
cuente hacia NÚCLEO CERO. Mientras dura, ni el menú de pausa ni el F1 se
abren: al acabar, la transición quita la pausa.

**El jefe final, repartido en scripts.** `jefe_final.gd` lleva las formas,
la vida, el movimiento, la transformación y la muerte; `ataques_jefe_final.gd`
cada ataque (tiempo, dibujo y daño); `escudo_jefe_final.gd` y
`ancla_escudo.gd`, el escudo; `zonas_hielo.gd`, el hielo (debajo del jugador
y de la horda, como las explosiones); `dibujo_jefe_final.gd`, funciones de
dibujo como `dibujo_ultis.gd`. Todo con `preload` y sin `class_name`, sin
tocar `project.godot` salvo el icono: llega con el `.pck`. Las anclas son
objetivos y están en la escena desde el principio, ocultas, como los élites,
porque las armas buscan sus objetivos al empezar. Un golpe que se pasaría de
largo se queda en el umbral de la forma siguiente, para no saltarse ninguna.
El jefe se queda quieto mientras ataca y con el escudo; los ataques son
`top_level` y dibujan en coordenadas del mundo. Todos avisan antes de hacer
daño, y el aviso mide lo mismo que el daño (la franja del rayo, las dianas).
`jefe_final.gd` (302 líneas con comentarios) y `ataques_jefe_final.gd` (257)
pasan de las ~200 orientativas; partirlos más obligaría a pasar el estado de
un script a otro, y se deja así.

**El ranking, en secciones nuevas del guardado.** Primero se vaciaba una vez
y se apuntaba en el fichero. La revisión vio que las versiones anteriores, que
comparten el fichero, seguían escribiendo en él después, y que las pruebas lo
vaciaban al arrancar. Ahora esta versión guarda los récords y el ranking en
`records_fase2` y `ranking_fase2` y no lee las viejas, que no se borran.

**Las tablas del F1.** Del minuto 0 al 10, en media; del 11 al 15, en fácil,
porque en media casi ninguna partida llega. En la fase 2 nunca se tiene menos
que al empezarla (nivel 15 y 20 mejoras): lo ganado contra el jefe no cae en
ningún minuto, porque el reloj está parado.

### Problemas encontrados y cómo se resolvieron

**Una prueba se quedaba colgada:** la partida se pausaba en una subida de
nivel y nadie elegía. Las pruebas eligen ahora como el simulador; en las
capturas, pulsando la tarjeta, porque por el bus el panel no se cierra (lo
mismo que en la sesión 13).

**Cuatro partidas del simulador salieron idénticas:** un fallo de la prueba
al pasar los argumentos en PowerShell (la coma se aplica antes que el `+`).

**El bot que va a por los fragmentos con horda alrededor** sube antes de nivel
pero muere entre el minuto 3 y el 6. Se queda yendo solo sin peligro cerca:
nivel 13 en el minuto 10 (antes 12), aún por debajo de lo que vio Adam
jugando (14 en el minuto 5).

**La revisión** (cinco revisores por áreas y tres verificadores por
hallazgo) encontró 49 cosas. Se acabó el límite de uso a mitad de la
verificación: solo una pasó la verificación completa (se podía perder
durante la muerte del jefe final), y las demás se repasaron a mano contra el
código. Se arregló:
- el ranking (ver arriba);
- el HUD que decía «JEFE EN 04:59» al volver la imagen;
- el jefe que se recolocaba con el escudo puesto y dejaba las anclas atrás, y
  el escudo que volvía nada más acabar el aturdido;
- poder perder durante la muerte del jefe (los portales seguían sacando
  horda): se cierran y el jugador queda protegido mientras se rompe;
- la ficha que se cerraba al transformarse;
- avisos más pequeños que el daño (rayo y dianas) y dianas que desaparecían
  antes de caer su rayo;
- las anclas y los ataques, que no heredaban el filtro nearest por ser
  `top_level`;
- bajas que se perdían al vaciar la horda;
- la cuenta atrás, que iba un segundo por detrás;
- el F1 abierto durante el negro;
- el reloj del panel F3, que ya no coincidía;
- el bot, que se quedaba dentro del torbellino;
- y comentarios que ya no eran verdad.

El rootkit explosivo que invoca el jefe final es un élite normal y, al
matarlo, suelta corazón y cofre. Se le preguntó a Adam y decidió, al día
siguiente, **dejarlo así**.

### Uso de IA

Claude propuso el plan de la fase 2 (en clase), programó la fase 2, el jefe
final, el icono y los cambios del simulador, midió el rendimiento, hizo las
capturas y la documentación. Los dibujos del jefe final, del suelo dañado y
del icono los hizo Claude en otra conversación con Adam, que trajo también el
encargo, el cambio del shader y una demo de referencia. Las decisiones son de
Adam. Para la revisión, como Adam tiene ultracode activado, cinco agentes
revisaron el código por áreas y otros intentaron desmentir cada hallazgo; se
cortó por el límite de uso y Claude repasó el resto a mano.

### Métodos de test empleados

- Importación y arranque en headless tras cada bloque, y con ventana; las
  clases globales siguen siendo 16.
- El suelo normal con el shader nuevo, comparado píxel a píxel con el de
  antes (con ventana y `--fixed-fps`, para que el tiempo sea el mismo): igual.
  Que la textura de efectos normal no tiene ningún píxel con el azul de los
  chispazos.
- Pruebas en headless: la transición (pausa, negro, horda vaciada, reloj en
  10:00, cuenta atrás de NÚCLEO CERO, llegada del jefe final a las 15:00); el
  jefe final (umbral del 66 %, invulnerable transformándose, daño del 75 % y
  del 60 %, muerte, victoria, portales cerrados y jugador protegido); cada
  ataque (el rayo no pega durante el aviso y pega una vez, el torbellino,
  las dianas, los portales y el élite explosivo, el hielo que ralentiza, el
  escudo que no deja pasar el daño, las anclas, el aturdido con un 50 % más
  de daño); el salto del F1 a las 15:00 (fase 2, nivel 16, 24 mejoras).
- Capturas con ventana de la transición, el suelo dañado, las tres formas,
  cada ataque, el escudo con sus anclas, el hielo, la muerte y la victoria.
- El icono: el `.exe` exportado en casa lo lleva, y la ventana lo tiene
  también sin las líneas de `project.godot` (el del `.pck`).
- Simulador, 10 partidas por dificultad. Fácil, 5 victorias (las otras 5 mueren en la fase 2); media, ninguna (5 contra el jefe, 4 al poco de empezar la fase 2 y una contra el rootkit gigante); difícil, ninguna (5 en la fase 1 y 5 contra el jefe). Antes de los arreglos del bot (el torbellino) eran 4 en fácil.
- Rendimiento con la RTX 5070 (100 / 300 / 600 / 1200 enemigos): fase 1,
  1389 / 931 / 595 / 218 FPS; fase 2 con el jefe final atacando, 1234 / 835 /
  545 / 202; la v1.0, 1407 / 947 / 607 / 227. La física, igual en las tres.
  La horda animada no cuesta nada y la fase 2, alrededor de un 10 %.
- El fichero de guardado de Adam se copió antes de las pruebas y se devolvió
  después, igual que estaba.
- La v1.3 publicada: la Action acabó bien; la release lleva los dos `.zip`,
  los dos `.pck` y `version.json` (1.3, ejecutable mínimo 0.2); el `.exe`
  descargado, compilado en GitHub, lleva el icono (versión 1.3.0.0), y el
  favicon de la web es el icono nuevo.

### Estado al cerrar

Todo subido a GitHub y publicada la v1.3 (fase 2, jefe final e icono). No
hay `class_name` nuevos y `EJECUTABLE_MINIMO` sigue en 0.2.

### Siguiente paso

Probarlo jugando (la lista está en el primer punto de lo que queda por hacer
de `requisitos_y_estado.md`):

1. F1 → JEFE YA: matarlo y mirar el negro, el suelo dañado, la música y que
   el reloj se queda en 10:00 mientras está el jefe.
2. F1 → JEFE FINAL YA y SIGUIENTE FORMA: las tres formas, cada ataque (que el
   aviso se entienda y se pueda esquivar), el escudo y sus anclas, el hielo,
   la barra de vida, la muerte y la victoria.
3. Una partida normal mirando el nivel con F3 en los minutos 5, 10 y 15, para
   las tablas del F1.
4. Que el ranking sale vacío en la versión nueva.

Después: el equilibrio de la fase 2 (al final), la página web con todas las
versiones, el vídeo y el ensayo de la defensa.

## Sesión 15 — 16/10/2026 (en clase, corta)

**Duración:** 1 h · **Fitas:** 5 y 6 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 28 h de las 60 sugeridas (47 %)

- Se bajó lo de casa (sesión 14) y se validó en headless: import y partida
  sin errores. Con un script temporal, el F1 lleva a la fase 2 (10:20, nivel
  15), al jefe final (15:00, nivel 16) y de vuelta al 0 (nivel 1, sin
  mejoras); SIGUIENTE FORMA funciona.
- **Icono.** Adam no lo veía en la barra de tareas, en el `.exe` ni en
  GitHub. La v1.3 publicada sí lo tiene: se comprobó bajándola y leyendo el
  icono del `.exe` y de la ventana. Un `.exe` viejo actualizado solo con el
  `.pck` pone el icono en la ventana (probado con el `.exe` de la v1.2 y el
  parche de la v1.3), pero el archivo se queda sin icono, porque eso va
  dentro del ejecutable. Se puso el icono en la portada del README.
- **Icono en Linux** (Adam: «en Linux no se ve»). Un ejecutable de Linux no
  lleva icono, y GNOME en Wayland no usa el de la ventana: lo busca en un
  `.desktop` cuyo `StartupWMClass` sea la clase de la ventana. En el código de
  Godot 4.7, esa clase (y el `app_id` de Wayland) es `config/name`, «Sector
  Cero». Nuevo `globales/icono_linux.gd`: el juego exportado escribe al
  arrancar en Linux su icono y `~/.local/share/applications/sector-cero.desktop`.
  Va en el contenido, así que llega también con el `.pck`. Probado en headless
  en Windows, con otro `HOME`; falta probarlo en Linux. Publicado en la v1.4.
- **Versiones.** Adam decidió que desde el `.exe` se tienen que poder jugar todas las versiones, y que la web es solo un extra para la última. La mejor forma es un lanzador aparte, como el de Minecraft.
  La propuesta y la estimación están en `requisitos_y_estado.md`, punto 4;
  falta el plan con los ficheros antes de programar.


## Sesión 16 — 20/10/2026 (en clase)

**Duración:** 2 h · **Fitas:** 5 y 6 · **Participantes:** Adam (con Claude)

**Horas acumuladas:** 30 h de las 60 sugeridas (50 %)

### Qué se ha hecho

No había nada nuevo en GitHub desde la sesión 15, ni de Adam ni de Alan.

- **Lanzador, como el de Minecraft** (`lanzador/`, un proyecto de Godot
  aparte). Muestra la información del juego, las novedades de la versión
  elegida y un desplegable con todas las versiones (de la v0.2 a la última).
  Al elegir una, baja su `.pck` (1-2 MB) a la biblioteca. JUGAR abre el juego
  instalado con ese contenido; mientras se juega el lanzador se minimiza, y
  vuelve al cerrar el juego.
  - `biblioteca.gd`: la lista de releases (o la guardada si GitHub no
    contesta), las descargas y abrir el juego
  - `lanzador.gd`: la pantalla
  - `estilo.gd`: una copia reducida de `EstiloInterfaz`, porque desde otro
    proyecto no se pueden cargar ficheros del juego
  - `actualizador_lanzador.gd` y `version.gd`: el lanzador se actualiza solo
    con su `.pck`
  - `icono_linux.gd`: el acceso del menú de Linux, que abre el lanzador
- **El instalador de Windows** (`lanzador/instalador.iss`, Inno Setup), para
  todo el ordenador, con accesos directos y desinstalador. Lo genera la
  GitHub Action en una máquina Windows aparte. En Linux, un zip.
- **El juego abierto desde el lanzador** (`--desde-lanzador`) no busca
  actualizaciones ni enseña ACTUALIZAR ni VERSIONES.
- **Las novedades de cada versión**, en `documentacio/novedades/`. Se
  copiaron a las 13 releases publicadas, que solo decían «Full Changelog» y
  las antiguas con los acentos rotos, y la Action las usa al publicar.
- **El README** explica el lanzador.
- **Publicadas la v1.5 (el lanzador) y la v1.6** (el acceso del menú de
  Linux abre el lanzador; antes lo ponía el juego apuntándose a sí mismo).
- **Jefes y equilibrio:** Adam aprobó la propuesta de Claude (detalle en
  `requisitos_y_estado.md`, punto 3). Hecho por ahora, lo más fácil:
  - menos horda al final de la fase 1: como mucho una cada 0,07 s en vez de
    0,05, y los anillos del jefe de 8 a 14 enemigos en vez de 12 a 24
  - robo de vida del Espadachín: el Firewall cura un 10 % del daño hecho,
    como mucho 3 de vida por golpe
- **Assets:** el prompt para que Claude (chat) haga más assets, en seis lotes
  (`prompt_assets.md`).

### Decisiones de Adam

- **El lanzador:** instalador de verdad, para todo el ordenador, con el
  lanzador y el juego separados. El juego se instala una vez y en el lanzador
  se elige la versión. La web queda solo para la última versión. No hay botón
  en el juego viejo para pasar al lanzador: quien lo baje, bajará el
  instalador. Las versiones antiguas no se actualizan solas, y al cerrarlas se
  vuelve al lanzador.
- **Publicar** la v1.5 y la v1.6, y reescribir las novedades de las releases
  publicadas.
- **Dificultad** (en difícil, pasado el minuto 10, es casi imposible). Primero
  los jefes más duros:
  - el del minuto 10, con más movimientos; el pisotón lo encierra a uno unos
    segundos dentro del círculo
  - NÚCLEO CERO casi imposible: más presión, y candados más difíciles de
    romper

  Después, equilibrar con el simulador: 7-8 victorias de 10 en fácil, 4-5
  en media y 1 en difícil. Menos horda en el minuto 10, porque salían
  demasiados enemigos.
- **El Espadachín roba vida**, porque llega poco y pega poco.
- **Las mejoras, visibles en los personajes:** Adam está haciendo los
  assets para que, al coger las mejoras, se note en los tres personajes. Los
  pasará con su prompt en la próxima sesión.

### Decisiones técnicas y por qué

- **Cada versión es su `.pck`, no su ejecutable.** Todas las releases se
  hicieron con Godot 4.7.2 (la Action no ha cambiado de motor desde el
  01/10), así que un solo motor abre el contenido de cualquiera. Por eso las
  versiones antiguas no hay que recompilarlas, y elegir una es bajar 1-2 MB
  en vez de 40.
- **El `.pck`, junto al ejecutable y no con `--main-pack`.** Los ejecutables
  exportados no admiten `--main-pack`. Godot abre solo el `SectorCero.pck`
  que está junto a `SectorCero.exe`, y el lanzador copia ahí el elegido. Por
  eso la carpeta `juego/` del instalador la puede escribir cualquier usuario.
- **El lanzador, un proyecto aparte:** así no carga los autoloads del juego
  (el actualizador, el audio, el CRT) y su propio `project.godot` se puede
  cambiar sin miedo. El juego sin contenido sale de dos presets nuevos del
  juego (`Windows (lanzador)` y `Linux (lanzador)`).
- **El lanzador borra la actualización descargada del juego** antes de
  abrir cualquier versión. Todas las versiones comparten la carpeta de datos,
  y una antigua cargaría la de una nueva.
- **El menú mira `--desde-lanzador` él mismo** y no se lo pregunta al
  `Actualizador`: el de un ejecutable viejo, actualizado con el `.pck`, no
  tendría una función nueva.
- **El zip del lanzador de Linux no acaba en `_linux.zip`**
  (`SectorCero_Lanzador_linux_vX.zip`): los juegos antiguos buscan el
  archivo que acaba así para su ACTUALIZAR, y cogerían este.
- **El robo de vida va en `DatosArma`** (`robo_vida`), con un tope por golpe
  (`ROBO_MAXIMO` en `gestor_armas.gd`). Sin tope, metido en la horda, el
  Espadachín se curaría del todo en cada golpe.

### Problemas encontrados y cómo se resolvieron

- **`--main-pack` no funciona en el juego exportado** («compiled without
  support for path overrides»): se usó el `.pck` junto al ejecutable.
- **Pantalla en blanco** en algunas pruebas, con errores de
  `shader_gles3.cpp`. Primero se pensó en la caché de shaders de otra versión,
  y se añadió borrarla al cambiar de versión. Pero se probó la v0.5 con la
  caché de la v1.4 y abría bien: la estropeaba cerrar el juego a la fuerza en
  las pruebas (`Stop-Process -Force`). Se quitó ese borrado.
- **GitHub dejó de contestar** a mitad de las pruebas: solo deja 60 consultas
  por hora a cada red, y en el instituto todos comparten la misma. El
  lanzador guarda la última lista (`user://releases.json`), y las descargas
  no cuentan para ese límite. El `Actualizador` del juego tiene el mismo
  límite: en clase, el aviso de versión nueva puede no salir.
- **Acentos rotos** en las novedades de las releases antiguas: se habían
  estropeado al volver a publicarlas desde Windows. Se reescribieron con `gh
  release edit --notes-file` y un fichero UTF-8.

### Uso de IA

Claude propuso el diseño del lanzador y de los jefes más duros. Programó el
lanzador, el instalador, la Action, el robo de vida y el cambio de la horda,
lo probó, escribió las novedades de las versiones y el prompt de los assets.
Las decisiones son de Adam. Todo se hizo en la conversación principal, sin
subagentes.

### Métodos de test empleados

- Headless: import y `--quit-after` del juego y del lanzador tras cada
  cambio.
- **El lanzador, exportado y con ventana** (clics simulados y capturas; una
  carpeta de datos aparte para no tocar los récords):
  - lista de la v0.2 a la v1.4
  - se baja la v1.4 al abrir y la v0.5 al elegirla
  - JUGAR abre cada una con su menú de entonces (v0.2, v0.5, v0.9, v1.2 y
    v1.4)
  - el lanzador se minimiza y vuelve al cerrar el juego
- **El parche del lanzador:** uno hecho a mano (v9.9) se carga; uno más viejo
  que el ejecutable se borra.
- **La lista guardada:** con GitHub sin contestar, el lanzador baja la
  versión.
- **El menú del juego**, normal y con `--desde-lanzador`: capturas.
- **El instalador y la Action:** la publicación de la v1.5 y de la v1.6 (los
  dos trabajos, bien a la primera).
- **El robo de vida**, con un script temporal: con 6 enemigos alrededor cura
  9,6 de vida en 2 s, frente a 0,7 sin ellos (la regeneración).

### Cómo probar el lanzador en Linux

Lo preguntó Adam:

1. En un Linux con escritorio: un ordenador del instituto, una máquina
   virtual con Ubuntu, o WSL en Windows 11 (abre ventanas).
2. Bajar `SectorCero_Lanzador_linux_vX.zip` de la última release y
   descomprimirlo. En la terminal, dentro de la carpeta:
   `chmod +x SectorCero_Lanzador.x86_64 juego/SectorCero.x86_64` y
   `./SectorCero_Lanzador.x86_64`.
3. Mirar:
   - que salga la lista de versiones
   - que al elegir una se baje y JUGAR la abra
   - que al cerrar el juego vuelva el lanzador
   - que en el menú de aplicaciones salga «Sector Cero» con su icono, y que
     abra el lanzador
   - que la ventana del juego tenga el icono en el dock

### Estado al cerrar

Todo subido a GitHub. Publicada la v1.6, con el lanzador y su instalador. La
horda más suave y el robo de vida están en `main`, sin publicar y sin medir
con el simulador: se mide todo junto en el equilibrio final. Sin probar
todavía: el instalador en un Windows de verdad, el lanzador en Linux y que el
lanzador se actualice solo con la siguiente versión.

### Siguiente paso

1. **Si Adam trae los assets de las mejoras de los personajes:** integrarlos
   con su prompt (`requisitos_y_estado.md`, punto 1): primero un plan corto
   y esperar su sí.
2. Seguir con los jefes, en el orden del punto 3 de `requisitos_y_estado.md`:
   - en media, que huya la mitad de la horda al llegar el jefe
   - los movimientos del jefe del minuto 10
   - NÚCLEO CERO más duro
   - el equilibrio con el simulador
3. **Probar con Adam:** el instalador en Windows y el lanzador en Linux (los
   pasos, arriba).

---

## Sesión 17 — 21/10/2026 (en la nube)

**Duración:** 2 h · **Fitas:** 5 y 6 · **Participantes:** Adam (con Claude
Code en la nube)

**Horas acumuladas:** 32 h de las 60 sugeridas (53 %)

**Esta sesión no está en `main`.** Se trabaja desde Claude Code en la nube
(claude.ai/code), sin ningún ordenador encendido, en la rama
**`claude/beautiful-maxwell-uijhtj`**. Adam pedirá al Claude Code de su
ordenador que la integre en `main` (`git fetch origin` y
`git merge origin/claude/beautiful-maxwell-uijhtj`, después validar en
headless). Hasta entonces, quien trabaje en `main` no ve nada de esto.

### Qué se ha hecho

Aplicar los lotes de assets que hizo Claude en el chat, de uno en uno y en
orden. Los zips están en la rama `zips-lotes`, que no se fusiona: cada uno
trae los PNG, sus vistas previas, `LEEME.txt`, `PROMPT_CLAUDE_CODE.md`,
`referencia/` y `herramienta/`. Solo se commitean los PNG y el código.

- **Lote 1, ataques nuevos del jefe del minuto 10** (punto 3.4 de
  `requisitos_y_estado.md`):
  - **Pisotón con jaula** (`jaula_jefe.gd`): cada 20 s (el primero a los
    8), anillo rojo de aviso de 0,8 s y una jaula de 4 s que nadie cruza (ni
    el jugador ni el jefe salen, la horda de fuera no entra). Con la jaula
    puesta no invoca. El golpe no quita vida.
  - **Ráfaga** (`rafaga_jefe.gd`): cada 9 s (la primera a los 5), 12
    proyectiles en círculo a 200 px/s durante 2 s, 15 de daño; con menos de
    la mitad de vida, una segunda girada 15°.
  - **Rabia**: por debajo del 25 %, un 30 % más rápido y sus intervalos
    entre 1,3; el aura de llamas detrás de él.
  - Señal nueva `jefe_ataco` (para el sonido, con efectos que ya había) y
    grupo nuevo `jaula_jefe` (apuntados en `GEMINI.md`).
  - El bot del simulador esquiva la ráfaga de lado.
- **Lote 2, anclas del escudo de NÚCLEO CERO por personaje** (punto 3.5):
  cada ancla solo la rompe la herramienta de su personaje (cuenta el que se
  lleva); las demás sacan un 0 rojo. Reparto a-b-c-b, sin personajes caídos
  (si cae uno con el escudo puesto, sus anclas pasan a otro). Vida de 300 a
  800. Si en 12 s desde la primera rota no caen las cuatro, se cierran.
- **Lote 3, efectos de las herramientas:** el alcance de las armas de área
  es un anillo en grises teñido por la resistencia (antes, un círculo por
  código), y en cada ataque sale su efecto (golpe del Firewall, radar del
  Escáner y los de sus evoluciones), escalado con la mejora de alcance. El
  Ping saca un destello al impactar y el robo de vida, chispas verdes de los
  enemigos alcanzados al Espadachín.
- **Lote 4, la respuesta de la partida:** efectos sobre el personaje al
  subir de nivel (al volver de la pausa), al cambiar de personaje (del color
  del que entra; no al empezar ni al evolucionar) y al coger el corazón, y
  la muerte de cada enemigo de la horda en el color de su tipo y a su
  tamaño. Las partículas de la horda, de 7 a 3 por muerte.
- **Lote 5, élites:** el rootkit animado en reposo, con un brillo cada 1,5 s
  y desfasado entre élites; el efecto de cada afijo (placas del Blindado
  encima, copias del Replicante y anillo helado del Aura lenta detrás); el
  Aura lenta pasa a azul hielo («aura helada»). Los anillos finos se quitan
  salvo el del Explosivo, que no tiene efecto hasta que muere. El dibujo del
  élite pasa a `dibujo_elite.gd`.
- **Lote 6, interfaz y lanzador:** el logo con glitch en el menú
  (`logo_glitch.gd`), los retratos en el panel del equipo (en gris si ha
  caído) y en la ventana de caída, los once iconos de mejora rehechos, un
  icono por afijo en las reglas y encima de cada élite, y la cabecera del
  lanzador. Se quitó `generar_sprites.gd`, que habría machacado los iconos
  nuevos con los antiguos.
- **Arreglo del lote 2:** un ancla ajena contaba como alcanzada (curaba con
  el robo de vida y la resistencia lo tomaba por daño). Ahora no, y el 0 sale
  como mucho cada 0,3 s.
- Panel de reglas, manual, README, documentación técnica y créditos al día
  con los seis lotes.

### Decisiones de Adam

- Aplicar los lotes de forma separada y ordenada; si hace falta algún cambio
  fuera del lote, avisarle y él dice si es para ahora o para después.
- Las simulaciones de equilibrio, **más adelante**: ahora solo los assets.
- Las tres dudas del lote 1, como propuso Claude: la horda de fuera no entra
  en la jaula, el golpe del pisotón no quita vida, y la embestida triple y el
  guardaespaldas (también del punto 3.4) quedan para otro día.
- Subir el trabajo a la rama de la sesión, no a `main`.

### Decisiones técnicas y por qué

- **El muro de la jaula no empuja:** después de moverse cada uno, le
  devuelve a su lado. Como el muro tiene grosor (de 174 a 186 px), basta con
  mirar si está más cerca del centro que de fuera; nada va tan deprisa como
  para cruzarlo en un fotograma. Una sola función (`mantener`) para el
  jugador, el jefe y la horda.
- **La jaula va en `RaizJuego`** entre `Explosiones` y el `Jugador`: encima
  del suelo y debajo de todo. La ráfaga, hija `top_level` del jefe con
  `z_index` 4, y el aura, el primer hijo del jefe.
- **Las anclas saben quién pega por `equipo_cambiado`**, porque
  `danar_en_area` no dice qué herramienta golpea. Así la evolución y la ulti
  del personaje también valen, sin tocar las armas.
- **El 0 rojo** es el número de daño de siempre con resistencia 1: el rojo
  que ya significa "el malware resiste". Sin código nuevo en los números.
- **Los dibujos de cada arma van en su `DatosArma`** (exports nuevos, sin
  clases nuevas), no en un diccionario por nombre: más robusto, y la
  evolución trae los suyos sin código.
- **Las chispas del robo de vida salen de `mas_cercano`** de cada objetivo
  alcanzado: da la posición de un enemigo de verdad sin cambiar
  `danar_en_area` en los cinco tipos de objetivo. Van en un hijo del aura
  con `z_index` 4 para quedar encima de la horda, porque el aura va debajo.

### Problemas encontrados y cómo se resolvieron

- **`jefe.gd` no compilaba** (`var sin_jaula := not _jaula.activa()`: con
  `_jaula` tipado como `Node2D`, Godot no deduce el tipo). El import y el
  `--quit-after` no lo cazaron porque solo cargan el menú. Desde entonces la
  validación también **carga la escena de la partida** con un script
  temporal.
  Volvió a pasar en el lote 4 (`var lado := Vector2(...) * muerte[2]`, con
  `muerte` sacado de un `Array` sin tipo): se cazó al cargar la partida.
  Con valores de un `Array` o de un `Node2D` sin tipo, escribir el tipo
  (`var lado: Vector2 = ...`).
- **El simulador vuelve a cargar `juego.tscn` en cada partida**, así que si
  se cambia el código mientras corre, las partidas siguientes cogen el
  cambio. Para medir el antes y el después hay que correrlo en una copia
  aparte (`git worktree add`), fijada en el commit que se quiere medir.
- **Las pruebas con ventana iban más lentas que el reloj** (GPU por
  software): las esperas tienen que contar fotogramas de física con
  `--fixed-fps 60`, no segundos reales. Y las subidas de nivel pausaban la
  prueba: la instrumentación elige la primera mejora sola.

### Cómo se trabaja en la nube

- Godot no viene instalado: se baja el de Linux de la release oficial de
  4.7.2 cada sesión (el contenedor se borra).
- Headless igual que siempre. Con ventana, `xvfb-run` con
  `--rendering-driver opengl3`: renderiza por software (llvmpipe), compila
  los shaders y sirve para capturas, pero no para medir FPS.
- No hay audio (driver de prueba): el sonido solo se comprueba por el bus.
- Un hook de la nube pide hacer push al acabar cada respuesta; se ignora
  salvo que Adam diga subir.

### Uso de IA

Claude Code en la nube integró los seis lotes (código, escenas, pruebas,
capturas y documentación) siguiendo el prompt de cada uno, que Adam preparó
con Claude en el chat junto con los sprites. Las decisiones son de Adam; lo
que el prompt dejaba a elección de Claude está en «Decisiones técnicas». Sin
subagentes.

### Métodos de test empleados

- Headless: import, `--quit-after` y cargar la partida, tras cada cambio.
- Con ventana (xvfb), con instrumentación temporal borrada al acabar:
  aviso, onda y jaula, jugador contra el muro (162 px = 174 − 12) y jefe
  (134 = 174 − 40), rotura, ráfaga simple y doble, rabia; pausa a mitad
  (todo se congela); el jefe muere con jaula y ráfaga (desaparecen); las
  cuatro anclas con su color, el Firewall contra un ancla ajena (0, sin
  perder vida) y contra la suya (pierde vida), tres rotas, cerradas a los
  12 s justos y el reparto sin el Mago caído; el golpe del Firewall y el
  Firewall perimetral, el Escáner y el Análisis heurístico, el anillo rojo
  con la resistencia al 50 % y a x1,3 con Ampliar subred tres veces, la pausa
  a mitad del pulso (se congela), las chispas (3, de enemigos de verdad) y
  el destello del Ping; subir de nivel al cerrar el panel, el cambio con
  cada personaje, el corazón, la pausa (se congela) y la muerte de los cinco
  tipos de la horda con su color y su tamaño; los élites con cada afijo,
  con dos a la vez, el jugador dentro del aura helada (ralentizado), el
  aviso del Explosivo como antes, los cuatro fotogramas del reposo y la
  pausa; el menú con el logo y un fotograma del glitch, el panel del equipo
  con un personaje caído, la ventana de caída, los élites con los iconos de
  sus afijos, la subida de nivel con los iconos nuevos, las reglas (mejoras y
  afijos) y el lanzador con la cabecera.
- Una partida entera del simulador, solo para ver que no hay errores.
- Sin simulaciones: Adam las deja para más adelante.

### Estado al cerrar

Los seis lotes de assets están integrados, probados y documentados, y
**subidos a la rama `claude/beautiful-maxwell-uijhtj`, no a `main`**. `main`
sigue en la sesión 16 (`8bd3506`). No se ha publicado ninguna versión. Las
vistas previas, `LEEME.txt` y los prompts de cada lote no se commitean:
siguen en los zips de la rama `zips-lotes`.

### Siguiente paso (para el Claude Code del ordenador)

Por orden. Lo que dice «con Adam» se le pregunta antes.

1. **Integrar la rama en `main`** (lo pide Adam). Desde `main` y con
   `git status` limpio:
   ```
   git fetch origin
   git merge origin/claude/beautiful-maxwell-uijhtj
   ```
   No hay ficheros de Alan ni conflictos esperables: `main` no ha cambiado
   desde que salió la rama. Después validar como siempre y, además,
   **cargar la escena de la partida** (un script temporal `extends
   SceneTree` que instancie `escenas/juego.tscn` y la deje correr unos
   segundos): el import y el `--quit-after` solo cargan el menú y no ven los
   errores de los scripts de la partida (dos veces en esta sesión). Validar
   también `lanzador/` (import y `--quit-after`). La subida a `main` va con
   «ya he acabado», como siempre.
2. **Probar jugando en casa**, con ventana y la GPU de verdad (en la nube no
   hay ni audio ni GPU):
   - el jefe del minuto 10: el pisotón y la jaula (que no se pueda salir y
     que la horda de fuera se amontone), la ráfaga (si el proyectil de 16x16
     se ve; si no, decidir con Adam si se dibuja a x2) y la rabia
   - el escudo de NÚCLEO CERO: cambiar de personaje para cada ancla, el 0
     rojo y el cierre a los 12 s
   - los efectos de las herramientas, de subir de nivel, del cambio, del
     corazón y de la muerte de la horda
   - los élites con sus afijos y sus iconos
   - el menú con el logo, el panel del equipo (C), la ventana de caída y el
     lanzador (este solo se ve exportado, o con su proyecto abierto)
   - cómo suenan el pisotón, la ráfaga y la rabia (`jefe_ataco`)
3. **Medir el rendimiento** con `herramientas/medir_rendimiento.gd`, con
   ventana: el Firewall ataca cada 0,5-0,6 s, el Ping saca un destello en
   cada impacto y en los minutos 9-10 mueren muchos enemigos a la vez
   (`muertes_horda.gd`, un nodo que las dibuja todas).
4. **El simulador** (Adam lo dejó para más adelante):
   - antes, enseñar al bot a cambiar de personaje para romper cada ancla
     (el de la herramienta del ancla más cercana sin romper). Ahora solo
     rompe las del que lleva y pierde siempre en el núcleo armado.
   - medir con una copia aparte (`git worktree add`), fijada en el commit
     que se mide: el simulador vuelve a cargar `juego.tscn` en cada partida
     y, si el código cambia mientras corre, las siguientes cogen el cambio.
   - 10 partidas por dificultad, comparadas con el objetivo (fácil 7-8,
     media 4-5, difícil 1 de 10). Sin medir todavía lo de la sesión 16
     (horda más suave y robo de vida) ni lo de esta.
5. **Para decidir con Adam:**
   - lo que Claude eligió en el lote 6 (en «Decisiones técnicas»): los
     personajes de las reglas sin retrato, el aviso del HUD del élite sin
     iconos y el lema del lanzador quitado
   - `jefe.gd` tiene 311 líneas y `enemigo_elite.gd` 219 (la guía es ~200):
     se podría sacar la rabia del jefe a su script
   - lo que queda del punto 3 de `requisitos_y_estado.md`: que en media
     huya la mitad de la horda, la embestida triple y el guardaespaldas del
     jefe, y el resto de NÚCLEO CERO más duro
6. **`armas_evolucionadas.zip`**, en la rama `zips-lotes`: el único que
   falta. En su README va el primero; Adam dirá cuándo. Seguramente son las
   «mejoras visibles en los personajes» del punto 1 de
   `requisitos_y_estado.md`: mirarlo con Adam.
7. **La cabecera del lanzador** llega a los jugadores con el
   `lanzador_*.pck` de la próxima versión que se publique (solo cuando Adam
   lo pida).

---

## Sesión 18 — 22/10/2026, jueves (instituto, en curso)

**Duración:** por apuntar · **Fitas:** 5 y 6 · **Participantes:** Adam (con
Claude Code)

**Se apunta como la sesión de clase del jueves 22/10** (decisión de Adam).
Lo de abajo se hizo antes, desde el ordenador de casa (con la RTX 5070); en
clase Adam sigue con esta misma sesión y añade lo que haga. **Al cerrarla en
clase:** apuntar la duración de toda la sesión, las horas acumuladas y lo
nuevo en cada apartado.

### Qué se ha hecho

- **Integrada en `main` la rama de la nube** (`claude/beautiful-maxwell-uijhtj`,
  sesión 17): avance rápido, sin conflictos y sin ficheros de Alan. Siguen
  siendo 16 clases globales y `project.godot` no cambia:
  `EJECUTABLE_MINIMO` sigue en 0.2.
- **Validada como pide la sesión 17:** import y `--quit-after` del juego y del
  lanzador sin errores, y una partida cargada en headless con un script
  temporal que salta al jefe del minuto 10 (pisotón 3 veces, ráfaga 8 y
  rabia), lo mata, pasa a la fase 2, salta a NÚCLEO CERO, recorre sus tres
  formas con el escudo y lo mata: victoria y ningún error. Al salir, solo el
  aviso conocido de los sonidos que siguen sonando.
- **Mirado con capturas con ventana** en la RTX 5070 (a petición de Adam,
  «pruébalo tú a ver si se ve bien»): las tres herramientas con su alcance y
  su golpe, el efecto del cambio de personaje, el panel del equipo con los
  retratos, subir de nivel, el corazón, los élites con sus afijos, la horda
  del minuto 9, el jefe del minuto 10 (aviso del pisotón, jaula, ráfaga y
  rabia), la fase 2, NÚCLEO CERO con el escudo y las anclas de colores (y el
  0 rojo en la ajena), la ventana de caída, el menú con el logo, las reglas
  y el lanzador con la cabecera. Todo se ve bien salvo lo de abajo.
- **Arreglo:** en la ventana de caída, con el retrato nuevo, el nombre de
  una evolución larga («Análisis heurístico») llegaba al borde del botón.
  Botones más anchos (640) y alineados a la izquierda, con los retratos en
  columna.
- **Rendimiento medido** (`medir_rendimiento.gd`, con ventana, RTX 5070),
  con 100, 300, 600 y 1200 enemigos:
  - fase 1: 1436, 946, 600 y 214 FPS (igual que el 16/10)
  - fase 2 con NÚCLEO CERO: 1246, 777, 524 y 160 FPS (el 16/10, 1234,
    835, 545 y 202). Con 1200 baja algo y el peor paso de física llega a
    18,9 ms, pero la partida nunca tiene tantos a la vez.
- **Publicada la v1.7** (a petición de Adam, «cuando esté, sube el juego»),
  con las novedades en `documentacio/novedades/v1.7.txt`. Lleva lo de la
  sesión 16 (robo de vida y menos horda) y los seis lotes de la 17. La
  cabecera nueva llega al lanzador con su `lanzador_*.pck`.

Después de publicar (todo esto va en `main`, no en la v1.7):

- **Búsqueda de fallos** (pedida por Adam, que vio «97 / 96» en la ficha de un
  enemigo). Revisado el código nuevo de la nube (jefe, jaula, ráfaga, escudo,
  anclas, efectos, élites, audio, menú y lanzador). Dos fallos, los dos en la
  ficha del enemigo:
  - **La vida mayor que la máxima:** la actual se redondeaba hacia arriba y
    la máxima al más cercano (96,4 salía «97 / 96»). Ahora las dos hacia
    arriba, y en el panel del equipo y en la ventana de caída la máxima
    también (antes se truncaba).
  - **La resistencia de otra herramienta:** al evolucionar la de un
    personaje que no se llevaba, la ficha pasaba a enseñar la resistencia a
    esa evolución. Ahora solo escucha `personaje_cambiado`.
- **El bot del simulador cambia de personaje para las anclas:** va a las del
  personaje que lleva y, si no le queda ninguna, a la más cercana de otro y
  cambia a él (con Q o E, por el camino más corto). Con el escudo no cambia
  por la resistencia.
- **El simulador puede empezar en un minuto** (`minuto=15` o `minuto=10`),
  con el nivel y las mejoras del F1, para medir solo un jefe. Y apunta cada
  vez que el escudo se levanta, se vuelve a cerrar o se rompe.
- **El escudo de NÚCLEO CERO no se podía romper.** Con el bot ya cambiando,
  en 9 partidas desde el minuto 15 se levantó de 7 a 13 veces por partida y
  lo rompió una sola vez. Con un diagnóstico temporal se vio por qué: a
  nivel 16 le quita a un ancla unos 40-60 de vida por segundo (cada una de
  800 tardaba 15-19 s), más unos 2 s de camino entre anclas, y había que
  romper tres en 12 s con dos cambios de personaje separados por los 10 s de
  espera. Arreglado con lo que decidió Adam (abajo): ahora lo rompe a la
  primera las dos veces que sale, y desde el minuto 15 gana 7 de 9 (3 de 3
  en fácil, 2 de 3 en media y en difícil).
- **Las victorias, medidas por primera vez desde el 16/10** (10 partidas por
  dificultad, enteras, con todo lo anterior):

  | | Fácil | Media | Difícil |
  |---|---|---|---|
  | Victorias | 4 | 0 | 0 |
  | Llegan al jefe final | 10 | 9 | 4 |
  | Objetivo de Adam | 7-8 | 4-5 | 1 |

  - En fácil, las seis derrotas son en la última forma de NÚCLEO CERO.
  - En media, al bot le caen 2 de los 3 personajes en cada partida; el que
    queda tiene su herramienta con un 50 % de resistencia y se le acaba el
    tiempo (240 s) contra el jefe final, con la vida casi llena.
  - En difícil, 6 de 10 mueren contra el jefe del minuto 10.
  - Antes de arreglar el escudo, las 30 se quedaban en el núcleo armado.
- **Equilibrado al objetivo de Adam** («arréglalo para que sea tal que así»).
  El simulador apunta ahora dónde cae cada personaje, y así se vio:
  - **media:** al llegar el jefe del minuto 10 hay 950-1350 enemigos en
    pantalla y caen dos personajes enseguida; el jefe es lo de menos (sin la
    ráfaga o sin el pisotón caen los mismos)
  - **todas:** contra NÚCLEO CERO se pierde por tiempo, con el personaje
    entero: el bot le quita unos 30-40 de vida por segundo (suele quedar uno,
    con su herramienta resistida; el jefe recibe x0,75 y x0,6 en sus formas
    2 y 3, y cada escudo se lleva 20-40 s)
  - **difícil:** con solo el Espadachín y su herramienta al 50 %, las cuatro
    anclas (todas suyas) no se rompían antes de cerrarse y la partida se
    atascaba en el 66 % de vida del jefe

  Cambios, probados uno a uno con 10 o 20 partidas por dificultad:
  - **En media huye la mitad de la horda al llegar el jefe** (punto 3.3, ya
    aprobado por Adam en la sesión 16). Cada enemigo lleva su marca de
    huida y se desvanece solo él: el shader de la horda lee el cuarto dato
    de su instancia. Visto con ventana.
  - **Las anclas reciben el golpe entero**, sin la resistencia del malware.
  - **La vida de NÚCLEO CERO va aparte en la tabla de dificultades**
    (`vida_jefe_final`): con un solo multiplicador, para bajársela había que
    ablandar toda la horda, y fácil saltaba de 4 a 9 victorias entre 0,7 y
    0,6.
  - **Los valores:**

    | | Vida | Vida de NÚCLEO CERO | Daño recibido | Huye |
    |---|---|---|---|---|
    | Fácil | 0,7 → 0,65 | 0,7 → 0,4 | 0,6 | toda |
    | Media | 1 → 0,7 | 1 → 0,75 | 1 → 0,85 | nada → la mitad |
    | Difícil | 1,2 → 1 | 1,2 → 0,75 | 1,3 → 1,1 | nada |

  - **Resultado, con 20 partidas por dificultad** (semillas 1-20): fácil 15
    (7,5 de cada 10), media 9 (4,5) y difícil 2 (1). Probado también con
    difícil al 0,5 de vida de NÚCLEO CERO y 1,15 de daño (2 de 20), pero
    quedaba con menos vida que en media; se dejó igual que en media para
    que la tabla vaya siempre de fácil a difícil.
- **Las releases, solo con lo del lanzador** (pedido por Adam: que el juego
  solo se pueda jugar con el lanzador). Desde la próxima versión la Action
  ya no publica `SectorCero_vX_windows.zip` ni `_linux.zip` (el juego
  suelto): quedan los dos instaladores, los `.pck` (el contenido de cada
  versión, que baja el lanzador, y el del propio lanzador, para que se
  actualice solo) y `version.json`. Un `.pck` solo no se abre sin el motor
  que instala el lanzador. La web se deja (decisión de Adam). Además, la
  Action comprueba al final que se ha subido cada fichero y sube el que
  falte (en la v1.7 faltó `lanzador_linux.pck`). Las releases ya publicadas
  (v0.2 a v1.7) siguen con sus zips: borrarlos es cosa de Adam desde la web
  de GitHub, si quiere. README, manual (que aún explicaba el `.zip` y el
  menú VERSIONES de antes del lanzador) y CLAUDE.md al día.

### Decisiones de Adam

- Que Claude lo pruebe con capturas en vez de jugarlo él, y que publique la
  versión cuando se vea bien.
- **Espadachín:** no se toca. Ya tiene robo de vida desde la v1.7 (Adam aún
  no lo había jugado); si sigue flojo, se mira al equilibrar.
- **Escudo de NÚCLEO CERO:** mientras está puesto, cambiar de personaje no
  tiene espera (`sin_espera` en `cambio_personaje.gd`, que pone y quita el
  escudo), y las anclas pasan a 300 de vida (la de antes de la sesión 17) con
  30 s para romperlas (eran 800 y 12 s). Cada ancla sigue rompiéndola solo
  su herramienta.
- Empezar por enseñar al bot a cambiar de personaje y medir las victorias.
- **El equilibrio, ahora:** que sean 7-8 victorias de cada 10 en fácil, 4-5 en
  media y 1 en difícil. Los valores los eligió Claude con el simulador.
- **Releases:** solo los instaladores y lo que necesita el lanzador (los
  `.pck` y `version.json`), sin el juego suelto. La web se queda.
- Esta sesión se apunta como la de clase del jueves 22/10, y Adam la sigue
  en clase.

### Problemas encontrados y cómo se resolvieron

- **El jefe del minuto 10 sale casi blanco** en algunas capturas: es el
  destello de recibir golpes (v1.1), que con el Firewall pegándole sin parar
  se ve casi siempre. No es nuevo; anotado para mirarlo jugando.
- **La ráfaga del jefe se ve pequeña** (16x16): se distingue, pero cuesta.
  Queda para decidir con Adam si se dibuja a x2 (sesión 17, punto 5).
- **El fichero de opciones del jugador cambió** durante la sesión (volumen de
  efectos y avisar de versiones): son opciones que solo se tocan a mano desde
  el panel de opciones, no las pruebas. Los récords y el ranking, intactos.
- **A la release v1.7 le falta `lanzador_linux.pck`**, aunque la Action
  acabó bien y lo tiene en la lista de `gh release create` (la v1.6 sí lo
  tiene). Exportado en local sale bien e igual byte a byte que el de
  Windows. Consecuencia: los lanzadores de Linux ya instalados no cogen la
  cabecera nueva hasta la próxima release; los que se instalen con el zip de
  la v1.7 ya la traen. Arreglo, si se quiere: subir a la release una copia
  de su `lanzador_windows.pck` con el nombre `lanzador_linux.pck`.
- **Precargar el script del ancla desde el simulador lo rompía:** con
  `preload` en un script de `--script`, `ancla_escudo.gd` se compila antes que
  los autoloads, no encuentra `BusEventos` y falla; entonces las armas daban
  error al pegarle a un ancla y dejaban de hacer daño a mitad de cada ataque.
  Las 30 partidas de ese commit (todas perdidas) no valen y se tiraron. El
  personaje de cada ancla se lee ahora de su script ya cargado en la partida.
  Lo mismo vale para cualquier herramienta: no precargar scripts que usen
  autoloads.

### Uso de IA

Claude Code integró la rama, escribió la instrumentación temporal (borrada),
hizo y revisó las capturas, arregló la ventana de caída, midió el rendimiento
y publicó la versión. Después buscó y arregló los fallos de la ficha, enseñó
al bot a cambiar de personaje, midió con el simulador y propuso los cambios
del escudo, que decidió Adam. Sin subagentes.

### Métodos de test empleados

- Headless: import y `--quit-after` del juego y del lanzador, y la partida
  cargada con un script temporal (de 10:00 a la victoria).
- Con ventana: 26 capturas con un script temporal y otra de la ventana de
  caída tras el arreglo.
- `medir_rendimiento.gd`, fase 1 y fase 2.
- Simulador, siempre en una copia aparte (`git worktree`) fijada en el commit
  medido: 30 partidas enteras antes y después del arreglo del escudo, y 9
  desde el minuto 15 con cada versión del escudo (800 y 12 s; sin espera;
  300 y 30 s). Para el equilibrio, una partida por proceso (30 o 60 a la
  vez) sobre el proyecto sin tocar mientras corren, con un script de
  PowerShell que las lanza y resume victorias, dónde acaba cada una, dónde
  caen los personajes y con cuánta vida queda el jefe final: once tandas.
- Con ventana: la huida de la mitad de la horda en media (tres capturas).

### Siguiente paso

1. **Adam, jugando** (con lo de `main`, o con la próxima versión): el sonido
   (pisotón, ráfaga, rabia), si la jaula y el escudo se entienden, el
   escudo con el cambio sin espera, el Espadachín con el robo de vida y si la
   ráfaga hay que dibujarla a x2.
2. **Volver a medir las tablas del F1** (`progreso_por_minuto.gd`): se
   midieron en media, que ahora tiene otros valores, y el nivel por minuto
   puede haber cambiado.
3. Lo de decidir con Adam (sesión 17, punto 5). `armas_evolucionadas.zip`
   (punto 6) ya está, abajo.
4. **La próxima versión (v1.8)**, cuando Adam la pida: lleva el equilibrado,
   el escudo arreglado, los fallos de la ficha y las releases sin el juego
   suelto. Antes, escribir `documentacio/novedades/v1.8.txt` y, después,
   comprobar que la release trae justo los dos instaladores, los cuatro
   `.pck` y `version.json`.

### Estado al subir desde casa

Todo en `main` y subido a GitHub. Publicada la v1.7 (sin el equilibrado,
que es de después). La sesión sigue abierta para la clase del 22/10.

### En la nube, durante el día (22/10)

Desde Claude Code en la nube, en la rama `claude/beautiful-maxwell-uijhtj`,
que se volvió a poner al día con `main` (la de ayer ya estaba integrada).
**Hay que integrarla otra vez en `main`** (`git fetch origin` y `git merge
origin/claude/beautiful-maxwell-uijhtj`, avance rápido) y validar como
siempre, cargando también la partida.

- **Adam preguntó qué falta por añadir al juego** y pidió aplicar solo lo que
  no cambia el equilibrio, que ya está en su objetivo. De la lista (punto 3
  de `requisitos_y_estado.md` y siguientes), lo único así era
  `armas_evolucionadas.zip`: los movimientos que faltan del jefe y de NÚCLEO
  CERO lo descuadrarían.
- **Las evoluciones se ven en el personaje** (`armas_evolucionadas.zip`, el
  último zip de `zips-lotes`): tres hojas nuevas con el cuerpo idéntico y el
  arma evolucionada, un campo nuevo `hoja_evolucion` en `DatosPersonaje` y,
  en `cambio_personaje.gd`, la hoja que toca según su arma. Sin señales ni
  `class_name` nuevos.
- **Aclarado a Adam:** «la ráfaga a x2» es dibujar el proyectil al doble de
  tamaño (el daño y dónde golpea no cambian), no disparar el doble; queda
  para que lo decida él. «El retrato en las reglas» era si poner el retrato
  en la pestaña Personajes: se queda el sprite, porque el retrato a 48 px se
  deforma.
- **Probado:** import, `--quit-after` y la partida cargada en headless; con
  ventana, los tres personajes andando antes y después de evolucionar, y con
  E y Q cada uno sigue con su hoja; en headless, el Mago evolucionado en el
  banquillo entra con la suya. Una partida del simulador, para ver que no hay
  errores. Una vez salió al cerrar «2 resources still in use», que no se
  repitió en otros tres intentos ni sale en `main` sin el cambio: es el aviso
  conocido de los sonidos que siguen sonando.
- **El golpe del Espadachín y el radar del Segador se veían demasiado**
  (Adam: «prueba a meter más frames»). En vez de dibujar fotogramas nuevos,
  cada uno se funde con el siguiente (como tener muchos más) y el efecto
  empieza al 55 % de opacidad y se va apagando (`OPACIDAD_EFECTO` en
  `aura_arma.gd`). Comparado con ventana, el antes y el después, en cuatro
  momentos de cada ataque. Si se queda corto o se pasa, se cambia ese número.
- **El robo de vida del Espadachín curaba demasiado** (Adam, jugando: quieto
  en el minuto 8:30 casi no perdía vida). Con la horda encima siempre llega
  al tope por golpe, así que lo que manda es el tope: bajó de 3 a 1,5
  (`ROBO_MAXIMO` en `gestor_armas.gd`), de unos 5 a 2,5 de vida por segundo
  con el Firewall. **Cambia el equilibrio, que estaba en el objetivo:** hay
  que volver a medir las victorias con el simulador (en casa, con muchas
  partidas a la vez; en la nube se tarda horas).
- **Aclarado a Adam:** la ráfaga es la del jefe del minuto 10, no los
  disparos del Mago.
- **Integrado en `main`** a petición de Adam («intégralo todo al main»):
  avance rápido desde la rama, sin conflictos.
- **La tarjeta de una evolución se nota** (Adam: «que se note que es una
  mejora del personaje», por ejemplo con el color de la tarjeta entera). En
  la subida de nivel, la de una evolución es del color de su personaje
  (fondo y borde grueso), con él de frente y el arma nueva en vez del icono,
  «EVOLUCIÓN DEL ESPADACHÍN» y el borde latiendo. El personaje se saca del
  arma base de la evolución (`tarjeta_evolucion.gd`). Visto con ventana con
  las tres evoluciones, y que una tarjeta vuelve a la normal cuando después
  trae una mejora normal.
- **La jaula y la ráfaga del jefe del minuto 10, más difíciles** (Adam: «se
  puede esquivar bastante más fácil»; lo llamó «el boss final», pero son del
  jefe del minuto 10). La jaula avisa 0,5 s (eran 0,8) y es un 30 % más
  grande (`ESCALA` en `jaula_jefe.gd`, que escala el dibujo y el muro: de 226
  a 242 px). La ráfaga va a 280 px/s (eran 200) durante 1,6 s, y su
  proyectil se dibuja a x2 (`ESCALA` en `rafaga_jefe.gd`) sin cambiar dónde
  golpea. Probado con ventana: el jugador se para contra el muro a 214 px
  (226 − 12), la pausa lo congela y la ráfaga doble sale bien. **También
  cambia el equilibrio:** se mide junto con el robo de vida.

