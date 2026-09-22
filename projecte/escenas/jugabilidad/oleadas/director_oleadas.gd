extends Node

@export var config: DatosConfigOleada

var _tiempo := 0.0
var _tiempo_restante := 0.0
var _jugador: Node2D
var _gestores: Array[GestorEnemigos] = []


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")

	for nodo in get_tree().get_nodes_in_group("gestor_enemigos"):
		_gestores.append(nodo)


func _physics_process(delta: float) -> void:
	_tiempo += delta
	_tiempo_restante -= delta

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


func _posicion_fuera_de_pantalla() -> Vector2:
	var angulo := randf() * TAU
	return _jugador.global_position + Vector2.RIGHT.rotated(angulo) * config.distancia_aparicion
