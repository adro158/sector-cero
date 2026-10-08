extends Node2D

## Las ultis de los personajes, con R. Cada personaje carga la suya matando
## mientras juega (una carga por personaje) y, llena, la lanza:
## - "rayo" (Mago): un rayo morado enorme hacia el enemigo más cercano.
## - "giro" (Espadachín): gira con sus hojas y golpea todo alrededor.
## - "tormenta" (Segador): un rayo sobre la guadaña y luego mini rayos alrededor.
##
## Pegan con danar_en_area, como las armas, a todo el grupo objetivos. No
## cuentan para la resistencia del malware: no son una herramienta. Escalan con
## las mejoras de daño. Los efectos se dibujan con _draw, sin sprites.

const CARGA_NECESARIA := 180.0
## Un élite carga como diez enemigos de la horda.
const CARGA_ELITE := 10.0

const RAYO_LARGO := 900.0
const RAYO_RADIO := 34.0
const RAYO_DANO := 160.0
const RAYO_GOLPES := [0.0, 0.15, 0.3]
const GIRO_DURACION := 1.5
const GIRO_RADIO := 170.0
const GIRO_DANO := 50.0
const GIRO_CADA := 0.2
const TORMENTA_RADIO := 200.0
const TORMENTA_DANO := 250.0
const MINI_RAYOS := 10
const MINI_RADIO := 80.0
const MINI_DANO := 100.0
const MINI_ALCANCE := 320.0

var _cargas: Array[float] = []
var _efecto := ""
var _tiempo := 0.0
## Golpes del efecto en curso: [segundo, centro en el mundo, radio, daño].
var _golpes: Array = []
var _direccion := Vector2.RIGHT
var _origen := Vector2.ZERO
## Dónde caen los mini rayos de la tormenta, para dibujarlos (los golpes se
## van quitando de _golpes al aplicarse).
var _mini: Array[Vector2] = []
var _equipo: Node
var _armas: Node


func _ready() -> void:
	_equipo = get_parent().get_node("CambioPersonaje")
	_armas = get_parent().get_node("GestorArmas")
	for personaje in _equipo.personajes:
		_cargas.append(0.0)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	_avisar.call_deferred()


func lista() -> bool:
	return _cargas[_equipo.indice_actual()] >= CARGA_NECESARIA


## Para el menú de desarrollador.
func llenar_todas() -> void:
	for i in _cargas.size():
		_cargas[i] = CARGA_NECESARIA
	_avisar()


func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo == "jefe" or _efecto != "":
		return
	var i: int = _equipo.indice_actual()
	_cargas[i] = minf(_cargas[i] + (CARGA_ELITE if tipo == "elite" else 1.0), CARGA_NECESARIA)
	_avisar()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ulti"):
		lanzar()


func lanzar() -> void:
	if not lista() or _efecto != "":
		return
	var personaje: DatosPersonaje = _equipo.personaje_actual()
	_cargas[_equipo.indice_actual()] = 0.0
	_efecto = personaje.ulti
	_tiempo = 0.0
	_origen = global_position
	_golpes.clear()
	_mini.clear()
	var dano: float = _armas.multiplicador_dano
	match _efecto:
		"rayo":
			_direccion = _hacia_el_mas_cercano()
			# El rayo es una fila de círculos seguidos, sin solaparse: así cada
			# enemigo del camino recibe un golpe por pasada.
			for segundo in RAYO_GOLPES:
				for paso in range(0, int(RAYO_LARGO), int(RAYO_RADIO * 2.0)):
					_golpes.append([segundo, _origen + _direccion * paso, RAYO_RADIO, RAYO_DANO * dano])
		"giro":
			var segundo := 0.0
			while segundo < GIRO_DURACION:
				_golpes.append([segundo, Vector2.INF, GIRO_RADIO, GIRO_DANO * dano])
				segundo += GIRO_CADA
		"tormenta":
			_golpes.append([0.0, _origen, TORMENTA_RADIO, TORMENTA_DANO * dano])
			for i in MINI_RAYOS:
				var donde := _origen + Vector2.from_angle(randf() * TAU) * randf_range(60.0, MINI_ALCANCE)
				_mini.append(donde)
				_golpes.append([0.3 + i * 0.08, donde, MINI_RADIO, MINI_DANO * dano])
	BusEventos.ulti_lanzada.emit(personaje)
	_avisar()


