extends CanvasLayer

## Filtro CRT a pantalla completa, encima del juego y de la interfaz. Es un
## autoload para que esté en todas las escenas sin añadirlo a cada una. Se
## enciende y se apaga desde las opciones. Desde el 19/11, con el tema de
## color del pase (premios.gd, de Alan): el tinte del shader.

const Premios := preload("res://globales/premios.gd")
## Cuánto se tiñe con un tema puesto (0: nada; 1: todo del color del tema).
const FUERZA_TEMA := 0.7

var _material: ShaderMaterial


func _ready() -> void:
	# Por encima del juego, el HUD y el panel técnico; por debajo del fundido.
	layer = 110

	var filtro := ColorRect.new()
	_material = ShaderMaterial.new()
	_material.shader = preload("res://medios/shaders/crt.gdshader")
	filtro.material = _material
	filtro.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Que los clicks lo atraviesen hasta los botones de debajo.
	filtro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(filtro)

	visible = GestorGuardado.opcion("crt")
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)
	# En diferido: la cartera la crea Transicion, que va antes, pero así no
	# depende del orden.
	_poner_tema.call_deferred()


func _al_cambiar_opcion(clave: String, valor: Variant) -> void:
	if clave == "crt":
		visible = valor
	elif clave == "perfil":
		_poner_tema()


## El tema que lleva puesto (si lo tiene): su color en el tinte.
func _poner_tema() -> void:
	var cartera: Node = load("res://globales/cartera.gd").actual
	var tema: String = Premios.perfil(cartera).tema if cartera != null else ""
	_material.set_shader_parameter("tinte", Premios.color("tema", tema, Color.WHITE))
	_material.set_shader_parameter("fuerza_tinte", FUERZA_TEMA if tema != "" else 0.0)
