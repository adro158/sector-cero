extends VBoxContainer

## La parte izquierda del armario (armario.gd): el personaje andando con la
## skin que se está mirando, su nombre, su categoría, su frase y PONÉRSELA.
## Aparte de armario.gd para que ese no pase de ~200 líneas.
##
## Sin class_name: la crea armario.gd con preload.

signal ponersela

const LADO := Vector2(64.0, 72.0)
const COLUMNAS := 6
## Lo mismo que en la partida (controlador_jugador.gd).
const FOTOGRAMAS_POR_SEGUNDO := 7.7
const ANCHO := 260.0

var _recorte := AtlasTexture.new()
var _tiempo := 0.0
var _nombre: Label
var _categoria: Label
var _frase: Label
var _poner: Button


func _ready() -> void:
	custom_minimum_size.x = ANCHO
	add_theme_constant_override("separation", 6)
	var dibujo := TextureRect.new()
	dibujo.texture = _recorte
	dibujo.custom_minimum_size = LADO * 3.0
	dibujo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dibujo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dibujo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(dibujo)
	# 18 y no 22: desde 20 se usa la fuente pixel, que separa las íes.
	_nombre = EstiloInterfaz.etiqueta("", 18)
	_categoria = EstiloInterfaz.etiqueta("", 14)
	_frase = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_frase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_frase.custom_minimum_size = Vector2(ANCHO, 60)
	for etiqueta in [_nombre, _categoria, _frase]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(etiqueta)
	_poner = EstiloInterfaz.boton("PONÉRSELA", ponersela.emit, ANCHO)
	add_child(_poner)


## Enseña ese aspecto: hoja de andar, nombre, categoría (con su color) y
## frase. puesta: si ya la lleva; disponible: si la tiene (si no, no se puede
## poner).
func mirar(hoja: Texture2D, nombre: String, categoria: String, color: Color, frase: String, puesta: bool, disponible: bool) -> void:
	_recorte.atlas = hoja
	_nombre.text = nombre
	_categoria.text = categoria
	_categoria.add_theme_color_override("font_color", color)
	_frase.text = frase
	_poner.text = "LA LLEVAS PUESTA" if puesta else "PONÉRSELA"
	_poner.disabled = puesta or not disponible


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_tiempo += delta
	# Andando en el sitio, de frente, como en el menú (personajes_menu.gd).
	var columna := int(_tiempo * FOTOGRAMAS_POR_SEGUNDO) % COLUMNAS
	var fila := Direcciones8.fila(Vector2.DOWN)
	_recorte.region = Rect2(Vector2(columna * LADO.x, fila * LADO.y), LADO)
