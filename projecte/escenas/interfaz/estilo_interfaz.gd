class_name EstiloInterfaz
extends RefCounted

## Estilo común de toda la interfaz: colores neón, fuente monoespaciada y
## aspecto de paneles y botones. Está en un solo sitio para que el menú, el
## HUD, el panel de mejoras y la pantalla final se vean iguales, y para no
## repetir la misma configuración en cada uno.
##
## Desde el lote 9 los paneles, los botones, las pestañas y los controles de
## las opciones son de pixel art: texturas de 9 trozos (StyleBoxTexture) en
## grises, teñidas con el color de cada sitio (modulate_color). Antes eran
## StyleBoxFlat con las esquinas redondeadas, que no parecían del juego.

const NEON := Color(0.0, 0.85, 0.95)
const TEXTO := Color(0.85, 0.9, 0.95)
const TEXTO_SUAVE := Color(0.55, 0.65, 0.75)
const FONDO := Color(0.03, 0.06, 0.1, 0.95)
const VICTORIA := Color(0.3, 1.0, 0.6)
const DERROTA := Color(1.0, 0.3, 0.4)
## Con la opción «Texto grande» (accesibilidad, mejoras propuestas, jugabilidad
## 12), los textos salen así de más grandes. Se mira al crear cada pantalla: al
## cambiar la opción, se nota al volver a abrirla.
const ESCALA_TEXTO_GRANDE := 1.25

const PANEL := preload("res://medios/interfaz/panel.png")
## Dos fotogramas de 48x48: normal y encima.
const PANEL_EVOLUCION := preload("res://medios/interfaz/panel_evolucion.png")
## Cinco de 48x24, en el orden de Boton.
const BOTONES := preload("res://medios/interfaz/botones.png")
enum Boton { NORMAL, ENCIMA, PULSADO, FOCO, DESACTIVADO }
## Dos de 32x24: seleccionada y sin seleccionar.
const PESTANAS := preload("res://medios/interfaz/pestanas.png")
## Estos dos van ya de color: apagado y encendido; normal y encima.
const INTERRUPTOR := preload("res://medios/interfaz/interruptor.png")
const AGARRE := preload("res://medios/interfaz/deslizador_agarre.png")
## Tres de 8x24: carril, agarre y agarre encima.
const DESPLAZAMIENTO := preload("res://medios/interfaz/desplazamiento.png")

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

	_tema.set_stylebox("normal", "Button", boton_estilo(Boton.NORMAL, NEON))
	_tema.set_stylebox("hover", "Button", boton_estilo(Boton.ENCIMA, NEON))
	_tema.set_stylebox("pressed", "Button", boton_estilo(Boton.PULSADO, NEON))
	_tema.set_stylebox("disabled", "Button", boton_estilo(Boton.DESACTIVADO, NEON))
	# El foco se dibuja encima del estado: con el ratón encima de un botón y el
	# mando en otro, se distinguen (antes eran el mismo estilo).
	var foco := boton_estilo(Boton.FOCO, Color.WHITE)
	foco.set_expand_margin_all(3.0)
	_tema.set_stylebox("focus", "Button", foco)
	_tema.set_color("font_color", "Button", TEXTO)
	_tema.set_color("font_hover_color", "Button", Color.WHITE)
	_tema.set_color("font_focus_color", "Button", Color.WHITE)
	_tema.set_color("font_disabled_color", "Button", Color(TEXTO_SUAVE, 0.6))

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
	_tema.set_icon("grabber", "HSlider", _trozo(AGARRE, 0, Vector2(12, 20)))
	_tema.set_icon("grabber_highlight", "HSlider", _trozo(AGARRE, 1, Vector2(12, 20)))
	_tema.set_color("font_color", "CheckButton", TEXTO)
	_tema.set_icon("unchecked", "CheckButton", _trozo(INTERRUPTOR, 0, Vector2(80, 40)))
	_tema.set_icon("checked", "CheckButton", _trozo(INTERRUPTOR, 1, Vector2(80, 40)))

	# Barras de desplazamiento (reglas y versiones), finas y de neón. El ancho
	# de la barra sale de los márgenes de contenido: 4 y 4, los 8 del dibujo.
	_tema.set_stylebox("scroll", "VScrollBar", _textura(DESPLAZAMIENTO, 0, Vector2(8, 24), 3, Color(NEON, 0.6), 4))
	_tema.set_stylebox("grabber", "VScrollBar", _textura(DESPLAZAMIENTO, 1, Vector2(8, 24), 3, NEON, 4))
	_tema.set_stylebox("grabber_highlight", "VScrollBar", _textura(DESPLAZAMIENTO, 2, Vector2(8, 24), 3, NEON, 4))
	_tema.set_stylebox("grabber_pressed", "VScrollBar", _textura(DESPLAZAMIENTO, 2, Vector2(8, 24), 3, Color.WHITE, 4))
	# Los interruptores, sin la caja de botón alrededor: solo el dibujo. Su foco,
	# sin margen: el botón mide lo que el más grande de sus estilos, y cada fila
	# de las opciones crecía 20 px.
	for estado in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		_tema.set_stylebox(estado, "CheckButton", StyleBoxEmpty.new())
	var foco_interruptor := foco.duplicate() as StyleBoxTexture
	foco_interruptor.set_content_margin_all(0)
	_tema.set_stylebox("focus", "CheckButton", foco_interruptor)
	# El nombre del ranking y las ayudas de las mejoras, con el panel.
	_tema.set_stylebox("normal", "LineEdit", caja(Color(NEON, 0.6), 8))
	_tema.set_stylebox("focus", "LineEdit", caja(NEON, 8))
	_tema.set_stylebox("panel", "TooltipPanel", caja(NEON, 8))

	# Pestañas de la ventana de reglas.
	_tema.set_stylebox("panel", "TabContainer", caja(Color(NEON, 0.35), 18))
	_tema.set_stylebox("tab_selected", "TabContainer", _textura(PESTANAS, 0, Vector2(32, 24), 8, NEON, 10))
	_tema.set_stylebox("tab_unselected", "TabContainer", _textura(PESTANAS, 1, Vector2(32, 24), 8, Color(NEON, 0.5), 10))
	_tema.set_stylebox("tab_hovered", "TabContainer", _textura(PESTANAS, 1, Vector2(32, 24), 8, NEON, 10))
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


