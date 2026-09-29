extends Control

## Sustituto provisional de la interfaz de Alan: panel de mejoras al subir de
## nivel y aviso de pausa. Existe para poder jugar y enseñar el juego mientras
## su interfaz no esté terminada; cuando lo esté, se borra este nodo entero.
##
## Solo usa señales del BusEventos, igual que tendrá que hacer su interfaz: si
## esto funciona, el contrato tiene todo lo necesario.

const OPCIONES_POR_NIVEL := 3
const COLOR_NEON := Color(0.0, 0.85, 0.95)

var _opciones: Array = []
var _botones: Array[Button] = []
var _en_pausa := false
var _terminada := false
var _ventana_mejoras: ColorRect
var _ventana_pausa: ColorRect


func _ready() -> void:
	# Se usa precisamente con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	for i in OPCIONES_POR_NIVEL:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(460, 56)
		boton.pressed.connect(_elegir.bind(i))
		_botones.append(boton)

	_ventana_mejoras = _crear_ventana("SUBIDA DE NIVEL", "Elige una mejora: click o teclas 1, 2 y 3", _botones)
	_ventana_pausa = _crear_ventana("PAUSA", "Esc o P para continuar", [])

	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)
	BusEventos.partida_terminada.connect(_al_terminar)


## Un fondo que oscurece el juego con una ventana centrada encima: título,
## subtítulo y, debajo, los controles que se le pasen.
func _crear_ventana(titulo: String, subtitulo: String, contenido: Array) -> ColorRect:
	var fondo := ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.0, 0.6)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.visible = false
	add_child(fondo)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)

	# Estilo de consola de neón, a juego con la rejilla del fondo.
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.03, 0.06, 0.1, 0.95)
	estilo.border_color = COLOR_NEON
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(6)
	estilo.set_content_margin_all(28)

	var ventana := PanelContainer.new()
	ventana.add_theme_stylebox_override("panel", estilo)
	centro.add_child(ventana)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	ventana.add_child(caja)

	caja.add_child(_crear_etiqueta(titulo, 40, COLOR_NEON))
	caja.add_child(_crear_etiqueta(subtitulo, 16, Color(0.8, 0.85, 0.9)))

	for control in contenido:
		caja.add_child(control)

	return fondo


func _crear_etiqueta(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	return etiqueta


func _al_subir_nivel(opciones: Array) -> void:
	_opciones = opciones

	for i in _botones.size():
		_botones[i].visible = i < opciones.size()
		if i < opciones.size():
			_botones[i].text = "%d.  %s\n%s" % [i + 1, opciones[i].nombre, opciones[i].descripcion]

	_ventana_mejoras.visible = true


func _elegir(indice: int) -> void:
	if indice >= _opciones.size():
		return

	# Primero se cierra y después se avisa: si quedan niveles pendientes, la
	# respuesta a la señal vuelve a abrir la ventana con las opciones del
	# siguiente, y cerrarla después la dejaría oculta.
	var mejora: DatosMejora = _opciones[indice]
	_opciones = []
	_ventana_mejoras.visible = false
	BusEventos.mejora_seleccionada.emit(mejora)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausar"):
		_alternar_pausa()
	elif not _opciones.is_empty() and evento is InputEventKey and evento.pressed and not evento.echo:
		if evento.keycode in [KEY_1, KEY_2, KEY_3]:
			_elegir(evento.keycode - KEY_1)


func _alternar_pausa() -> void:
	# No se pausa encima de la elección de mejora ni tras el fin de partida: el
	# juego ya está parado por otro motivo y el aviso confundiría.
	if _terminada or not _opciones.is_empty():
		return

	_en_pausa = not _en_pausa
	_ventana_pausa.visible = _en_pausa
	BusEventos.juego_pausado.emit(_en_pausa)


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
	_ventana_mejoras.visible = false
	_ventana_pausa.visible = false
