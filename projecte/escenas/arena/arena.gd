extends Node2D

## Mapa infinito, como en Vampire Survivors. El suelo es un rectángulo mucho más
## grande que la pantalla que se recoloca cada fotograma bajo la cámara. Su
## shader dibuja según la posición en el mundo, así que el dibujo no se mueve
## con él: parece un suelo fijo que no se acaba nunca.
##
## Además, el suelo reacciona a la partida: los pulsos de datos van más rápido
## y brillan más según pasan los minutos, y cuando aparece el jefe los pulsos y
## el brillo de los chips se vuelven rojos y los pulsos se aceleran.

## Velocidad de los pulsos (baldosas por segundo) al empezar, al llegar al
## final de la partida y con el jefe.
@export var velocidad_inicial := 0.3
@export var velocidad_final := 0.6
@export var velocidad_jefe := 1.1
## Brillo de los pulsos al empezar y al llegar al final de la partida.
@export var intensidad_inicial := 1.0
@export var intensidad_final := 1.6
@export var color_jefe := Color(1.0, 0.25, 0.3)

@onready var _suelo: ColorRect = $Suelo

var _material: ShaderMaterial
var _velocidad := 0.3
var _avance := 0.0
var _hay_jefe := false


func _ready() -> void:
	# Una copia del material para esta partida: si se cambiara el del fichero,
	# el rojo del jefe se quedaría puesto en la siguiente partida.
	_material = _suelo.material.duplicate() as ShaderMaterial
	_suelo.material = _material
	_velocidad = velocidad_inicial
	_material.set_shader_parameter("intensidad_pulso", intensidad_inicial)
	BusEventos.tiempo_partida.connect(_al_pasar_tiempo)
	BusEventos.jefe_aparecio.connect(_al_aparecer_jefe)


func _process(delta: float) -> void:
	var camara := get_viewport().get_camera_2d()
	if camara != null:
		_suelo.global_position = camara.get_screen_center_position() - _suelo.size * 0.5
	# El avance de los pulsos se suma aquí, y no con TIME en el shader, para poder
	# cambiar la velocidad sin que salten de sitio. Con la pausa también se paran.
	_avance += _velocidad * delta
	_material.set_shader_parameter("avance_pulsos", _avance)


func _al_pasar_tiempo(segundos: float, duracion: float) -> void:
	if _hay_jefe:
		return
	var progreso := clampf(segundos / duracion, 0.0, 1.0)
	_velocidad = lerpf(velocidad_inicial, velocidad_final, progreso)
	_material.set_shader_parameter("intensidad_pulso", lerpf(intensidad_inicial, intensidad_final, progreso))


func _al_aparecer_jefe() -> void:
	_hay_jefe = true
	_velocidad = velocidad_jefe
	# Los pulsos y el brillo de los chips pasan a rojo a la vez, en segundo y medio.
	var cambio := create_tween().set_parallel()
	cambio.tween_property(_material, "shader_parameter/color_pulso", color_jefe, 1.5)
	cambio.tween_property(_material, "shader_parameter/color_brillo", color_jefe, 1.5)
