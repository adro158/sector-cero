extends Node2D

## Jefe final. Está en la escena desde el principio, oculto e inactivo, y el
## director lo hace aparecer al cumplirse el tiempo de la partida. Derrotarlo
## es la victoria.
##
## Persigue al jugador despacio y hace daño por contacto. Cada cierto tiempo se
## tiñe de rojo como aviso y embiste en línea recta hacia donde estaba el
## jugador: se puede esquivar si se reacciona al aviso.
##
## Para las armas es un objetivo más, igual que los gestores de la horda: está
## en el grupo objetivos y tiene danar_en_area y mas_cercano.

signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)
signal derrotado

enum Estado { PERSEGUIR, AVISO, EMBESTIDA }

const FOTOGRAMAS_ANDAR := 12

@export var velocidad: float = 90.0
@export var radio: float = 40.0
@export var dano_contacto: float = 15.0
@export var fotogramas_por_segundo: float = 7.7

@export_group("Embestida")
@export var intervalo_embestida: float = 7.0
@export var duracion_aviso: float = 0.8
@export var duracion_embestida: float = 0.7
@export var velocidad_embestida: float = 480.0
@export var color_aviso: Color = Color(1.0, 0.3, 0.3, 1.0)

var _activo := false
var _estado := Estado.PERSEGUIR
var _tiempo_estado := 0.0
var _direccion := Vector2.DOWN
var _tiempo_andando := 0.0
var _jugador: Node2D
var _salud_jugador: Salud

@onready var _sprite: Sprite2D = $Sprite
@onready var _salud: Salud = $Salud


func _ready() -> void:
	visible = false
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_salud.murio.connect(_al_morir)
	_salud.vida_cambiada.connect(func(_actual, _maxima): queue_redraw())


func aparecer(posicion: Vector2) -> void:
	global_position = posicion
	visible = true
	_activo = true


## Misma forma que en los gestores de la horda: devuelve a cuántos alcanza.
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0) -> int:
	if not _activo or global_position.distance_to(centro) > radio_golpe + radio:
		return 0

	_salud.recibir_dano(cantidad)
	# El número sale sobre el cuerpo y un poco desplazado, para que varios
	# golpes seguidos no se pinten uno encima de otro.
	enemigo_danado.emit(global_position + Vector2(randf_range(-24.0, 24.0), -40.0), cantidad, resistencia)
	return 1


func mas_cercano(desde: Vector2, radio_busqueda: float) -> Vector2:
	if _activo and global_position.distance_to(desde) < radio_busqueda:
		return global_position
	return Vector2.INF


func _physics_process(delta: float) -> void:
	if not _activo:
		return

	_tiempo_estado += delta
	var hacia_jugador := (_jugador.global_position - global_position).normalized()

	match _estado:
		Estado.PERSEGUIR:
			_direccion = hacia_jugador
			global_position += _direccion * velocidad * delta
			if _tiempo_estado >= intervalo_embestida:
				_cambiar_estado(Estado.AVISO)
		Estado.AVISO:
			# Quieto y mirando al jugador: la embestida irá hacia donde esté
			# cuando acabe el aviso, no hacia donde vaya después.
			_direccion = hacia_jugador
			if _tiempo_estado >= duracion_aviso:
				_cambiar_estado(Estado.EMBESTIDA)
		Estado.EMBESTIDA:
			global_position += _direccion * velocidad_embestida * delta
			if _tiempo_estado >= duracion_embestida:
				_cambiar_estado(Estado.PERSEGUIR)

	if global_position.distance_to(_jugador.global_position) < radio + 16.0:
		_salud_jugador.recibir_dano(dano_contacto)

	_animar(delta)


func _cambiar_estado(nuevo: Estado) -> void:
	_estado = nuevo
	_tiempo_estado = 0.0
	_sprite.modulate = color_aviso if nuevo == Estado.AVISO else Color.WHITE


func _animar(delta: float) -> void:
	if _estado != Estado.AVISO:
		_tiempo_andando += delta
	var columna := int(_tiempo_andando * fotogramas_por_segundo) % FOTOGRAMAS_ANDAR
	_sprite.frame = Direcciones8.fila(_direccion) * FOTOGRAMAS_ANDAR + columna


func _draw() -> void:
	if not _activo:
		return

	# Barra de vida sobre la corona.
	var ancho := 110.0
	var origen := Vector2(-ancho * 0.5, -130.0)
	var proporcion := _salud.vida() / _salud.vida_maxima
	draw_rect(Rect2(origen, Vector2(ancho, 7.0)), Color(0.05, 0.05, 0.1, 0.9))
	draw_rect(Rect2(origen, Vector2(ancho * proporcion, 7.0)), Color(0.75, 0.3, 1.0))


func _al_morir() -> void:
	_activo = false
	visible = false
	BusEventos.enemigo_muerto.emit(global_position, "jefe")
	derrotado.emit()