func _physics_process(delta: float) -> void:
	if _efecto == "":
		return
	_tiempo += delta
	# Los golpes cuyo segundo ya ha llegado se aplican y se quitan de la lista.
	# Vector2.INF es "donde esté el jugador ahora" (el giro le sigue).
	while not _golpes.is_empty() and _golpes[0][0] <= _tiempo:
		var golpe: Array = _golpes.pop_front()
		var centro: Vector2 = global_position if golpe[1] == Vector2.INF else golpe[1]
		for objetivo in get_tree().get_nodes_in_group("objetivos"):
			objetivo.danar_en_area(centro, golpe[2], golpe[3])
	if _tiempo >= _duracion():
		_efecto = ""
	queue_redraw()


func _duracion() -> float:
	match _efecto:
		"rayo":
			return 0.6
		"giro":
			return GIRO_DURACION
	return 0.3 + MINI_RAYOS * 0.08 + 0.3


func _hacia_el_mas_cercano() -> Vector2:
	var mejor := Vector2.INF
	for objetivo in get_tree().get_nodes_in_group("objetivos"):
		var punto: Vector2 = objetivo.mas_cercano(global_position, RAYO_LARGO)
		if punto != Vector2.INF and (mejor == Vector2.INF or global_position.distance_to(punto) < global_position.distance_to(mejor)):
			mejor = punto
	return Vector2.RIGHT if mejor == Vector2.INF else (mejor - global_position).normalized()


func _avisar() -> void:
	var fracciones := _cargas.map(func(carga): return carga / CARGA_NECESARIA)
	BusEventos.ulti_cambiada.emit(fracciones, _equipo.indice_actual())


# --- Dibujo ---


func _draw() -> void:
	match _efecto:
		"rayo":
			var desvanecer := 1.0 - _tiempo / 0.6
			var desde := to_local(_origen)
			var hasta := desde + _direccion * RAYO_LARGO
			draw_line(desde, hasta, Color(0.6, 0.2, 1.0, 0.5 * desvanecer), RAYO_RADIO * 2.4)
			draw_line(desde, hasta, Color(0.85, 0.5, 1.0, desvanecer), RAYO_RADIO * 1.2)
			draw_line(desde, hasta, Color(1.0, 1.0, 1.0, desvanecer), RAYO_RADIO * 0.4)
		"giro":
			# Seis hojas de luz girando, dos vueltas y media en todo el giro.
			for i in 6:
				var angulo := TAU * i / 6.0 + _tiempo * TAU * 1.7
				var punta := Vector2.from_angle(angulo) * GIRO_RADIO
				var lado := Vector2.from_angle(angulo + PI / 2.0) * 14.0
				draw_colored_polygon(PackedVector2Array([punta * 0.35, punta * 0.7 + lado, punta, punta * 0.7 - lado]), Color(0.4, 1.0, 0.5, 0.85))
			draw_arc(Vector2.ZERO, GIRO_RADIO, 0.0, TAU, 48, Color(0.4, 1.0, 0.5, 0.35), 3.0)
		"tormenta":
			if _tiempo < 0.35:
				_rayo(to_local(_origen), 22.0, 1.0 - _tiempo / 0.35)
				draw_circle(to_local(_origen), TORMENTA_RADIO * _tiempo / 0.35, Color(1.0, 0.6, 0.2, 0.25))
			for i in MINI_RAYOS:
				var cae := 0.3 + i * 0.08
				if _tiempo >= cae and _tiempo < cae + 0.25:
					_rayo(to_local(_mini[i]), 8.0, 1.0 - (_tiempo - cae) / 0.25)


## Un rayo en zigzag que baja del cielo hasta el punto.
func _rayo(abajo: Vector2, grosor: float, opacidad: float) -> void:
	var puntos := PackedVector2Array()
	var arriba := abajo + Vector2(0.0, -520.0)
	for tramo in 9:
		var punto := arriba.lerp(abajo, tramo / 8.0)
		if tramo > 0 and tramo < 8:
			punto.x += sin(tramo * 12.9 + abajo.x) * 22.0
		puntos.append(punto)
	draw_polyline(puntos, Color(1.0, 0.65, 0.2, opacidad * 0.6), grosor * 2.0)
	draw_polyline(puntos, Color(1.0, 1.0, 0.85, opacidad), grosor * 0.6)
