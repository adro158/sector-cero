extends RefCounted

## El aspecto del lanzador: el mismo neón sobre fondo oscuro que el juego.
## Es una copia reducida de EstiloInterfaz (projecte/escenas/interfaz/): el
## lanzador es otro proyecto de Godot y no puede cargar ficheros del juego.

const NEON := Color(0.0, 0.85, 0.95)
const TEXTO := Color(0.85, 0.9, 0.95)
const TEXTO_SUAVE := Color(0.55, 0.65, 0.75)
const FONDO := Color(0.03, 0.06, 0.1, 0.95)
const BIEN := Color(0.3, 1.0, 0.6)
const MAL := Color(1.0, 0.3, 0.4)


static func tema() -> Theme:
	var fuente := SystemFont.new()
	fuente.font_names = PackedStringArray(["Consolas", "Cascadia Mono", "DejaVu Sans Mono", "Liberation Mono", "monospace"])

	var tema_nuevo := Theme.new()
	tema_nuevo.default_font = fuente
	tema_nuevo.default_font_size = 16
	tema_nuevo.set_color("font_color", "Label", TEXTO)
	tema_nuevo.set_stylebox("panel", "PanelContainer", caja(Color(NEON, 0.5)))
	for tipo in ["Button", "OptionButton"]:
		tema_nuevo.set_stylebox("normal", tipo, caja(Color(NEON, 0.35), 10))
		tema_nuevo.set_stylebox("hover", tipo, caja(NEON, 10))
		tema_nuevo.set_stylebox("pressed", tipo, caja(Color.WHITE, 10))
		tema_nuevo.set_stylebox("focus", tipo, caja(NEON, 10))
		tema_nuevo.set_stylebox("disabled", tipo, caja(Color(TEXTO_SUAVE, 0.3), 10))
		tema_nuevo.set_color("font_color", tipo, TEXTO)
		tema_nuevo.set_color("font_hover_color", tipo, Color.WHITE)
	# La lista que se despliega al pulsar el selector de versión.
	tema_nuevo.set_stylebox("panel", "PopupMenu", caja(NEON, 8))
	tema_nuevo.set_color("font_color", "PopupMenu", TEXTO)
	tema_nuevo.set_color("font_hover_color", "PopupMenu", NEON)
	return tema_nuevo


## Panel oscuro con borde del color dado.
static func caja(color_borde: Color, margen: int = 20) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = FONDO
	estilo.border_color = color_borde
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	estilo.set_content_margin_all(margen)
	return estilo


static func etiqueta(texto: String, tamano: int = 16, color: Color = TEXTO) -> Label:
	var nueva := Label.new()
	nueva.text = texto
	nueva.add_theme_font_size_override("font_size", tamano)
	nueva.add_theme_color_override("font_color", color)
	return nueva
