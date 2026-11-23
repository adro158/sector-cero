# Plan de la cartera: bits, misiones, pase de batalla y tienda

El **contrato** del sistema de Alan (issue #16): qué se ha decidido, qué
guarda, cómo se usa desde fuera y en qué orden se hace. Se fusiona antes que
el código (PR pequeño, como pide `flujo_de_trabajo.md`). Si algo de aquí
cambia, se cambia aquí primero.

Decidido el 19/11/2026: el plan de la #16 (del Claude de Adam, 17/11), la
«idea nueva» de Adam en la misma issue (19/11, aprobada por él) y lo que
eligió Alan ese día (bitácora `2026-11-19_alan_cartera-contrato.md`).

## Las decisiones

**Las de antes** (las D de la #16 que siguen igual):
- **Dueño: Alan**, con ficheros nuevos suyos (D1). Lo que haya que tocar de
  Adam se le pide o se hace con su sí, como con las skins (#23).
- **Solo en local** (D3): `user://cartera.cfg`, para invitados y con cuenta.
  No en `sector_cero.cfg`, que es de Adam. Pasarlo a Supabase, al final y
  solo si sobra tiempo (y Adam quiere).
- **Sin antitrampas en local** (D16): el jugador es dueño de su ordenador;
  lo que tuviera valor de verdad se validaría en el servidor. Se dice así al
  tribunal. Lo mismo con las misiones y la hora del ordenador.
- **Con el menú F1 (`trucos`), nada** (D12): ni bits ni puntos ni misiones.
- **En red, sí** (D13): cada uno en su ordenador, con el `partida_terminada`
  que le llega.
- **Nada de dinero real.** La moneda solo se gana jugando.

**Las de Adam (19/11)**, que cambian D2, D10 y D11:
- **La moneda, «bits»** (D2): un chip de neón cian con una «b». Se gana un
  poco por partida y **sobre todo con las misiones**. El asset lo hace Claude
  en el chat (`lote_bits.zip`: icono de 16 y de 32, la moneda girando y un
  destello) y va en `medios/sprites/bits/`.
- **Misiones diarias y semanales** (nuevo): 3 diarias (de 50 a 100 bits y
  puntos del pase) y 3 semanales cada lunes (unos 300 bits y más puntos). Se
  sortean de una lista fija con la fecha como semilla: todos tienen las
  mismas el mismo día, sin servidor. Se cuentan escuchando el bus (sin tocar
  ficheros de Adam).
- **El pase** (D10, D11): sube con puntos (por minuto aguantado y, sobre
  todo, por misiones), **Temporada 1 sin fecha de caducidad**, unos **30
  niveles**, **un solo carril y gratis**, y los premios se dan solos al
  subir de nivel y se avisan en la pantalla final.
- **Qué skins van a cada sitio** (las categorías del lote):
  - **S y S+**: exclusivas del pase;
  - **C y B**: en la tienda, con bits;
  - **A**: en la tienda, más caras, o en los paquetes del gacha;
  - la **original**: gratis.

  Hasta que haya tienda (fase 4), el armario las sigue dejando todas.
- **Otros premios del pase:** títulos (bajo el nombre), marcos de la placa
  del nombre en red, estelas al moverse, iconos de perfil y paquetes
  cifrados (tiradas gratis del gacha).

**Las de Alan (19/11)**, de las ideas que se le dieron:
- **Misiones de personaje:** una de las semanales es de un personaje
  concreto («gana con el Segador», «elimina 2000 con el Mago») y da más
  puntos.
- **Cambiar 1 misión diaria al día**, gratis.
- **Doble en cooperativo:** los puntos del pase de una partida en red valen
  el doble (los bits, no).
- **Logros permanentes:** retos que no caducan («derrota a NÚCLEO CERO en
  difícil», «gana con los tres personajes»), cada uno con su título.
- **Colores de la interfaz y del CRT** como premio: el neón en ámbar, verde
  o rosa. Toca `EstiloInterfaz` y el filtro CRT, que son de Adam: se le
  pide.
- **Racha suave:** unos bits de más por jugar días seguidos (hasta un tope),
  sin perder nada si se falla un día: la racha solo vuelve a empezar.

**Los números**, para empezar (se ajustan al probar; los de cada partida se
calibran con el simulador):

| Qué | Cuánto |
|---|---|
| Bits por partida | 2 por minuto aguantado, +10 si llega a la fase 2, +25 si gana; ×0,75 en fácil, ×1,5 en difícil |
| Misión diaria | 50 a 100 bits y 60 puntos del pase |
| Misión semanal | unos 300 bits y 250 puntos; la de personaje, 350 puntos |
| Puntos del pase por partida | 10 por minuto aguantado; ×2 en red |
| Pase | 30 niveles de 300 puntos |
| Racha | +10 bits por día seguido jugado, hasta +50 |
| Cambio de misión | 1 al día, de una diaria sin completar |
| Tienda (fase 4) | C 300, B 600, A 1200 bits |

## Qué guarda: `user://cartera.cfg`

Un `ConfigFile` propio. Si un día cambia el formato, sube `[formato]
version` y se convierte al leerlo.

```ini
[formato]
version=1
[cartera]
bits=0
[skins]
tengo={}                ; personaje -> números de skin conseguidas: {"Mago": [3, 10]}
[misiones]
dia=""                  ; "2026-11-19": el día de las diarias de ahora
diarias=[]              ; ids de las 3 diarias
semana=""               ; "2026-11-16": el lunes de las semanales de ahora
semanales=[]            ; ids de las 3 semanales
progreso={}             ; id -> lo que lleva (de las de ahora)
hechas=[]               ; ids de las de ahora ya cobradas
cambio_usado=""         ; el día en que se usó el cambio de misión
[pase]
temporada=1
puntos=0                ; puntos totales de la temporada
nivel_dado=0            ; último nivel cuyo premio ya se ha dado
[logros]
hechos=[]               ; ids de los logros conseguidos
progreso={}             ; id -> lo que lleva (los que se suman entre partidas)
[racha]
ultimo_dia=""
dias=0
[premios]
titulos=[]              ; ids de títulos, marcos, estelas, iconos y temas conseguidos
marcos=[]
estelas=[]
iconos=[]
temas=[]
paquetes=0              ; tiradas gratis del gacha
```

Lo que se **lleva puesto** (el título, el marco, la estela, el icono y el
tema) va en las opciones de `GestorGuardado`, como la skin (`"skins"`): así
se sube a la cuenta y, en red, viaja con el jugador. Se añade en su fase.

## La cartera por dentro: `globales/cartera.gd`

Un `Node` sin `class_name`, con `static var actual` como `cuenta.gd` y
`red.gd`. **Lo crea `Transicion`** al arrancar (sin autoload ni cambios en
`project.godot`). Para no pasar de ~200 líneas, lo que no es estado ni
guardado va en scripts sin nodo cargados con `preload`:
`globales/misiones.gd` (la lista y el sorteo), `globales/pase_batalla.gd`
(la tabla de niveles y premios) y `globales/logros.gd`.

**Lo que usan los demás** (el contrato; el esqueleto de la fase 1 ya lo
tiene, devolviendo vacío o lo de siempre):

```gdscript
func bits() -> int
func tiene_skin(personaje: String, numero: int) -> bool   # hasta la fase 4, siempre true
func misiones() -> Array        # [{id, texto, tipo, progreso, objetivo, bits, puntos, hecha}]
func cambiar_mision(id: String) -> bool
func pase() -> Dictionary       # {nivel, puntos, necesarios, maximo}
func logros() -> Array          # [{id, texto, titulo, progreso, objetivo, hecho}]
func ultima_ganancia() -> Dictionary  # {bits, puntos, misiones, niveles, premios} de la última partida
static func recompensa(estadisticas: Dictionary) -> Dictionary  # {bits, puntos}, sin estado: el simulador la usa para calibrar
```

**Sus señales** (del nodo, no del bus: solo las escuchan las pantallas de
Alan; así no se toca `bus_eventos.gd`):

```gdscript
signal bits_cambiados(total: int)
signal mision_completada(mision: Dictionary)
signal pase_cambiado(nivel: int, puntos: int, necesarios: int)
signal premio_conseguido(premio: Dictionary)   # {tipo, id, nombre}
```

**Cómo cuenta** (fase 2): escucha del bus `partida_terminada` (tiempo,
victoria, eliminados, dificultad, personaje, `en_red`, `trucos`, `donde`) y,
durante la partida, `enemigo_muerto`, `cofre_recogido`, `ulti_lanzada`,
`arma_evolucionada`, `personaje_cambiado` y `jefe_aparecio`. Lo de la partida
se guarda todo junto al recibir `partida_terminada`. El azar de los sorteos,
con su propio `RandomNumberGenerator`, nunca con `randi()` (el simulador fija
la semilla global).

La **pantalla final** (de Adam) lee `Cartera.actual.ultima_ganancia()` desde
su `_mostrar`, ya diferido (como `GestorGuardado.records_batidos`): una señal
en `partida_terminada` llegaría antes de que existiera la ventana.

## Lo de Adam

- **Fase 1 (este PR, con su sí):** una línea en `globales/transicion.gd`
  (`add_child(Cartera.new())`, después de `Red`) y, en
  `herramientas/simular_partidas.gd`, apartar la cartera del bus como la
  cuenta, para que las partidas simuladas no den bits.
- **Fase 2:** en `pantalla_final.gd`, la línea de lo ganado
  (`ultima_ganancia()`).
- **Fase 5:** los títulos, los marcos y los iconos en la placa
  (`indicador_companeros_red.gd`), la sala y el ranking; las estelas en el
  jugador; los temas de color en `EstiloInterfaz` y el CRT. Cada uno, un
  `get` de su opción, como con las skins.

## Las fases (un PR cada una)

1. **El contrato** (este): `plan_tienda.md`, `reparto.md` y `contexto.md`,
   el esqueleto de `cartera.gd` y lo de Adam de arriba. El simulador, igual
   que siempre.
2. **Bits y misiones:** el sorteo diario y semanal (con la de personaje), el
   cambio de una al día, la racha, `recompensa()`, la pestaña **MISIONES**
   en la ventana SKINS, el aviso en la pantalla final y el asset de la
   moneda.
3. **El pase:** la tabla de 30 niveles, los puntos (×2 en red), los premios
   que se dan solos (bits, paquetes y las skins S y S+), la pestaña **PASE**
   y los **logros** con sus títulos.
4. **La tienda:** las skins C, B y A por bits, la pestaña **TIENDA** y
   `tiene_skin()` de verdad: desde aquí el armario solo deja poner las que
   se tienen.
5. **Los otros premios:** títulos, marcos, estelas, iconos, temas de color y
   paquetes del gacha. Los marcos y los iconos necesitan otro lote de arte.

En cada fase: `/validar` (el simulador igual que siempre y 16 clases), una
prueba en headless que copia y deja como estaba `user://cartera.cfg`, y
capturas con ventana de lo que se vea.

## Estado (19/11, al acabar las cinco fases)

Hechas las cinco, cada una en su rama y su PR, una encima de otra:
`alan/cartera-contrato` → `alan/cartera-misiones` → `alan/cartera-pase` →
`alan/cartera-tienda` → `alan/cartera-premios`. Se fusionan en ese orden.

**Los ficheros de Alan** (todos sin `class_name`):
- `globales/cartera.gd`: el estado, el guardado y lo que usan los demás.
- `globales/contador_partida.gd`: lo contado durante la partida (hijo de la
  cartera; empieza de cero al entrar una `RaizJuego`).
- `globales/misiones.gd`, `pase_batalla.gd`, `logros.gd`, `tienda.gd`,
  `premios.gd`, `recompensa.gd` y `cobro.gd`: sin nodo, cargados con
  `preload`. Repartidos así para que ninguno pase de ~200 líneas.
- `escenas/skins/`: la ventana SKINS con sus seis pestañas (ARMARIO, PERFIL,
  MISIONES, PASE, LOGROS y TIENDA), `resumen_cartera.gd` (lo ganado, en la
  pantalla final) y `estela.gd`.

**Lo hecho en ficheros de Adam** (con su sí, como en la #23; cada fase en su
commit aparte para revisarlo): `transicion.gd` (crea la cartera),
`simular_partidas.gd` (la aparta), `pantalla_final.gd` (lo ganado),
`gestor_guardado.gd` (la opción `"perfil"`), `cambio_personaje.gd` (la
estela), `red.gd` y `preparar_red.gd` (el perfil en la sala y solo las
skins que se tienen), `indicador_companeros_red.gd` (marco y título en la
placa), `sala_red.gd` (icono y título), `menu_principal.gd` (el título) y
`efecto_crt.gd` y `crt.gdshader` (el tinte del tema).

**Diferencias con lo planeado arriba, y por qué:**
- **Los iconos de perfil** son los retratos de las skins que se tienen (y
  los originales), no un premio del pase: así no hace falta otro lote de
  arte.
- **Los temas de color** tiñen el filtro CRT, no `EstiloInterfaz`, cuyos
  colores son constantes usadas en todo el juego: cambiarlos sería tocar
  toda la interfaz.
- **Los paquetes** también se pueden comprar (250 bits), además de los del
  pase, para que el gacha sirva antes del nivel 3.
- **El título no sale en el ranking**: habría que guardarlo con cada
  partida (el ranking es de Adam). Sale en la placa en red, en la sala y en
  el menú.
- **Una skin puesta que no se tiene** (de cuando todas eran gratis) sale como
  la original, y en red no se manda.
- **Modo demostración** para la defensa (D17): con `cartera=demo`, solo en
  depuración, otro fichero con 20 000 bits y el pase en el nivel 28.

**La moneda** (`lote_bits.zip`, 23/11, rama `alan/bits`, encima de
`alan/cartera-premios`): `escenas/skins/contador_bits.gd` (la moneda
girando y los bits, con el destello al subir) en la ventana SKINS y en el
menú, y los iconos en la pantalla final, las misiones, el pase y la tienda.
