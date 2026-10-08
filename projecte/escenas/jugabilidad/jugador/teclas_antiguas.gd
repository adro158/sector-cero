extends RefCounted

## Las teclas nuevas están en project.godot, pero project.godot no viaja en las
## actualizaciones pequeñas (.pck): un ejecutable antiguo sigue con sus teclas
## de siempre. Aquí se añaden las que le falten al empezar la partida, y así la
## versión nueva funciona sin descargar el juego entero.
##
## - v0.7: E pasa al siguiente personaje y Q vuelve al anterior. Antes, Q
##   pasaba al siguiente.
## - v0.8: R lanza la ulti.


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


static func _anadir_tecla(accion: String, tecla: Key) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = tecla
	InputMap.action_add_event(accion, evento)
