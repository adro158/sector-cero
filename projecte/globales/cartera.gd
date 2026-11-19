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
const RUTA := "user://cartera.cfg"
## Si cambia lo que se guarda, sube y _leer convierte lo viejo.
const FORMATO := 1
## La racha: bits por cada día seguido jugado, hasta un tope (decisión de
## Alan, 19/11: sin perder nada si se falla un día, la racha solo empieza otra vez).
const RACHA_POR_DIA := 10
const RACHA_MAXIMA := 50

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


## Cómo va el pase: {nivel, puntos, necesarios, maximo}. Fase 3.
func pase() -> Dictionary:
	return {"nivel": 0, "puntos": 0, "necesarios": 0, "maximo": 0}


## Los logros: [{id, texto, titulo, progreso, objetivo, hecho}]. Fase 3.
func logros() -> Array:
	return []


## Lo ganado en la última partida, para la pantalla final (la lee en su
## _mostrar, ya diferido): {bits, puntos, racha, misiones, niveles, premios,
## sin_recompensa}.
func ultima_ganancia() -> Dictionary:
	return _ultima if not _ultima.is_empty() else _ganancia_vacia()


## Los bits y los puntos del pase de una partida, sin estado: así se prueba
## sin nodo y el simulador la usa para calibrar los números (plan_tienda.md).
static func recompensa(estadisticas: Dictionary) -> Dictionary:
	if estadisticas.get("trucos", false):
		return {"bits": 0, "puntos": 0}
	var tiempo: float = estadisticas.get("tiempo", 0.0)
	var victoria: bool = estadisticas.get("victoria", false)
	var minutos := int(tiempo / 60.0)
	var bits := 2.0 * minutos
	# Llegar a la fase 2 (derrotar a Kernel Panic) y ganar dan un poco más.
	if tiempo > 600.0 or victoria:
		bits += 10.0
	if victoria:
		bits += 25.0
	bits *= {"facil": 0.75, "dificil": 1.5}.get(estadisticas.get("dificultad", "media"), 1.0)
	var puntos := 10 * minutos
	# En red los puntos del pase valen el doble (decisión de Alan, 19/11).
	if estadisticas.get("en_red", false):
		puntos *= 2
	return {"bits": roundi(bits), "puntos": puntos}


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
	_ultima.racha = _contar_racha()
	_ultima.bits += _ultima.racha
	Misiones.renovar(_fichero, hoy())
	for mision in Misiones.contar(_fichero, _contador.resumen(estadisticas)):
		_ultima.bits += mision.bits
		_ultima.puntos += mision.puntos
		_ultima.misiones.append(mision)
		mision_completada.emit(mision)
	_sumar_bits(_ultima.bits)
	_guardar()


## Los días seguidos jugando (0 si se ha roto: el último no es hoy ni ayer).
func racha() -> int:
	var ultimo: String = _fichero.get_value("racha", "ultimo_dia", "")
	return _fichero.get_value("racha", "dias", 0) if ultimo == hoy() or ultimo == Misiones.ayer_de(hoy()) else 0


## Unos bits más por la primera partida de cada día, según los días seguidos.
func _contar_racha() -> int:
	var ultimo: String = _fichero.get_value("racha", "ultimo_dia", "")
	if ultimo == hoy():
		return 0
	var dias: int = _fichero.get_value("racha", "dias", 0) + 1 if ultimo == Misiones.ayer_de(hoy()) else 1
	_fichero.set_value("racha", "ultimo_dia", hoy())
	_fichero.set_value("racha", "dias", dias)
	return mini(RACHA_POR_DIA * dias, RACHA_MAXIMA)


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
