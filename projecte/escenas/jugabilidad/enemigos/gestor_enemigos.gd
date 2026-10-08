class_name GestorEnemigos
extends Node2D

## Señal local, no del BusEventos: se dispara decenas de veces por segundo y solo
## interesa dentro de la jugabilidad. El bus queda para lo que cruza la frontera
## con la interfaz. La resistencia viaja con el golpe para que el número de daño
## pueda mostrar que el malware se está adaptando a esa arma.
signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)

const MAXIMO_ENEMIGOS := 600
## Segundos que un enemigo se queda en blanco al recibir un golpe.
const DURACION_DESTELLO := 0.1
## Lo que tarda la horda en huir y desvanecerse cuando llega el jefe.
const DURACION_HUIDA := 1.2
const MATERIAL_HORDA := preload("res://medios/shaders/horda.tres")
const EmbestidaHorda := preload("res://escenas/jugabilidad/enemigos/embestida_horda.gd")
const BarraVida := preload("res://escenas/jugabilidad/enemigos/barra_vida_enemigo.gd")

@export var datos: DatosTipoEnemigo
@export var radio_separacion: float = 26.0
@export var fuerza_separacion: float = 1.8
## El mapa no tiene fin: un enemigo que se queda a más de esta distancia del
## jugador reaparece al otro lado, en lugar de quedarse rezagado para siempre.
@export var distancia_reciclaje: float = 1200.0

var _posiciones := PackedVector2Array()
var _vidas := PackedFloat32Array()
## La vida con la que apareció cada uno: depende del nivel del jugador en ese
## momento, así que no es la misma para todos.
var _vidas_maximas := PackedFloat32Array()
var _destellos := PackedFloat32Array()
## Un número único por enemigo, que viaja con él cuando cambia de hueco: la
## ficha del enemigo que se ha pinchado lo sigue con él.
var _ids := PackedInt32Array()
var _siguiente_id := 1
var _vivos := 0
## Nivel del jugador: los que aparecen a partir de ahora tienen más vida.
var _nivel := 1
## Segundos de partida: también dan más vida a los que aparecen.
var _segundos := 0.0
var _jugador: Node2D
var _salud_jugador: Salud
var _rejilla: RejillaEspacial
## Solo en los tipos que embisten (el troyano). En los demás se queda en null.
var _embestida: EmbestidaHorda
## Segundos que le quedan a la huida (0 si no está huyendo).
var _huida := 0.0

@onready var _horda: MultiMeshInstance2D = $Horda


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_posiciones.resize(MAXIMO_ENEMIGOS)
	_vidas.resize(MAXIMO_ENEMIGOS)
	_vidas_maximas.resize(MAXIMO_ENEMIGOS)
	_destellos.resize(MAXIMO_ENEMIGOS)
	_ids.resize(MAXIMO_ENEMIGOS)
	_rejilla = RejillaEspacial.new(radio_separacion)
	if datos.embiste:
		_embestida = EmbestidaHorda.new(datos, MAXIMO_ENEMIGOS)
	_preparar_multimesh()
	# Las barras de vida se dibujan en este nodo: la horda, que es su hijo, va
	# detrás para que no las tape.
	_horda.show_behind_parent = datos.mostrar_vida
	BusEventos.experiencia_cambiada.connect(func(_actual, _necesaria, nivel): _nivel = nivel)
	BusEventos.tiempo_partida.connect(func(segundos, _duracion): _segundos = segundos)


func vivos() -> int:
	return _vivos


func tiempo_aparicion() -> float:
	return datos.tiempo_aparicion


## Si cabe otro de este tipo sin pasar de su máximo a la vez (0 es sin límite).
func cabe_otro() -> bool:
	return datos.maximo_vivos == 0 or _vivos < datos.maximo_vivos


## Al llegar el jefe la horda huye: durante DURACION_HUIDA se aleja del jugador
## sin hacerle daño y se desvanece, y después desaparece. No suelta
## experiencia ni cuenta como eliminada: no la ha matado el jugador.
func huir() -> void:
	_huida = DURACION_HUIDA


func aparecer(posicion: Vector2) -> void:
	if _vivos >= MAXIMO_ENEMIGOS:
		return

	_posiciones[_vivos] = posicion
	_vidas[_vivos] = datos.vida_para(_nivel, _segundos)
	_vidas_maximas[_vivos] = _vidas[_vivos]
	_destellos[_vivos] = 0.0
	_ids[_vivos] = _siguiente_id
	_siguiente_id += 1
	if _embestida != null:
		_embestida.reiniciar(_vivos)
	_vivos += 1


## Devuelve a cuántos enemigos ha alcanzado, que es lo que necesitan los
## proyectiles para saber si han impactado. La cantidad llega ya con la
## resistencia descontada; la resistencia solo se usa para el aviso.
func danar_en_area(centro: Vector2, radio: float, cantidad: float, resistencia := 0.0) -> int:
	var alcanzados := 0

	for i in _rejilla.indices_cerca(centro, radio):
		# Uno que ya ha muerto en este fotograma sigue en el array hasta la
		# próxima retirada. Sin esta comprobación recibiría más golpes y
		# mostraría números de daño sobre un enemigo que ya no existe.
		if _vidas[i] <= 0.0:
			continue

		if _posiciones[i].distance_to(centro) < radio:
			_vidas[i] -= cantidad
			_destellos[i] = DURACION_DESTELLO
			enemigo_danado.emit(_posiciones[i], cantidad, resistencia)
			alcanzados += 1

	return alcanzados


