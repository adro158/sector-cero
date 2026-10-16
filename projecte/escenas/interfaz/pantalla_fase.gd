extends ColorRect

## La transición a la fase 2: la pantalla se va a negro, se escribe «SECTOR
## CERO DAÑADO» letra a letra, con algún tirón como de imagen rota, y vuelve
## la imagen. Mientras dura, el juego está en pausa (lo pone raiz_juego.gd) y
## este negro se queda los clicks.
##
## Sin class_name: lo carga hud.gd con preload.

const TEXTO := "SECTOR CERO DAÑADO"
## Lo que tarda en irse a negro y en volver, en segundos.
const FUNDIDO := 0.4
## Cada cuánto da un tirón el texto.
const CADA_TIRON := 0.06
## Los tirones se repiten en este orden: así no gastan números del azar de la
## partida (el simulador tiene que repetir las mismas partidas).
const TIRONES: Array[Vector2] = [Vector2(0, 0), Vector2(6, -2), Vector2(-4, 1), Vector2(0, 0), Vector2(0, 0), Vector2(-7, 2), Vector2(3, 0), Vector2(0, 0)]

var _texto: Label
var _hasta_tiron := 0.0
var _tiron := 0


func _ready() -> void:
	# Todo esto pasa con el juego en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color.BLACK
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	_texto = EstiloInterfaz.etiqueta(TEXTO, 44, EstiloInterfaz.DERROTA)
	_texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_texto)
	BusEventos.transicion_fase.connect(_empezar)


func _empezar(segundos: float) -> void:
	visible = true
	modulate.a = 0.0
	_texto.visible_ratio = 0.0
	var escribir := segundos * 0.4
	var efecto := create_tween()
	efecto.tween_property(self, "modulate:a", 1.0, FUNDIDO)
	efecto.tween_property(_texto, "visible_ratio", 1.0, escribir)
	efecto.tween_interval(segundos - FUNDIDO * 2.0 - escribir)
	efecto.tween_property(self, "modulate:a", 0.0, FUNDIDO)
	efecto.tween_callback(hide)


func _process(delta: float) -> void:
	if not visible:
		return
	_hasta_tiron -= delta
	if _hasta_tiron > 0.0:
		return
	_hasta_tiron = CADA_TIRON
	_tiron = (_tiron + 1) % TIRONES.size()
	_texto.position = TIRONES[_tiron]
	# Con los tirones hacia la izquierda, un instante en cian.
	var color_texto := EstiloInterfaz.NEON if TIRONES[_tiron].x < 0.0 else EstiloInterfaz.DERROTA
	_texto.add_theme_color_override("font_color", color_texto)
