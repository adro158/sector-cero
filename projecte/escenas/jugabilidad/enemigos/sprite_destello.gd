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

## Lo que le queda al destello, en segundos.
var _restante := 0.0


func _ready() -> void:
	# Un material para cada uno: si lo compartieran, al dar a un élite
	# destellarían todos.
	material = ShaderMaterial.new()
	material.shader = SHADER


func destellar() -> void:
	_restante = DURACION


func _process(delta: float) -> void:
	if _restante <= 0.0:
		return
	# Como en la horda: blanco del todo al recibir el golpe y vuelve a su color
	# en DURACION. Con el juego en pausa se queda como esté.
	_restante = maxf(_restante - delta, 0.0)
	material.set_shader_parameter("destello", _restante / DURACION)
