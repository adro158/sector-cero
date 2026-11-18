extends PanelContainer

## En la partida en red: la ruleta del cofre que ha cogido un compañero, en
## pequeño y solo para mirar (petición de Adam, 18/11). No pausa ni contesta
## nada: gira hasta su premio (que llega ya sorteado, como en panel_ruleta.gd),
## lo enseña un momento y se va. Es la misma ruleta a x1 en vez de a x3, en el
## panel de siempre (EstiloInterfaz.caja) del color del compañero.
##
## Sin class_name: lo crea interfaz_red.gd con preload.

const RUEDA := preload("res://medios/sprites/ruleta_rueda.png")
const MARCOS := [preload("res://medios/sprites/ruleta_marco_a.png"), preload("res://medios/sprites/ruleta_marco_b.png")]
## Las mismas medidas que panel_ruleta.gd, en píxeles del dibujo.
const RADIO_ICONOS := 31.0
const SECTORES := 8
const GRADOS_SECTOR := 360.0 / SECTORES
const DURACION_GIRO := 3.5
const PARPADEO := 0.15
const SEGUNDOS_PREMIO := 2.0

var _titulo: Label
var _premio: Label
var _dibujo: Control
var _opciones: Array = []
## El giro del disco, en radianes (lo anima mostrar()).
var _giro := 0.0
var _tiempo := 0.0
var _animacion: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 6)
	add_child(columna)
	_titulo = EstiloInterfaz.etiqueta("", 14)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_titulo)
	_dibujo = Control.new()
	_dibujo.custom_minimum_size = Vector2(112.0, 112.0)
	_dibujo.draw.connect(_dibujar)
	columna.add_child(_dibujo)
	_premio = EstiloInterfaz.etiqueta("", 13)
	_premio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_premio)
	visible = false


func mostrar(nombre: String, color: Color, opciones: Array, premio: DatosMejora) -> void:
	add_theme_stylebox_override("panel", EstiloInterfaz.caja(color, 10))
	_titulo.text = "COFRE DE %s" % nombre.to_upper()
	_titulo.add_theme_color_override("font_color", color)
	_premio.text = " "
	_opciones = opciones
	_giro = 0.0
	visible = true
	# A la izquierda y a media altura, a 16 px del borde: no tapa al jugador
	# ni la columna de mejoras. Después de poner los textos, que cambian lo
	# que mide.
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT, Control.PRESET_MODE_MINSIZE, 16)
	# Como en panel_ruleta.gd: acaba en el sector del premio, tras unas vueltas.
	var final := deg_to_rad(-GRADOS_SECTOR * opciones.find(premio) - 360.0 * 3)
	if _animacion != null:
		_animacion.kill()
	_animacion = create_tween()
	_animacion.tween_property(self, "_giro", final, DURACION_GIRO).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_animacion.tween_callback(func(): _premio.text = premio.nombre)
	_animacion.tween_interval(SEGUNDOS_PREMIO)
	_animacion.tween_callback(hide)


func _process(delta: float) -> void:
	_tiempo += delta
	if visible:
		_dibujo.queue_redraw()


func _dibujar() -> void:
	var centro := _dibujo.size / 2.0
	_dibujo.draw_set_transform(centro, _giro)
	_dibujo.draw_texture(RUEDA, -RUEDA.get_size() / 2.0)
	_dibujo.draw_set_transform(Vector2.ZERO)
	for i in _opciones.size():
		var angulo := deg_to_rad(-90.0 + GRADOS_SECTOR * i) + _giro
		var donde := centro + Vector2.from_angle(angulo) * RADIO_ICONOS
		_dibujo.draw_texture(_opciones[i].icono, donde - Vector2(8.0, 8.0))
	# El marco, encima, con las bombillas parpadeando.
	var marco: Texture2D = MARCOS[int(_tiempo / PARPADEO) % 2]
	_dibujo.draw_texture(marco, centro - marco.get_size() / 2.0)
