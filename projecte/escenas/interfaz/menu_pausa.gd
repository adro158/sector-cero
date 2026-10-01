extends Control

## Menú de pausa: Esc, P o Start lo abren y lo cierran. La pausa la pone la
## jugabilidad al recibir juego_pausado; el menú solo la pide y se muestra.

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"

var _en_pausa := false
var _terminada := false
var _ventana: ColorRect
var _continuar: Button
var _opciones: PanelOpciones


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

	_continuar = EstiloInterfaz.boton("CONTINUAR", _alternar_pausa)
	caja.add_child(_continuar)
	var boton_opciones := EstiloInterfaz.boton("OPCIONES", _abrir_opciones)
	caja.add_child(boton_opciones)
	caja.add_child(EstiloInterfaz.boton("MENÚ PRINCIPAL", _ir_al_menu))

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	_ventana.visible = false
	add_child(_ventana)

	_opciones = PanelOpciones.new()
	_opciones.cerrado.connect(_al_cerrar_opciones.bind(boton_opciones))
	add_child(_opciones)
	BusEventos.partida_terminada.connect(_al_terminar)


func _unhandled_input(evento: InputEvent) -> void:
	# Con las opciones abiertas, Esc las cierra a ellas y no a la pausa.
	if _opciones.visible:
		return
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


func _abrir_opciones() -> void:
	_ventana.visible = false
	_opciones.abrir()


func _al_cerrar_opciones(boton: Button) -> void:
	_ventana.visible = true
	boton.grab_focus()


func _ir_al_menu() -> void:
	Transicion.cambiar_a(MENU_PRINCIPAL)


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
	_ventana.visible = false
