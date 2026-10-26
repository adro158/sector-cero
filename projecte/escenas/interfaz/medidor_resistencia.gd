extends Control

## El medidor de la resistencia del malware a la herramienta que se lleva, el
## elemento diferencial del juego a la vista (lote 9): el escudo con el bicho,
## la barra con una marca cada 10 % (llega al 50 %, el máximo) y el número.
## Todo en grises y teñido de cian a rojo según lo que resiste, como el anillo
## del arma. Cuando sube, el escudo da un latido.
##
## Va arriba a la derecha, al doble de tamaño (abajo pisaba los consejos de
## las primeras partidas), enfrente del panel del nivel. La herramienta llega
## con personaje_cambiado y el latido con malware_adaptado; lo que resiste se
## lee del nodo del malware, como en el panel del equipo, porque también baja
## (cuando se deja de usar) y eso no tiene señal.
##
## Sin class_name: lo crea hud.gd con preload.

const ICONO := preload("res://medios/interfaz/resistencia_icono.png")
const LATIDO := preload("res://medios/interfaz/resistencia_latido.png")
const MARCO := preload("res://medios/interfaz/resistencia_marco.png")
const RELLENO := preload("res://medios/interfaz/resistencia_relleno.png")
## La resistencia más alta que puede tener (maximo de resistencia_malware.gd):
## con ella, la barra está llena.
const MAXIMO := 0.5
const SEGUNDOS_POR_FOTOGRAMA_LATIDO := 0.08
## El tono del color: de cian (0,52) a rojo (0,97), pasando por el azul, el
## morado y el magenta. Mezclar cian y rojo a medias daba un gris.
const TONO_SIN_RESISTENCIA := 0.52
const TONO_MAXIMO := 0.97

var _arma: DatosArma
var _resistencia_malware: Node
## Segundos desde que empezó el latido (-1: ninguno).
var _tiempo_latido := -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	# Con pantalla táctil, a la izquierda del botón de pausa, que va en esa
	# esquina (control_tactil.gd): el mismo aviso que usa él para dibujarse.
	var hueco := 140.0 if DisplayServer.is_touchscreen_available() else 0.0
	offset_left = -310.0 - hueco
	offset_right = -16.0 - hueco
	offset_top = 18.0
	offset_bottom = 54.0
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")
	BusEventos.personaje_cambiado.connect(func(_actual, arma, _siguiente, _espera): _arma = arma)
	BusEventos.malware_adaptado.connect(_al_adaptarse)


func _al_adaptarse(arma: DatosArma, _resistencia: float) -> void:
	if arma == _arma:
		_tiempo_latido = 0.0


## Con el juego en pausa no se llama: el latido se queda como esté.
func _process(delta: float) -> void:
	if _tiempo_latido >= 0.0:
		_tiempo_latido += delta
		if _tiempo_latido >= SEGUNDOS_POR_FOTOGRAMA_LATIDO * 4:
			_tiempo_latido = -1.0
	queue_redraw()


func _draw() -> void:
	if _arma == null or _resistencia_malware == null:
		return
	var resistencia: float = _resistencia_malware.resistencia(_arma)
	var parte := clampf(resistencia / MAXIMO, 0.0, 1.0)
	var tinte := Color.from_hsv(lerpf(TONO_SIN_RESISTENCIA, TONO_MAXIMO, parte), 0.85, 1.0)
	# Sin resistencia, más apagado: no hay nada de qué avisar.
	if resistencia <= 0.0:
		tinte.a = 0.5
	# Los dibujos, al doble y sin suavizar; el texto, aparte, a su tamaño.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(2.0, 2.0))
	var icono := Vector2(0.0, 1.0)
	if _tiempo_latido >= 0.0:
		var fotograma := int(_tiempo_latido / SEGUNDOS_POR_FOTOGRAMA_LATIDO)
		draw_texture_rect_region(LATIDO, Rect2(icono, Vector2(16.0, 16.0)), Rect2(fotograma * 16.0, 0.0, 16.0, 16.0), tinte)
	else:
		draw_texture(ICONO, icono, tinte)
	var marco := Vector2(20.0, 3.0)
	draw_texture(MARCO, marco, tinte)
	var ancho := RELLENO.get_width() * parte
	draw_texture_rect_region(RELLENO, Rect2(marco + Vector2(2.0, 2.0), Vector2(ancho, RELLENO.get_height())),
		Rect2(0.0, 0.0, ancho, RELLENO.get_height()), tinte)
	draw_set_transform(Vector2.ZERO)
	draw_string(get_theme_default_font(), Vector2(178.0, 24.0), "RESISTE %d %%" % roundi(resistencia * 100.0),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, tinte)
