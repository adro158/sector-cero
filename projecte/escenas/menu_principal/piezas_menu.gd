extends RefCounted

## Las piezas del menú principal (lote del menú, 24/11, hechas por Claude en el
## chat): los recortes de las tiras, el botón grande, las tarjetas, la cuenta,
## la peana, el cartel y las novedades. Casi todas van en grises y se tiñen
## con el color que toque; los márgenes de 9 trozos, en LEEME del lote. El
## marco de las ventanas, que usan todas, está en EstiloInterfaz.
##
## Sin class_name: se carga con preload.

## El orden de menu_iconos.png (17 de 16x16).
enum Icono { JUGAR, COLECCION, PERFIL, OPCIONES, SALIR, SOLO, EN_RED, AYUDA, VERSION,
	NOVEDADES, CUENTA, RANKING, PARTIDAS, ARMARIO, MISIONES, PASE, TIENDA }
## Los fotogramas de menu_tarjeta.png.
enum Tarjeta { NORMAL, ENCIMA, ELEGIDA }

const BOTON_GRANDE := preload("res://medios/interfaz/menu_boton_grande.png")
const ICONOS := preload("res://medios/interfaz/menu_iconos.png")
const TARJETA := preload("res://medios/interfaz/menu_tarjeta.png")
## Ya van de color: FÁCIL, MEDIA y DIFÍCIL (3 de 24x24).
const DIFICULTAD := preload("res://medios/interfaz/dificultad_iconos.png")
const CUENTA := preload("res://medios/interfaz/menu_cuenta.png")
const PEANA := preload("res://medios/interfaz/peana.png")
const CARTEL := preload("res://medios/interfaz/cartel.png")
const CARTEL_PICO := preload("res://medios/interfaz/cartel_pico.png")
const NOVEDADES := preload("res://medios/interfaz/novedades_marco.png")
const NOVEDADES_PESTANA := preload("res://medios/interfaz/novedades_pestana.png")
## Ya va de color: encendida y al revés, para que parpadee (2 de 32x12).
const NUEVO := preload("res://medios/interfaz/novedades_nuevo.png")
## JUGAR y EMPEZAR van en verde; los demás botones, apagados y en cian encima.
const VERDE_CLARO := Color(0.6, 1.0, 0.8)


## Un fotograma de una tira, como textura suelta.
static func trozo(tira: Texture2D, fotograma: int, lado: Vector2) -> AtlasTexture:
	var nuevo := AtlasTexture.new()
	nuevo.atlas = tira
	nuevo.region = Rect2(Vector2(fotograma * lado.x, 0.0), lado)
	return nuevo


static func icono(cual: Icono) -> AtlasTexture:
	return trozo(ICONOS, cual, Vector2(16.0, 16.0))


## Un dibujo de una tira a escala entera, teñido y sin suavizar.
static func dibujo(tira: Texture2D, fotograma: int, lado: Vector2, escala: float, color: Color = Color.WHITE) -> TextureRect:
	var nuevo := TextureRect.new()
	nuevo.texture = trozo(tira, fotograma, lado)
	nuevo.custom_minimum_size = lado * escala
	nuevo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nuevo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	nuevo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	nuevo.modulate = color
	return nuevo


## El botón grande (5 de 64x32: normal, encima, pulsado, foco y desactivado;
## márgenes 30, 10, 10 y 10). El icono va centrado en el hueco de 24x24 de la
## izquierda y el texto, después de la raya. El foco es transparente por
## dentro: Godot lo pinta encima del estado que toque, así que se distingue
## del de encima. color: el de siempre; color_encima: con el ratón o el foco.
static func boton_grande(texto: String, cual: Icono, accion: Callable, color := EstiloInterfaz.TEXTO_SUAVE, color_encima := EstiloInterfaz.NEON, ancho := 300.0) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.icon = icono(cual)
	boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boton.custom_minimum_size = Vector2(ancho, 32.0)
	boton.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	boton.add_theme_constant_override("h_separation", 16)
	var estados := ["normal", "hover", "pressed", "focus", "disabled"]
	var colores := [color, color_encima, color_encima, color_encima, Color(color, 0.5)]
	for i in estados.size():
		boton.add_theme_stylebox_override(estados[i], EstiloInterfaz.estilo_trozos(BOTON_GRANDE, i, Vector2(64.0, 32.0), [30, 10, 10, 10], [7, 4, 14, 4], colores[i]))
	for nombre in ["icon_normal_color", "icon_focus_color"]:
		boton.add_theme_color_override(nombre, color)
	for nombre in ["icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color"]:
		boton.add_theme_color_override(nombre, color_encima)
	for nombre in ["font_color", "font_focus_color"]:
		boton.add_theme_color_override(nombre, EstiloInterfaz.TEXTO)
	EstiloInterfaz.poner_letra(boton, 22)
	boton.pressed.connect(accion)
	return boton


## Las tarjetas de JUGAR (3 de 48x48: normal, encima y elegida; margen 12).
static func tarjeta(estado: Tarjeta, color: Color) -> StyleBoxTexture:
	return EstiloInterfaz.estilo_trozos(TARJETA, estado, Vector2(48.0, 48.0), [12, 12, 12, 12], [16, 14, 16, 14], color)


## El cartel de un personaje (40x40, margen 10).
static func cartel(color: Color) -> StyleBoxTexture:
	return EstiloInterfaz.estilo_trozos(CARTEL, 0, Vector2(40.0, 40.0), [10, 10, 10, 10], [14, 10, 14, 12], color)


## La etiqueta de la cuenta (2 de 48x20: márgenes 22, 6, 8 y 6). De alto,
## siempre 20: el icono está en el trozo de la izquierda y no se estira.
static func cuenta(encima: bool, color: Color) -> StyleBoxTexture:
	return EstiloInterfaz.estilo_trozos(CUENTA, 1 if encima else 0, Vector2(48.0, 20.0), [22, 6, 8, 6], [26, 1, 12, 1], color)


## El marco de la tarjeta de novedades (48x48, margen 12).
static func novedades(color: Color) -> StyleBoxTexture:
	return EstiloInterfaz.estilo_trozos(NOVEDADES, 0, Vector2(48.0, 48.0), [12, 12, 12, 12], [18, 18, 18, 14], color)
