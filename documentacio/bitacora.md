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
