# Documentación técnica — Sector Cero

**Autores:** Adam y Alan · **Motor:** Godot 4.7.2 (GDScript) · **Plataformas:**
Windows y Linux

Este documento explica cómo está hecho el juego por dentro. Cómo llegamos hasta
aquí, con capturas de cada etapa, está en la
[historia del proyecto](historia_del_proyecto.md), y el detalle de cada sesión
en la [bitácora](bitacora.md).

## 1. El juego en pocas palabras

Sector Cero es un *survivors-like* en 2D con vista desde arriba. Eres un
proceso antivirus dentro de un ordenador infectado: solo te mueves y tu
herramienta ataca sola. El malware llega en oleadas cada vez más densas, suelta
fragmentos de datos que dan experiencia y, al subir de nivel, eliges una de tres
mejoras. A los 10 minutos llega un jefe; al derrotarlo el sector queda dañado y
empieza la fase 2, y a los 15 minutos llega el jefe final, NÚCLEO CERO:
derrotarlo es ganar.

**Lo que lo hace distinto es la resistencia adaptativa:** el malware se vuelve
resistente a la herramienta que más daño le hace, como el malware real con los
antivirus más usados. Para seguir haciéndole daño hay que cambiar de personaje,
porque cada uno lleva una herramienta distinta.

## 2. Cómo está organizado

### Las escenas

```
menu_principal.tscn          Menú: reglas, ranking, opciones y récord
juego.tscn                   La partida, que junta tres piezas:
├── Arena                    El suelo infinito
├── RaizJuego                Toda la jugabilidad
│   ├── Jugador              Movimiento, salud, armas y cambio de personaje
│   ├── Un gestor por tipo de enemigo (cinco)
│   ├── Pools de gemas, proyectiles, partículas y números de daño
│   ├── ResistenciaMalware   El elemento diferencial
│   ├── Jefe, JefeFinal y tres élites   Ocultos hasta que el director los activa
│   ├── DirectorOleadas      Qué aparece, cuándo y dónde
│   └── SistemaNiveles       Experiencia, niveles y mejoras
└── Interfaz/HUD             HUD, mejoras, pausa, ficha del enemigo y final
```

Además hay seis **autoloads**, nodos que existen siempre aunque cambie la
escena: `Actualizador` (busca versiones nuevas), `BusEventos`, `GestorGuardado`
(récords, ranking y opciones), `GestorAudio`, `Transicion` (fundidos a negro) y
`EfectoCRT` (el filtro de monitor antiguo).

### Cómo se hablan las piezas

**Un bus de eventos.** `BusEventos` es un nodo que solo declara señales: la vida
del jugador ha cambiado, se ha subido de nivel, ha muerto un enemigo, ha
terminado la partida... La jugabilidad las emite y la interfaz, el audio y el
guardado las escuchan, sin conocerse entre ellos. Nació para que dos personas
pudieran trabajar sin tocar los ficheros del otro y lo mantuvimos porque hace el
código fácil de cambiar: el audio, por ejemplo, no lo llama nadie, escucha.

**Grupos en vez de rutas.** Cuando un nodo necesita a otro lo busca por su grupo
(`jugador`, `objetivos`, `elites`...) y no por su posición en el árbol. Así se
puede reorganizar una escena sin romper otra.

**Un mismo contrato para todo lo que recibe daño.** Los gestores de la horda,
los élites, los dos jefes y las anclas del escudo del jefe final están en el
grupo `objetivos` y tienen los mismos métodos:
`danar_en_area`, `mas_cercano` y, para la ficha del enemigo, `ficha_en` y
`ficha`. Las armas recorren el grupo sin saber qué es cada uno.

### Los datos, fuera del código

Cada arma, mejora, tipo de enemigo, afijo de élite y personaje, y la
configuración de las oleadas, es un **recurso** (`.tres`) con su clase de datos.
Añadir un enemigo o una mejora es crear un fichero, y el equilibrio se cambia
sin abrir ninguna escena.

Una regla importante: **las mejoras nunca modifican el `.tres`**. Godot comparte
los recursos cargados y los guarda en memoria; si una mejora sumara un 12 % de
daño al recurso del arma, se quedaría para la siguiente partida. Por eso las
mejoras son multiplicadores en el nodo al que afectan.

