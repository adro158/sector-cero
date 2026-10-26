class_name IconoMejora
extends Control

## Icono de una mejora en la columna del HUD, con su nivel debajo en forma de
## puntos: uno por cada vez que se ha elegido. A partir de cinco, un número.
## Las evoluciones son de un personaje y se ven distintas, como su tarjeta al
## subir de nivel: del color del personaje, con el borde grueso y «EVO» debajo
## (se cogen una vez, no tienen nivel). El HUD las pone las primeras.
##
## Los marcos y los puntos son del lote 9, en grises y teñidos; al subir de
## nivel, el marco parpadea con su fotograma de destello.

const MAXIMO_PUNTOS := 5
const TarjetaEvolucion := preload("res://escenas/interfaz/tarjeta_evolucion.gd")
const MARCO := preload("res://medios/interfaz/mejora_marco.png")
const MARCO_EVOLUCION := preload("res://medios/interfaz/mejora_marco_evolucion.png")
const PUNTO := preload("res://medios/interfaz/mejora_punto.png")
const DURACION_DESTELLO := 0.6

var mejora: DatosMejora
var nivel := 1
## El personaje de la evolución, o null si es una mejora normal.
var personaje: DatosPersonaje
## De 1 a 0 después de cogerla: mientras no es 0, el marco parpadea.
var destello := 0.0:
	set(nuevo):
		destello = nuevo
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(44, 52)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tooltip_text = "%s\n%s" % [mejora.nombre, mejora.descripcion]
	personaje = TarjetaEvolucion.personaje_de(mejora)


func poner_nivel(nuevo: int) -> void:
	nivel = nuevo
	create_tween().tween_property(self, "destello", 0.0, DURACION_DESTELLO).from(1.0)


func _draw() -> void:
	# Parpadea tres veces mientras dura el destello.
	var fotograma := 1 if destello > 0.0 and int(destello * 6.0) % 2 == 1 else 0
	var trozo := Rect2(fotograma * 40.0, 0.0, 40.0, 40.0)
	var marco := Rect2(Vector2(2, 0), Vector2(40, 40))
	if personaje != null:
		draw_texture_rect_region(MARCO_EVOLUCION, marco, trozo, personaje.color)
		if mejora.icono != null:
			draw_texture_rect(mejora.icono, Rect2(Vector2(6, 4), Vector2(32, 32)), false)
		draw_string(get_theme_default_font(), Vector2(4, 52), "EVO", HORIZONTAL_ALIGNMENT_CENTER, 36, 12, personaje.color)
		return

	draw_texture_rect_region(MARCO, marco, trozo, EstiloInterfaz.NEON)
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
		draw_texture(PUNTO, Vector2(x + i * 6, 44), EstiloInterfaz.NEON)
