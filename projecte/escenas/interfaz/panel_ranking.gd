extends Control

## Ventana del ranking en el menú: las 10 mejores partidas de este ordenador,
## con el orden de GestorGuardado (victorias de la más rápida a la más lenta y
## después derrotas de la que más aguantó).
##
## Sin class_name: el menú la carga con preload (ver embestida_horda.gd).

signal cerrado

const COLUMNAS := ["#", "NOMBRE", "RESULTADO", "TIEMPO", "NIVEL", "ELIMINADOS", "PERSONAJE"]

var _tabla: GridContainer
var _volver: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("RANKING", 32, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	_tabla = GridContainer.new()
	_tabla.columns = COLUMNAS.size()
	_tabla.add_theme_constant_override("h_separation", 28)
	_tabla.add_theme_constant_override("v_separation", 8)
	var centro := CenterContainer.new()
	centro.add_child(_tabla)
	caja.add_child(centro)

	_volver = EstiloInterfaz.boton("VOLVER  [Esc]", cerrar)
	_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_volver)

	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false


## Se rellena al abrir, así siempre muestra lo último guardado.
func abrir() -> void:
	for hijo in _tabla.get_children():
		hijo.queue_free()
	for columna in COLUMNAS:
		_tabla.add_child(EstiloInterfaz.etiqueta(columna, 14, EstiloInterfaz.TEXTO_SUAVE))

	var partidas := GestorGuardado.ranking()
	if partidas.is_empty():
		_tabla.columns = 1
		_tabla.add_child(EstiloInterfaz.etiqueta("Todavía no hay partidas en el ranking.", 16))
	else:
		_tabla.columns = COLUMNAS.size()
	for i in partidas.size():
		var partida: Dictionary = partidas[i]
		var color := EstiloInterfaz.VICTORIA if partida.victoria else EstiloInterfaz.TEXTO
		var tiempo := int(partida.tiempo)
		for texto in [str(i + 1), partida.nombre, "Victoria" if partida.victoria else "Derrota",
				"%02d:%02d" % [tiempo / 60, tiempo % 60], str(partida.nivel), str(partida.eliminados), partida.personaje]:
			_tabla.add_child(EstiloInterfaz.etiqueta(texto, 16, color))

	visible = true
	_volver.grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()
