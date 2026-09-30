class_name IconoMejora
extends Control

## Icono de una mejora en la columna del HUD, con su nivel debajo en forma de
## puntos: uno por cada vez que se ha elegido. A partir de cinco, un número.

const MAXIMO_PUNTOS := 5

var mejora: DatosMejora
var nivel := 1


func _ready() -> void:
	custom_minimum_size = Vector2(44, 52)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tooltip_text = "%s\n%s" % [mejora.nombre, mejora.descripcion]


func poner_nivel(nuevo: int) -> void:
	nivel = nuevo
	queue_redraw()


func _draw() -> void:
	var marco := Rect2(Vector2(2, 0), Vector2(40, 40))
	draw_rect(marco, EstiloInterfaz.FONDO)
	draw_rect(marco, Color(EstiloInterfaz.NEON, 0.7), false, 2.0)
	if mejora.icono != null:
		# El icono mide 16x16 y se dibuja al doble, así sigue siendo nítido.
		draw_texture_rect(mejora.icono, Rect2(Vector2(6, 4), Vector2(32, 32)), false)

	if nivel > MAXIMO_PUNTOS:
		draw_string(get_theme_default_font(), Vector2(4, 51), "x%d" % nivel, HORIZONTAL_ALIGNMENT_CENTER, 36, 12, EstiloInterfaz.NEON)
		return

	# Puntos centrados bajo el marco, uno por nivel.
	var ancho_total := nivel * 6 - 2
	var x := 22.0 - ancho_total / 2.0
	for i in nivel:
		draw_rect(Rect2(Vector2(x + i * 6, 44), Vector2(4, 4)), EstiloInterfaz.NEON)
