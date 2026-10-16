extends Control

## Barra de vida del jefe final, arriba en el centro, debajo del reloj. El
## marco (jefe_final_barra.png) ya trae el nombre y las marcas del 66 % y del
## 33 %, donde cambia de forma; encima va el relleno, recortado según la vida.
## Como el resto del HUD, se entera de todo por el bus.
##
## Sin class_name: lo carga hud.gd con preload.

const MARCO := preload("res://medios/sprites/jefe_final/jefe_final_barra.png")
const RELLENO := preload("res://medios/sprites/jefe_final/jefe_final_barra_relleno.png")
## Dónde empieza el relleno dentro del marco.
const ESQUINA_RELLENO := Vector2(16.0, 20.0)

var _fraccion := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Centrada arriba, debajo del reloj y de la cuenta atrás. Anclada al centro
	# de arriba: los offsets son relativos a ese punto.
	set_anchors_preset(Control.PRESET_CENTER_TOP)
	offset_left = -MARCO.get_width() * 0.5
	offset_right = MARCO.get_width() * 0.5
	offset_top = 62.0
	offset_bottom = 62.0 + MARCO.get_height()
	visible = false
	BusEventos.jefe_final_aparecio.connect(show)
	BusEventos.jefe_final_vida_cambiada.connect(_al_cambiar_vida)


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	_fraccion = clampf(actual / maxima, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	draw_texture(MARCO, Vector2.ZERO)
	var ancho := RELLENO.get_width() * _fraccion
	draw_texture_rect_region(RELLENO, Rect2(ESQUINA_RELLENO, Vector2(ancho, RELLENO.get_height())), Rect2(0.0, 0.0, ancho, RELLENO.get_height()))
