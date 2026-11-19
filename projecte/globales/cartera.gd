extends Node

## La cartera del jugador (de Alan, 19/11; documentacio/plan_tienda.md): los
## bits, las misiones diarias y semanales, el pase de batalla, los logros, la
## tienda y lo conseguido (skins y otros premios). Se guarda en su propio
## fichero, user://cartera.cfg, y no en el de las opciones (de Adam).
##
## Al acabar cada partida (partida_terminada) cobra lo ganado (cobro.gd); con
## el menú F1 (trucos), nada. Lo contado durante la partida lo lleva su hijo
## contador_partida.gd. El resto, en scripts sin nodo: misiones.gd,
## pase_batalla.gd, logros.gd, tienda.gd, premios.gd y recompensa.gd.
##
## Lo crea Transicion al arrancar, como cuenta.gd y red.gd: sin autoload
## nuevo, sin tocar project.godot ni subir EJECUTABLE_MINIMO. Sin class_name.

## El total de bits ha cambiado (ganados, gastados o de un premio).
signal bits_cambiados(total: int)
## Una misión se ha completado y se ha cobrado: {id, texto, tipo, bits, puntos}.
signal mision_completada(mision: Dictionary)
## El pase ha cambiado de puntos o de nivel.
signal pase_cambiado(nivel: int, puntos: int, necesarios: int)
## Se ha conseguido algo: {tipo, ..., nombre}. tipo: "skin", "titulo",
## "marco", "estela", "tema", "paquete" o "bits".
signal premio_conseguido(premio: Dictionary)

const Misiones := preload("res://globales/misiones.gd")
const ContadorPartida := preload("res://globales/contador_partida.gd")
const PaseBatalla := preload("res://globales/pase_batalla.gd")
const Logros := preload("res://globales/logros.gd")
const Premios := preload("res://globales/premios.gd")
const Recompensa := preload("res://globales/recompensa.gd")
const Tienda := preload("res://globales/tienda.gd")
const Cobro := preload("res://globales/cobro.gd")
const RUTA := "user://cartera.cfg"
## Para enseñarlo en la defensa sin jugar 30 niveles (solo en depuración, con
## el argumento cartera=demo): otro fichero, con muchos bits y el pase avanzado.
const RUTA_DEMO := "user://cartera_demo.cfg"
## Si cambia lo que se guarda, sube y se convierte lo viejo al leerlo.
const FORMATO := 1

static var actual: Node

## Para las pruebas: el día que se toma como hoy ("2026-11-19"); vacío, el del
## ordenador.
var fecha_de_prueba := ""

var _ruta := RUTA
var _fichero := ConfigFile.new()
var _contador: Node
var _ultima := {}
## El azar de los paquetes: propio, nunca el global (lo fija el simulador).
var _azar := RandomNumberGenerator.new()


func _ready() -> void:
	actual = self
	_azar.randomize()
	if OS.is_debug_build() and "cartera=demo" in OS.get_cmdline_user_args():
		_ruta = RUTA_DEMO
	# La primera vez el fichero no existe y load da un error: no pasa nada,
	# todo empieza a cero hasta que se guarde algo.
	if _fichero.load(_ruta) != OK and _ruta == RUTA_DEMO:
		_fichero.set_value("cartera", "bits", 20000)
		_fichero.set_value("pase", "puntos", 8650)
	_contador = ContadorPartida.new()
	add_child(_contador)
	BusEventos.partida_terminada.connect(_al_terminar_partida)


func bits() -> int:
	return _fichero.get_value("cartera", "bits", 0)


## Si este jugador tiene esa skin: la original (1) siempre; las demás, si las
## ha conseguido (en el pase, la tienda o un paquete).
func tiene_skin(personaje: String, numero: int) -> bool:
	return numero == 1 or numero in _fichero.get_value("skins", "tengo", {}).get(personaje, [])


## Compra esa skin en la tienda. Devuelve si se ha podido (se vende, no la
## tiene y le llegan los bits).
func comprar(personaje: String, numero: int) -> bool:
	var precio := Tienda.precio(personaje, numero)
	if precio == 0 or precio > bits() or tiene_skin(personaje, numero):
		return false
	_sumar_bits(-precio)
	_conseguir_skin(personaje, numero)
	_guardar()
	return true


