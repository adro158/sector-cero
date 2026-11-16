# Plan del multijugador (cooperativo en red local)

Decidido por Adam el 06/11/2026 (bitácora,
`bitacora/2026-11-06_adam_plan-online.md`). Este fichero es el **contrato**:
lo que hay que decidir antes de programar, cómo se habla entre la red y el
juego y quién hace qué. Se fusiona antes que el código (PR pequeño, como pide
`flujo_de_trabajo.md`). Si algo de aquí cambia, se cambia aquí primero.

## Lo que ha decidido Adam

- **Red local, con código de sala.** El que crea la partida ve un código
  corto y los demás lo escriben para unirse. Nadie escribe una IP.
- **De 2 a 3 jugadores, cada uno con un personaje distinto.** Al entrar en
  la sala cada uno elige el suyo.
  - Con 3 jugadores, cada uno el suyo y no se cambia.
  - Con 2, el tercer personaje queda **libre**: cualquiera de los dos puede
    cambiar a él (E/Q, con la espera de siempre), y el suyo se queda libre.
  - **Si cae el personaje de un jugador y queda uno libre y vivo, pasa a
    ese.** Así, con dos jugadores, el que cae sigue jugando con el tercero.
- **Experiencia común, cada uno elige su mejora.** Al subir de nivel el juego
  se pausa para todos; cada uno elige en su pantalla y sigue cuando han
  elegido todos. Cada mejora es del personaje que la elige (la vida, el
  daño...); las evoluciones, del que lleva esa herramienta.
- **Si un jugador se queda sin personaje, mira la partida** (la cámara sigue
  a otro) y vuelve con media vida al empezar la fase 2, como los caídos de
  ahora. Se pierde si caen todos.

## Confirmado por Adam (13/11, ventana de preguntas)

- **La pausa:** en red no se pausa. Esc abre el menú sin parar el juego;
  solo el anfitrión puede acabar la partida para todos.
- **La dificultad:** la horda y los jefes con más vida según los jugadores
  (por ejemplo ×1,6 con dos y ×2,2 con tres), medido con el simulador.
- **El ranking y las cuentas:** las partidas en red no entran en el ranking
  de una persona; como mucho, más adelante, una lista aparte.
- **Desconexiones:** si se va un cliente, su personaje queda libre; si se va
  el anfitrión, se acaba la partida para todos con un aviso.

## Propuestas, a confirmar

- **El F1:** desactivado en red.
- **La ulti:** cada jugador carga y lanza la de su personaje.
- **La web:** sin red (ENet no funciona en el navegador): el botón no sale.

## Cómo funciona

- **Un ordenador hace de anfitrión** y lleva toda la partida: la horda, los
  jefes, el daño, la experiencia y el azar. Así las partidas no se
  desincronizan y el simulador sigue sirviendo.
- **Los otros mandan lo que pulsan** (dirección, ulti, cambiar, la mejora
  elegida) y **reciben lo que hay que dibujar**: posiciones de los
  jugadores, de la horda, de los fragmentos y de los proyectiles, y los
  sucesos del bus (muertes, daños, avisos). En los clientes, los gestores no
  simulan: solo dibujan lo que llega.
- **La conexión:** `ENetMultiplayerPeer` de Godot, por un puerto fijo (por
  ejemplo 7777, UDP).
- **El código de sala** (propuesta, lo decide Alan al probarlo): seis letras
  que llevan dentro la IP del anfitrión en la red local (la parte que cambia,
  por ejemplo `192.168.1.37` → `7HQ2KD`). El que lo escribe saca la IP y se
  conecta. Ventaja: no hace falta que la red deje anunciar partidas
  (*broadcast*), que en el instituto puede estar cortado. Alternativa: el
  anfitrión anuncia su código por *broadcast* UDP y el cliente lo busca.
- **El nodo de red** (`globales/red.gd`) lo crea `Transicion` al arrancar,
  como `cuenta.gd` y `entrada.gd`: sin autoload nuevo, así no se toca
  `project.godot` ni hay que subir `EJECUTABLE_MINIMO`. Sin `class_name`.
- **Todos con la misma versión:** al unirse, se comprueba `Version.ACTUAL` y
  se rechaza con un aviso si no coincide.

## El contrato entre la red y el juego

La red (Alan) no sabe nada de la partida y el juego (Adam) no sabe nada de
ENet. Se hablan por el bus y por estas funciones de `red.gd`:

