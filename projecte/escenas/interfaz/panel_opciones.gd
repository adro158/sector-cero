class_name PanelOpciones
extends Control

## Ventana de opciones: volumen de la música y de los efectos, pantalla completa
## y filtro CRT. La usan el menú principal y el menú de pausa. Cada cambio se
## guarda en el momento a través de GestorGuardado, que también lo aplica.

signal cerrado

var _ventana: ColorRect
var _primero: Control


func _ready() -> void:
	# Desde el menú de pausa se abre con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Anclajes y tamaño a la vez: con solo set_anchors_preset el panel se quedaba
	# en 0x0 y la ventana salía centrada en la esquina de arriba a la izquierda.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("OPCIONES", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 24)
	rejilla.add_theme_constant_override("v_separation", 14)
	caja.add_child(rejilla)
	_primero = _deslizador(rejilla, "Música", "volumen_musica")
	_deslizador(rejilla, "Efectos", "volumen_efectos")
	_casilla(rejilla, "Pantalla completa", "pantalla_completa")
	_casilla(rejilla, "Filtro CRT", "crt")
	_casilla(rejilla, "Avisar de versiones nuevas", "avisar_versiones")

	var volver := EstiloInterfaz.boton("VOLVER  [Esc]", cerrar)
	caja.add_child(volver)

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	add_child(_ventana)
	visible = false


func abrir() -> void:
	visible = true
	_primero.grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría o quitaría la pausa.
		get_viewport().set_input_as_handled()


func _deslizador(rejilla: GridContainer, texto: String, clave: String) -> HSlider:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var deslizador := HSlider.new()
	deslizador.custom_minimum_size = Vector2(260, 24)
	deslizador.max_value = 1.0
	deslizador.step = 0.05
	deslizador.value = GestorGuardado.opcion(clave)
	deslizador.value_changed.connect(func(valor: float): GestorGuardado.cambiar_opcion(clave, valor))
	rejilla.add_child(deslizador)
	return deslizador


func _casilla(rejilla: GridContainer, texto: String, clave: String) -> void:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var casilla := CheckButton.new()
	casilla.button_pressed = GestorGuardado.opcion(clave)
	# Solo el interruptor, sin estirarse a lo ancho de la columna.
	casilla.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	casilla.toggled.connect(func(activa: bool): GestorGuardado.cambiar_opcion(clave, activa))
	rejilla.add_child(casilla)
