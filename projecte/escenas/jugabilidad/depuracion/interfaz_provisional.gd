extends Control

## Sustituto provisional del menú de pausa de Alan: al pulsar la acción pausar
## oscurece el juego y muestra un aviso. Cuando su menú exista, se borra este
## nodo entero; si no, cada pulsación se aplicaría dos veces.
##
## Solo usa señales del BusEventos, igual que tendrá que hacer su menú.

const COLOR_NEON := Color(0.0, 0.85, 0.95)

var _en_pausa := false
var _terminada := false
var _ventana_pausa: ColorRect


func _ready() -> void:
	# Tiene que atender al teclado precisamente con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ventana_pausa = _crear_ventana("PAUSA", "Esc o P para continuar")
	BusEventos.partida_terminada.connect(_al_terminar)


## Un fondo que oscurece el juego con una ventana centrada encima.
func _crear_ventana(titulo: String, subtitulo: String) -> ColorRect:
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
	return fondo


func _crear_etiqueta(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	return etiqueta


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausar"):
		_alternar_pausa()


func _alternar_pausa() -> void:
	# Si el juego ya está pausado y no lo he pausado yo, es otra pausa (elegir
	# mejora o fin de partida): el aviso confundiría y no hay que tocarla.
	if _terminada or (get_tree().paused and not _en_pausa):
		return

	_en_pausa = not _en_pausa
	_ventana_pausa.visible = _en_pausa
	BusEventos.juego_pausado.emit(_en_pausa)


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
	_ventana_pausa.visible = false