```gdscript
# Estado de la red, para el juego y la interfaz
func es_anfitrion() -> bool
func en_red() -> bool                 # false en una partida de un jugador
func mi_id() -> int
func jugadores() -> Array             # [{id, nombre, personaje}]

# Del juego a la red
func enviar_entrada(entrada: Dictionary)   # cliente → anfitrión, cada fotograma
func enviar_estado(estado: Dictionary)     # anfitrión → clientes, 20 veces/s
func enviar_suceso(suceso: String, datos: Array)  # anfitrión → clientes
```

Señales nuevas del bus, **añadidas el 13/11** en `globales/bus_eventos.gd`
(PR pequeño `adam/contrato-red`) y apuntadas en `equipo/contexto.md`. Un
jugador es `{id, nombre, personaje}`: `id` el de la red (1 es el
anfitrión) y `personaje` su índice en el equipo (0, 1 o 2):

```gdscript
signal sala_cambiada(jugadores: Array)          # alguien entra, sale o elige personaje
signal partida_en_red_empieza(jugadores: Array) # el anfitrión pulsa EMPEZAR
signal entrada_recibida(id: int, entrada: Dictionary)  # en el anfitrión
signal estado_recibido(estado: Dictionary)      # en los clientes
signal suceso_recibido(suceso: String, datos: Array)   # en los clientes
signal jugador_desconectado(id: int)
```

## El reparto

### La red (`globales/red.gd`, `escenas/red/`): de Alan; desde el 13/11, de Adam

Adam decidió el 13/11 hacerla él, con su Claude, para acabar el online
(`equipo/reparto.md`). Alan hizo el punto 1 (`alan/red`, 09/11).

**Hecho el 13/11 (rama `adam/red`, con el commit de Alan dentro):**
- `globales/red.gd` (lo crea `Transicion`, como `cuenta.gd`): crear la
  sala, unirse con el código, la lista de jugadores `{id, nombre,
  personaje}` con el primer personaje libre, elegir otro libre, la versión
  (si no coincide, «La sala es de la versión...»), la sala llena (3), EMPEZAR
  (solo el anfitrión), `enviar_entrada`/`enviar_estado` (sin garantía de
  llegada, el siguiente trae lo de ahora) y `enviar_suceso` (con garantía),
  y las desconexiones. Mensajes `[tipo, datos]` con `var_to_bytes` y
  `send_bytes`, como la prueba de Alan. Avisa por el bus (las señales del
  contrato) y los errores, con su señal `error_de_red`.
- `globales/codigo_sala.gd`: el código, 7 letras con la IP dentro (base 32,
  sin 0, O, 1 ni I), enseñado como `52C-J2B7`.
- `escenas/red/sala_red.gd` y el botón EN RED del menú (no en la web): el
  nombre, CREAR SALA, el código con UNIRSE, y en la sala el código, los
  jugadores con su personaje, elegir personaje, EMPEZAR y SALIR DE LA SALA.
  Hasta el punto 5, EMPEZAR solo avisa de que la partida en red no está
  lista.
- Probado con dos y cuatro copias del juego en el mismo ordenador
  (`127.0.0.1`): la sala, los personajes, las entradas, el estado, los
  sucesos, la salida de un cliente, la sala llena; y con ventana, las dos
  pantallas de la sala. **Falta que Alan (o Adam) lo pruebe entre dos
  ordenadores de verdad.**

1. **Probar que conecta**, lo primero: dos ordenadores del instituto en la
   misma red con un script mínimo de ENet. Si la red de clase lo bloquea, se
   sabe ya (y se prueba en casa o con el móvil como punto de acceso).
2. `red.gd`: crear la sala (anfitrión), unirse con el código, la lista de
   jugadores, comprobar la versión, desconexiones.
3. El código de sala: de la IP al código y del código a la IP.
4. La sala (`escenas/red/`): desde el menú, JUGAR EN RED → CREAR SALA (el
   código grande, los jugadores y su personaje, EMPEZAR solo el anfitrión) o
   UNIRSE (escribir el código). Con el estilo de la interfaz
   (`EstiloInterfaz`); el botón del menú lo pone Adam (es su menú).
5. Mandar y recibir: `enviar_entrada`, `enviar_estado` y `enviar_suceso` con
   sus señales. Probarlo con dos ventanas en el mismo ordenador.

### Adam: el juego con varios jugadores (`adam/varios-jugadores`)

