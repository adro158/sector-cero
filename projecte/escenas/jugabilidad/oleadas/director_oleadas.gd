extends Node

@export var intervalo: float = 0.2
@export var distancia_aparicion: float = 700.0

var _jugador: Node2D
var _tiempo_restante := 0.0

@onready var _gestor_enemigos: GestorEnemigos = get_tree().get_first_node_in_group("gestor_enemigos")


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")


func _physics_process(delta: float) -> void:
	_tiempo_restante -= delta
	if _tiempo_restante > 0.0:
		return

	_tiempo_restante = intervalo
	_gestor_enemigos.aparecer(_posicion_fuera_de_pantalla())


func _posicion_fuera_de_pantalla() -> Vector2:
	var angulo := randf() * TAU
	return _jugador.global_position + Vector2.RIGHT.rotated(angulo) * distancia_aparicion
