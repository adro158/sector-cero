class_name GestorEnemigos
extends Node2D

const MAXIMO_ENEMIGOS := 500

@export var velocidad: float = 90.0
@export var tamano: float = 24.0

var _posiciones := PackedVector2Array()
var _vivos := 0
var _jugador: Node2D

@onready var _horda: MultiMeshInstance2D = $Horda


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_posiciones.resize(MAXIMO_ENEMIGOS)
	_preparar_multimesh()


func _preparar_multimesh() -> void:
	var malla := QuadMesh.new()
	malla.size = Vector2(tamano, tamano)

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = malla
	multimesh.instance_count = MAXIMO_ENEMIGOS
	multimesh.visible_instance_count = 0

	_horda.multimesh = multimesh


func aparecer(posicion: Vector2) -> void:
	if _vivos >= MAXIMO_ENEMIGOS:
		return

	_posiciones[_vivos] = posicion
	_vivos += 1


func eliminar(indice: int) -> void:
	# El último vivo pasa a ocupar el hueco del que muere. Así los vivos siempre
	# son las primeras posiciones del array, sin huecos que haya que saltarse.
	_vivos -= 1
	_posiciones[indice] = _posiciones[_vivos]


func _physics_process(delta: float) -> void:
	var destino := _jugador.global_position

	for i in _vivos:
		var direccion := (destino - _posiciones[i]).normalized()
		_posiciones[i] += direccion * velocidad * delta

	_volcar_al_multimesh()


func _volcar_al_multimesh() -> void:
	var multimesh := _horda.multimesh

	for i in _vivos:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, _posiciones[i]))

	multimesh.visible_instance_count = _vivos
