extends RefCounted

## Barra de vida de los enemigos fuertes (élites, anclas del escudo y la horda
## que la enseña, como el ransomware): un marco con el fondo oscuro y el
## relleno del color del enemigo, para que se lea sobre cualquier fondo y en
## medio de la horda. Los dos sprites están en grises: el relleno lo tiñe el
## color y el marco va sin teñir.
##
## Sin class_name: se carga con preload desde cada enemigo que la dibuja (ver
## embestida_horda.gd para el porqué). El que la dibuja necesita el filtro
## nearest.

## El marco mide 48x9 y su hueco, 44x5 en (2, 2). Todas sus columnas del centro
## son iguales: se estira por ahí para cualquier ancho.
const MARCO := preload("res://medios/sprites/efectos/barra_enemigo_marco.png")
## El relleno mide 44x5 y también es igual en todas sus columnas.
const RELLENO := preload("res://medios/sprites/efectos/barra_enemigo_relleno.png")
## Lo que se queda tal cual a cada lado del marco.
const LADO := 5.0


## Dibuja en el CanvasItem dado una barra de ancho píxeles de relleno centrada
## en horizontal sobre el punto (que es el borde de arriba del relleno). La
## proporción va de 0 a 1.
static func dibujar(lienzo: CanvasItem, arriba: Vector2, ancho: float, proporcion: float, color: Color) -> void:
	# En píxeles enteros: a medio píxel, el dibujo se emborrona.
	var esquina := Vector2(roundf(arriba.x - ancho * 0.5) - 2.0, roundf(arriba.y) - 2.0)
	var total := ancho + 4.0
	# El marco en 3 trozos: los lados tal cual y el centro estirado.
	lienzo.draw_texture_rect_region(MARCO, Rect2(esquina, Vector2(LADO, 9.0)), Rect2(0.0, 0.0, LADO, 9.0))
	lienzo.draw_texture_rect_region(MARCO, Rect2(esquina + Vector2(LADO, 0.0), Vector2(total - LADO * 2.0, 9.0)), Rect2(LADO, 0.0, 48.0 - LADO * 2.0, 9.0))
	lienzo.draw_texture_rect_region(MARCO, Rect2(esquina + Vector2(total - LADO, 0.0), Vector2(LADO, 9.0)), Rect2(48.0 - LADO, 0.0, LADO, 9.0))
	# El relleno, recortado a la vida que queda (o estirado si es más ancho).
	var lleno := roundf(ancho * clampf(proporcion, 0.0, 1.0))
	lienzo.draw_texture_rect_region(RELLENO, Rect2(esquina + Vector2(2.0, 2.0), Vector2(lleno, 5.0)), Rect2(0.0, 0.0, minf(lleno, 44.0), 5.0), color)
