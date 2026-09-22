extends Node2D

const MAXIMO_GEMAS := 800

@export var tamano: float = 10.0
@export var experiencia: int = 1
@export var radio_iman: float = 100.0
@export var radio_recogida: float = 18.0
@export var velocidad_iman: float = 420.0

var _posiciones := PackedVector2Array()
var _vivas := 0
var _jugador: Node2D

@onready var _gemas: MultiMeshInstance2D = $Gemas


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_posiciones.resize(MAXIMO_GEMAS)
	_preparar_multimesh()
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


func _preparar_multimesh() -> void:
	var malla := QuadMesh.new()
	malla.size = Vector2(tamano, tamano)

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = malla
	multimesh.instance_count = MAXIMO_GEMAS
	multimesh.visible_instance_count = 0

	_gemas.multimesh = multimesh


func _al_morir_enemigo(posicion: Vector2, _tipo: String) -> void:
	if _vivas >= MAXIMO_GEMAS:
		return

	_posiciones[_vivas] = posicion
	_vivas += 1


func _physics_process(delta: float) -> void:
	var objetivo := _jugador.global_position

	# Hacia atrás porque al recoger una gema se trae la última a su hueco.
	var i := _vivas - 1

	while i >= 0:
		var distancia := _posiciones[i].distance_to(objetivo)

		if distancia < radio_recogida:
			BusEventos.experiencia_ganada.emit(experiencia)
			_eliminar(i)
		elif distancia < radio_iman:
			_posiciones[i] = _posiciones[i].move_toward(objetivo, velocidad_iman * delta)

		i -= 1

	_volcar_al_multimesh()


func _eliminar(indice: int) -> void:
	_vivas -= 1
	_posiciones[indice] = _posiciones[_vivas]


func _volcar_al_multimesh() -> void:
	var multimesh := _gemas.multimesh

	for i in _vivas:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, _posiciones[i]))

	multimesh.visible_instance_count = _vivas
