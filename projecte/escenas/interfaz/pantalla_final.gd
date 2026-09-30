extends Control

## Pantalla de victoria o derrota. Aparece con un fundido al terminar la
## partida, con el resumen y dos salidas: reintentar o volver al menú.

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"

var _ventana: ColorRect


func _ready() -> void:
	# La partida termina con el juego pausado, y aun así hay que poder pulsar.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	BusEventos.partida_terminada.connect(_al_terminar)


func _al_terminar(estadisticas: Dictionary) -> void:
	var victoria: bool = estadisticas.victoria
	var color := EstiloInterfaz.VICTORIA if victoria else EstiloInterfaz.DERROTA

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("SECTOR ASEGURADO" if victoria else "PROCESO ELIMINADO", 44, color)
	var subtitulo := EstiloInterfaz.etiqueta(
		"Has derrotado al jefe final. El sistema está limpio." if victoria
		else "El malware se ha apoderado del sector de arranque.", 16, EstiloInterfaz.TEXTO_SUAVE)
	caja.add_child(titulo)
	caja.add_child(subtitulo)

	var datos := GridContainer.new()
	datos.columns = 2
	datos.add_theme_constant_override("h_separation", 40)
	for fila in [
		["Tiempo", "%02d:%02d" % [int(estadisticas.tiempo) / 60, int(estadisticas.tiempo) % 60]],
		["Nivel", str(estadisticas.nivel)],
		["Malware eliminado", str(estadisticas.eliminados)],
	]:
		datos.add_child(EstiloInterfaz.etiqueta(fila[0], 18, EstiloInterfaz.TEXTO_SUAVE))
		datos.add_child(EstiloInterfaz.etiqueta(fila[1], 18, EstiloInterfaz.TEXTO))
	var centro := CenterContainer.new()
	centro.add_child(datos)
	caja.add_child(centro)

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	botones.add_child(_boton("REINTENTAR  [Enter]", _reintentar))
	botones.add_child(_boton("MENÚ  [Esc]", _ir_al_menu))
	caja.add_child(botones)

	for hijo in caja.get_children():
		if hijo is Label:
			hijo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_ventana = EstiloInterfaz.ventana_centrada(caja, color)
	add_child(_ventana)

	# Fundido de entrada: la pantalla aparece poco a poco en lugar de golpe.
	_ventana.modulate.a = 0.0
	create_tween().tween_property(_ventana, "modulate:a", 1.0, 0.6)
	botones.get_child(0).grab_focus()


func _boton(texto: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(220, 44)
	boton.pressed.connect(accion)
	return boton


func _unhandled_input(evento: InputEvent) -> void:
	if _ventana == null or not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_reintentar()
	elif evento.keycode == KEY_ESCAPE:
		_ir_al_menu()


func _reintentar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _ir_al_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL)
