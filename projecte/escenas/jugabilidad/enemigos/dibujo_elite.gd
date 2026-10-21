extends RefCounted

## Cómo se dibuja el élite (enemigo_elite.gd): el rootkit en reposo y el aviso
## de la explosión del Explosivo. Va aparte para que enemigo_elite.gd se quede
## con lo que hace el élite y no con cómo se ve.
##
## Sin class_name: se carga con preload, como embestida_horda.gd.

## El rootkit en reposo: 4 fotogramas de 48x48. El 0 es rootkit.png, que sigue
## siendo la textura de sus datos (la ficha y las reglas).
const REPOSO := preload("res://recursos/enemigos/sprites/rootkit_anim.png")
const FOTOGRAMAS_REPOSO := 4
## Casi todo el rato quieto (el fotograma 0) y, al final de cada vuelta, un
## brillo que recorre el marco (los fotogramas 1, 2 y 3, de 0,1 s cada uno).
const QUIETO := 1.2
const BRILLO_CADA := 0.1
const VUELTA := QUIETO + BRILLO_CADA * 3.0

const SOBRECARGA := preload("res://medios/sprites/explosion/rootkit_sobrecarga.png")
const ZONA := preload("res://medios/sprites/explosion/rootkit_zona.png")


## El fotograma del rootkit en reposo a los segundos que lleva aparecido.
static func fotograma_reposo(segundos: float) -> int:
	var en_vuelta := fmod(segundos, VUELTA)
	if en_vuelta < QUIETO:
		return 0
	return 1 + mini(int((en_vuelta - QUIETO) / BRILLO_CADA), 2)


## El aviso del Explosivo: la zona se va llenando, su anillo gira (sus 4
## fotogramas pasan cuatro veces) y el rootkit se agrieta y tiembla cada vez
## más hasta que estalla. cuenta_atras baja de aviso a 0.
static func aviso_explosion(lienzo: CanvasItem, cuenta_atras: float, aviso: float, radio: float) -> void:
	var progreso := 1.0 - cuenta_atras / aviso
	lienzo.draw_circle(Vector2.ZERO, radio * progreso, Color(1.0, 0.4, 0.1, 0.18))
	var giro := int(progreso * 16.0) % 4
	lienzo.draw_texture_rect_region(ZONA, Rect2(-152.0, -152.0, 304.0, 304.0), Rect2(giro * 304.0, 0.0, 304.0, 304.0))
	# Con senos y no al azar: randf() gastaría números del azar de la partida
	# y el simulador ya no repetiría las mismas partidas.
	var temblor := Vector2(sin(cuenta_atras * 97.0), cos(cuenta_atras * 71.0)) * 2.0 * progreso
	var fotograma := mini(int(progreso * 6.0), 5)
	lienzo.draw_texture_rect_region(SOBRECARGA, Rect2(Vector2(-32.0, -32.0) + temblor, Vector2(64.0, 64.0)), Rect2(fotograma * 64.0, 0.0, 64.0, 64.0))
