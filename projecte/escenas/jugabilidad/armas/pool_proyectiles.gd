extends Node2D

const MAXIMO_PROYECTILES := 200

## Tras impactar no puede volver a golpear durante este rato. Sin esto seguiría
## dentro del mismo enemigo al fotograma siguiente y lo golpearía sin parar en
## lugar de saltar al siguiente.
const ESPERA_TRAS_IMPACTO := 0.08

## Destello morado donde impacta o rebota: 4 fotogramas de 24x24.
const IMPACTO := preload("res://medios/sprites/herramientas/ping_impacto.png")
const LADO_IMPACTO := 24.0
const FOTOGRAMAS_IMPACTO := 4
const SEGUNDOS_POR_FOTOGRAMA_IMPACTO := 0.05

const TiraFotogramas := preload("res://escenas/jugabilidad/efectos/tira_fotogramas.gd")
## Los proyectiles, apuntando a la derecha (se giran hacia donde van): 4
## fotogramas que se repiten. El Ping de inundación (la evolución) tiene el suyo,
## más grande, y va en su propio MultiMesh: cada MultiMesh tiene una textura.
const PING := preload("res://medios/sprites/herramientas/proyectil_ping_anim.png")
const PING_INUNDACION := preload("res://medios/sprites/herramientas/proyectil_ping_inundacion.png")
const INUNDACION := preload("res://recursos/armas/datos/ping_inundacion.tres")
const FOTOGRAMAS := 4
const SEGUNDOS_POR_FOTOGRAMA := 0.06

@export var radio_busqueda_rebote: float = 320.0

var _posiciones := PackedVector2Array()
var _direcciones := PackedVector2Array()
var _velocidades := PackedFloat32Array()
var _danos := PackedFloat32Array()
var _radios := PackedFloat32Array()
var _rebotes := PackedInt32Array()
var _vidas := PackedFloat32Array()
var _esperas := PackedFloat32Array()
# Qué arma lanzó cada proyectil, para aplicar y registrar su resistencia.
var _armas: Array[DatosArma] = []
var _activos := 0
var _objetivos: Array = []
var _resistencia_malware: Node
## Cada destello: [posición, segundos desde el impacto].
var _impactos: Array = []
## Los fotogramas de cada sprite, cortados al empezar, y los segundos que lleva
## la animación.
var _fotogramas: Array[Texture2D] = []
var _fotogramas_inundacion: Array[Texture2D] = []
var _tiempo := 0.0

@onready var _malla: MultiMeshInstance2D = $Proyectiles
@onready var _malla_inundacion: MultiMeshInstance2D = $ProyectilesInundacion


func _ready() -> void:
	_posiciones.resize(MAXIMO_PROYECTILES)
	_direcciones.resize(MAXIMO_PROYECTILES)
	_velocidades.resize(MAXIMO_PROYECTILES)
	_danos.resize(MAXIMO_PROYECTILES)
	_radios.resize(MAXIMO_PROYECTILES)
	_rebotes.resize(MAXIMO_PROYECTILES)
	_vidas.resize(MAXIMO_PROYECTILES)
	_esperas.resize(MAXIMO_PROYECTILES)
	_armas.resize(MAXIMO_PROYECTILES)

	# La horda y el jefe: todo lo que tiene danar_en_area y mas_cercano.
	_objetivos = get_tree().get_nodes_in_group("objetivos")

	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")

	_fotogramas = TiraFotogramas.cortar(PING, FOTOGRAMAS)
	_fotogramas_inundacion = TiraFotogramas.cortar(PING_INUNDACION, FOTOGRAMAS)
	_preparar_multimesh(_malla, _fotogramas[0])
	_preparar_multimesh(_malla_inundacion, _fotogramas_inundacion[0])


func _preparar_multimesh(malla: MultiMeshInstance2D, textura: Texture2D) -> void:
	var quad := QuadMesh.new()
	quad.size = textura.get_size()

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = quad
	multimesh.instance_count = MAXIMO_PROYECTILES
	multimesh.visible_instance_count = 0

	malla.multimesh = multimesh
	malla.texture = textura
	malla.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


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
	_armas[_activos] = arma
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
	var arma := _armas[indice]
	var resistencia: float = _resistencia_malware.resistencia(arma)
	var dano := _danos[indice] * (1.0 - resistencia)
	var alcanzados := 0

	for objetivo in _objetivos:
		alcanzados += objetivo.danar_en_area(_posiciones[indice], _radios[indice], dano, resistencia)

	if alcanzados == 0:
		return false

	_impactos.append([_posiciones[indice], 0.0])
	_resistencia_malware.registrar_dano(arma, alcanzados * dano)

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

	for objetivo in _objetivos:
		var candidato: Vector2 = objetivo.mas_cercano(desde, radio)
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
	_armas[indice] = _armas[_activos]


func _volcar_al_multimesh() -> void:
	var normales := _malla.multimesh
	var inundacion := _malla_inundacion.multimesh
	var cuantos_normales := 0
	var cuantos_inundacion := 0

	# Girado hacia donde va; al rebotar cambia la dirección y el giro la sigue.
	# Escala vertical -1: el QuadMesh tiene la textura invertida respecto al 2D.
	# Cada uno, en el MultiMesh de su sprite.
	for i in _activos:
		var transformada := Transform2D(_direcciones[i].angle(), Vector2(1.0, -1.0), 0.0, _posiciones[i])
		if _armas[i] == INUNDACION:
			inundacion.set_instance_transform_2d(cuantos_inundacion, transformada)
			cuantos_inundacion += 1
		else:
			normales.set_instance_transform_2d(cuantos_normales, transformada)
			cuantos_normales += 1

	normales.visible_instance_count = cuantos_normales
	inundacion.visible_instance_count = cuantos_inundacion


## Con el juego en pausa no se llama: los proyectiles y los destellos se
## quedan quietos.
func _process(delta: float) -> void:
	# Todos los proyectiles van en el mismo fotograma: se cambia la textura.
	_tiempo += delta
	var fotograma := int(_tiempo / SEGUNDOS_POR_FOTOGRAMA) % FOTOGRAMAS
	_malla.texture = _fotogramas[fotograma]
	_malla_inundacion.texture = _fotogramas_inundacion[fotograma]

	if _impactos.is_empty():
		return
	for impacto in _impactos:
		impacto[1] += delta
	var dura := FOTOGRAMAS_IMPACTO * SEGUNDOS_POR_FOTOGRAMA_IMPACTO
	_impactos = _impactos.filter(func(impacto): return impacto[1] < dura)
	queue_redraw()


func _draw() -> void:
	var lado := Vector2(LADO_IMPACTO, LADO_IMPACTO)
	for impacto in _impactos:
		var fotograma := int(impacto[1] / SEGUNDOS_POR_FOTOGRAMA_IMPACTO)
		draw_texture_rect_region(IMPACTO, Rect2(impacto[0] - lado / 2.0, lado), Rect2(Vector2(fotograma * LADO_IMPACTO, 0.0), lado))
