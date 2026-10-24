extends Control

## Menú de pausa: Esc, P o Start lo abren y lo cierran. La pausa la pone la
## jugabilidad al recibir juego_pausado; el menú solo la pide y se muestra.
## Desde el 24/10 tiene REGLAS (para mirar un afijo o el escudo sin salir) y
## pregunta antes de abandonar: un Enter o un click de más tiraba una partida
## de 15 minutos (mejoras propuestas, interfaz 7 y jugabilidad 13).

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"

var _en_pausa := false
var _terminada := false
var _ventana: ColorRect
var _continuar: Button
var _opciones: PanelOpciones
var _reglas: PanelReglas
## La pregunta de si se abandona la partida, y su botón NO.
var _confirmar: ColorRect
var _no: Button


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
	var boton_reglas := EstiloInterfaz.boton("REGLAS", _abrir_reglas)
	caja.add_child(boton_reglas)
	var boton_opciones := EstiloInterfaz.boton("OPCIONES", _abrir_opciones)
	caja.add_child(boton_opciones)
	var boton_menu := EstiloInterfaz.boton("MENÚ PRINCIPAL", _preguntar_si_salir)
	caja.add_child(boton_menu)

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	_ventana.visible = false
	add_child(_ventana)

	_crear_confirmacion(boton_menu)

	_opciones = PanelOpciones.new()
	_opciones.cerrado.connect(_volver_a_la_pausa.bind(boton_opciones))
	add_child(_opciones)
	_reglas = PanelReglas.new()
	_reglas.cerrado.connect(_volver_a_la_pausa.bind(boton_reglas))
	add_child(_reglas)
	BusEventos.partida_terminada.connect(_al_terminar)


## ¿Abandonar? SÍ va al menú; NO (y Esc) vuelve a la pausa. El foco empieza en
## NO, para que un Enter de más no tire la partida.
func _crear_confirmacion(boton_menu: Button) -> void:
	var caja := VBoxContainer.new()
	var pregunta := EstiloInterfaz.etiqueta("¿ABANDONAR LA PARTIDA?", 28, EstiloInterfaz.DERROTA)
	var aviso := EstiloInterfaz.etiqueta("No contará para los récords ni para el ranking", 14, EstiloInterfaz.TEXTO_SUAVE)
	for etiqueta in [pregunta, aviso]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 16)
	fila.add_child(EstiloInterfaz.boton("SÍ, SALIR", _ir_al_menu, 160))
	_no = EstiloInterfaz.boton("NO", _volver_a_la_pausa.bind(boton_menu), 160)
	fila.add_child(_no)
	caja.add_child(fila)
	_confirmar = EstiloInterfaz.ventana_centrada(caja, EstiloInterfaz.DERROTA)
	_confirmar.visible = false
	add_child(_confirmar)


func _unhandled_input(evento: InputEvent) -> void:
	# Con las opciones o las reglas abiertas, Esc las cierra a ellas y no a la
	# pausa.
	if _opciones.visible or _reglas.visible:
		return
	if _confirmar.visible:
		if evento.is_action_pressed("pausar") or evento.is_action_pressed("ui_cancel"):
			_no.pressed.emit()
			get_viewport().set_input_as_handled()
		return
	if evento.is_action_pressed("pausar"):
		_alternar_pausa()
		get_viewport().set_input_as_handled()


## Al cambiar de ventana (o de pestaña en la web) se pausa sola: si no, la
## horda seguía y, por ejemplo en la defensa, al enseñar el código el personaje
## caía. Al volver no se quita: se sigue con Esc o con CONTINUAR.
func _notification(que: int) -> void:
	if que == NOTIFICATION_APPLICATION_FOCUS_OUT and not _en_pausa:
		_alternar_pausa()


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


func _abrir_reglas() -> void:
	_ventana.visible = false
	_reglas.abrir()


func _preguntar_si_salir() -> void:
	_ventana.visible = false
	_confirmar.visible = true
	_no.grab_focus()


## Al cerrar las opciones, las reglas o la pregunta, otra vez la pausa, con el
## foco en el botón del que se venía.
func _volver_a_la_pausa(boton: Button) -> void:
	_confirmar.visible = false
	_ventana.visible = true
	boton.grab_focus()


func _ir_al_menu() -> void:
	Transicion.cambiar_a(MENU_PRINCIPAL)


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
	_ventana.visible = false
	_confirmar.visible = false
