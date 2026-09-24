extends Node2D

const MAXIMO_PROYECTILES := 200

## Tras impactar no puede volver a golpear durante este rato. Sin esto seguiría
## dentro del mismo enemigo al fotograma siguiente y lo golpearía sin parar en
## lugar de saltar al siguiente.
const ESPERA_TRAS_IMPACTO := 0.08

@export var tamano: float = 10.0
@export var radio_busqueda_rebote: float = 320.0

var _posiciones := PackedVector2Array()
var _direcciones := PackedVector2Array()
var _velocidades := PackedFloat32Array()
var _danos := PackedFloat32Array()
var _radios := PackedFloat32Array()
var _rebotes := PackedInt32Array()
var _vidas := PackedFloat32Array()
var _esperas := PackedFloat32Array()
var _activos := 0
var _gestores: Array[GestorEnemigos] = []

@onready var _malla: MultiMeshInstance2D = $Proyectiles


func _ready() -> void:
	_posiciones.resize(MAXIMO_PROYECTILES)
	_direcciones.resize(MAXIMO_PROYECTILES)
	_velocidades.resize(MAXIMO_PROYECTILES)
	_danos.resize(MAXIMO_PROYECTILES)
	_radios.resize(MAXIMO_PROYECTILES)
	_rebotes.resize(MAXIMO_PROYECTILES)
	_vidas.resize(MAXIMO_PROYECTILES)
	_esperas.resize(MAXIMO_PROYECTILES)

	for nodo in get_tree().get_nodes_in_group("gestor_enemigos"):
		_gestores.append(nodo)

	_preparar_multimesh()


func _preparar_multimesh() -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(tamano, tamano)

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = quad
	multimesh.instance_count = MAXIMO_PROYECTILES
	multimesh.visible_instance_count = 0

	_malla.multimesh = multimesh


func lanzar(origen: Vector2, arma: DatosArma, dano: float, radio: float) -> void:
	if _activos >= MAXIMO_PROYECTILES:
		return

	var objetivo := _buscar_objetivo(origen, radio_busqueda_rebote)
	var direccion := Vector2.RIGHT.rotated(randf() * TAU)
	if objetivo != Vector2.INF:
		direccion = (objetivo - origen).normalized()

	_posiciones[_activos] = origen
	_direcciones[_activos] = direccion
	_velocidades[_activos] = arma.velocidad_proyectil
	_danos[_activos] = dano
	_radios[_activos] = radio
	_rebotes[_activos] = arma.rebotes
	_vidas[_activos] = arma.vida_util
	_esperas[_activos] = 0.0
	_activos += 1


func _physics_process(delta: float) -> void:
	var i := _activos - 1

	while i >= 0:
		_vidas[i] -= delta
		_esperas[i] -= delta

		if _vidas[i] <= 0.0:
			_eliminar(i)
		else:
			_posiciones[i] += _direcciones[i] * _velocidades[i] * delta
			if _esperas[i] <= 0.0 and _impactar(i):
				_eliminar(i)

		i -= 1

	_volcar_al_multimesh()


## Devuelve true si el proyectil debe desaparecer.
func _impactar(indice: int) -> bool:
	var alcanzados := 0
	for gestor in _gestores:
		alcanzados += gestor.danar_en_area(_posiciones[indice], _radios[indice], _danos[indice])

	if alcanzados == 0:
		return false

	if _rebotes[indice] <= 0:
		return true

	var siguiente := _buscar_objetivo(_posiciones[indice], radio_busqueda_rebote)
	if siguiente == Vector2.INF:
		return true

	_direcciones[indice] = (siguiente - _posiciones[indice]).normalized()
	_rebotes[indice] -= 1
	_esperas[indice] = ESPERA_TRAS_IMPACTO
	return false


func _buscar_objetivo(desde: Vector2, radio: float) -> Vector2:
	var mejor := Vector2.INF
	var mejor_distancia := radio

	for gestor in _gestores:
		var candidato := gestor.mas_cercano(desde, radio)
		if candidato == Vector2.INF:
			continue

		var distancia := candidato.distance_to(desde)
		if distancia < mejor_distancia:
			mejor_distancia = distancia
			mejor = candidato

	return mejor


func _eliminar(indice: int) -> void:
	_activos -= 1
	_posiciones[indice] = _posiciones[_activos]
	_direcciones[indice] = _direcciones[_activos]
	_velocidades[indice] = _velocidades[_activos]
	_danos[indice] = _danos[_activos]
	_radios[indice] = _radios[_activos]
	_rebotes[indice] = _rebotes[_activos]
	_vidas[indice] = _vidas[_activos]
	_esperas[indice] = _esperas[_activos]


func _volcar_al_multimesh() -> void:
	var multimesh := _malla.multimesh

	for i in _activos:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, _posiciones[i]))

	multimesh.visible_instance_count = _activos