1. Varios jugadores en la partida: uno por jugador en el grupo `jugador`, y
   todo lo que hoy busca «el» jugador (la horda, los élites, los jefes, la
   jaula, los fragmentos, la cámara) busca al más cercano o al local.
   **Empezado el 13/11** (`escenas/jugabilidad/jugadores.gd`, con
   `posiciones`, `mas_cercana` y `mas_cercano`): ya lo hacen la horda (cada
   enemigo va al más cercano y golpea a cualquiera que toque), las oleadas
   (salen alrededor de cada jugador por turnos, sin gastar azar), los
   fragmentos, el corazón y el cofre de los élites, el hielo, los élites
   (persiguen al más cercano; el golpe, el aura y la explosión, a todos),
   Kernel Panic (persigue y apunta al más cercano; el golpe, la jaula, la
   ráfaga y la sacudida, a todos) y NÚCLEO CERO (lo mismo; el rayo pega una
   vez a cada uno y el escudo quita la espera de cambiar a todos). El nombre
   tapado de los élites usa el primer jugador del grupo, que en red será el
   local. Con un jugador, el simulador da lo mismo que antes (también una
   partida entera: derrota en 1142 s con 5743 eliminados). Probado con un
   segundo jugador quieto a 600 px: sin errores y la horda se reparte entre
   los dos. **Falta:** las partículas, la cámara (con dos, Godot avisa de
   que hay dos `Camera2D`), y lo de los puntos 2 a 4: al caer el segundo
   jugador, la partida se para en «elige quién sigue» porque todo lo del
   equipo (`cambio_personaje.gd`, `raiz_juego.gd`, `sistema_niveles.gd`)
   sigue pensando en uno.
2. Los personajes repartidos: quién lleva cuál, el libre, cambiar a él y
   pasar a él al caer (`cambio_personaje.gd` y la barra del equipo).
   **Hecho el 13/11, menos la barra del equipo:** el equipo es uno por
   partida (`jugador/equipo.gd`, lo crea el primer jugador y se guarda en la
   raíz con `set_meta`, sin tocar la escena): los personajes, su herramienta,
   su vida, los caídos y quién lleva a cada uno. `cambio_personaje.gd` es lo
   de cada jugador: empieza con el primero libre, solo cambia a uno libre y,
   con varios jugadores, si cae el suyo pasa sin pausa al libre que quede o
   se queda sin personaje (sale del grupo `jugador`, la horda deja de verle).
   Las mejoras del equipo (vida máxima, evoluciones) llegan a quien lleve a
   cada uno. Con un jugador, igual que antes (el simulador da lo mismo).
   Probado con dos: el 2 empieza con el Mago, al caer pasa al Segador libre,
   al caer este se queda sin personaje y la partida acaba al caer el
   Espadachín del 1. **Falta:** la barra del equipo y quién elige al entrar
   (la sala de Alan dirá qué personaje lleva cada uno; ahora, el primero
   libre).
3. La experiencia común y las mejoras por jugador, con la pausa hasta que
   elijan todos.
   **Hecho el 13/11 en `sistema_niveles.gd`:** al subir de nivel cada
   jugador tiene su propio sorteo (`opciones_de(jugador)`, para mandárselo
   por la red) y la partida sigue en pausa hasta que han elegido todos. El
   de este ordenador elige con el panel, como siempre
   (`mejora_seleccionada`); los demás, con `elegir(jugador, mejora)`, que es
   lo que llamará la red al recibir su elección (punto 5). Las mejoras del
   arma, la velocidad y la espera de cambio son del que las elige; la vida
   máxima, las evoluciones, la adaptación y el imán, del equipo. Una
   evolución solo le sale al que lleva esa herramienta (si está en el
   banquillo, al primero), para que no la elijan dos. Quien se queda sin
   personaje ya no elige. El premio del cofre, de momento, para el de este
   ordenador (en red, para quien lo recoja). Con un jugador, el mismo sorteo
   y lo mismo que antes. Probado con dos: la partida espera al segundo y su
   Heurística agresiva le sube su daño (×1,12) y no el del primero.
   **Falta:** que el panel diga «esperando a los demás» mientras eligen.
4. El espectador y la vuelta en la fase 2.
   **Hecho el 13/11 en `cambio_personaje.gd`:** sin personaje, el jugador
   sale del grupo `jugador` (la horda y los jefes dejan de verle), no se
   mueve, no dispara, no lanza la ulti, no se ve y va donde el jugador más
   cercano, así que su cámara le sigue. Al revivir los caídos (al empezar la
   fase 2, y con el F1) cada espectador vuelve con un personaje libre, con
   su vida a medias y protegido un momento (`equipo.gd` guarda todos los
   jugadores en `miembros`). Con un jugador nunca hay espectadores: el
   simulador da lo mismo. Probado con dos: el 2 se queda mirando encima del
   1, vuelve con el Mago a media vida y después le pasa lo mismo al 1.
