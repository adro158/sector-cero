extends Sprite2D

## Sprite de los élites y del jefe: se pone blanco un instante al recibir un
## golpe, como la horda, para que se note que se les está dando. Su script
## llama a destellar() en danar_en_area.
##
## Sin class_name a propósito: lo cargan sus escenas y sus scripts con preload
## (ver embestida_horda.gd).

const SHADER := preload("res://medios/shaders/destello.gdshader")
## Lo mismo que la horda (DURACION_DESTELLO de gestor_enemigos.gd).
const DURACION := 0.1
## Después de un destello, esto sin volver a destellar: con el Firewall y los
## rebotes del Ping reciben varios golpes por segundo y, si no, se verían casi
## siempre blancos (mejoras propuestas, sonido 15).
const RESPIRO := 0.1

## Lo blanco que se pone, de 0 a 1. Los jefes, 0,6: así no pierden su color.
@export var intensidad: float = 1.0

## Lo que le queda al destello, en segundos.
var _restante := 0.0
## Lo que falta para que pueda volver a destellar.
var _hasta_otro := 0.0


func _ready() -> void:
	# Un material para cada uno: si lo compartieran, al dar a un élite
	# destellarían todos.
	material = ShaderMaterial.new()
	material.shader = SHADER


func destellar() -> void:
	if _hasta_otro > 0.0:
		return
	_restante = DURACION
	_hasta_otro = DURACION + RESPIRO


func _process(delta: float) -> void:
	_hasta_otro = maxf(_hasta_otro - delta, 0.0)
	if _restante <= 0.0:
		return
	# Como en la horda: blanco al recibir el golpe y vuelve a su color en
	# DURACION. Con el juego en pausa se queda como esté.
	_restante = maxf(_restante - delta, 0.0)
	material.set_shader_parameter("destello", _restante / DURACION * intensidad)
