extends Node2D

## Mapa infinito, como en Vampire Survivors. El suelo es un rectángulo mucho más
## grande que la pantalla que se recoloca cada fotograma bajo la cámara. Su
## shader dibuja según la posición en el mundo, así que el dibujo no se mueve
## con él: parece un suelo fijo que no se acaba nunca.

@onready var _suelo: ColorRect = $Suelo


func _process(_delta: float) -> void:
	var camara := get_viewport().get_camera_2d()
	if camara != null:
		_suelo.global_position = camara.get_screen_center_position() - _suelo.size * 0.5
