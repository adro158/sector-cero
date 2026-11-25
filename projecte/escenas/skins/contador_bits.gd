extends HBoxContainer

## El contador de bits (de Alan, 23/11): la moneda girando a x2 y cuántos bits
## se tienen; cuando suben, un destello encima de la moneda. Escucha
## Cartera.bits_cambiados. Va en la ventana SKINS y en el menú principal.
##
## Los PNG son de lote_bits.zip (medios/sprites/bits/): la moneda gira a 0,1 s
## por fotograma, en bucle, y el destello va a 0,06 s, una vez.
##
## Sin class_name: se carga con preload.

const Cartera := preload("res://globales/cartera.gd")
const GIRO := preload("res://medios/sprites/bits/bits_giro.png")
const DESTELLO := preload("res://medios/sprites/bits/bits_destello.png")
const BITS := Color("#00E5FF")
## La moneda, a escala entera: con píxel duro, una escala no entera se ve mal.
const ESCALA := 2.0
const SEGUNDOS_GIRO := 0.1
const SEGUNDOS_DESTELLO := 0.06

var _moneda: Control
var _cantidad: Label
var _tiempo := 0.0
## Cuánto lleva el destello (negativo: no hay).
var _destello := -1.0
var _ultimo := -1


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	alignment = BoxContainer.ALIGNMENT_END
	_moneda = Control.new()
	_moneda.custom_minimum_size = Vector2(16.0, 16.0) * ESCALA
	_moneda.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_moneda.draw.connect(_dibujar_moneda)
	add_child(_moneda)
	_cantidad = EstiloInterfaz.etiqueta("", 22, BITS)
	add_child(_cantidad)
	Cartera.actual.bits_cambiados.connect(_al_cambiar)
	_al_cambiar(Cartera.actual.bits())


func _process(delta: float) -> void:
	_tiempo += delta
	if _destello >= 0.0:
		_destello += delta
		if _destello >= SEGUNDOS_DESTELLO * 4.0:
			_destello = -1.0
	_moneda.queue_redraw()


## Si suben, el destello; si bajan (una compra), solo el número.
func _al_cambiar(total: int) -> void:
	if _ultimo >= 0 and total > _ultimo:
		_destello = 0.0
	_ultimo = total
	_cantidad.text = "%d" % total


func _dibujar_moneda() -> void:
	var fotograma := int(_tiempo / SEGUNDOS_GIRO) % 8
	_moneda.draw_texture_rect_region(GIRO, Rect2(Vector2.ZERO, Vector2(16.0, 16.0) * ESCALA), Rect2(fotograma * 16.0, 0.0, 16.0, 16.0))
	if _destello >= 0.0:
		# Centrado encima de la moneda: 24 de lado, 4 más arriba y a la izquierda.
		var cuadro := mini(int(_destello / SEGUNDOS_DESTELLO), 3)
		_moneda.draw_texture_rect_region(DESTELLO, Rect2(Vector2(-4.0, -4.0) * ESCALA, Vector2(24.0, 24.0) * ESCALA), Rect2(cuadro * 24.0, 0.0, 24.0, 24.0))
