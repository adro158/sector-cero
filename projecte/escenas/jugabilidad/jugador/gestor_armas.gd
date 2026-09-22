extends Node

@export var armas: Array[DatosArma] = []

var _tiempos := PackedFloat32Array()
var _jugador: Node2D
var _gestor_enemigos: GestorEnemigos


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_gestor_enemigos = get_tree().get_first_node_in_group("gestor_enemigos")
	_tiempos.resize(armas.size())


func _physics_process(delta: float) -> void:
	for i in armas.size():
		_tiempos[i] -= delta
		if _tiempos[i] > 0.0:
			continue

		_tiempos[i] = armas[i].cadencia
		_atacar(armas[i])


func _atacar(arma: DatosArma) -> void:
	_gestor_enemigos.danar_en_area(_jugador.global_position, arma.radio, arma.dano)
