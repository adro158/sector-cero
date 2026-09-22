class_name GestorEnemigos
extends Node2D

const MAXIMO_ENEMIGOS := 500

@export var velocidad: float = 90.0
@export var tamano: float = 24.0
@export var radio_separacion: float = 26.0
@export var fuerza_separacion: float = 1.8
@export var radio_contacto: float = 28.0
@export var dano_contacto: float = 8.0

var _posiciones := PackedVector2Array()
var _vivos := 0
var _jugador: Node2D
var _salud_jugador: Salud
var _rejilla: RejillaEspacial

@onready var _horda: MultiMeshInstance2D = $Horda


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_posiciones.resize(MAXIMO_ENEMIGOS)
	_rejilla = RejillaEspacial.new(radio_separacion)
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
	_reconstruir_rejilla()
	_mover(delta)
	_danar_jugador()
	_volcar_al_multimesh()


func _danar_jugador() -> void:
	var posicion_jugador := _jugador.global_position

	for i in _rejilla.indices_cerca(posicion_jugador):
		if _posiciones[i].distance_to(posicion_jugador) < radio_contacto:
			# Basta con el primero que toque: el golpe activa la invulnerabilidad
			# y los demás del montón no harían nada.
			_salud_jugador.recibir_dano(dano_contacto)
			return


func _reconstruir_rejilla() -> void:
	# Se reconstruye entera cada fotograma en vez de ir moviendo enemigos de
	# celda en celda: con todos en movimiento constante, rehacerla sale más
	# barato que detectar y aplicar los cambios uno a uno.
	_rejilla.limpiar()

	for i in _vivos:
		_rejilla.insertar(i, _posiciones[i])


func _mover(delta: float) -> void:
	var destino := _jugador.global_position

	for i in _vivos:
		var hacia_jugador := (destino - _posiciones[i]).normalized()
		var empuje := _separacion(i) * fuerza_separacion

		# El empuje se suma al avance en lugar de normalizarse junto a él: si se
		# normalizara, la separación solo podría girar la dirección y nunca
		# llegaría a vencer al impulso hacia el jugador, que es justo lo que
		# hace falta cuando dos enemigos están encima el uno del otro.
		_posiciones[i] += (hacia_jugador + empuje) * velocidad * delta


func _separacion(indice: int) -> Vector2:
	var empuje := Vector2.ZERO
	var posicion := _posiciones[indice]

	for otro in _rejilla.indices_cerca(posicion):
		if otro == indice:
			continue

		var diferencia := posicion - _posiciones[otro]
		var distancia := diferencia.length()

		if distancia > 0.0 and distancia < radio_separacion:
			# Cuanto más cerca está el vecino, más fuerte empuja.
			empuje += diferencia / distancia * (1.0 - distancia / radio_separacion)

	return empuje


func _volcar_al_multimesh() -> void:
	var multimesh := _horda.multimesh

	for i in _vivos:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, _posiciones[i]))

	multimesh.visible_instance_count = _vivos
