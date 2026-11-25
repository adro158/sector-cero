extends RefCounted

## Las piezas del lote de la interfaz de skins (de Alan, 25/11;
## medios/sprites/cartera/, hechas por Claude con IA por encargo de Alan):
## recortar un fotograma de una hoja, el marco de carta teñido por categoría,
## las chapitas, los iconos de premio y el fondo de la ventana. Aquí y no en
## EstiloInterfaz, que es de Adam. Lo gris del lote se tiñe por código.
##
## Sin class_name: se carga con preload("res://escenas/skins/piezas_cartera.gd").

const RUTA := "res://medios/sprites/cartera/"
const MARCO_CARTA := preload(RUTA + "general/marco_carta.png")
const CHAPITAS := preload(RUTA + "general/chapitas_categoria.png")
const FONDO := preload(RUTA + "general/fondo_ventana.png")
const ICONOS_PREMIO := preload(RUTA + "pase/iconos_premio_32.png")
const ICONOS_PESTANA := preload(RUTA + "general/iconos_pestanas.png")
const ICONO_BITS := preload("res://medios/sprites/bits/bits_icono_grande.png")
## De la menos a la más trabajada, con su color (propuesta del lote del Mago).
const CATEGORIAS := {
	"C": Color("#8A97A6"),
	"B": Color("#59D98C"),
	"A": Color("#4DA6FF"),
	"S": Color("#FFC23D"),
	"S+": Color("#FF4DD2"),
}
## El orden de los iconos de premio en su hoja (los bits van aparte).
const PREMIOS := ["paquete", "titulo", "marco", "estela", "tema", "skin"]
## El orden de los iconos de las pestañas en su hoja.
const PESTANAS := ["ARMARIO", "PERFIL", "MISIONES", "PASE", "LOGROS", "TIENDA"]
const BITS := Color("#00E5FF")
const CONSEGUIDO := Color("#4DFF99")


## El fotograma número «indice» de una hoja horizontal de cuadros de ese lado.
static func fotograma(hoja: Texture2D, indice: int, lado: Vector2) -> AtlasTexture:
	var recorte := AtlasTexture.new()
	recorte.atlas = hoja
	recorte.region = Rect2(Vector2(indice * lado.x, 0.0), lado)
	return recorte


## Un dibujo de píxel a escala entera (x2 casi siempre), sin suavizar.
static func dibujo(textura: Texture2D, escala := 2, color := Color.WHITE) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = textura
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.custom_minimum_size = textura.get_size() * escala
	rect.size = rect.custom_minimum_size
	rect.self_modulate = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


## El marco de las cartas de skin (marco_carta.png: 5 de 32x32, C a S+, en
## grises): 9-slice de 10 px por lado, teñido del color de la categoría.
static func marco_carta(categoria: String, color: Color, margen := 6) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = MARCO_CARTA
	estilo.region_rect = Rect2(Vector2(32.0 * maxi(CATEGORIAS.keys().find(categoria), 0), 0.0), Vector2(32.0, 32.0))
	estilo.set_texture_margin_all(10.0)
	estilo.set_content_margin_all(margen)
	estilo.modulate_color = color
	return estilo


## La chapita de una categoría (C, B, A, S o S+), ya en su color.
static func chapita(categoria: String, escala := 1) -> TextureRect:
	return dibujo(fotograma(CHAPITAS, maxi(CATEGORIAS.keys().find(categoria), 0), Vector2(24.0, 12.0)), escala)


## El icono de 32x32 de un premio del pase (los bits, con su moneda).
static func icono_premio(tipo: String, color: Color, escala := 1) -> TextureRect:
	if tipo == "bits":
		return dibujo(ICONO_BITS, escala)
	return dibujo(fotograma(ICONOS_PREMIO, maxi(PREMIOS.find(tipo), 0), Vector2(32.0, 32.0)), escala, color)


## El icono de una pestaña de la ventana SKINS (16x16, en grises).
static func icono_pestana(nombre: String) -> AtlasTexture:
	return fotograma(ICONOS_PESTANA, maxi(PESTANAS.find(nombre), 0), Vector2(16.0, 16.0))


## El fondo de la ventana: la rejilla de circuito, repetida a x2.
static func fondo() -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = FONDO
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	rect.stretch_mode = TextureRect.STRETCH_TILE
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


## Un dibujo animado: los fotogramas de una hoja horizontal, uno detrás de
## otro, en bucle o una vez (y entonces avisa con «acabada» y se queda en el
## último). Es un TextureRect: se coloca como cualquier otro.
class Animada extends TextureRect:
	signal acabada

	var _hoja: Texture2D
	var _lado: Vector2
	var _segundos: float
	var _bucle: bool
	var _total: int
	var _tiempo := 0.0
	var _recorte := AtlasTexture.new()

	func _init(hoja: Texture2D, lado: Vector2, segundos: float, bucle: bool, escala := 2) -> void:
		_hoja = hoja
		_lado = lado
		_segundos = segundos
		_bucle = bucle
		_total = int(hoja.get_width() / lado.x)
		_recorte.atlas = hoja
		_recorte.region = Rect2(Vector2.ZERO, lado)
		texture = _recorte
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stretch_mode = TextureRect.STRETCH_SCALE
		custom_minimum_size = lado * escala
		size = custom_minimum_size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	## Vuelve a empezar desde el primer fotograma.
	func empezar() -> void:
		_tiempo = 0.0
		set_process(true)
		_poner(0)

	## El fotograma por el que va (para lo que tiene que pasar a mitad).
	func cuadro() -> int:
		return mini(int(_tiempo / _segundos), _total - 1)

	func _process(delta: float) -> void:
		_tiempo += delta
		var indice := int(_tiempo / _segundos)
		if _bucle:
			_poner(indice % _total)
		elif indice >= _total:
			_poner(_total - 1)
			set_process(false)
			acabada.emit()
		else:
			_poner(indice)

	func _poner(indice: int) -> void:
		_recorte.region = Rect2(Vector2(indice * _lado.x, 0.0), _lado)