## 3. Las piezas principales

**La horda: un enemigo no es un nodo.** Con un nodo por enemigo, cientos de
enemigos serían cientos de nodos procesándose y dibujándose por separado. Cada
tipo de enemigo es un gestor con listas de tamaño fijo (posiciones, vidas,
destellos...) y un solo `MultiMeshInstance2D` que los dibuja todos de una vez.
Cuando un enemigo muere, el último de la lista ocupa su hueco: los vivos siempre
están al principio y crear o destruir uno es mover un contador.

**La rejilla espacial.** Para que los enemigos no se amontonen, cada uno tendría
que compararse con todos los demás, y eso crece con el cuadrado. La rejilla
divide el mapa en celdas y solo se miran las cercanas: con 500 enemigos, el
cálculo bajó de 19 ms a 4 ms por fotograma (el límite a 60 FPS son 16,7 ms). Las
armas la usan también para encontrar a quién golpear.

**Animación y efectos, en el shader.** Un MultiMesh dibuja todos los enemigos
de un tipo con una sola textura y un solo material, así que no puede darle a
cada uno su propio sprite. La animación se consigue igualmente: la textura es
una **tira de fotogramas** en horizontal y el shader (`horda.gdshader`) elige
el fotograma de cada enemigo con el tiempo y su número de instancia, con un
desfase para que no se muevan todos a la vez. Como `UV` va de 0 a 1 en todo
el cuadrado del enemigo, se lleva al trozo de la tira que toca: el fotograma
*f* de *n* va de *f/n* a *(f+1)/n*. El color que llega a `fragment()` ya trae
la textura leída con `UV` (el primer fotograma), así que se lee la buena y se
multiplica por el color del vértice, que `vertex()` guarda en un `varying` (un
valor que pasa de un paso del shader al otro): así la horda se sigue
desvaneciendo al huir. Sigue siendo una llamada de dibujo por tipo, con una
copia del material por tipo para sus fotogramas y su velocidad. El mismo
shader pone el destello blanco al recibir un golpe, un *glitch* que los hace
saltar como una imagen corrupta y el parpadeo rojo del troyano antes de
embestir; cada enemigo le pasa sus propios datos (`INSTANCE_CUSTOM`). El
troyano, dibujado mirando a la izquierda, se da la vuelta para mirar al
jugador con la escala x de su transformación (`volteo_horda.gd`), y solo
cambia de lado si el jugador está a más de 8 px, para no parpadear.

**El destello de los élites y del jefe.** Son nodos, y su `Sprite2D` lleva
`sprite_destello.gd`: un material propio con un shader que mezcla con blanco,
como la horda. No usa el `modulate`, que ya cambian el aviso rojo y el latido
morado del jefe. Las piernas del jugador y del jefe avanzan en proporción a la
velocidad a la que se mueven de verdad (con la mejora de velocidad, en el aura
lenta o embistiendo), para que los pies no patinen.

**Los efectos de las herramientas.** Desde el 21/10 el alcance de las armas
de área es un anillo dibujado en grises que `aura_arma.gd` tiñe de cian a
rojo según la resistencia (antes era un círculo hecho por código), y en cada
ataque sale encima su efecto en su color: el golpe del Firewall y el pulso
de radar del Escáner, y los de sus evoluciones. Cada arma lleva sus dibujos
en su `DatosArma` (efecto, fotogramas, tiempo, anillo y el radio al que están
dibujados), así que no hay que elegirlos por el nombre; con la mejora de
alcance se escalan (radio de verdad / radio del dibujo). El efecto empieza
medio transparente y se va apagando, y cada fotograma se funde con el
siguiente para que salga suave (a petición de Adam, el 22/10: se veía
demasiado). El aura va detrás
del jugador (`show_behind_parent`), debajo de él y de la horda. El Ping saca
un destello donde impacta o rebota (`pool_proyectiles.gd`). Con el robo de
vida salen chispas verdes de los enemigos alcanzados al Espadachín: como
`danar_en_area` solo dice a cuántos alcanza, la posición la da
`mas_cercano` de cada objetivo alcanzado (como mucho 5 por golpe). Van en un
hijo del aura con `z_index` 4, encima de la horda.

