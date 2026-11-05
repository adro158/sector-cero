extends Node

## Lo que es de todo el juego y no de una pantalla (05/11):
## - el mando en los menús: en Godot 4.7, ui_accept y ui_cancel solo traen el
##   teclado, así que con el mando no se podía elegir mejora ni volver. Al
##   arrancar se añaden A (aceptar) y B (volver).
## - con qué se juega, mando o teclado y ratón, para que la interfaz enseñe sus
##   botones o sus teclas (texto_mando.gd y la barra del equipo). Avisa con
##   BusEventos.dispositivo_cambiado.
## - F11, pantalla completa en cualquier pantalla.
##
## Lo crea Transicion al arrancar, como el icono: así llega con el .pck, sin
## tocar project.godot. Sin class_name: se carga con preload.

## Si lo último que se ha tocado es el mando. Estática para que la lea
## cualquiera sin buscar el nodo.
static var con_mando := false


func _ready() -> void:
	# También en pausa: los menús de pausa, mejoras y fin de partida.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_anadir_boton("ui_accept", JOY_BUTTON_A)
	_anadir_boton("ui_cancel", JOY_BUTTON_B)


## _input, y no _unhandled_input, para enterarse aunque otro se quede el
## evento (un botón con el foco se queda el A).
func _input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo and evento.keycode == KEY_F11:
		GestorGuardado.cambiar_opcion("pantalla_completa", not GestorGuardado.opcion("pantalla_completa"))
		get_viewport().set_input_as_handled()

	# El stick, solo si se empuja de verdad: parado tiembla un poco y daría
	# saltos de teclado a mando.
	var mando := evento is InputEventJoypadButton or (evento is InputEventJoypadMotion and absf(evento.axis_value) > 0.5)
	var teclado := evento is InputEventKey or evento is InputEventMouseButton
	if (mando and not con_mando) or (teclado and con_mando):
		con_mando = mando
		BusEventos.dispositivo_cambiado.emit(con_mando)


## Solo si la acción no lo tiene ya (como en teclas_antiguas.gd).
func _anadir_boton(accion: String, boton: JoyButton) -> void:
	for evento in InputMap.action_get_events(accion):
		if evento is InputEventJoypadButton and evento.button_index == boton:
			return
	var nuevo := InputEventJoypadButton.new()
	nuevo.button_index = boton
	InputMap.action_add_event(accion, nuevo)
