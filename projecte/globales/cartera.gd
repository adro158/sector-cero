extends Node

## La cartera del jugador (de Alan, 19/11; documentacio/plan_tienda.md): los
## bits, las misiones diarias y semanales, el pase de batalla, los logros y lo
## conseguido (skins y otros premios). Se guarda en su propio fichero,
## user://cartera.cfg, y no en el de las opciones (sector_cero.cfg, de Adam).
##
## Fase 1, el contrato: aquí solo están las funciones y las señales que usan
## los demás, que devuelven vacío o lo de siempre. Las fases 2 a 5 las van
## llenando (plan_tienda.md, «Las fases»), sin cambiar cómo se llaman.
##
## Lo crea Transicion al arrancar, como cuenta.gd y red.gd: sin autoload
## nuevo, sin tocar project.godot ni subir EJECUTABLE_MINIMO. Sin class_name.

## El total de bits ha cambiado (ganados, gastados o de un premio).
signal bits_cambiados(total: int)
## Una misión se ha completado y se ha cobrado: {id, texto, tipo, bits, puntos}.
signal mision_completada(mision: Dictionary)
## El pase ha cambiado de puntos o de nivel.
signal pase_cambiado(nivel: int, puntos: int, necesarios: int)
## Se ha conseguido algo: {tipo, id, nombre}. tipo: "skin", "titulo",
## "marco", "estela", "icono", "tema" o "paquete".
signal premio_conseguido(premio: Dictionary)

const RUTA := "user://cartera.cfg"
## Si cambia lo que se guarda, sube y _leer convierte lo viejo.
const FORMATO := 1

static var actual: Node

var _fichero := ConfigFile.new()


func _ready() -> void:
	actual = self
	# La primera vez el fichero no existe y load da un error: no pasa nada,
	# todo empieza a cero hasta que se guarde algo.
	_fichero.load(RUTA)


func bits() -> int:
	return _fichero.get_value("cartera", "bits", 0)


## Si este jugador tiene esa skin (1 es la original, que se tiene siempre).
## Hasta la tienda (fase 4) se tienen todas: el armario las deja todas.
func tiene_skin(_personaje: String, _numero: int) -> bool:
	return true


## Las misiones de ahora (3 diarias y 3 semanales):
## [{id, texto, tipo, progreso, objetivo, bits, puntos, hecha}]. Fase 2.
func misiones() -> Array:
	return []


## Cambia esa misión diaria (sin completar) por otra, una vez al día.
## Devuelve si se ha podido. Fase 2.
func cambiar_mision(_id: String) -> bool:
	return false


## Cómo va el pase: {nivel, puntos, necesarios, maximo}. Fase 3.
func pase() -> Dictionary:
	return {"nivel": 0, "puntos": 0, "necesarios": 0, "maximo": 0}


## Los logros: [{id, texto, titulo, progreso, objetivo, hecho}]. Fase 3.
func logros() -> Array:
	return []


## Lo ganado en la última partida, para la pantalla final (la lee en su
## _mostrar, ya diferido): {bits, puntos, misiones, niveles, premios}. Fase 2.
func ultima_ganancia() -> Dictionary:
	return {"bits": 0, "puntos": 0, "misiones": [], "niveles": [], "premios": []}


## Al acabar una partida: cuenta lo ganado, las misiones y el pase, y lo
## guarda. En la fase 2 se conecta a BusEventos.partida_terminada en _ready;
## el simulador la desconecta (simular_partidas.gd, _apartar_cartera).
func _al_terminar_partida(_estadisticas: Dictionary) -> void:
	pass


## Los bits y los puntos del pase de una partida, sin estado: así se prueba
## sin nodo y el simulador la usa para calibrar los números. Fase 2.
static func recompensa(_estadisticas: Dictionary) -> Dictionary:
	return {"bits": 0, "puntos": 0}
