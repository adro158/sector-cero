extends CanvasLayer

## El aviso de la partida en red cuando a este ordenador le toca esperar: ya
## ha elegido su mejora (o no le toca) y otro aún está eligiendo, así que la
## partida está parada hasta que elijan todos. Sin él parecía que el juego se
## había quedado colgado (Adam, 17/11).
##
## Sin class_name: lo crea partida_red.gd con preload.

const Red := preload("res://globales/red.gd")
## En los clientes: sin estados durante más de esto, el anfitrión está parado.
const SIN_ESTADO_MS := 500

var _partida: Node
var _aviso: Label


func _init(partida: Node) -> void:
	_partida = partida


func _ready() -> void:
	# Por encima de la interfaz de la partida, y también con el juego en pausa.
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_aviso = EstiloInterfaz.etiqueta("", 22, EstiloInterfaz.NEON)
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_aviso.offset_top = 90.0
	_aviso.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(_aviso)
	visible = false


func _process(_delta: float) -> void:
	if _partida.terminada():
		visible = false
		return
	var raiz: Node = _partida.get_parent()
	if Red.actual.es_anfitrion():
		# Parado eligiendo, y a este no le toca: espera a los demás.
		var niveles: Node = raiz.get_node("SistemaNiveles")
		visible = niveles.eligiendo() and not niveles.elige(raiz.get_node("Jugador"))
		_aviso.text = "Esperando a que los demás jugadores elijan..."
	else:
		# Sin pausa aquí (ya ha elegido) y sin estados: el anfitrión está parado.
		visible = not get_tree().paused and _partida.sin_estados_ms() > SIN_ESTADO_MS
		_aviso.text = "Esperando a los demás jugadores..."