**La respuesta de la partida.** También desde el 21/10, sobre el personaje
salen efectos al subir de nivel, al cambiar de personaje (teñido del color
del que entra) y al coger el corazón de los élites (`efectos_jugador.gd`, un
hijo del jugador en el centro de su sprite, así que le sigue). Como subir de
nivel pausa el juego, el efecto sale en el primer fotograma después de la
pausa, ya con la mejora elegida. El de cambio sale solo si entra otro
personaje: `personaje_cambiado` también llega al empezar y al evolucionar la
herramienta. Y cada enemigo de la horda que muere se deshace en trocitos del
color de su tipo, escalados a su tamaño (`muertes_horda.gd`): un solo nodo
las dibuja todas con la misma textura, así que el motor las junta en pocas
llamadas de dibujado; las partículas de la horda bajaron de 7 a 3 por muerte.

**La interfaz con arte propio.** Desde el 21/10, el título del menú es el logo
(`medios/interfaz/`, la carpeta del arte de la interfaz) con un glitch cada 2
a 5 s (`logo_glitch.gd`): un `AtlasTexture` al que un `Tween` le cambia la
región, con su propio `RandomNumberGenerator` para no gastar el azar de la
partida. Dos campos nuevos en los recursos: `retrato` en `DatosPersonaje`
(64x64, en el panel del equipo y la ventana de caída, siempre a tamaño real
porque escalado se deforma) e `icono` en `DatosAfijoElite` (16x16, en las
reglas y encima de cada élite). El lanzador tiene su cabecera
(`lanzador/cabecera.png`), que está en su propia carpeta porque el lanzador es
otro proyecto de Godot y no ve los ficheros de `projecte/`.

**La explosión del rootkit.** Un élite explosivo avisa 0,8 s antes de
estallar: en su `_draw` se agrieta y se pone al rojo (6 fotogramas según lo
que queda de aviso), tiembla cada vez más y un anillo de peligro gira en el
borde de la zona de 130 px. El temblor sale de senos y no de `randf()`: un
número al azar gastado al dibujar cambiaría el azar de la partida y el
simulador dejaría de repetir las mismas partidas. Al estallar avisa por el
bus (`elite_exploto`) y `explosiones_elite.gd` dibuja la explosión (12
fotogramas) y la quemadura que queda 4 s en el suelo. Ese nodo va el primero
en la partida, así que la quemadura queda debajo del jugador y de la horda; la
explosión la dibuja su hijo `Fuego`, con más `z_index`, encima de todos. Es
solo dibujo: el daño, el radio y el tiempo de aviso no cambian.

**El troyano embiste sin ser un nodo.** Persigue y, cerca del jugador, se para,
parpadea y embiste en línea recta, igual que el jefe. Pero el jefe guarda su
estado en variables y un troyano es solo una posición en una lista; su estado,
su cronómetro y su dirección van en tres listas más que se mueven con él. Ese
código está aparte (`embestida_horda.gd`) y solo lo usan los tipos que
embisten.

**Personajes y herramientas.** Hay dos tipos de arma: de área (el Firewall del
Espadachín golpea alrededor y el Escáner del Segador da un pulso amplio y
lento) y de proyectil (el Ping del Mago salta de un enemigo a otro). Solo
dispara la del personaje activo y se cambia con E (siguiente) o Q (anterior),
con 10 s de espera. Los tres hacen un daño por segundo parecido; los diferencia
dónde pegan. Cada uno tiene su vida (Espadachín 120, Segador 100, Mago 90): el
nodo `Salud` del jugador es siempre la del activo, y el equipo
(`cambio_personaje.gd`) guarda la de los demás, que se curan 1,5 por segundo
mientras esperan. Si cae el activo y quedan otros, el juego se pausa y se elige
quién sigue (`personaje_caido` y `personaje_elegido`), y entra con 2 s sin
recibir daño; la partida se pierde al caer los tres. Con C se ve la vida de
todos.

