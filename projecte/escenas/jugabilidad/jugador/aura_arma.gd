extends Node2D

## Dibuja el alcance de un arma de área y destella cuando esta se ejecuta, para
## que se vea dónde golpea y en qué momento. Es un marcador de posición: cuando
## haya shaders y partículas, este dibujo se sustituye.

@export var indice_arma: int = 0
@export var color: Color = Color(0.35, 0.8, 1.0, 1.0)
@export var duracion_destello: float = 0.12

var _gestor_armas: Node
var _destello := 0.0


func _ready() -> void:
	_gestor_armas = get_parent().get_node("GestorArmas")
	_gestor_armas.arma_disparada.connect(_al_disparar)


func _al_disparar(indice: int) -> void:
	if indice == indice_arma:
		_destello = duracion_destello


func _process(delta: float) -> void:
	_destello = maxf(_destello - delta, 0.0)
	queue_redraw()


func _draw() -> void:
	if indice_arma >= _gestor_armas.armas.size():
		return

	var arma: DatosArma = _gestor_armas.armas[indice_arma]
	var radio: float = arma.radio * _gestor_armas.multiplicador_alcance
	var encendido := _destello > 0.0

	if encendido:
		draw_circle(Vector2.ZERO, radio, Color(color, 0.12))

	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 64, Color(color, 0.85 if encendido else 0.3), 2.0, true)
