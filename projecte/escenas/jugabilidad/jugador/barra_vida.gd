extends Node2D

## Barra de vida sobre la cabeza del personaje. Pasa de verde a rojo según baja
## la vida, para que se lea de un vistazo sin mirar a una esquina de la pantalla.
## Debajo, más fina, la carga de su ulti: cuando está llena, a la derecha
## parpadea un rayo que avisa de que se puede lanzar (con R o con B del mando).

## El marco mide 44x12 y lleva el fondo oscuro: el hueco de la vida es de 40x5
## en (2, 2) y el de la ulti, de 40x2 en (2, 8). Los rellenos están en grises
## y los tiñe su color.
const MARCO := preload("res://medios/sprites/efectos/barra_personaje_marco.png")
const VIDA := preload("res://medios/sprites/efectos/barra_personaje_vida.png")
const ULTI := preload("res://medios/sprites/efectos/barra_personaje_ulti.png")
## El rayo de la ulti lista: 2 fotogramas de 8x8, ya pintados.
const LISTA := preload("res://medios/sprites/efectos/ulti_lista.png")
const COLOR_ULTI := Color(1.0, 0.8, 0.2)
## La esquina de arriba a la izquierda del marco, para que quede centrado.
const ESQUINA := Vector2(-22.0, -2.0)

var _proporcion := 1.0
var _ulti := 0.0
var _tiempo := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	get_parent().get_node("Salud").vida_cambiada.connect(_al_cambiar_vida)
	BusEventos.ulti_cambiada.connect(_al_cambiar_ulti)


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	_proporcion = clampf(actual / maxima, 0.0, 1.0)
	queue_redraw()


func _al_cambiar_ulti(cargas: Array, activo: int) -> void:
	_ulti = cargas[activo]
	queue_redraw()


func _process(delta: float) -> void:
	# Solo hace falta redibujar sin parar para el parpadeo de la ulti llena.
	if _ulti >= 1.0:
		_tiempo += delta
		queue_redraw()


func _draw() -> void:
	draw_texture(MARCO, ESQUINA)
	var color := Color(1.0, 0.25, 0.3).lerp(Color(0.3, 1.0, 0.5), _proporcion)
	# Los rellenos, recortados a lo que haya.
	var vida := roundf(40.0 * _proporcion)
	draw_texture_rect_region(VIDA, Rect2(ESQUINA + Vector2(2.0, 2.0), Vector2(vida, 5.0)), Rect2(0.0, 0.0, vida, 5.0), color)
	var ulti := roundf(40.0 * _ulti)
	draw_texture_rect_region(ULTI, Rect2(ESQUINA + Vector2(2.0, 8.0), Vector2(ulti, 2.0)), Rect2(0.0, 0.0, ulti, 2.0), COLOR_ULTI)
	if _ulti >= 1.0:
		var fotograma := int(_tiempo / 0.25) % 2
		draw_texture_rect_region(LISTA, Rect2(ESQUINA + Vector2(46.0, 2.0), Vector2(8.0, 8.0)), Rect2(fotograma * 8.0, 0.0, 8.0, 8.0))