**Las ultis.** Cada personaje carga la suya matando mientras juega (180
enemigos; un élite cuenta por 10) y la lanza con R: el Mago, un rayo morado
que atraviesa todo; el Espadachín, un giro con seis hojas de luz; el
Segador, un rayo sobre su guadaña y diez mini rayos alrededor. Pegan con el
mismo `danar_en_area` que las armas, a todo el grupo `objetivos`, y escalan con
las mejoras de daño, pero no cuentan para la resistencia del malware: no son
una herramienta. El rayo es una fila de círculos seguidos, sin solaparse, para
que cada enemigo del camino reciba un golpe por pasada. Los efectos se dibujan
con sprites (`dibujo_ultis.gd`: funciones estáticas a las que `ultis.gd` se pasa
a sí mismo como lienzo, para que la lógica y el dibujo vayan separados); el
rayo se arma con un tramo de 32 px repetido, se gira con `draw_set_transform` y
sale del pecho del Mago. Con el teclado, el Mago apunta el rayo con el ratón (R
para apuntar, click para lanzar); con el mando, en el móvil y en el simulador,
sin ratón, va solo al enemigo más cercano. El click de apuntar se lee en
`_input`, antes que la interfaz, para que no abra también la ficha del enemigo.

**El menú de desarrollador (F1).** Para probar cualquier parte del juego sin
jugar hasta ella: saltar a un minuto, darse mejoras, subir de nivel, ser
invencible, llenar las ultis, sacar el jefe, un élite o los premios, ir a la
fase 2, sacar el jefe final y pasarlo a su forma siguiente, revivir al equipo,
limpiar la horda y acelerar el juego. Está en todas las versiones; por
eso la partida en la que se abre no cuenta para los récords ni el ranking. Vive
en la escena de la partida, como el panel técnico (F3), y usa la jugabilidad
directamente.

Al saltar a un minuto, el jugador llega con el nivel y las mejoras que tendría
si hubiera jugado hasta ahí (se puede desmarcar). Las cifras de cada minuto,
hasta el 15, son la media de 10 partidas del simulador
(`depuracion/progreso_por_minuto.gd`), y las mejoras se eligen como las elige
su bot: la evolución si sale y, si no, una de ataque. Entre dos minutos se
toma lo que queda en medio (a las 7:30, la mitad entre el minuto 7 y el 8), y
volviendo atrás no se quita nada. Si cambia el balance, la tabla se vuelve a
medir: el simulador anota el nivel y las mejoras de cada minuto.

**La resistencia adaptativa.** Cada arma avisa del daño que hace. Cada 20 s, el
malware mira cuál le ha hecho más y gana un 10 % de resistencia contra ella
(máximo 50 %); contra las demás pierde un 5 %. Se ve en los números de daño y en
el anillo del arma, que se vuelven rojos. El jugador tiene dos respuestas:
cambiar de personaje o elegir la mejora Actualizar firmas, que frena la
adaptación.

**Progresión.** Las gemas de experiencia se tiñen según lo que valen y caducan
a los 30 s. Cada nivel cuesta un 50 % más que el anterior. Al subir, el juego se
pausa y se ofrecen tres de las ocho mejoras; si se suben varios niveles de golpe
quedan en cola. Elegir tres veces una mejora concreta ofrece la **evolución** de
una herramienta, que es otro recurso de arma, así que el malware empieza sin
resistencia contra ella. Desde el 22/10 se ve también en el personaje: cada
uno tiene en su `DatosPersonaje` una segunda hoja (`hoja_evolucion`) con el
arma nueva, y `cambio_personaje.gd` la pone cuando su arma ya no es la de sus
datos; así sale con ella también si evolucionó en el banquillo. En la subida
de nivel, la tarjeta de una evolución es de su personaje (su color, él con el
arma nueva y el borde latiendo; `tarjeta_evolucion.gd`).

