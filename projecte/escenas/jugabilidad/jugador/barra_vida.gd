extends Node2D

## Barra de vida sobre la cabeza del personaje. Pasa de verde a rojo según baja
## la vida, para que se lea de un vistazo sin mirar a una esquina de la pantalla.

@export var ancho: float = 40.0
@export var alto: float = 5.0

var _proporcion := 1.0


func _ready() -> void:
	get_parent().get_node("Salud").vida_cambiada.connect(_al_cambiar_vida)


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	_proporcion = clampf(actual / maxima, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var zona := Rect2(Vector2(-ancho * 0.5, 0.0), Vector2(ancho, alto))
	draw_rect(zona.grow(1.0), Color(0.0, 0.0, 0.0, 0.8))
	var color := Color(1.0, 0.25, 0.3).lerp(Color(0.3, 1.0, 0.5), _proporcion)
	draw_rect(Rect2(zona.position, Vector2(ancho * _proporcion, alto)), color)
