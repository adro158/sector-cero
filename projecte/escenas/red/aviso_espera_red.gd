extends CanvasLayer

## El aviso de la partida en red cuando a este ordenador le toca esperar: ya
## ha elegido su mejora (o no le toca) y otro aún está eligiendo, así que la
## partida está parada hasta que elijan todos. Sin él parecía que el juego se
## había quedado colgado (Adam, 17/11). Va en la banda de los avisos del HUD,
## con un reloj de arena (lote de la interfaz de red).
##
## Sin class_name: lo crea partida_red.gd con preload.

const Red := preload("res://globales/red.gd")
## En los clientes: sin estados durante más de esto, el anfitrión está parado.
const SIN_ESTADO_MS := 500
## El reloj de arena: 8 fotogramas de 16x16 en bucle (la arena cae y da media
## vuelta), al doble.
const RELOJ := preload("res://medios/interfaz/red_espera.png")
const SEGUNDOS_FOTOGRAMA := 0.1
## Lo que baja desde el borde de arriba: debajo del reloj de la partida.
const ARRIBA := 90.0

var _partida: Node
var _caja: PanelContainer
var _aviso: Label
var _reloj := AtlasTexture.new()
var _tiempo := 0.0


func _init(partida: Node) -> void:
	_partida = partida


func _ready() -> void:
	# Por encima de la interfaz de la partida, y también con el juego en pausa.
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_caja = PanelContainer.new()
	_caja.add_theme_stylebox_override("panel", EstiloInterfaz.banda(EstiloInterfaz.NEON))
	_caja.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caja)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	_caja.add_child(fila)
	_reloj.atlas = RELOJ
	_reloj.region = Rect2(0.0, 0.0, 16.0, 16.0)
	var reloj := TextureRect.new()
	reloj.texture = _reloj
	reloj.custom_minimum_size = Vector2(32.0, 32.0)
	reloj.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reloj.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reloj.modulate = EstiloInterfaz.NEON
	fila.add_child(reloj)
	_aviso = EstiloInterfaz.etiqueta("", 22, EstiloInterfaz.NEON)
	_aviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(_aviso)
	visible = false


func _process(delta: float) -> void:
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
	if not visible:
		return
	_tiempo += delta
	_reloj.region.position.x = int(_tiempo / SEGUNDOS_FOTOGRAMA) % 8 * 16.0
	# Centrado arriba: a mano, porque lo que mide cambia con el texto.
	_caja.reset_size()
	_caja.position = Vector2((_caja.get_viewport_rect().size.x - _caja.size.x) / 2.0, ARRIBA)