**El director de oleadas.** La dificultad sale de pocos números: el tiempo
entre apariciones baja de 0,5 s a 0,05 s en 10 minutos, cada tipo de enemigo
dice a partir de qué minuto sale y cada enemigo aparece con un 4 % más de vida
por cada nivel del jugador y, desde el minuto 3, con un 15 % más por cada
minuto de partida: el principio es suave y a mitad de partida cuesta más matar.
Un tipo puede limitar cuántos hay a la vez: sin ese límite, el ransomware se
acumulaba por cientos. Cada minuto llega un **élite**
con uno o dos afijos al azar (blindado, replicante, aura lenta, explosivo). Desde
el 21/10 el rootkit está animado en reposo (cada uno empieza en un punto
distinto de su animación, sacado de dónde aparece y no de `randf()`, para no
gastar el azar del simulador) y cada afijo se ve con su efecto teñido de su
color (`dibujo_elite.gd`): las placas del Blindado encima del rootkit, en un
hijo que se dibuja con su señal `draw`, y las copias del Replicante y el
anillo helado del Aura lenta detrás, en el `_draw` del élite, que va antes
que su `Sprite`. El Explosivo, que no se ve hasta que muere, conserva un
anillo fino de su color. Al
morir deja un corazón, que cura la mitad de la vida, y un cofre. El cofre va a
la misma cola que las subidas de nivel, que distingue "nivel" y "cofre" para
que cada uno salga con su panel, y abre una **ruleta** de 8 sectores con las
mejoras (y una evolución si hay alguna disponible). El premio se sortea antes de
girar; el disco frena con un `Tween` hasta -45·k grados más unas vueltas, que
deja el sector k bajo la flecha. A los 10 minutos deja de salir horda y llega
el **jefe**; en fácil huye toda la horda que queda (se aleja del jugador y se
desvanece en 1,2 s, sin dar experiencia), en media la mitad (uno sí y otro
no: cada enemigo lleva su marca y su desvanecido, que el shader lee en el
cuarto dato de su instancia) y en difícil se queda. Además de embestir, el jefe tiene un tercer estado: cada
15 s se para, late en morado mientras crece un anillo y saca un círculo de 8 a
14 enemigos, más cuanto menos vida le queda; los crean los gestores de la
horda, como hace el élite replicante. Desde el 21/10 tiene tres más. La
**ráfaga** (`rafaga_jefe.gd`): cada 9 s dispara 12 proyectiles en círculo,
que se esquivan por los huecos, y con menos de la mitad de vida dos ráfagas,
la segunda girada 15°. El **pisotón** (`jaula_jefe.gd`): cada 20 s avisa con
un anillo rojo en el suelo y, al pisar, deja durante 4 s una jaula que nadie
cruza. La jaula no empuja a nadie: después de que cada uno se mueve, le
devuelve a su lado del muro. Como el muro tiene grosor (de 226 a 242 px desde el 22/10; era de 174 a 186),
basta con mirar si está más cerca del centro que de fuera, y nada va tan
deprisa como para cruzarlo en un solo fotograma. Lo usan el jugador, el jefe
y los cinco gestores de la horda, que encuentran la jaula por su grupo. Y la
**rabia**: por debajo del 25 % de vida va un 30 % más rápido y sus
intervalos se dividen entre 1,3, pero sus avisos duran lo mismo, así que se
siguen pudiendo esquivar. Los dibujos de la jaula van en un nodo de la raíz
de la partida entre las explosiones y el jugador, para quedar encima del
suelo y debajo de todo lo demás.

