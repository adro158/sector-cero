extends RefCounted

## Cómo se dibuja el élite (enemigo_elite.gd): el rootkit en reposo, el efecto
## de cada afijo, sus iconos y el aviso de la explosión del Explosivo. Va
## aparte para que enemigo_elite.gd se quede con lo que hace el élite y no con
## cómo se ve.
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

## El efecto de cada afijo, en grises para teñirlo con su color:
## [hoja, fotogramas, segundos por fotograma]. Todos van centrados en el
## élite y en bucle. El Explosivo no está: su efecto es el aviso al morir.
const AFIJOS := {
	DatosAfijoElite.Efecto.BLINDADO: [preload("res://recursos/enemigos/sprites/afijo_blindado.png"), 4, 0.15],
	DatosAfijoElite.Efecto.REPLICANTE: [preload("res://recursos/enemigos/sprites/afijo_replicante.png"), 4, 0.1],
	DatosAfijoElite.Efecto.AURA_LENTA: [preload("res://recursos/enemigos/sprites/afijo_aura_lenta.png"), 4, 0.15],
}

const SOBRECARGA := preload("res://medios/sprites/explosion/rootkit_sobrecarga.png")
const ZONA := preload("res://medios/sprites/explosion/rootkit_zona.png")


## El fotograma del rootkit en reposo a los segundos que lleva aparecido.
static func fotograma_reposo(segundos: float) -> int:
	var en_vuelta := fmod(segundos, VUELTA)
	if en_vuelta < QUIETO:
		return 0
	return 1 + mini(int((en_vuelta - QUIETO) / BRILLO_CADA), 2)


## Lo que va detrás del rootkit: el anillo helado del Aura lenta (del radio de
## RADIO_AURA), las copias del Replicante y, para los afijos sin efecto (el
## Explosivo), un anillo fino de su color alrededor del cuerpo.
static func afijos_detras(lienzo: CanvasItem, afijos: Array[DatosAfijoElite], segundos: float, radio: float) -> void:
	var anillos := 0
	for afijo in afijos:
		if afijo.efecto == DatosAfijoElite.Efecto.AURA_LENTA or afijo.efecto == DatosAfijoElite.Efecto.REPLICANTE:
			_afijo(lienzo, afijo, segundos)
		elif not afijo.efecto in AFIJOS:
			lienzo.draw_arc(Vector2.ZERO, radio + 6.0 + anillos * 5.0, 0.0, TAU, 32, afijo.color, 2.0)
			anillos += 1


## Lo que va encima del rootkit: las placas del Blindado.
static func afijos_encima(lienzo: CanvasItem, afijos: Array[DatosAfijoElite], segundos: float) -> void:
	for afijo in afijos:
		if afijo.efecto == DatosAfijoElite.Efecto.BLINDADO:
			_afijo(lienzo, afijo, segundos)


## Los iconos de sus afijos en fila y centrados, a tamaño real, a la altura y
## (encima de su nombre).
static func iconos(lienzo: CanvasItem, afijos: Array[DatosAfijoElite], y: float) -> void:
	const PASO := 20.0
	var ancho := afijos.size() * PASO - 4.0
	for i in afijos.size():
		if afijos[i].icono != null:
			lienzo.draw_texture(afijos[i].icono, Vector2(-ancho / 2.0 + i * PASO, y))


## El efecto de un afijo, teñido de su color, a los segundos que lleva el élite.
static func _afijo(lienzo: CanvasItem, afijo: DatosAfijoElite, segundos: float) -> void:
	var hoja: Texture2D = AFIJOS[afijo.efecto][0]
	var fotogramas: int = AFIJOS[afijo.efecto][1]
	var fotograma := int(segundos / AFIJOS[afijo.efecto][2]) % fotogramas
	var lado := Vector2(hoja.get_width() / float(fotogramas), hoja.get_height())
	lienzo.draw_texture_rect_region(hoja, Rect2(-lado / 2.0, lado), Rect2(Vector2(fotograma * lado.x, 0.0), lado), afijo.color)


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
