extends CanvasLayer

## Fundido a negro entre escenas: la pantalla se oscurece, se cambia de escena y
## vuelve a aclararse. Es un autoload porque tiene que sobrevivir al cambio de
## escena, que borra todo lo demás.
##
## Además, al arrancar pone el icono de la ventana (ver _ready): es la primera
## pantalla que se ve y su script llega con el .pck de actualización.

const IconoLinux := preload("res://globales/icono_linux.gd")
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

	# El icono de la ventana. Godot lo pone al arrancar con el project.godot
	# del ejecutable, y los anteriores a la v1.3 no lo traen: así llega también
	# a quien actualiza solo con el .pck. En Windows, el .ico, que tiene los
	# tamaños pequeños dibujados a mano.
	if OS.get_name() == "Windows":
		DisplayServer.set_native_icon("res://medios/icono/icono.ico")
	elif OS.get_name() == "Linux":
		DisplayServer.set_icon(load("res://medios/icono/icono.png").get_image())
		# Solo en el juego exportado: desde el editor, el .desktop apuntaría
		# al ejecutable de Godot.
		if OS.has_feature("template"):
			IconoLinux.instalar()


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
