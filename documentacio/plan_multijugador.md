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

Señales nuevas del bus (se añaden en este PR de contrato o en el primero de
código, y se apuntan en `equipo/contexto.md`):

```gdscript
signal sala_cambiada(jugadores: Array)          # alguien entra, sale o elige personaje
signal partida_en_red_empieza(jugadores: Array) # el anfitrión pulsa EMPEZAR
signal entrada_recibida(id: int, entrada: Dictionary)  # en el anfitrión
signal estado_recibido(estado: Dictionary)      # en los clientes
signal suceso_recibido(suceso: String, datos: Array)   # en los clientes
signal jugador_desconectado(id: int)
```

## El reparto

### Alan: la red (`alan/red`, `globales/red.gd`, `escenas/red/`)

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