## Ficha del enemigo más cercano al punto dentro del radio, para la ficha que
## sale al pinchar en él. Vacía si no hay ninguno. Mismo método en los élites y
## el jefe: la interfaz recorre el grupo objetivos sin saber qué es cada uno.
func ficha_en(punto: Vector2, radio: float) -> Dictionary:
	var indice := -1
	var mejor_distancia := radio
	for i in _rejilla.indices_cerca(punto, radio):
		var distancia := _posiciones[i].distance_to(punto)
		if _vidas[i] > 0.0 and distancia < mejor_distancia:
			mejor_distancia = distancia
			indice = i
	if indice == -1:
		return {}
	var resultado := ficha(_ids[indice])
	resultado.distancia = mejor_distancia
	return resultado


## Los datos actuales del enemigo con ese id, o vacía si ya no existe.
func ficha(id: int) -> Dictionary:
	for i in _vivos:
		if _ids[i] == id and _vidas[i] > 0.0:
			return {"id": id, "nombre": datos.nombre, "textura": datos.textura, "color": datos.color,
				"vida": _vidas[i], "vida_maxima": _vidas_maximas[i], "dano": datos.dano_contacto,
				"velocidad": datos.velocidad}
	return {}


## Posición del enemigo vivo más cercano dentro del radio, o Vector2.INF si no
## hay ninguno.
func mas_cercano(desde: Vector2, radio: float) -> Vector2:
	var mejor := Vector2.INF
	var mejor_distancia := radio

	for i in _rejilla.indices_cerca(desde, radio):
		if _vidas[i] <= 0.0:
			continue

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
	# Los datos propios de cada enemigo son su destello y, en los que embisten,
	# el aviso. Los lee el shader. Hay que activarlo antes de fijar el número de
	# instancias.
	multimesh.use_custom_data = true
	multimesh.mesh = malla
	multimesh.instance_count = MAXIMO_ENEMIGOS
	multimesh.visible_instance_count = 0

	_horda.multimesh = multimesh
	_horda.material = MATERIAL_HORDA
	_horda.texture = datos.textura
	_horda.modulate = Color.WHITE if datos.textura else datos.color
	_horda.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _physics_process(delta: float) -> void:
	# Primero se retiran los muertos y después se reconstruye la rejilla. Al
	# revés, la retirada cambiaría de índice a los enemigos que llegan a los
	# huecos y la rejilla seguiría apuntando a los índices antiguos: las armas,
	# que la consultan después, fallarían contra esos enemigos.
	_retirar_muertos()
	_reconstruir_rejilla()
	_mover(delta)
	if _huida > 0.0:
		_avanzar_huida(delta)
	else:
		_danar_jugador()
	_volcar_al_multimesh(delta)
	if datos.mostrar_vida:
		queue_redraw()


func _draw() -> void:
	if not datos.mostrar_vida:
		return
	for i in _vivos:
		var arriba := _posiciones[i] - Vector2(0.0, datos.tamano * 0.5 + 10.0)
		BarraVida.dibujar(self, arriba, datos.tamano, 5.0, _vidas[i] / _vidas_maximas[i], datos.color)


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
		# Se refleja al otro lado del jugador, algo más cerca: si el jugador
		# huía de él, ahora lo tiene delante, fuera de la pantalla.
		if _posiciones[i].distance_to(destino) > distancia_reciclaje:
			_posiciones[i] = destino + (destino - _posiciones[i]) * 0.6

		# Mientras avisa o embiste, no persigue: se mueve por su cuenta.
		if _embestida != null and _huida <= 0.0:
			_embestida.actualizar(i, _posiciones[i], destino, delta)
			if not _embestida.persigue(i):
				_posiciones[i] += _embestida.avance(i, delta)
				continue

		var hacia_jugador := (destino - _posiciones[i]).normalized()
		var empuje := _separacion(i) * fuerza_separacion

		# El empuje se suma al avance en lugar de normalizarse junto a él: si se
		# normalizara, la separación solo podría girar la dirección y nunca
		# llegaría a vencer al impulso hacia el jugador, que es justo lo que
		# hace falta cuando dos enemigos están encima el uno del otro.
		# Huyendo, al revés y al doble de velocidad.
		if _huida > 0.0:
			hacia_jugador *= -2.0
		_posiciones[i] += (hacia_jugador + empuje) * datos.velocidad * delta


func _avanzar_huida(delta: float) -> void:
	_huida -= delta
	_horda.modulate.a = maxf(_huida / DURACION_HUIDA, 0.0)
	if _huida <= 0.0:
		_vivos = 0
		_horda.modulate.a = 1.0


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
	_vidas_maximas[indice] = _vidas_maximas[_vivos]
	_destellos[indice] = _destellos[_vivos]
	_ids[indice] = _ids[_vivos]
	if _embestida != null:
		_embestida.copiar(_vivos, indice)


func _volcar_al_multimesh(delta: float) -> void:
	var multimesh := _horda.multimesh

	# Escala vertical -1: el QuadMesh tiene la textura invertida respecto al 2D.
	for i in _vivos:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2(1.0, -1.0), 0.0, _posiciones[i]))
		_destellos[i] = maxf(_destellos[i] - delta, 0.0)
		var aviso := _embestida.avisando(i) if _embestida != null else 0.0
		multimesh.set_instance_custom_data(i, Color(_destellos[i] / DURACION_DESTELLO, aviso, 0.0, 0.0))

	multimesh.visible_instance_count = _vivos