## Los paquetes cifrados gratis que se tienen (premios del pase).
func paquetes() -> int:
	return _fichero.get_value("premios", "paquetes", 0)


## Abre un paquete: uno gratis si hay; si no, se paga. Devuelve la skin que ha
## tocado, {personaje, numero, categoria, nombre, nueva, devueltos}, o {} si
## no hay paquete ni bits.
func abrir_paquete() -> Dictionary:
	if paquetes() > 0:
		_fichero.set_value("premios", "paquetes", paquetes() - 1)
	elif bits() >= Tienda.PRECIO_PAQUETE:
		_sumar_bits(-Tienda.PRECIO_PAQUETE)
	else:
		return {}
	var skin := Tienda.sortear(_azar)
	skin.nueva = not tiene_skin(skin.personaje, skin.numero)
	skin.devueltos = 0 if skin.nueva else Tienda.DEVUELTOS[skin.categoria]
	skin.nombre = Premios.nombre({"tipo": "skin", "personaje": skin.personaje, "numero": skin.numero})
	if skin.nueva:
		_conseguir_skin(skin.personaje, skin.numero)
	else:
		_sumar_bits(skin.devueltos)
	_guardar()
	return skin


## Las misiones de ahora (3 diarias y 3 semanales), renovadas si ha cambiado
## el día o la semana: [{id, texto, tipo, progreso, objetivo, bits, puntos, hecha}].
func misiones() -> Array:
	if Misiones.renovar(_fichero, hoy()):
		_guardar()
	return Misiones.lista(_fichero)


## Si hoy aún se puede cambiar una misión diaria.
func puede_cambiar() -> bool:
	return _fichero.get_value("misiones", "cambio_usado", "") != hoy()


## Cambia esa misión diaria (sin completar) por otra, una vez al día.
func cambiar_mision(id: String) -> bool:
	Misiones.renovar(_fichero, hoy())
	if not Misiones.cambiar(_fichero, id, hoy()):
		return false
	_guardar()
	return true


## Cómo va el pase: {nivel, puntos, en_el_nivel, necesarios, maximo}.
func pase() -> Dictionary:
	return PaseBatalla.estado(_fichero)


## Los logros: [{id, texto, titulo, progreso, objetivo, hecho}].
func logros() -> Array:
	return Logros.lista(_fichero)


## Los títulos, marcos, estelas o temas que se tienen (sus ids).
func conseguidos(tipo: String) -> Array:
	return Premios.conseguidos(_fichero, tipo)


## Los días seguidos jugando (0 si se ha roto).
func racha() -> int:
	return Recompensa.racha(_fichero, hoy())


## Lo ganado en la última partida, para la pantalla final (la lee en su
## _mostrar, ya diferido): {bits, puntos, racha, misiones, niveles, premios,
## sin_recompensa}.
func ultima_ganancia() -> Dictionary:
	return _ultima if not _ultima.is_empty() else Cobro.vacia()


## Los bits y los puntos del pase de una partida (recompensa.gd), sin estado.
static func recompensa(estadisticas: Dictionary) -> Dictionary:
	return Recompensa.de_partida(estadisticas)


func hoy() -> String:
	return fecha_de_prueba if fecha_de_prueba != "" else Time.get_date_string_from_system()


func _al_terminar_partida(estadisticas: Dictionary) -> void:
	_ultima = Cobro.cobrar(self, estadisticas, _contador.resumen(estadisticas))
	if not _ultima.sin_recompensa:
		_guardar()


func _conseguir_skin(personaje: String, numero: int) -> void:
	var premio := {"tipo": "skin", "personaje": personaje, "numero": numero}
	Premios.dar(_fichero, premio)
	premio.nombre = Premios.nombre(premio)
	premio_conseguido.emit(premio)


func _sumar_bits(cantidad: int) -> void:
	if cantidad == 0:
		return
	_fichero.set_value("cartera", "bits", bits() + cantidad)
	bits_cambiados.emit(bits())


func _guardar() -> void:
	_fichero.set_value("formato", "version", FORMATO)
	_fichero.save(_ruta)