## Panel oscuro con borde del color dado, de 9 trozos.
static func caja(color_borde: Color, margen: int = 20) -> StyleBoxTexture:
	return _textura(PANEL, 0, Vector2(48, 48), 12, color_borde, margen)


## El panel de borde grueso de las evoluciones: normal o con el ratón encima.
static func caja_evolucion(color: Color, encima: bool, margen: int = 10) -> StyleBoxTexture:
	return _textura(PANEL_EVOLUCION, 1 if encima else 0, Vector2(48, 48), 12, color, margen)


static func boton_estilo(estado: Boton, color: Color) -> StyleBoxTexture:
	return _textura(BOTONES, estado, Vector2(48, 24), 8, color, 10)


## Un trozo de una tira de 9 trozos, teñido. Un color medio transparente se
## oscurece en vez de transparentarse: si no, se vería a través también el
## fondo del panel, y antes solo se apagaba el borde.
static func _textura(tira: Texture2D, fotograma: int, lado: Vector2, margen_textura: int, color: Color, margen: int = 0) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = tira
	estilo.region_rect = Rect2(Vector2(fotograma * lado.x, 0.0), lado)
	estilo.set_texture_margin_all(margen_textura)
	estilo.set_content_margin_all(margen)
	estilo.modulate_color = Color(color.r * color.a, color.g * color.a, color.b * color.a) if color.a < 1.0 else color
	return estilo


static func _trozo(tira: Texture2D, fotograma: int, lado: Vector2) -> AtlasTexture:
	var trozo := AtlasTexture.new()
	trozo.atlas = tira
	trozo.region = Rect2(Vector2(fotograma * lado.x, 0.0), lado)
	return trozo


static func etiqueta(texto: String, tamano: int = 16, color: Color = TEXTO) -> Label:
	var nueva := Label.new()
	nueva.text = texto
	nueva.add_theme_font_size_override("font_size", tamano_texto(tamano))
	nueva.add_theme_color_override("font_color", color)
	return nueva


## El tamaño de letra que toca, con «Texto grande» o sin él. Todos los textos de
## la interfaz pasan por aquí.
static func tamano_texto(tamano: int) -> int:
	return roundi(tamano * ESCALA_TEXTO_GRANDE) if GestorGuardado.opcion("texto_grande") else tamano


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
