extends Control

## La carta de la skin que ha tocado en un paquete (de Alan, 25/11; la usa
## apertura_paquete.gd): el marco de su categoría con el retrato, que se
## descifra de arriba abajo en 4 pasos con una línea de datos en el borde; la
## chapita NUEVA o REPETIDA, y debajo el nombre, que se descifra letra a letra
## entre caracteres al azar. Mide lo que la carta (192x256, a x2); el texto
## sale por debajo, centrado en ANCHO_TEXTO.
##
## Sin class_name: la crea apertura_paquete.gd con preload.

const Piezas := preload("res://escenas/skins/piezas_cartera.gd")
const Tienda := preload("res://globales/tienda.gd")
const RUTA := "res://medios/sprites/cartera/paquete/"
const LADO := Vector2(192.0, 256.0)
const ANCHO_TEXTO := 480.0
const RUIDO := "01#%&$@<>/=+ABCDEF"

## Lo que no ha bajado todavía no se ve: crece hacia abajo.
var _recorte: Control
var _marco: TextureRect
var _retrato: TextureRect
var _linea: ColorRect
var _chapita: TextureRect
var _nombre: Label
var _detalle: Label
## En la placa de la carta (x=12..83, y=92..106 a x1), de quién es.
var _placa: Label
var _texto := ""
## Cuánto lleva descifrándose el nombre, y cuánto tarda (-1: no empieza).
var _nombre_lleva := -1.0
var _nombre_dura := 1.0


func _ready() -> void:
	size = LADO
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_recorte = Control.new()
	_recorte.clip_contents = true
	_recorte.size = Vector2(LADO.x, 0.0)
	add_child(_recorte)
	_marco = Piezas.dibujo(load(RUTA + "marco_revelacion_c.png"))
	_recorte.add_child(_marco)
	# El hueco del retrato, en (16, 22) de la carta de 96x128 (a x2).
	_retrato = Piezas.dibujo(PlaceholderTexture2D.new())
	_retrato.position = Vector2(32.0, 44.0)
	_retrato.size = Vector2(128.0, 128.0)
	_recorte.add_child(_retrato)
	_linea = ColorRect.new()
	_linea.color = EstiloInterfaz.NEON
	_linea.size = Vector2(LADO.x, 4.0)
	_recorte.add_child(_linea)
	_placa = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO)
	_placa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placa.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_placa.position = Vector2(24.0, 184.0)
	_placa.size = Vector2(144.0, 30.0)
	_recorte.add_child(_placa)
	_chapita = Piezas.dibujo(load(RUTA + "chapita_nueva.png"))
	add_child(_chapita)
	_nombre = _etiqueta(LADO.y + 10.0, 24)
	_detalle = _etiqueta(LADO.y + 44.0, 16)


## Prepara la carta de esa skin, todavía sin descifrar.
func preparar(resultado: Dictionary, color: Color) -> void:
	var skin: Resource = Tienda.DATOS[resultado.personaje].skin(resultado.numero)
	_texto = skin.nombre.to_upper()
	_marco.texture = load(RUTA + "marco_revelacion_%s.png" % resultado.categoria.to_lower().replace("+", "_mas"))
	_retrato.texture = skin.retrato
	_chapita.texture = load(RUTA + ("chapita_nueva.png" if resultado.nueva else "chapita_repetida.png"))
	_chapita.size = _chapita.texture.get_size() * 2.0
	_chapita.position = Vector2(LADO.x - _chapita.size.x * 0.5, -_chapita.size.y - 4.0)
	_chapita.visible = false
	_nombre.text = ""
	_nombre.add_theme_color_override("font_color", color)
	_placa.text = resultado.personaje.to_upper()
	var como := " · ¡NUEVA!" if resultado.nueva else " · repetida: +%d bits" % resultado.devueltos
	_detalle.text = "categoría %s%s" % [resultado.categoria, como]
	_detalle.visible = false
	_nombre_lleva = -1.0
	descifrar(0)


## Paso de 0 (nada) a 4 (entera), con la línea de datos en el borde.
func descifrar(paso: int) -> void:
	_recorte.size.y = LADO.y * paso / 4.0
	_linea.position.y = _recorte.size.y - 4.0
	_linea.visible = paso > 0 and paso < 4


## Empieza a descifrar el nombre, que tarda esos segundos.
func descifrar_nombre(segundos: float) -> void:
	_nombre_lleva = 0.0
	_nombre_dura = segundos


## Todo descifrado: la carta entera, el nombre, la chapita y el detalle.
func terminar() -> void:
	descifrar(4)
	_nombre_lleva = -1.0
	_nombre.text = _texto
	_chapita.visible = true
	_detalle.visible = true


func _process(delta: float) -> void:
	if _linea.visible:
		_linea.modulate.a = randf_range(0.4, 1.0)
	if _nombre_lleva < 0.0:
		return
	_nombre_lleva += delta
	var hechas := mini(int(_nombre_lleva / _nombre_dura * _texto.length()), _texto.length())
	var texto := _texto.substr(0, hechas)
	for i in range(hechas, _texto.length()):
		texto += " " if _texto[i] == " " else RUIDO[randi() % RUIDO.length()]
	_nombre.text = texto


func _etiqueta(y: float, tamano: int) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta("", tamano, EstiloInterfaz.TEXTO)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.position = Vector2((LADO.x - ANCHO_TEXTO) / 2.0, y)
	etiqueta.size = Vector2(ANCHO_TEXTO, 28.0)
	add_child(etiqueta)
	return etiqueta