**La fase 2 y el jefe final.** Al derrotar al jefe, la raíz de la partida
pausa el juego y emite `transicion_fase`: la interfaz pone un negro de 3 s con
«SECTOR CERO DAÑADO» escrito letra a letra. Detrás del negro, la horda
desaparece sin dar experiencia y llega `fase_cambiada(2)`: la arena pone el
suelo dañado (el mismo shader con otras texturas y dos efectos nuevos,
chispazos y humo, que con sus valores por defecto no cambian nada: lo
comprobamos comparando el suelo normal píxel a píxel), el audio baja el tono
de la música y el HUD avisa. Mientras está el jefe, el reloj se para en las
10:00 y la fase 2 sigue desde ahí: así dura siempre lo mismo (5 minutos, en el
`.tres` de las oleadas) y el tiempo de una partida siempre crece con lo que se
avanza, que es lo que comparan el ranking y los récords. Como las victorias
pasan de unos 11 minutos a más de 15, el ranking y los récords empiezan de
cero: van en secciones nuevas del fichero de guardado, y las de antes no se
borran porque las versiones anteriores, que comparten el fichero, siguen
escribiendo en ellas. A las 15:00 llega
**NÚCLEO CERO**. Tiene tres formas en una sola hoja de sprites (una fila por
forma) y se transforma al 66 % y al 33 % de vida; un golpe que se pasaría de
largo se queda justo en el umbral, para no saltarse ninguna. En cada forma
recibe menos daño (100, 75 y 60 %) y ataca más deprisa. Sus ataques van en
otro script (`ataques_jefe_final.gd`): un rayo, un torbellino y una tormenta
robados a los personajes (se dibujan con las mismas funciones que sus ultis),
portales que sacan horda y cristales que dejan hielo, que ralentiza con la
misma función que el aura de los élites. Todos avisan antes de hacer daño. Al
cambiar de forma se encierra en un escudo: no recibe daño hasta que se rompen
sus cuatro anclas, que son objetivos con su vida y están en la escena desde el
principio, como los élites, porque las armas buscan sus objetivos al empezar.
Desde el 21/10 cada ancla es de un personaje y solo le quita vida su
herramienta. Las armas no dicen quién pega, así que el ancla escucha
`equipo_cambiado` y mira quién se lleva en ese momento: lo demás le saca un 0
rojo. El reparto es a-b-c-b, para que no queden dos del mismo color juntas,
y solo con los personajes que no han caído; si alguien cae con el escudo
puesto, sus anclas pasan a otro, porque si no el escudo no se podría romper.
Si en 30 s desde la primera rota no caen las cuatro, las rotas se cierran.
Mientras está el escudo, cambiar de personaje no tiene espera (`sin_espera`,
en `cambio_personaje.gd`). Hasta la sesión 18 eran 800 de vida, 12 s y la
espera de siempre (10 s), y el bot del simulador lo rompió una vez en nueve
partidas: le quita a un ancla unos 50 de vida por segundo y hacían falta dos
cambios. Ahora, 300 de vida (la de antes de la sesión 17) y 30 s. Y las
anclas reciben el golpe entero, sin la resistencia del malware (que es del
malware, no del escudo): si solo quedaba un personaje con su herramienta al
50 %, sus cuatro anclas no se rompían antes de cerrarse y la partida se
atascaba.
Su barra de vida, arriba en el centro, se entera de todo por el bus. Ninguno
de estos scripts tiene `class_name` ni toca `project.godot`: así llegan con la
actualización pequeña.

**Las dificultades.** Se eligen en el menú principal y se guardan con las
opciones. Están en una tabla (`globales/dificultad.gd`) con cuatro datos cada
una (fácil, media y difícil): cuánto se multiplica la vida de la horda, los
élites, el jefe y las anclas (0,65, 0,7 y 1), la de NÚCLEO CERO, que va aparte
(0,4, 0,75 y 0,75), el daño que recibe el jugador (0,6, 0,85 y 1,1) y qué
parte de la horda huye al llegar el jefe (toda, la mitad y nada). Están
ajustadas con el simulador (sesión 18) al objetivo de Adam: de cada 10
partidas, 7-8 victorias en fácil, 4-5 en media y 1 en difícil; con 20 por
dificultad salen 15, 9 y 2. La vida de NÚCLEO CERO va aparte porque contra él
se pierde por falta de daño, no de vida: con un solo multiplicador, bajarla
para el jefe final ablandaba a la vez toda la horda. Cada sistema lee la dificultad en su sitio: los enemigos al
aparecer, la salud del jugador al empezar la partida (la pone la raíz) y el
director al llegar el jefe. La ficha del enemigo enseña el daño que hace de
verdad, y el ranking y la pantalla final, la dificultad de cada partida.
Medido con el simulador (10 partidas cada una): fácil, 10 victorias; media, 1;
difícil, ninguna, y en la mitad no llega al jefe. Que la horda se quede es lo
que endurece la media: con la horda huyendo, como antes, el mismo bot gana 4.
Para medir esto el bot cambió: antes solo iba a por el jefe si no tenía a nadie
cerca, y con la horda presente no llegaba nunca; ahora va a por él
apartándose de lo que tiene encima. Con la fase 2 y el jefe final, el bot
(que ahora también recoge los fragmentos, rompe las anclas del escudo y sale
del torbellino) gana 5 de 10 en fácil y ninguna en media ni en difícil. El equilibrio de la fase 2
lo dejamos para el final, con el juego terminado.