5. El anfitrión manda el estado (cada gestor da sus posiciones) y los
   clientes lo dibujan sin simular.
   **En tres tandas.** La primera, hecha el 13/11 (`escenas/red/partida_red.gd`,
   que añade `raiz_juego.gd` solo en red): EMPEZAR lleva a todos a la
   partida; el jugador de la escena es el de este ordenador y los demás se
   crean sin cámara ni teclado (`por_red` en el controlador), cada uno con
   su personaje de la sala (`tomar()`), y no chocan entre ellos. En el
   anfitrión se mueven, cambian y lanzan la ulti con `entrada_recibida`; los
   clientes mandan lo que pulsan cada fotograma. La interfaz enseña solo lo
   del de este ordenador (`equipo.local`, `es_local()`). Si se va un
   cliente, su jugador se queda mirando y su personaje queda libre; si se va
   el anfitrión, todos vuelven al menú. Probado con dos copias: el jugador
   del cliente se mueve en el anfitrión con lo que pulsa en el suyo.
   **La segunda, hecha el 13/11** (`escenas/red/estado_red.gd`): el
   anfitrión manda cada 3 pasos de física (20 veces por segundo) los
   jugadores (posición, velocidad, personaje y vida), la horda de cada tipo,
   los fragmentos, el reloj, la experiencia y las vidas del equipo; los
   clientes no simulan (las oleadas paradas, `solo_dibujar` en los gestores
   y en los fragmentos) y lo dibujan. Las mejoras: el anfitrión manda a
   cada uno sus opciones (por su ruta, un recurso no viaja), el cliente
   elige con su panel y la elegida vuelve con garantía de llegada
   (`enviar_entrada(..., true)`); el anfitrión sigue cuando han elegido
   todos. Probado con dos copias: el reloj, el nivel y la horda iguales, y
   la Memoria redundante del cliente sube la vida de los dos.
   **La tercera, empezada el 16/11:** en red no se pausa (`raiz_juego.gd`:
   el menú sale y la partida sigue); el final de la partida para todos (el
   anfitrión manda «fin» con las estadísticas, los personajes por su ruta, y
   cada cliente enseña su pantalla final con el juego en pausa); las
   partidas en red llevan `en_red` y no van al ranking, a los récords ni a
   la cuenta; en red no hay REINTENTAR; el que se queda sin personaje
   también se ve mirando en su pantalla (`seguir_red`); salir de la partida
   es salir de la red, y si la partida ya ha acabado, cada uno sale de su
   pantalla final cuando quiere. Probado con dos copias: la pausa no para
   nada, el del cliente cae dos veces y se queda mirando también en el
   cliente, y el final le llega sin tocar sus récords.
   Los élites, también el 16/11: el anfitrión los manda en el estado (clave
   `l`, en el orden del grupo `elites`: posición, vida, máxima y sus
   afijos por la ruta) y en los clientes no persiguen ni reciben golpes
   (`solo_dibujar`): aparecen con su aviso, destellan al perder vida y al
   morir se parten o estallan como en el anfitrión, sin soltar nada ni
   hacer daño (eso es de la partida del anfitrión). Probado con dos copias:
   misma vida y sitio en los dos, y el explosivo estalla en el cliente.
   Kernel Panic, también el 16/11: el anfitrión lo manda en el estado
   (clave `k`: posición, vida, máxima, estado, hacia dónde mira y furia) y
   en los clientes no persigue, no ataca ni recibe golpes; aparece con su
   aviso, pone sus poses, se enfurece a la vez y, al morir, el cliente
   también pasa a la fase 2 (el negro, la arena y la música). Su muerte no
   da experiencia ni carga las ultis en los clientes: eso llega del
   anfitrión. Probado con dos copias: misma vida, furia 1 y 2 y la fase 2
   en los dos.
   NÚCLEO CERO, también el 16/11: el anfitrión lo manda en el estado
   (clave `n`: posición, vida, máxima, estado y forma) y en los clientes no
   se mueve, no ataca ni recibe golpes; aparece con su aviso, se transforma,
   se queda aturdido y muere como en el anfitrión. Al acabar de morir en un
   cliente no avisa de la victoria: el final llega del anfitrión («fin»), y
   si no saldrían dos. Probado con dos copias: la forma 1 a la vez y una
   sola victoria en el cliente.
   Los ataques de los jefes, también el 16/11: la jaula y la ráfaga de
   Kernel Panic, los cinco ataques de NÚCLEO CERO (con sus portales), su
   escudo con las anclas y las zonas de hielo van en el estado (clave `a`,
   con los dos jefes: la lista `RAIZ` de `estado_red.gd`, cada nodo con su
   `datos_red()` y su `poner_desde_red()`). En los clientes no hacen daño,
   no sacan horda ni encierran a nadie, pero se ven y suenan, y el HUD dice
   qué anclas quedan. Probado con dos copias: la ráfaga, el pisotón,
   invocar, la tormenta, el escudo, las anclas rotas y la rotura, a la vez.
   Las anclas, arregladas el 16/11: miraban el personaje del anfitrión
   (`equipo_cambiado` lleva el del jugador local), así que el de otro
   ordenador solo rompía las del personaje que llevara el anfitrión. Ahora
   cada golpe dice qué jugador lo da (`danar_en_area(..., quien)`, desde las
   armas, el Ping y las ultis) y el ancla mira el personaje que lleva él en
   ese momento, la regla de siempre. De paso, `gestor_armas.gd` cogía «el
   primer jugador del grupo»: las armas de los demás salían del jugador
   local y su robo de vida le curaba a él. Ahora es su padre. Probado con
   dos copias (cada ancla acepta solo al suyo, y el Segador del cliente
   rompe la suya solo) y el simulador da lo mismo, también la partida
   entera.
   Las mejoras con el anfitrión mirando, arregladas el 16/11: la red
   mandaba las opciones a los demás al oír `jugador_subio_nivel`, que solo
   salta si el de este ordenador elige; con el anfitrión sin personaje no
   llegaban y la partida se quedaba en pausa. Ahora escucha
   `opciones_sorteadas`, una señal del sistema de niveles (no del bus) que
   salta siempre. Probado con dos copias: el anfitrión cae dos veces, se
   queda mirando, sube del nivel 1 al 5 y el cliente elige sus cuatro
   mejoras sin que la partida se quede en pausa.
   **Falta:** los efectos y los números de daño en los clientes, y la
   ruleta del cofre y la animación de la caída en los clientes (el premio
   del cofre lo elige siempre el anfitrión, lo recoja quien lo recoja).
