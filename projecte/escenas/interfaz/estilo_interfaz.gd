class_name EstiloInterfaz
extends RefCounted

## Estilo común de toda la interfaz: colores neón, fuente monoespaciada y
## aspecto de paneles y botones. Está en un solo sitio para que el menú, el
## HUD, el panel de mejoras y la pantalla final se vean iguales, y para no
## repetir la misma configuración en cada uno.

const NEON := Color(0.0, 0.85, 0.95)
const TEXTO := Color(0.85, 0.9, 0.95)
const TEXTO_SUAVE := Color(0.55, 0.65, 0.75)
const FONDO := Color(0.03, 0.06, 0.1, 0.95)
const VICTORIA := Color(0.3, 1.0, 0.6)
const DERROTA := Color(1.0, 0.3, 0.4)

static var _tema: Theme


## Tema para asignar al nodo raíz de cada pantalla: sus hijos lo heredan.
static func tema() -> Theme:
	if _tema != null:
		return _tema

	var fuente := SystemFont.new()
	fuente.font_names = PackedStringArray(["Consolas", "Cascadia Mono", "DejaVu Sans Mono", "Liberation Mono", "monospace"])

	_tema = Theme.new()
	_tema.default_font = fuente
	_tema.default_font_size = 16
	_tema.set_color("font_color", "Label", TEXTO)
	_tema.set_stylebox("panel", "PanelContainer", caja(NEON))

	_tema.set_stylebox("normal", "Button", caja(Color(NEON, 0.35), 10))
	_tema.set_stylebox("hover", "Button", caja(NEON, 10))
	_tema.set_stylebox("pressed", "Button", caja(Color.WHITE, 10))
	_tema.set_stylebox("focus", "Button", caja(NEON, 10))
	_tema.set_color("font_color", "Button", TEXTO)
	_tema.set_color("font_hover_color", "Button", Color.WHITE)

	# Deslizadores de volumen: carril oscuro que se llena de neón.
	var carril := StyleBoxFlat.new()
	carril.bg_color = Color(0.1, 0.15, 0.2)
	carril.content_margin_top = 4
	carril.content_margin_bottom = 4
	var lleno := carril.duplicate() as StyleBoxFlat
	lleno.bg_color = NEON
	_tema.set_stylebox("slider", "HSlider", carril)
	_tema.set_stylebox("grabber_area", "HSlider", lleno)
	_tema.set_stylebox("grabber_area_highlight", "HSlider", lleno)
	_tema.set_color("font_color", "CheckButton", TEXTO)

	# Pestañas de la ventana de reglas.
	_tema.set_stylebox("panel", "TabContainer", caja(Color(NEON, 0.35), 18))
	_tema.set_stylebox("tab_selected", "TabContainer", caja(NEON, 8))
	_tema.set_stylebox("tab_unselected", "TabContainer", caja(Color(NEON, 0.25), 8))
	_tema.set_stylebox("tab_hovered", "TabContainer", caja(Color(NEON, 0.6), 8))
	_tema.set_stylebox("tab_focus", "TabContainer", StyleBoxEmpty.new())
	_tema.set_color("font_selected_color", "TabContainer", NEON)
	_tema.set_color("font_unselected_color", "TabContainer", TEXTO_SUAVE)
	_tema.set_color("font_hovered_color", "TabContainer", TEXTO)
	return _tema


## Botón con el tamaño común de los menús. La acción se conecta a pressed.
static func boton(texto: String, accion: Callable, ancho: float = 240.0) -> Button:
	var nuevo := Button.new()
	nuevo.text = texto
	nuevo.custom_minimum_size = Vector2(ancho, 44)
	nuevo.pressed.connect(accion)
	return nuevo


## Panel oscuro con borde de neón del color dado.
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


## Fondo que oscurece lo que hay detrás y centra un panel encima. Devuelve el
## fondo; el contenido va dentro de la caja vertical que se pasa.
static func ventana_centrada(caja_vertical: VBoxContainer, color_borde: Color = NEON) -> ColorRect:
	var fondo := ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.0, 0.65)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", caja(color_borde, 28))
	centro.add_child(panel)

	caja_vertical.add_theme_constant_override("separation", 14)
	panel.add_child(caja_vertical)
	return fondo