**El mapa infinito.** El suelo es un rectángulo más grande que la pantalla que
se coloca bajo la cámara en cada fotograma, y su shader dibuja según la posición
en el mundo, no en el rectángulo: el dibujo se queda quieto y parece un suelo que
no se acaba. El suelo divide el mundo en casillas de 256 píxeles y cada una
elige uno de 12 dibujos de placa base que encajan entre sí. Dos texturas más
llevan datos en vez de dibujo, y con ellas el shader anima pulsos de luz por las
pistas, LEDs y ventiladores.

**Interfaz.** Un estilo común (`EstiloInterfaz`) para que todas las pantallas
se vean iguales. La **ficha del enemigo** pasa el click de la pantalla al mundo
y pregunta a todos los objetivos cuál está debajo; para seguir a un enemigo de
la horda, que cambia de posición en la lista cuando muere otro, cada uno lleva
un número único. La barra de experiencia se llena con un `Tween` y destella al
subir de nivel; como al subir de nivel el juego ya está en pausa, sus `Tween`
siguen corriendo en pausa (`TWEEN_PAUSE_PROCESS`).

**Guardado y actualizaciones.** `GestorGuardado` guarda en un fichero de texto
de Godot (`ConfigFile`) los récords, el ranking de las 10 mejores partidas y
las opciones. Al arrancar y después cada 5 minutos, el `Actualizador` pregunta
a GitHub si hay una versión nueva; si la hay, sale un aviso en cualquier
pantalla, también en plena partida. El botón ACTUALIZAR descarga solo el
contenido del juego (1 MB en lugar de 110) y lo carga al arrancar, antes que
nada. Si una versión necesitara un ejecutable nuevo (por ejemplo, por un
autoload más), el mismo botón descarga el juego completo, pone el ejecutable
nuevo en lugar del viejo y reinicia (`instalador_juego.gd`). Ese código va con
el contenido y no en el `Actualizador`, porque el `Actualizador` ya está en
marcha antes de cargar ninguna actualización: así funciona también en
ejecutables antiguos.
Con el botón VERSIONES del menú, el mismo instalador pone cualquier release,
también una anterior, para jugar versiones viejas. Tiene una biblioteca
(`user://versiones/<versión>/`): INSTALAR solo descarga ahí el ejecutable de
esa versión, sin cambiar de versión, y CAMBIAR es lo único que lo pone en el
sitio del que está en marcha y reinicia; el de antes se guarda también, para
volver sin descargar. Todas las versiones comparten esa carpeta, así que lo
instalado desde una sale como instalado en las demás. Las v0.2 a v1.0 se
volvieron a publicar con esta ventana (`herramientas/recompilar_version.sh`,
que solo cambia esos dos scripts y el botón del menú). Las teclas nuevas (Q, E y R)
están en `project.godot`, que no viaja con la actualización pequeña: si a un
ejecutable antiguo le faltan, `teclas_antiguas.gd` las añade al empezar la
partida. Con el icono pasa lo mismo: Godot lo pone en la ventana al arrancar,
leyéndolo de `project.godot`, así que `Transicion` lo vuelve a poner al
empezar (en Windows, el `.ico`, que trae los tamaños pequeños dibujados a
mano). El icono del `.exe` en el explorador solo cambia con un ejecutable
nuevo.

**Audio.** Todos los sonidos los genera un script que suma ondas simples, como
los chips de sonido antiguos: 17 efectos y 3 músicas. `GestorAudio` escucha el
bus y decide qué suena.

## 4. Problemas y cómo los resolvimos

**Golpes que no hacían daño.** La rejilla se reconstruía antes de quitar a los
muertos; al quitar uno, el último cambiaba de posición en la lista y la rejilla
seguía apuntando a la antigua, así que ese enemigo no recibía daño durante un
fotograma. No daba ningún error. Lo encontramos con una prueba que, la primera
vez, tampoco lo detectaba porque miraba un fotograma tarde; aprendimos a
comprobar que una prueba falla cuando debe fallar.

