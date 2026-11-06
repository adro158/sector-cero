extends Control

## Ventana del ranking en el menú: las 10 mejores partidas de este ordenador,
## con el orden de GestorGuardado (victorias de la más rápida a la más lenta y
## después derrotas de la que más aguantó).
##
## Desde el 06/11, una fila dibujada por partida (fila_partida.gd, la misma de
## «tus últimas partidas» de la cuenta): medallas, victoria o derrota con su
## icono, la dificultad en un chip de su color y, resaltadas, las partidas de
## la cuenta con la que se ha entrado. Antes era una tabla de texto.
##
## Sin class_name: el menú la carga con preload (ver embestida_horda.gd).

signal cerrado

const FilaPartida := preload("res://escenas/interfaz/fila_partida.gd")
const Cuenta := preload("res://globales/cuenta.gd")

var _filas: VBoxContainer
var _volver: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("RANKING", 32, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	_filas = VBoxContainer.new()
	_filas.add_theme_constant_override("separation", 4)
	var centro := CenterContainer.new()
	centro.add_child(_filas)
	caja.add_child(centro)

	_volver = EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_volver)

	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false


## Se rellena al abrir, así siempre muestra lo último guardado.
func abrir() -> void:
	for hijo in _filas.get_children():
		hijo.queue_free()
	var partidas := GestorGuardado.ranking()
	if partidas.is_empty():
		_filas.add_child(EstiloInterfaz.etiqueta("Todavía no hay partidas en el ranking.", 16))
	else:
		_filas.add_child(FilaPartida.cabecera("#", true))
	var tuya := _nombre_de_la_cuenta()
	for i in partidas.size():
		var partida: Dictionary = partidas[i]
		# Con cuenta, la partida se guarda con su nombre (pantalla_final.gd):
		# así se sabe cuáles son tuyas. Sin cuenta no se resalta ninguna.
		var resaltada: bool = not tuya.is_empty() and str(partida.nombre).to_lower() == tuya.to_lower()
		_filas.add_child(FilaPartida.crear(partida, i, resaltada))

	visible = true
	_volver.grab_focus()


## Vacío si se juega como invitado.
func _nombre_de_la_cuenta() -> String:
	if Cuenta.actual == null:
		return ""
	return Cuenta.actual.nombre


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()
