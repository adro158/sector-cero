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
