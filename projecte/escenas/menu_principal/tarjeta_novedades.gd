extends Button

## La tarjeta de novedades del menú (24/11): lo nuevo de esta versión, el
## mismo texto que enseña el lanzador. La Action lo copia de
## documentacio/novedades/<versión>.txt a res://novedades.txt al publicar
## (publicar_release.yml); en desarrollo no existe y la tarjeta no sale.
##
## Con la insignia NUEVO, que parpadea, mientras la versión no sea la de la
## opción "novedades_vistas": al pulsar la tarjeta o al empezar una partida
## (ventana_jugar.gd, marcar_vistas) se apunta y ya no sale.
##
## Sin class_name: la crea el menú con preload.

const Piezas := preload("res://escenas/menu_principal/piezas_menu.gd")
const RUTA := "res://novedades.txt"
## Las líneas que caben (las novedades son una frase por línea, con «- »).
const LINEAS := 3
const ANCHO := 340.0

var _nuevo: TextureRect
var _pestana: Control
var _tiempo := 0.0


func _ready() -> void:
	visible = FileAccess.file_exists(RUTA)
	if not visible:
		return
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for estado in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(estado, Piezas.novedades(EstiloInterfaz.NEON if estado != "normal" else EstiloInterfaz.TEXTO_SUAVE))
	var textos := VBoxContainer.new()
	textos.add_theme_constant_override("separation", 4)
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.position = Vector2(18.0, 18.0)
	add_child(textos)
	var cabecera := HBoxContainer.new()
	cabecera.add_theme_constant_override("separation", 10)
	cabecera.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cabecera.add_child(EstiloInterfaz.etiqueta("Versión %s" % Version.ACTUAL, 22, EstiloInterfaz.NEON))
	_nuevo = Piezas.dibujo(Piezas.NUEVO, 0, Vector2(32.0, 12.0), 2.0)
	_nuevo.visible = GestorGuardado.opcion("novedades_vistas") != Version.ACTUAL
	cabecera.add_child(_nuevo)
	textos.add_child(cabecera)
	for linea in _lineas():
		var texto := EstiloInterfaz.etiqueta("· " + linea, 13)
		texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texto.custom_minimum_size.x = ANCHO - 36.0
		texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(texto)
	textos.reset_size()
	custom_minimum_size = Vector2(ANCHO, textos.size.y + 32.0)
	# La pestaña «NOVEDADES», 10 px por encima del marco y 8 a la derecha de
	# su esquina (sus 2 filas de abajo tapan el borde).
	_pestana = Control.new()
	_pestana.position = Vector2(8.0, -10.0)
	_pestana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pestana.draw.connect(_dibujar_pestana)
	add_child(_pestana)
	pressed.connect(marcar_vistas)


## Las primeras líneas del fichero, sin el «- » del principio.
func _lineas() -> Array:
	var lineas := []
	for linea in FileAccess.get_file_as_string(RUTA).split("\n", false):
		lineas.append(linea.trim_prefix("- ").strip_edges())
		if lineas.size() == LINEAS:
			break
	return lineas


## Apunta que las novedades de esta versión ya se han visto.
static func marcar_vistas() -> void:
	GestorGuardado.cambiar_opcion("novedades_vistas", Version.ACTUAL)


## La pestaña de 3 trozos (6, 12 que se estira y 6) con «NOVEDADES» en la
## fuente pixel a 11, con la línea de las letras en y = 10.
func _dibujar_pestana() -> void:
	var fuente := EstiloInterfaz.fuente_pixel()
	var ancho := fuente.get_string_size("NOVEDADES", HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 16.0
	var tira := Piezas.NOVEDADES_PESTANA
	var color := EstiloInterfaz.NEON
	_pestana.draw_texture_rect_region(tira, Rect2(0.0, 0.0, 6.0, 12.0), Rect2(0.0, 0.0, 6.0, 12.0), color)
	_pestana.draw_texture_rect_region(tira, Rect2(6.0, 0.0, ancho - 12.0, 12.0), Rect2(6.0, 0.0, 12.0, 12.0), color)
	_pestana.draw_texture_rect_region(tira, Rect2(ancho - 6.0, 0.0, 6.0, 12.0), Rect2(18.0, 0.0, 6.0, 12.0), color)
	_pestana.draw_string(fuente, Vector2(8.0, 10.0), "NOVEDADES", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)


func _process(delta: float) -> void:
	if not visible:
		return
	# NUEVO parpadea (medio segundo cada fotograma) hasta que se ven.
	_nuevo.visible = GestorGuardado.opcion("novedades_vistas") != Version.ACTUAL
	_tiempo += delta
	_nuevo.texture.region.position.x = (int(_tiempo / 0.5) % 2) * 32.0