6. La interfaz: el botón JUGAR EN RED del menú, el HUD de cada jugador y la
   pantalla final.
7. La dificultad con varios jugadores, medida con el simulador.
   **Puesto el 13/11, sin medir:** `jugadores.gd`, `vida_por_jugadores()`,
   ×1,6 con dos y ×2,2 con tres (lo confirmó Adam), sobre la vida de la
   horda, los élites, Kernel Panic, NÚCLEO CERO y sus anclas. Cuenta a todos
   los que empezaron (grupo `en_partida`, que pone `cambio_personaje.gd`),
   también a los que miran: si no, al caer uno los enemigos nuevos saldrían
   más flojos. Con uno, ×1 y el simulador da lo mismo. Probado con dos: un
   bit corrupto nuevo sale con 32 de vida en vez de 20. **Falta medirlo:**
   que el simulador juegue con varios bots y ajustar los números.

### Juntos

- **PR de integración:** cuando las dos ramas estén, se juntan y se prueba
  jugando entre dos y tres ordenadores.
- Cada uno revisa el PR del otro (`/code-review`).

## Orden

1. Este plan (PR `adam/plan-online`), revisado por los dos.
2. A la vez: Alan con los puntos 1 a 3 de la red; Adam con los puntos 1 a 4
   del juego, probando con varios jugadores en el mismo ordenador (sin red).
3. Alan, puntos 4 y 5; Adam, puntos 5 a 7.
4. Integración y prueba jugando.

## Riesgos

- **Es lo más grande que queda:** toca casi todos los sistemas. Lo primero
  sigue siendo que el juego de un jugador funcione igual (el simulador da lo
  mismo que antes en cada PR).
- **La red del instituto** puede bloquear las conexiones entre ordenadores:
  por eso es lo primero que se prueba.
- **El rendimiento:** mandar la horda entera 20 veces por segundo; con 500
  enemigos son unos 4 KB por envío, de sobra en una red local.
- **El tiempo:** el vídeo y la defensa van al final, con el juego acabado
  (decisión del 05/11). Si no da tiempo, el online se enseña como «lo que
  viene» y lo de un jugador no se ha tocado.
