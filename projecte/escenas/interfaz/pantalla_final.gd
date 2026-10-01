extends Control

## Pantalla de victoria o derrota. Aparece con un fundido al terminar la
## partida, con el resumen, los récords batidos y dos salidas: reintentar o
## volver al menú.

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"

const NOMBRES_RECORD := {
	"tiempo": "tiempo",
	"nivel": "nivel",
	"eliminados": "malware eliminado",
}

var _ventana: ColorRect


func _ready() -> void:
	# La partida termina con el juego pausado, y aun así hay que poder pulsar.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Diferido: así el gestor de guardado ya ha anotado la partida cuando se
	# pregunta qué récords se han batido, conecte quien conecte antes.
	BusEventos.partida_terminada.connect(_mostrar, CONNECT_DEFERRED)


func _mostrar(estadisticas: Dictionary) -> void:
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

	if not GestorGuardado.records_batidos.is_empty():
		var nombres := []
		for clave in GestorGuardado.records_batidos:
			nombres.append(NOMBRES_RECORD[clave])
		var record := EstiloInterfaz.etiqueta("¡NUEVO RÉCORD! " + ", ".join(nombres), 20, EstiloInterfaz.NEON)
		caja.add_child(record)
		# Parpadea para que se vea que es una novedad.
		var latido := create_tween().set_loops()
		latido.tween_property(record, "modulate:a", 0.4, 0.5)
		latido.tween_property(record, "modulate:a", 1.0, 0.5)

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	botones.add_child(EstiloInterfaz.boton("REINTENTAR  [Enter]", _reintentar, 220))
	botones.add_child(EstiloInterfaz.boton("MENÚ  [Esc]", _ir_al_menu, 220))
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


func _unhandled_input(evento: InputEvent) -> void:
	if _ventana == null or not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_reintentar()
	elif evento.keycode == KEY_ESCAPE:
		_ir_al_menu()


func _reintentar() -> void:
	# Ruta vacía: recargar la escena actual.
	Transicion.cambiar_a("")


func _ir_al_menu() -> void:
	Transicion.cambiar_a(MENU_PRINCIPAL)
