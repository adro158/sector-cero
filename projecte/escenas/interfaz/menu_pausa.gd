extends Control

## Menú de pausa: Esc, P o Start lo abren y lo cierran. La pausa la pone la
## jugabilidad al recibir juego_pausado; el menú solo la pide y se muestra.

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"

var _en_pausa := false
var _terminada := false
var _ventana: ColorRect
var _continuar: Button


func _ready() -> void:
	# Tiene que atender al teclado precisamente con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("PAUSA", 40, EstiloInterfaz.NEON)
	var ayuda := EstiloInterfaz.etiqueta("Esc o P para continuar", 14, EstiloInterfaz.TEXTO_SUAVE)
	for etiqueta in [titulo, ayuda]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)

	_continuar = Button.new()
	_continuar.text = "CONTINUAR"
	_continuar.custom_minimum_size = Vector2(240, 44)
	_continuar.pressed.connect(_alternar_pausa)
	caja.add_child(_continuar)

	var menu := Button.new()
	menu.text = "MENÚ PRINCIPAL"
	menu.custom_minimum_size = Vector2(240, 44)
	menu.pressed.connect(_ir_al_menu)
	caja.add_child(menu)

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	_ventana.visible = false
	add_child(_ventana)
	BusEventos.partida_terminada.connect(_al_terminar)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausar"):
		_alternar_pausa()
		get_viewport().set_input_as_handled()


func _alternar_pausa() -> void:
	# Si el juego ya está pausado y no lo he pausado yo, es otra pausa (elegir
	# mejora o fin de partida): el menú confundiría y no hay que tocarla.
	if _terminada or (get_tree().paused and not _en_pausa):
		return

	_en_pausa = not _en_pausa
	_ventana.visible = _en_pausa
	if _en_pausa:
		_continuar.grab_focus()
	BusEventos.juego_pausado.emit(_en_pausa)


func _ir_al_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL)


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
	_ventana.visible = false
