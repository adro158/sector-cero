extends RefCounted

## Dibujo de las ultis con sprites. Son funciones estáticas: ultis.gd las llama
## desde su _draw pasándose a sí mismo como "lienzo", y así la lógica (golpes,
## carga) y el dibujo quedan en ficheros separados.
##
## Todas las hojas tienen los fotogramas en horizontal y se dibujan a 1x, como
## los personajes. El nodo que dibuja tiene que tener el filtro "nearest".
##
## Es el código con el que Adam grabó los GIF de muestra de los sprites (con
## Claude en el chat). Sin class_name: ultis.gd lo carga con preload.

const RAYO_TRAMO := preload("res://medios/sprites/ultis/ulti_rayo_tramo.png")
const RAYO_PUNTA := preload("res://medios/sprites/ultis/ulti_rayo_punta.png")
const RAYO_ORIGEN := preload("res://medios/sprites/ultis/ulti_rayo_origen.png")
const TORBELLINO := preload("res://medios/sprites/ultis/ulti_torbellino.png")
const TORMENTA_RAYO := preload("res://medios/sprites/ultis/ulti_tormenta_rayo.png")
const TORMENTA_IMPACTO := preload("res://medios/sprites/ultis/ulti_tormenta_impacto.png")
const TORMENTA_MINI := preload("res://medios/sprites/ultis/ulti_tormenta_mini.png")
const TORMENTA_CHISPA := preload("res://medios/sprites/ultis/ulti_tormenta_chispa.png")

## El dibujo del rayo se repite cada 32 px; la punta mide 48.
const TRAMO := 32.0
const PUNTA := 48.0


## Dibuja el fotograma n de una hoja (fotogramas en horizontal, de ancho
## `ancho`) con su esquina de arriba a la izquierda en `esquina`.
static func _fotograma(lienzo: CanvasItem, hoja: Texture2D, n: int, ancho: float, esquina: Vector2, color := Color.WHITE) -> void:
	var alto := float(hoja.get_height())
	lienzo.draw_texture_rect_region(hoja, Rect2(esquina, Vector2(ancho, alto)), Rect2(n * ancho, 0.0, ancho, alto), color)


## 0 → 1 en `entrar` segundos y 1 → 0 en los últimos `salir` segundos.
static func _aparecer(tiempo: float, duracion: float, entrar: float, salir: float) -> float:
	return clampf(tiempo / entrar, 0.0, 1.0) * clampf((duracion - tiempo) / salir, 0.0, 1.0)


## Rayo de datos (Mago). `desde` en coordenadas del lienzo. Probado con el
## rayo saliendo del pecho del mago (22 px más arriba) y 40 px por delante, con
## `largo` 860: así el círculo del origen no le tapa.
static func rayo(lienzo: CanvasItem, desde: Vector2, direccion: Vector2, largo: float, tiempo: float, duracion: float) -> void:
	var n := int(tiempo / 0.05) % 4
	# Se abre muy rápido y se cierra al final (solo cambia el grosor).
	var grosor := _aparecer(tiempo, duracion, 0.08, 0.2)
	lienzo.draw_set_transform(desde, direccion.angle(), Vector2(1.0, grosor))
	var tramos := int((largo - PUNTA) / TRAMO)
	for i in tramos:
		_fotograma(lienzo, RAYO_TRAMO, n, TRAMO, Vector2(i * TRAMO, -40.0))
	_fotograma(lienzo, RAYO_PUNTA, n, PUNTA, Vector2(tramos * TRAMO, -40.0))
	# El círculo del origen va derecho, encima del principio del rayo.
	lienzo.draw_set_transform(desde, 0.0, Vector2.ONE)
	_fotograma(lienzo, RAYO_ORIGEN, n, 96.0, Vector2(-48.0, -48.0), Color(1.0, 1.0, 1.0, minf(1.0, grosor * 1.5)))
	lienzo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Torbellino (Espadachín), centrado en el lienzo. 6 fotogramas de 10 grados:
## con 6 hojas, a los 60 grados el dibujo vuelve a ser el mismo.
static func torbellino(lienzo: CanvasItem, tiempo: float, duracion: float, vueltas_por_segundo: float) -> void:
	var n := int(tiempo * vueltas_por_segundo * 36.0) % 6
	var opacidad := _aparecer(tiempo, duracion, 0.1, 0.25)
	_fotograma(lienzo, TORBELLINO, n, 352.0, Vector2(-176.0, -176.0), Color(1.0, 1.0, 1.0, opacidad))


## Tormenta (Segador). `centro` y `mini` en coordenadas del lienzo; el mini
## rayo i cae en el segundo 0,3 + i * 0,08, como en ultis.gd.
static func tormenta(lienzo: CanvasItem, centro: Vector2, mini: Array[Vector2], tiempo: float) -> void:
	# Onda en el suelo: 6 fotogramas de 0,08 s.
	var onda := int(tiempo / 0.08)
	if onda < 6:
		_fotograma(lienzo, TORMENTA_IMPACTO, onda, 416.0, centro - Vector2(208.0, 208.0))
	# Rayo grande: el punto de impacto es el centro del borde de abajo.
	if tiempo < 0.35:
		var opacidad := clampf((0.35 - tiempo) / 0.1, 0.0, 1.0)
		_fotograma(lienzo, TORMENTA_RAYO, int(tiempo / 0.05) % 4, 96.0, centro - Vector2(48.0, TORMENTA_RAYO.get_height()), Color(1.0, 1.0, 1.0, opacidad))
	for i in mini.size():
		var t := tiempo - (0.3 + i * 0.08)
		if t < 0.0 or t >= 0.25:
			continue
		_fotograma(lienzo, TORMENTA_CHISPA, int(t / 0.05), 128.0, mini[i] - Vector2(64.0, 64.0))
		if t < 0.12:
			_fotograma(lienzo, TORMENTA_MINI, int(t / 0.04) % 3, 32.0, mini[i] - Vector2(16.0, TORMENTA_MINI.get_height()))


## Mira del rayo mientras el Mago apunta con el ratón: una línea morada a trazos
## del largo del rayo y el aviso de que sale con el click. Sin sprite.
static func mira(lienzo: CanvasItem, desde: Vector2, direccion: Vector2, largo: float) -> void:
	var color := Color(0.8, 0.45, 1.0, 0.6)
	lienzo.draw_dashed_line(desde, desde + direccion * largo, color, 3.0, 14.0)
	lienzo.draw_circle(desde, 17.0, Color(color, 0.3))
	lienzo.draw_string(ThemeDB.fallback_font, Vector2(-34.0, 46.0), "CLICK", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
