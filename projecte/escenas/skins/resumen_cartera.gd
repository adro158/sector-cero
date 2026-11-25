extends RefCounted

## Lo ganado en la partida, para la pantalla final (de Alan, 19/11): los bits
## y los puntos del pase, la racha, las misiones completadas y, desde la fase
## 3, los niveles del pase y sus premios. La pantalla final (de Adam) solo lo
## coloca: crear(Cartera.actual.ultima_ganancia()).
##
## Sin class_name: se carga con preload.

const BITS := Color("#00E5FF")
const HECHA := Color("#4DFF99")
const ICONO := preload("res://medios/sprites/bits/bits_icono.png")


static func crear(ganancia: Dictionary) -> VBoxContainer:
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 2)
	if ganancia.get("sin_recompensa", false):
		caja.add_child(_linea("Con el menú de desarrollador no se ganan bits ni puntos del pase", 13, EstiloInterfaz.TEXTO_SUAVE))
		return caja
	var texto := "+%d bits  ·  +%d puntos del pase" % [ganancia.bits, ganancia.puntos]
	if ganancia.get("racha", 0) > 0:
		texto += "  (racha: +%d)" % ganancia.racha
	# Con la moneda delante, a x2 (lote_bits).
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_child(_icono(ICONO, 2.0))
	fila.add_child(_linea(texto, 16, BITS))
	caja.add_child(fila)
	for mision in ganancia.get("misiones", []):
		caja.add_child(_linea("Misión cumplida: %s (+%d bits)" % [mision.texto, mision.bits], 14, HECHA))
	for nivel in ganancia.get("niveles", []):
		caja.add_child(_linea("Pase: nivel %d" % nivel, 14, EstiloInterfaz.NEON))
	for premio in ganancia.get("premios", []):
		caja.add_child(_linea("Conseguido: %s" % premio.nombre, 14, EstiloInterfaz.VICTORIA))
	return caja


static func _linea(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, tamano, color)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return etiqueta


## Una imagen de píxel duro a escala entera (sin suavizar).
static func _icono(textura: Texture2D, escala: float) -> TextureRect:
	var icono := TextureRect.new()
	icono.texture = textura
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.custom_minimum_size = textura.get_size() * escala
	icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return icono
