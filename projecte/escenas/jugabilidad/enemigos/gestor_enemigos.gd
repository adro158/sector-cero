class_name GestorEnemigos
extends Node2D

## Señal local, no del BusEventos: se dispara decenas de veces por segundo y solo
## interesa dentro de la jugabilidad. El bus queda para lo que cruza la frontera
## con la interfaz.
signal enemigo_danado(posicion: Vector2, cantidad: float)

const MAXIMO_ENEMIGOS := 400

@export var datos: DatosTipoEnemigo
@export var radio_separacion: float = 26.0
@export var fuerza_separacion: float = 1.8

var _posiciones := PackedVector2Array()
var _vidas := PackedFloat32Array()
var _vivos := 0
var _jugador: Node2D
var _salud_jugador: Salud
var _rejilla: RejillaEspacial

@onready var _horda: MultiMeshInstance2D = $Horda


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_posiciones.resize(MAXIMO_ENEMIGOS)
	_vidas.resize(MAXIMO_ENEMIGOS)
	_rejilla = RejillaEspacial.new(radio_separacion)
	_preparar_multimesh()


func vivos() -> int:
	return _vivos


func tiempo_aparicion() -> float:
	return datos.tiempo_aparicion


func aparecer(posicion: Vector2) -> void:
	if _vivos >= MAXIMO_ENEMIGOS:
		return

	_posiciones[_vivos] = posicion
	_vidas[_vivos] = datos.vida
	_vivos += 1


## Devuelve a cuántos enemigos ha alcanzado, que es lo que necesitan los
## proyectiles para saber si han impactado.
func danar_en_area(centro: Vector2, radio: float, cantidad: float) -> int:
	var alcanzados := 0

	for i in _rejilla.indices_cerca(centro, radio):
		if _posiciones[i].distance_to(centro) < radio:
			_vidas[i] -= cantidad
			enemigo_danado.emit(_posiciones[i], cantidad)
			alcanzados += 1

	return alcanzados


## Posición del enemigo vivo más cercano dentro del radio, o Vector2.INF si no
## hay ninguno.
func mas_cercano(desde: Vector2, radio: float) -> Vector2:
	var mejor := Vector2.INF
	var mejor_distancia := radio

	for i in _rejilla.indices_cerca(desde, radio):
		var distancia := _posiciones[i].distance_to(desde)
		if distancia < mejor_distancia:
			mejor_distancia = distancia
			mejor = _posiciones[i]

	return mejor


func _preparar_multimesh() -> void:
	var malla := QuadMesh.new()
	malla.size = Vector2(datos.tamano, datos.tamano)

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = malla
	multimesh.instance_count = MAXIMO_ENEMIGOS
	multimesh.visible_instance_count = 0

	_horda.multimesh = multimesh
	_horda.modulate = datos.color


func _physics_process(delta: float) -> void:
	_reconstruir_rejilla()
	_mover(delta)
	_danar_jugador()
	_retirar_muertos()
	_volcar_al_multimesh()


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
		_posiciones[i] += (hacia_jugador + empuje) * datos.velocidad * delta


func _separacion(indice: int) -> Vector2:
	var empuje := Vector2.ZERO
	var posicion := _posiciones[indice]

	for otro in _rejilla.indices_cerca(posicion, radio_separacion):
		if otro == indice:
			continue

		var diferencia := posicion - _posiciones[otro]
		var distancia := diferencia.length()

		if distancia > 0.0 and distancia < radio_separacion:
			# Cuanto más cerca está el vecino, más fuerte empuja.
			empuje += diferencia / distancia * (1.0 - distancia / radio_separacion)

	return empuje


func _danar_jugador() -> void:
	var posicion_jugador := _jugador.global_position
	var radio_contacto := datos.tamano * 0.5 + 16.0

	for i in _rejilla.indices_cerca(posicion_jugador, radio_contacto):
		if _posiciones[i].distance_to(posicion_jugador) < radio_contacto:
			# Basta con el primero que toque: el golpe activa la invulnerabilidad
			# y los demás del montón no harían nada.
			_salud_jugador.recibir_dano(datos.dano_contacto)
			return


func _retirar_muertos() -> void:
	# Se recorre hacia atrás porque al eliminar se trae el último vivo al hueco:
	# ese que llega ya lo hemos comprobado, así que no hace falta repetirlo.
	var i := _vivos - 1

	while i >= 0:
		if _vidas[i] <= 0.0:
			BusEventos.enemigo_muerto.emit(_posiciones[i], datos.tipo)
			_eliminar(i)
		i -= 1


func _eliminar(indice: int) -> void:
	# El último vivo pasa a ocupar el hueco del que muere. Así los vivos siempre
	# son las primeras posiciones del array, sin huecos que haya que saltarse.
	_vivos -= 1
	_posiciones[indice] = _posiciones[_vivos]
	_vidas[indice] = _vidas[_vivos]


func _volcar_al_multimesh() -> void:
	var multimesh := _horda.multimesh

	for i in _vivos:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, _posiciones[i]))

	multimesh.visible_instance_count = _vivos
