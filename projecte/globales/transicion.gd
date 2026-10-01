extends CanvasLayer

## Fundido a negro entre escenas: la pantalla se oscurece, se cambia de escena y
## vuelve a aclararse. Es un autoload porque tiene que sobrevivir al cambio de
## escena, que borra todo lo demás.

const DURACION := 0.25

var _velo: ColorRect
var _cambiando := false


func _ready() -> void:
	# Por encima de todo, también del filtro CRT.
	layer = 120
	# Los cambios de escena se piden a menudo con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_velo = ColorRect.new()
	_velo.color = Color.BLACK
	_velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_velo)

	# El juego también se abre con un fundido desde negro.
	create_tween().tween_property(_velo, "modulate:a", 0.0, DURACION * 2.0)


## Cambia a la escena de la ruta. Con la ruta vacía recarga la actual, que es
## lo que hace "reintentar".
func cambiar_a(ruta: String) -> void:
	# Un segundo Enter durante el fundido no debe lanzar otro cambio.
	if _cambiando:
		return
	_cambiando = true
	# Mientras dura, el velo se queda los clicks para no pulsar nada debajo.
	_velo.mouse_filter = Control.MOUSE_FILTER_STOP

	var fundido := create_tween()
	fundido.tween_property(_velo, "modulate:a", 1.0, DURACION)
	await fundido.finished

	get_tree().paused = false
	if ruta.is_empty():
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file(ruta)

	create_tween().tween_property(_velo, "modulate:a", 0.0, DURACION)
	_velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cambiando = false
