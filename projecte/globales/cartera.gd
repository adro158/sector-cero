extends Node

## La cartera del jugador (de Alan, 19/11; documentacio/plan_tienda.md): los
## bits, las misiones diarias y semanales, el pase de batalla, los logros y lo
## conseguido (skins y otros premios). Se guarda en su propio fichero,
## user://cartera.cfg, y no en el de las opciones (sector_cero.cfg, de Adam).
##
## Al acabar cada partida (partida_terminada) cuenta lo ganado: los bits de la
## partida, la racha, el avance de las misiones y lo demás de cada fase. Con
## el menú F1 (trucos) no se gana nada. Lo contado durante la partida lo lleva
## su hijo contador_partida.gd; las misiones, misiones.gd.
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

const Misiones := preload("res://globales/misiones.gd")
const ContadorPartida := preload("res://globales/contador_partida.gd")
const PaseBatalla := preload("res://globales/pase_batalla.gd")
const Logros := preload("res://globales/logros.gd")
const Premios := preload("res://globales/premios.gd")
const Recompensa := preload("res://globales/recompensa.gd")
## Si el pase da una skin que ya se tenía (comprada), se devuelve en bits.
const BITS_POR_REPETIDA := 300
const RUTA := "user://cartera.cfg"
## Si cambia lo que se guarda, sube y _leer convierte lo viejo.
const FORMATO := 1

static var actual: Node

## Para las pruebas: el día que se toma como hoy ("2026-11-19"); vacío, el del
## ordenador.
var fecha_de_prueba := ""

var _fichero := ConfigFile.new()
var _contador: Node
var _ultima := {}


func _ready() -> void:
	actual = self
	# La primera vez el fichero no existe y load da un error: no pasa nada,
	# todo empieza a cero hasta que se guarde algo.
	_fichero.load(RUTA)
	_contador = ContadorPartida.new()
	add_child(_contador)
	BusEventos.partida_terminada.connect(_al_terminar_partida)


func bits() -> int:
	return _fichero.get_value("cartera", "bits", 0)


## Si este jugador tiene esa skin (1 es la original, que se tiene siempre).
## Hasta la tienda (fase 4) se tienen todas: el armario las deja todas.
func tiene_skin(_personaje: String, _numero: int) -> bool:
	return true


## Si la ha conseguido de verdad (del pase, la tienda o un paquete).
func tiene_skin_de_verdad(personaje: String, numero: int) -> bool:
	return numero == 1 or numero in _fichero.get_value("skins", "tengo", {}).get(personaje, [])


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
## Devuelve si se ha podido.
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


## Lo ganado en la última partida, para la pantalla final (la lee en su
## _mostrar, ya diferido): {bits, puntos, racha, misiones, niveles, premios,
## sin_recompensa}.
func ultima_ganancia() -> Dictionary:
	return _ultima if not _ultima.is_empty() else _ganancia_vacia()


## Los bits y los puntos del pase de una partida (recompensa.gd), sin estado.
static func recompensa(estadisticas: Dictionary) -> Dictionary:
	return Recompensa.de_partida(estadisticas)


func hoy() -> String:
	return fecha_de_prueba if fecha_de_prueba != "" else Time.get_date_string_from_system()


func _al_terminar_partida(estadisticas: Dictionary) -> void:
	_ultima = _ganancia_vacia()
	# Con el menú de desarrollador se puede hacer cualquier cosa: no cuenta.
	if estadisticas.get("trucos", false):
		_ultima.sin_recompensa = true
		return
	var ganado := recompensa(estadisticas)
	_ultima.bits = ganado.bits
	_ultima.puntos = ganado.puntos
	_ultima.racha = Recompensa.contar_racha(_fichero, hoy())
	_ultima.bits += _ultima.racha
	var partida: Dictionary = _contador.resumen(estadisticas)
	Misiones.renovar(_fichero, hoy())
	for mision in Misiones.contar(_fichero, partida):
		_ultima.bits += mision.bits
		_ultima.puntos += mision.puntos
		_ultima.misiones.append(mision)
		mision_completada.emit(mision)
	_sumar_bits(_ultima.bits)
	# El pase: cada nivel nuevo da su premio solo.
	for nivel in PaseBatalla.sumar(_fichero, _ultima.puntos):
		_ultima.niveles.append(nivel)
		_dar(PaseBatalla.premio(nivel))
	var estado := pase()
	pase_cambiado.emit(estado.nivel, estado.en_el_nivel, estado.necesarios)
	for logro in Logros.contar(_fichero, partida, racha(), Premios.skins_conseguidas(_fichero)):
		_ultima.premios.append({"nombre": "Logro: %s" % logro.texto})
		_dar({"tipo": "titulo", "id": logro.titulo})
	_guardar()


## Da un premio del pase o de un logro y lo apunta para la pantalla final.
## Una skin que ya se tenía (comprada antes) se devuelve en bits.
func _dar(premio: Dictionary) -> void:
	if premio.tipo == "skin" and tiene_skin_de_verdad(premio.personaje, premio.numero):
		premio = {"tipo": "bits", "cantidad": BITS_POR_REPETIDA}
	if premio.tipo == "bits":
		_sumar_bits(premio.cantidad)
	else:
		Premios.dar(_fichero, premio)
	var conseguido := premio.duplicate()
	conseguido.nombre = Premios.nombre(premio)
	_ultima.premios.append(conseguido)
	premio_conseguido.emit(conseguido)


## Los días seguidos jugando (0 si se ha roto).
func racha() -> int:
	return Recompensa.racha(_fichero, hoy())


func _sumar_bits(cantidad: int) -> void:
	if cantidad == 0:
		return
	_fichero.set_value("cartera", "bits", bits() + cantidad)
	bits_cambiados.emit(bits())


func _guardar() -> void:
	_fichero.set_value("formato", "version", FORMATO)
	_fichero.save(RUTA)


static func _ganancia_vacia() -> Dictionary:
	return {"bits": 0, "puntos": 0, "racha": 0, "misiones": [], "niveles": [], "premios": [], "sin_recompensa": false}
