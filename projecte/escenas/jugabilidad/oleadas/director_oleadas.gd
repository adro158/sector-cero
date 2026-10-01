extends Node

## Se ha sobrevivido el tiempo que marca la configuración: llega el jefe, desde
## fuera de la pantalla como la horda.
signal llega_el_jefe(posicion: Vector2)

@export var config: DatosConfigOleada

var _tiempo := 0.0
var _tiempo_restante := 0.0
var _jefe_en_juego := false
var _siguiente_elite := 0.0
var _jugador: Node2D
var _gestores: Array[GestorEnemigos] = []
var _elites: Array[Node] = []


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_elites = get_tree().get_nodes_in_group("elites")
	_siguiente_elite = config.primer_elite

	for nodo in get_tree().get_nodes_in_group("gestor_enemigos"):
		_gestores.append(nodo)


## Segundos de partida jugados. Es el reloj de la partida: no avanza con el
## juego en pausa, porque el director tampoco se procesa.
func tiempo() -> float:
	return _tiempo


func _physics_process(delta: float) -> void:
	var segundo_anterior := int(_tiempo)
	_tiempo += delta
	_tiempo_restante -= delta

	# Una vez por segundo basta para un reloj en pantalla.
	if int(_tiempo) != segundo_anterior:
		BusEventos.tiempo_partida.emit(_tiempo, config.duracion_partida)

	# Con el jefe en juego ya no aparece más horda: el final es contra él.
	if _jefe_en_juego:
		return

	if _tiempo >= config.duracion_partida:
		_jefe_en_juego = true
		llega_el_jefe.emit(_posicion_fuera_de_pantalla())
		return

	if _tiempo >= _siguiente_elite:
		_siguiente_elite += config.intervalo_elites
		_aparecer_elite()

	if _tiempo_restante > 0.0:
		return

	_tiempo_restante = _intervalo_actual()

	var gestor := _elegir_tipo()
	if gestor != null:
		gestor.aparecer(_posicion_fuera_de_pantalla())


func _intervalo_actual() -> float:
	var progreso := clampf(_tiempo / config.tiempo_hasta_dificultad_maxima, 0.0, 1.0)
	return lerpf(config.intervalo_inicial, config.intervalo_final, progreso)


func _elegir_tipo() -> GestorEnemigos:
	# Cada tipo tiene su propio momento de entrada en la partida, así que la
	# variedad crece sola con el tiempo sin necesidad de guionizar oleadas.
	var disponibles: Array[GestorEnemigos] = []

	for gestor in _gestores:
		if gestor.tiempo_aparicion() <= _tiempo:
			disponibles.append(gestor)

	if disponibles.is_empty():
		return null

	return disponibles.pick_random()


## Activa el primer élite libre. Si están todos en juego, este turno se pierde:
## con tres a la vez ya hay presión de sobra.
func _aparecer_elite() -> void:
	for elite in _elites:
		if not elite.activo():
			elite.aparecer(_posicion_fuera_de_pantalla(), _sortear_afijos())
			return


func _sortear_afijos() -> Array[DatosAfijoElite]:
	var afijos := config.afijos_elite.duplicate()
	afijos.shuffle()
	var cantidad := 2 if _tiempo >= config.tiempo_dos_afijos else 1
	return afijos.slice(0, cantidad)


func _posicion_fuera_de_pantalla() -> Vector2:
	var angulo := randf() * TAU
	return _jugador.global_position + Vector2.RIGHT.rotated(angulo) * config.distancia_aparicion
