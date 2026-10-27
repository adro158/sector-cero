extends RefCounted

## El aspecto del lanzador: el mismo neón sobre fondo oscuro que el juego.
## Es una copia reducida de EstiloInterfaz (projecte/escenas/interfaz/): el
## lanzador es otro proyecto de Godot y no puede cargar ficheros del juego.
## Por eso los dibujos del lote 9 (el panel y los botones de 9 trozos, la
## fuente pixel art) están copiados aquí, junto a los suyos (el fondo, los
## iconos de las versiones y la barra de descarga).

const NEON := Color(0.0, 0.85, 0.95)
const TEXTO := Color(0.85, 0.9, 0.95)
const TEXTO_SUAVE := Color(0.55, 0.65, 0.75)
const FONDO := Color(0.03, 0.06, 0.1, 0.95)
const BIEN := Color(0.3, 1.0, 0.6)
const MAL := Color(1.0, 0.3, 0.4)

const PANEL := preload("res://panel.png")
## Cinco de 48x24: normal, encima, pulsado, foco y desactivado.
const BOTONES := preload("res://botones.png")
enum Boton { NORMAL, ENCIMA, PULSADO, FOCO, DESACTIVADO }
const FUENTE_PIXEL := preload("res://sector_cero_pixel.ttf")
## Seis de 16x16: descargada, por descargar y descargando (cuatro).
const ICONOS_VERSION := preload("res://versiones_iconos.png")
enum Icono { DESCARGADA, POR_DESCARGAR, DESCARGANDO }
const DESCARGA_MARCO := preload("res://descarga_marco.png")
const DESCARGA_RELLENO := preload("res://descarga_relleno.png")


static func tema() -> Theme:
	var fuente := SystemFont.new()
	fuente.font_names = PackedStringArray(["Consolas", "Cascadia Mono", "DejaVu Sans Mono", "Liberation Mono", "monospace"])

	var tema_nuevo := Theme.new()
	tema_nuevo.default_font = fuente
	tema_nuevo.default_font_size = 16
	tema_nuevo.set_color("font_color", "Label", TEXTO)
	tema_nuevo.set_stylebox("panel", "PanelContainer", caja(Color(NEON, 0.5)))
	for tipo in ["Button", "OptionButton"]:
		tema_nuevo.set_stylebox("normal", tipo, boton(Boton.NORMAL, NEON))
		tema_nuevo.set_stylebox("hover", tipo, boton(Boton.ENCIMA, NEON))
		tema_nuevo.set_stylebox("pressed", tipo, boton(Boton.PULSADO, NEON))
		tema_nuevo.set_stylebox("disabled", tipo, boton(Boton.DESACTIVADO, NEON))
		# El foco se dibuja encima del estado, un poco por fuera.
		var foco := boton(Boton.FOCO, Color.WHITE)
		foco.set_expand_margin_all(3.0)
		tema_nuevo.set_stylebox("focus", tipo, foco)
		tema_nuevo.set_color("font_color", tipo, TEXTO)
		tema_nuevo.set_color("font_hover_color", tipo, Color.WHITE)
		tema_nuevo.set_color("font_disabled_color", tipo, Color(TEXTO_SUAVE, 0.6))
	# La lista que se despliega al pulsar el selector de versión, con la
	# versión de encima marcada como un botón (antes salía el gris de Godot).
	tema_nuevo.set_stylebox("panel", "PopupMenu", caja(NEON, 8))
	tema_nuevo.set_stylebox("hover", "PopupMenu", boton(Boton.ENCIMA, NEON, 4))
	tema_nuevo.set_color("font_color", "PopupMenu", TEXTO)
	tema_nuevo.set_color("font_hover_color", "PopupMenu", Color.WHITE)
	return tema_nuevo


## Panel oscuro con borde del color dado, de 9 trozos.
static func caja(color: Color, margen: int = 20) -> StyleBoxTexture:
	return _textura(PANEL, 0, Vector2(48, 48), 12, color, margen)


static func boton(estado: Boton, color: Color, margen: int = 10) -> StyleBoxTexture:
	return _textura(BOTONES, estado, Vector2(48, 24), 8, color, margen)


## Un trozo de una tira de 9 trozos, teñido. Un color medio transparente se
## oscurece en vez de transparentarse, como en el juego.
static func _textura(tira: Texture2D, fotograma: int, lado: Vector2, margen_textura: int, color: Color, margen: int) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = tira
	estilo.region_rect = Rect2(Vector2(fotograma * lado.x, 0.0), lado)
	estilo.set_texture_margin_all(margen_textura)
	estilo.set_content_margin_all(margen)
	estilo.modulate_color = Color(color.r * color.a, color.g * color.a, color.b * color.a) if color.a < 1.0 else color
	return estilo


## El icono de una versión en el desplegable. Descargando, el fotograma que
## toque (de 0 a 3).
static func icono(cual: Icono, fotograma := 0) -> AtlasTexture:
	var trozo := AtlasTexture.new()
	trozo.atlas = ICONOS_VERSION
	trozo.region = Rect2((cual + fotograma) * 16.0, 0.0, 16.0, 16.0)
	return trozo


## La barra de una descarga, de 0 a 1: el marco y el relleno de 400x16, en
## grises y de neón, de 9 trozos para que quepa en lo que quede al lado de
## JUGAR (a 400 lo echaba de la ventana).
static func barra_descarga() -> TextureProgressBar:
	var barra := TextureProgressBar.new()
	barra.texture_under = DESCARGA_MARCO
	barra.texture_progress = DESCARGA_RELLENO
	barra.nine_patch_stretch = true
	for lado in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		barra.set_stretch_margin(lado, 4)
	barra.custom_minimum_size = Vector2(120, 16)
	barra.tint_progress = NEON
	barra.tint_under = Color(NEON, 0.8)
	barra.max_value = 1.0
	barra.step = 0.0
	return barra


## La fuente pixel art, sin suavizar (para JUGAR, como los títulos del juego).
static func fuente_pixel() -> FontFile:
	var fuente: FontFile = FUENTE_PIXEL
	fuente.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	fuente.hinting = TextServer.HINTING_NONE
	fuente.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	return fuente


static func etiqueta(texto: String, tamano: int = 16, color: Color = TEXTO) -> Label:
	var nueva := Label.new()
	nueva.text = texto
	nueva.add_theme_font_size_override("font_size", tamano)
	nueva.add_theme_color_override("font_color", color)
	return nueva
