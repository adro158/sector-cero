extends Node2D

## Dibuja el alcance de cada arma y destella cuando esta se ejecuta, para que se
## vea dónde golpea y en qué momento. El anillo se tiñe de rojo según la
## resistencia que el malware ha desarrollado contra esa arma. Es un marcador de
## posición: cuando haya shaders y partículas, este dibujo se sustituye.

@export var color: Color = Color(0.35, 0.8, 1.0, 1.0)
@export var color_resistido: Color = Color(1.0, 0.0, 0.15, 1.0)
@export var duracion_destello: float = 0.12

var _gestor_armas: Node
var _resistencia_malware: Node
var _destellos := PackedFloat32Array()


func _ready() -> void:
	_gestor_armas = get_parent().get_node("GestorArmas")
	_gestor_armas.arma_disparada.connect(_al_disparar)
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")


func _al_disparar(indice: int) -> void:
	while _destellos.size() <= indice:
		_destellos.append(0.0)

	_destellos[indice] = duracion_destello


func _process(delta: float) -> void:
	for i in _destellos.size():
		_destellos[i] = maxf(_destellos[i] - delta, 0.0)

	queue_redraw()


func _draw() -> void:
	var armas: Array = _gestor_armas.armas

	for i in armas.size():
		var arma: DatosArma = armas[i]
		if arma.tipo != DatosArma.Tipo.AREA:
			continue

		var radio: float = arma.radio * _gestor_armas.multiplicador_alcance
		var encendido := i < _destellos.size() and _destellos[i] > 0.0
		var tinte := color.lerp(color_resistido, _resistencia_malware.resistencia(arma))

		if encendido:
			draw_circle(Vector2.ZERO, radio, Color(tinte, 0.12))

		draw_arc(Vector2.ZERO, radio, 0.0, TAU, 64, Color(tinte, 0.85 if encendido else 0.25), 2.0, true)
