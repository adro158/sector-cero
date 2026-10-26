extends CanvasLayer

## Controles táctiles para jugar desde el móvil. Solo se activan en la versión
## web con pantalla táctil (o con ?tactil en la dirección, para probarlos desde
## el ordenador); en el resto de casos este autoload no hace nada.
##
## No toca al jugador: simula las mismas acciones que el teclado (mover_*,
## cambiar_personaje y pausar), así que el resto del juego no se entera.
## Joystick flotante en la mitad izquierda de la pantalla, botón de cambio de
## personaje abajo a la derecha, el de la ulti encima de él y el de pausa
## arriba a la derecha.
##
## Los botones y el joystick son dibujos del lote 9, en grises y teñidos (antes
## eran círculos hechos por código): el botón, normal y pulsado, mide 96x96
## (RADIO_BOTON) y la base del joystick 160x160 (RADIO_JOYSTICK).

const BOTON := preload("res://medios/interfaz/tactil_boton.png")
## Cambiar, ulti y pausa, de 48x48.
const ICONOS := preload("res://medios/interfaz/tactil_iconos.png")
const BASE := preload("res://medios/interfaz/tactil_joystick.png")
const PALANCA := preload("res://medios/interfaz/tactil_palanca.png")
const RADIO_JOYSTICK := 80.0
const RADIO_BOTON := 48.0
const MARGEN := 80.0
## Lo que se ve pulsado un botón después de tocarlo.
const SEGUNDOS_PULSADO := 0.15

var _dibujo: Control
## El dedo que maneja el joystick (-1 si no hay ninguno).
var _dedo := -1
var _centro := Vector2.ZERO
var _vector := Vector2.ZERO
var _boton_cambiar := Vector2.ZERO
var _boton_pausa := Vector2.ZERO
var _boton_ulti := Vector2.ZERO
## Lo que le queda a cada acción de verse pulsada.
var _pulsado := {}


func _ready() -> void:
	layer = 90
	# Tiene que seguir funcionando con el juego en pausa para poder reanudarlo.
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _hay_pantalla_tactil():
		set_process(false)
		set_process_input(false)
		return
	_dibujo = Control.new()
	_dibujo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dibujo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dibujo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_dibujo.draw.connect(_pintar)
	add_child(_dibujo)


func _hay_pantalla_tactil() -> bool:
	if not OS.has_feature("web"):
		return false
	if DisplayServer.is_touchscreen_available():
		return true
	return JavaScriptBridge.eval("new URLSearchParams(location.search).has('tactil')") == true


## Los controles solo se ven durante la partida y sin pausa.
func _jugando() -> bool:
	return not get_tree().paused and get_tree().get_first_node_in_group("jugador") != null


func _process(delta: float) -> void:
	for accion in _pulsado:
		_pulsado[accion] = maxf(_pulsado[accion] - delta, 0.0)
	var pantalla := get_viewport().get_visible_rect().size
	_boton_cambiar = pantalla - Vector2(MARGEN, MARGEN)
	_boton_pausa = Vector2(pantalla.x - MARGEN, MARGEN)
	_boton_ulti = pantalla - Vector2(MARGEN, MARGEN * 2.4)
	if not _jugando() and _dedo != -1:
		_soltar()
	_dibujo.visible = _jugando()
	_dibujo.queue_redraw()


func _input(evento: InputEvent) -> void:
	if not _jugando():
		return
	if evento is InputEventScreenTouch:
		if evento.pressed:
			_al_tocar(evento)
		elif evento.index == _dedo:
			_soltar()
	elif evento is InputEventScreenDrag and evento.index == _dedo:
		_vector = ((evento.position - _centro) / RADIO_JOYSTICK).limit_length(1.0)
		_aplicar()


func _al_tocar(evento: InputEventScreenTouch) -> void:
	if evento.position.distance_to(_boton_cambiar) <= RADIO_BOTON * 1.3:
		_pulsar("cambiar_personaje")
	elif evento.position.distance_to(_boton_pausa) <= RADIO_BOTON * 1.3:
		_pulsar("pausar")
	elif evento.position.distance_to(_boton_ulti) <= RADIO_BOTON * 1.3:
		_pulsar("ulti")
	elif _dedo == -1 and evento.position.x < get_viewport().get_visible_rect().size.x * 0.5:
		_dedo = evento.index
		_centro = evento.position
		_vector = Vector2.ZERO


func _soltar() -> void:
	_dedo = -1
	_vector = Vector2.ZERO
	_aplicar()


## Traduce la posición del joystick a las cuatro acciones de movimiento. La
## fuerza de cada una es lo lejos que está el dedo, así que se puede ir despacio.
func _aplicar() -> void:
	_fijar("mover_izquierda", maxf(-_vector.x, 0.0))
	_fijar("mover_derecha", maxf(_vector.x, 0.0))
	_fijar("mover_arriba", maxf(-_vector.y, 0.0))
	_fijar("mover_abajo", maxf(_vector.y, 0.0))


func _fijar(accion: String, fuerza: float) -> void:
	if fuerza > 0.0:
		Input.action_press(accion, fuerza)
	else:
		Input.action_release(accion)


## Una pulsación completa de una acción, como si se tocara y soltara una tecla.
func _pulsar(accion: String) -> void:
	_pulsado[accion] = SEGUNDOS_PULSADO
	for pulsada in [true, false]:
		var evento := InputEventAction.new()
		evento.action = accion
		evento.pressed = pulsada
		Input.parse_input_event(evento)


func _pintar() -> void:
	var color := EstiloInterfaz.NEON
	var base := _centro if _dedo != -1 else Vector2(MARGEN * 1.6, get_viewport().get_visible_rect().size.y - MARGEN * 1.6)
	var palanca := base + _vector * RADIO_JOYSTICK
	_dibujo.draw_texture(BASE, base - BASE.get_size() / 2.0, Color(color, 0.6))
	_dibujo.draw_texture(PALANCA, palanca - PALANCA.get_size() / 2.0, Color(color, 0.8 if _dedo != -1 else 0.4))
	_boton(_boton_cambiar, "cambiar_personaje", 0, color)
	_boton(_boton_ulti, "ulti", 1, Color(1.0, 0.8, 0.2))
	_boton(_boton_pausa, "pausar", 2, color)


## El botón de una acción con su icono (el número en la tira de iconos), y
## pulsado justo después de tocarlo.
func _boton(centro: Vector2, accion: String, icono: int, color: Color) -> void:
	var pulsado: bool = _pulsado.get(accion, 0.0) > 0.0
	var esquina := centro - Vector2(RADIO_BOTON, RADIO_BOTON)
	_dibujo.draw_texture_rect_region(BOTON, Rect2(esquina, Vector2(96.0, 96.0)), Rect2(96.0 if pulsado else 0.0, 0.0, 96.0, 96.0), Color(color, 0.85))
	_dibujo.draw_texture_rect_region(ICONOS, Rect2(centro - Vector2(24.0, 24.0), Vector2(48.0, 48.0)), Rect2(icono * 48.0, 0.0, 48.0, 48.0), Color.WHITE if pulsado else color)
