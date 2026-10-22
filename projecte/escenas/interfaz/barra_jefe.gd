extends Control

## Barra de vida de un jefe, arriba en el centro, debajo del reloj: hay una
## para Kernel Panic y otra para NÚCLEO CERO, cada una con su marco y su
## relleno. El marco ya trae el nombre y las marcas del 66 % y del 33 %, donde
## el jefe se enfurece o cambia de forma; encima va el relleno, recortado
## según la vida.
##
## hud.gd crea las dos y las conecta al bus: cuándo se ve y cuánta vida le
## queda. Sin class_name: lo carga hud.gd con preload.

## Dónde empieza el relleno dentro del marco. Los dos marcos son iguales.
const ESQUINA_RELLENO := Vector2(16.0, 20.0)

var _marco: Texture2D
var _relleno: Texture2D
var _fraccion := 1.0


func _init(marco: Texture2D, relleno: Texture2D) -> void:
	_marco = marco
	_relleno = relleno


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Centrada arriba, debajo del reloj y de la cuenta atrás. Anclada al centro
	# de arriba: los offsets son relativos a ese punto.
	set_anchors_preset(Control.PRESET_CENTER_TOP)
	offset_left = -_marco.get_width() * 0.5
	offset_right = _marco.get_width() * 0.5
	offset_top = 62.0
	offset_bottom = 62.0 + _marco.get_height()
	visible = false


func poner(actual: float, maxima: float) -> void:
	_fraccion = clampf(actual / maxima, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	draw_texture(_marco, Vector2.ZERO)
	var ancho := _relleno.get_width() * _fraccion
	draw_texture_rect_region(_relleno, Rect2(ESQUINA_RELLENO, Vector2(ancho, _relleno.get_height())), Rect2(0.0, 0.0, ancho, _relleno.get_height()))
