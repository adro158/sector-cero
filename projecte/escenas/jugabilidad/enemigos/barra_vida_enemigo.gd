extends RefCounted

## Barra de vida de los enemigos fuertes (élites, jefe y ransomware): un borde
## oscuro por fuera y uno claro por dentro, para que se lea sobre cualquier
## fondo y en medio de la horda.
##
## Sin class_name: se carga con preload desde cada enemigo que la dibuja (ver
## embestida_horda.gd para el porqué).


## Dibuja en el CanvasItem dado una barra centrada en horizontal sobre el punto
## (que es su borde de arriba). La proporción va de 0 a 1.
static func dibujar(lienzo: CanvasItem, arriba: Vector2, ancho: float, alto: float, proporcion: float, color: Color) -> void:
	var zona := Rect2(arriba - Vector2(ancho * 0.5, 0.0), Vector2(ancho, alto))
	lienzo.draw_rect(zona.grow(2.0), Color(0.0, 0.0, 0.0, 0.85))
	lienzo.draw_rect(zona, Color(0.08, 0.08, 0.12))
	lienzo.draw_rect(Rect2(zona.position, Vector2(ancho * clampf(proporcion, 0.0, 1.0), alto)), color)
	lienzo.draw_rect(zona.grow(1.0), Color(1.0, 1.0, 1.0, 0.8), false, 1.0)
