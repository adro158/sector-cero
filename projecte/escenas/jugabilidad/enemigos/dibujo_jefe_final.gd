extends RefCounted

## Dibujo del jefe final y de sus ataques con sprites, como dibujo_ultis.gd: son
## funciones estáticas a las que el nodo que dibuja se pasa a sí mismo como
## "lienzo". Así la lógica (cuándo, dónde, cuánto daño) y el dibujo quedan en
## ficheros separados.
##
## Todas las hojas tienen los fotogramas en horizontal y se dibujan a 1x. Los
## tamaños y los tiempos son los de la demo con la que Adam grabó los GIF de
## muestra (con Claude en el chat). Sin class_name: se carga con preload.

const TRANSFORMACION := preload("res://medios/sprites/jefe_final/jefe_final_transformacion.png")
const MUERTE := preload("res://medios/sprites/jefe_final/jefe_final_muerte.png")
const AVISO_LINEA := preload("res://medios/sprites/jefe_final/jefe_final_aviso_linea.png")
const AVISO_ZONA := preload("res://medios/sprites/jefe_final/jefe_final_aviso_zona.png")
const AVISO_DIANA := preload("res://medios/sprites/jefe_final/jefe_final_aviso_diana.png")
const PORTAL := preload("res://medios/sprites/jefe_final/jefe_final_portal.png")
const ESCUDO := preload("res://medios/sprites/jefe_final/jefe_final_escudo.png")
const ESCUDO_ROTURA := preload("res://medios/sprites/jefe_final/jefe_final_escudo_rotura.png")
const ANCLA := preload("res://medios/sprites/jefe_final/jefe_final_ancla.png")
const CADENA := preload("res://medios/sprites/jefe_final/jefe_final_cadena.png")
const HIELO := preload("res://medios/sprites/jefe_final/jefe_final_hielo.png")
const PROYECTIL_HIELO := preload("res://medios/sprites/jefe_final/jefe_final_proyectil_hielo.png")

## El aviso del rayo se repite cada 32 px; la cadena, cada 16.
const TRAMO_LINEA := 32.0
const ESLABON := 16.0
## Lo que tarda en cerrarse un portal (sus fotogramas 6 y 7).
const CIERRE_PORTAL := 0.2


## Dibuja el fotograma n de una hoja (fotogramas de ancho `ancho`) centrado en
## `centro`.
static func fotograma(lienzo: CanvasItem, hoja: Texture2D, n: int, ancho: float, centro: Vector2, color := Color.WHITE) -> void:
	var alto := float(hoja.get_height())
	lienzo.draw_texture_rect_region(hoja, Rect2(centro - Vector2(ancho, alto) * 0.5, Vector2(ancho, alto)), Rect2(n * ancho, 0.0, ancho, alto), color)


## Aviso del rayo: flechas rojas desde `desde` hacia `direccion`, que avanzan
## (4 fotogramas de 0,08 s), sobre una franja translúcida de `ancho`: lo que
## hará daño, que es más ancho que las flechas.
static func aviso_linea(lienzo: CanvasItem, desde: Vector2, direccion: Vector2, largo: float, ancho: float, tiempo: float) -> void:
	lienzo.draw_set_transform(desde, direccion.angle(), Vector2.ONE)
	lienzo.draw_rect(Rect2(0.0, -ancho * 0.5, largo, ancho), Color(1.0, 0.25, 0.3, 0.15))
	var n := int(tiempo / 0.08) % 4
	for i in int(largo / TRAMO_LINEA):
		fotograma(lienzo, AVISO_LINEA, n, TRAMO_LINEA, Vector2(TRAMO_LINEA * 0.5 + i * TRAMO_LINEA, 0.0))
	lienzo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Portal de invocación: se abre (0-2), gira mientras está abierto (3-5) y se
## cierra (6-7), con fotogramas de 0,1 s. `tiempo` desde que empezó a abrirse.
static func portal(lienzo: CanvasItem, centro: Vector2, tiempo: float, duracion: float) -> void:
	var n: int
	if tiempo < 0.3:
		n = int(tiempo / 0.1)
	elif tiempo < duracion - CIERRE_PORTAL:
		n = 3 + int((tiempo - 0.3) / 0.1) % 3
	else:
		n = mini(6 + int((tiempo - duracion + CIERRE_PORTAL) / 0.1), 7)
	fotograma(lienzo, PORTAL, n, 96.0, centro)


## Cadena de eslabones de `desde` a `hasta` (2 fotogramas que brillan por
## turnos).
static func cadena(lienzo: CanvasItem, desde: Vector2, hasta: Vector2, tiempo: float) -> void:
	var direccion := (hasta - desde).normalized()
	lienzo.draw_set_transform(desde, direccion.angle(), Vector2.ONE)
	var n := int(tiempo * 8.0) % 2
	for i in int(desde.distance_to(hasta) / ESLABON):
		fotograma(lienzo, CADENA, n, ESLABON, Vector2(ESLABON * 0.5 + i * ESLABON, 0.0))
	lienzo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Zona de hielo: se forma en 0,32 s (fotogramas 0-3) y luego brilla (4-7 en
## bucle). En el último medio segundo se va borrando.
static func hielo(lienzo: CanvasItem, centro: Vector2, tiempo: float, duracion: float) -> void:
	var n := int(tiempo / 0.08)
	if n >= 4:
		n = 4 + n % 4
	var opacidad := clampf((duracion - tiempo) / 0.5, 0.0, 1.0)
	fotograma(lienzo, HIELO, n, 160.0, centro, Color(1.0, 1.0, 1.0, opacidad))
