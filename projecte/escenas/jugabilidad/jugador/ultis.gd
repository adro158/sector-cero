extends Node2D

## Las ultis de los personajes, con R. Cada personaje carga la suya matando
## mientras juega (una carga por personaje) y, llena, la lanza:
## - "rayo" (Mago): un rayo morado enorme. Con el teclado, R pone a apuntar: el
##   rayo sigue al ratón y sale con el click (el derecho o otra R cancelan).
##   Con el mando, en el móvil y en el simulador, que no tienen ratón, va solo
##   hacia el enemigo más cercano.
## - "giro" (Espadachín): gira con sus hojas y golpea todo alrededor.
## - "tormenta" (Segador): un rayo sobre la guadaña y luego mini rayos alrededor.
##
## Pegan con danar_en_area, como las armas, a todo el grupo objetivos. No
## cuentan para la resistencia del malware: no son una herramienta. Escalan con
## las mejoras de daño. Los efectos los dibuja dibujo_ultis.gd con sprites; aquí
## solo se decide qué toca dibujar.

const DibujoUltis := preload("res://escenas/jugabilidad/jugador/dibujo_ultis.gd")

const CARGA_NECESARIA := 180.0
## Un élite carga como diez enemigos de la horda.
const CARGA_ELITE := 10.0

const RAYO_LARGO := 900.0
const RAYO_RADIO := 34.0
const RAYO_DANO := 160.0
const RAYO_GOLPES := [0.0, 0.15, 0.3]
const RAYO_DURACION := 0.6
## El dibujo del rayo sale del pecho del Mago y un poco por delante, para que el
## círculo del origen no le tape; los golpes salen de su centro (la diferencia
## es pequeña al lado del radio).
const RAYO_PECHO := Vector2(0.0, -22.0)
const RAYO_DELANTE := 40.0
const GIRO_DURACION := 1.5
const GIRO_RADIO := 170.0
const GIRO_DANO := 50.0
const GIRO_CADA := 0.2
const GIRO_VUELTAS := 1.7
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
## El Mago está apuntando el rayo con el ratón.
var _apuntando := false
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
	if not evento.is_action_pressed("ulti"):
		return
	if _apuntando:
		_dejar_de_apuntar()
	elif lista() and _equipo.personaje_actual().ulti == "rayo" and evento is InputEventKey:
		_apuntando = true
	else:
		lanzar()


## El click de apuntar va en _input, antes que la interfaz: si no, el click
## izquierdo abriría también la ficha del enemigo pinchado.
func _input(evento: InputEvent) -> void:
	if not _apuntando or not evento is InputEventMouseButton or not evento.pressed:
		return
	get_viewport().set_input_as_handled()
	if evento.button_index == MOUSE_BUTTON_LEFT:
		lanzar((get_global_mouse_position() - global_position).normalized())
	elif evento.button_index == MOUSE_BUTTON_RIGHT:
		_dejar_de_apuntar()


func _dejar_de_apuntar() -> void:
	_apuntando = false
	queue_redraw()


## Sin dirección (o con Vector2.ZERO), el rayo va al enemigo más cercano.
func lanzar(direccion := Vector2.ZERO) -> void:
	_apuntando = false
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
			_direccion = direccion if direccion != Vector2.ZERO else _hacia_el_mas_cercano()
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
	if _apuntando:
		# Si cambia de personaje mientras apunta, ya no es el Mago.
		if _equipo.personaje_actual().ulti != "rayo":
			_dejar_de_apuntar()
		queue_redraw()
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
			return RAYO_DURACION
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
	if _apuntando:
		var hacia := (get_global_mouse_position() - global_position).normalized()
		DibujoUltis.mira(self, RAYO_PECHO + hacia * RAYO_DELANTE, hacia, RAYO_LARGO - RAYO_DELANTE)
	match _efecto:
		"rayo":
			var desde := to_local(_origen) + RAYO_PECHO + _direccion * RAYO_DELANTE
			DibujoUltis.rayo(self, desde, _direccion, RAYO_LARGO - RAYO_DELANTE, _tiempo, RAYO_DURACION)
		"giro":
			DibujoUltis.torbellino(self, _tiempo, GIRO_DURACION, GIRO_VUELTAS)
		"tormenta":
			# Los puntos de los mini rayos, del mundo a las coordenadas de este nodo.
			var mini: Array[Vector2] = []
			for punto in _mini:
				mini.append(to_local(punto))
			DibujoUltis.tormenta(self, to_local(_origen), mini, _tiempo)

