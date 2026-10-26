extends RefCounted

## Cómo se viste la tarjeta de una evolución en el panel de subida de nivel
## (panel_mejoras.gd): de su personaje, de su color, con él dibujado con el arma
## nueva, para que se note que no es una mejora más. El latido del borde lo
## lleva el panel, que es un nodo y puede tener su tween.
##
## Sin class_name: se carga con preload, como embestida_horda.gd.

## Para saber de quién es cada evolución: del que lleva su arma base.
const PERSONAJES: Array[DatosPersonaje] = [
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
## Cada personaje se dibuja de 64x72 en su hoja; el primero es de frente.
const LADO_PERSONAJE := Vector2(64.0, 72.0)


## El personaje de una evolución, o null si es una mejora normal.
static func personaje_de(mejora: DatosMejora) -> DatosPersonaje:
	if mejora.efecto != DatosMejora.Efecto.EVOLUCIONAR_ARMA:
		return null
	for personaje in PERSONAJES:
		if personaje.arma == mejora.arma_base:
			return personaje
	return null


## Con un personaje, la tarjeta pasa a ser suya; sin él, vuelve a la de siempre.
## Devuelve sus bordes con su color, [estilo, color], para que el panel los haga
## latir (vacío si es una mejora normal).
static func vestir(tarjeta: Button, personaje: DatosPersonaje) -> Array:
	var contenido := tarjeta.get_child(0)
	var nombre: Label = contenido.get_child(2)
	var nivel: Label = contenido.get_child(3)
	if personaje == null:
		for estado in ["normal", "hover", "focus", "pressed"]:
			tarjeta.remove_theme_stylebox_override(estado)
		nombre.add_theme_color_override("font_color", EstiloInterfaz.NEON)
		nivel.add_theme_color_override("font_color", EstiloInterfaz.VICTORIA)
		return []

	# El personaje de frente, con el arma evolucionada.
	var retrato := AtlasTexture.new()
	retrato.atlas = personaje.hoja_evolucion if personaje.hoja_evolucion != null else personaje.hoja
	retrato.region = Rect2(Vector2.ZERO, LADO_PERSONAJE)
	contenido.get_child(1).texture = retrato
	nivel.text = "EVOLUCIÓN DEL %s" % personaje.nombre.to_upper()
	nombre.add_theme_color_override("font_color", personaje.color)
	nivel.add_theme_color_override("font_color", personaje.color)

	# El panel de borde grueso (lote 9), teñido de su color: el fondo sale
	# oscuro de su color, y con el ratón encima, un poco más claro.
	var estilo := EstiloInterfaz.caja_evolucion(personaje.color, false)
	var encima := EstiloInterfaz.caja_evolucion(personaje.color, true)
	tarjeta.add_theme_stylebox_override("normal", estilo)
	for estado in ["hover", "focus", "pressed"]:
		tarjeta.add_theme_stylebox_override(estado, encima)
	return [[estilo, personaje.color], [encima, personaje.color]]