**Un juego imposible, tres veces.** El simulador mostró que el bot moría antes
del minuto (se arregló con regeneración de vida), que con el mapa infinito no
encontraba al jefe y, en la última sesión, que con todos los cambios que
pedimos tras jugarlo no ganaba ninguna partida. Esa vez probamos nueve
variantes y la clave era la vida extra por nivel: con un 4 % en lugar de un 8 %
y algo más de daño, gana 6 de cada 10.

**Números que llegaban mal a los shaders.** En este proyecto, `0.05` escrito en
un shader llega como `0.5`. Lo comprobamos con un shader que pinta valores
conocidos; esos números se escriben como divisiones (`1.0 / 20.0`).

**La horda se veía más oscura de lo que era.** Al probar el parpadeo rojo del
troyano salía marrón. Dibujando el mismo sprite de tres formas y comparando
píxel a píxel vimos que nuestro shader aplicaba la textura dos veces. Después
de arreglarlo, la horda se ve con sus colores reales.

**Sin tarjeta gráfica en el instituto.** La máquina virtual dibujaba con el
procesador. Activamos la aceleración 3D, elegimos el renderizador
Compatibility, que funciona casi en cualquier ordenador, y medimos el
rendimiento en un PC con una tarjeta de verdad.

## 5. Pruebas y rendimiento

- **Ejecución sin ventana** tras cada cambio, para ver errores de código y de
  ejecución.
- **Scripts de prueba** que provocan una situación y comprueban el resultado:
  la embestida del troyano fotograma a fotograma, las mejoras eligiéndolas de
  verdad, el ranking con una copia del fichero de guardado, clicks de ratón
  simulados para la ficha del enemigo...
- **Capturas con ventana** para todo lo visual, como las de la
  [historia](historia_del_proyecto.md).
- **Simulador de partidas** (`simular_partidas.gd`): un bot juega partidas
  enteras con la misma "suerte" cada vez, así que un cambio de equilibrio se
  compara antes y después. En media, con la fase 2 y el jefe final, hoy no
  gana ninguna de 10: el equilibrio lo dejamos para el final.
- **Medida de rendimiento** (`medir_rendimiento.gd`) en una RTX 5070, el
  16/10/2026; en la fase 2, con el suelo dañado y el jefe final atacando al
  lado del jugador:

| Enemigos | FPS | FPS en la fase 2 | Tiempo de física por paso |
|---|---|---|---|
| 300 | 931 | 835 | 2,4 ms |
| 600 | 595 | 545 | 4,9 ms |
| 1200 | 218 | 202 | 10 ms |

El objetivo de la propuesta era 300 enemigos a 60 FPS. El coste de la física
crece casi en línea recta con el número de enemigos gracias a la rejilla. La
horda animada no cuesta nada (la v1.0, sin ella, da lo mismo) y la fase 2,
alrededor de un 10 %.

## 6. Herramientas, assets e inteligencia artificial

- **Godot 4.7.2**, **Git y GitHub**, y una **GitHub Action** que exporta y
  publica cada versión al subir una etiqueta.
- **Gráficos hechos con IA** a partir de nuestras ideas (Claude, y Gemini para
  la idea de los personajes); ocho iconos los dibuja un script. El
  detalle está en [créditos](creditos.md).
- **Audio** generado por un script. No hay ningún asset de terceros.
- **Claude** (Anthropic) escribió la mayor parte del código a partir de lo que
  le pedíamos y con nuestras normas (castellano, scripts cortos, comentarios
  del porqué, la versión más fácil de explicar). Las ideas, las decisiones y
  las pruebas de juego son nuestras. Está contado en la
  [historia](historia_del_proyecto.md#cómo-hemos-usado-la-inteligencia-artificial).

## 7. Qué mejoraríamos con más tiempo

- Pixel art propio para los personajes y el jefe.
- Más variedad de élites.
- Que la resistencia del malware se vea directamente en el HUD.
- Controles configurables y un ranking compartido en línea.
