extends RefCounted

## Las teclas nuevas están en project.godot, pero project.godot no viaja en las
## actualizaciones pequeñas (.pck): un ejecutable antiguo sigue con sus teclas
## de siempre. Aquí se añaden las que le falten al empezar la partida, y así la
## versión nueva funciona sin descargar el juego entero.
##
## - v0.7: E pasa al siguiente personaje y Q vuelve al anterior. Antes, Q
##   pasaba al siguiente.
## - v0.8: R lanza la ulti.
## - 24/10 (mejoras propuestas, jugabilidad 8): el mando completo. LB vuelve al
##   anterior y RB pasa al siguiente (además de Y), la cruceta mueve y Select
##   abre el panel del equipo, con la acción nueva ver_equipo (también la C).
##   Estos se añaden siempre por aquí: no están en project.godot.


static func configurar() -> void:
	if not InputMap.has_action("personaje_anterior"):
		InputMap.add_action("personaje_anterior")
		for evento in InputMap.action_get_events("cambiar_personaje"):
			if evento is InputEventKey and evento.physical_keycode == KEY_Q:
				InputMap.action_erase_event("cambiar_personaje", evento)
		_anadir_tecla("personaje_anterior", KEY_Q)
		_anadir_tecla("cambiar_personaje", KEY_E)
	if not InputMap.has_action("ulti"):
		InputMap.add_action("ulti")
		_anadir_tecla("ulti", KEY_R)
	if not InputMap.has_action("ver_equipo"):
		InputMap.add_action("ver_equipo")
		_anadir_tecla("ver_equipo", KEY_C)
	_anadir_boton("ver_equipo", JOY_BUTTON_BACK)
	_anadir_boton("personaje_anterior", JOY_BUTTON_LEFT_SHOULDER)
	_anadir_boton("cambiar_personaje", JOY_BUTTON_RIGHT_SHOULDER)
	_anadir_boton("mover_arriba", JOY_BUTTON_DPAD_UP)
	_anadir_boton("mover_abajo", JOY_BUTTON_DPAD_DOWN)
	_anadir_boton("mover_izquierda", JOY_BUTTON_DPAD_LEFT)
	_anadir_boton("mover_derecha", JOY_BUTTON_DPAD_RIGHT)


static func _anadir_tecla(accion: String, tecla: Key) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = tecla
	InputMap.action_add_event(accion, evento)


## Solo si la acción no lo tiene ya: configurar() se llama en cada partida.
static func _anadir_boton(accion: String, boton: JoyButton) -> void:
	for evento in InputMap.action_get_events(accion):
		if evento is InputEventJoypadButton and evento.button_index == boton:
			return
	var nuevo := InputEventJoypadButton.new()
	nuevo.button_index = boton
	InputMap.action_add_event(accion, nuevo)
