extends Node2D

## Partículas: chispas cuadradas que salen disparadas, frenan y se apagan. Las
## sueltan el malware al morir (de su color), el jugador al recibir daño y al
## subir de nivel.
##
## Mismo patrón que la horda: arrays de tamaño fijo y un MultiMesh que las
## dibuja todas de una vez. Cada partícula lleva su propio color en el MultiMesh
## (use_colors), que es lo que permite que cada explosión sea de un color.

const MAXIMO_PARTICULAS := 1200

@export var tamano: float = 4.0
@export var duracion: float = 0.45
## Fracción de la velocidad que se pierde por segundo.
@export var frenado: float = 3.5

var _posiciones := PackedVector2Array()
var _velocidades := PackedVector2Array()
var _tiempos := PackedFloat32Array()
var _colores := PackedColorArray()
var _activas := 0
var _color_por_tipo := {}
var _jugador: Node2D

@onready var _malla: MultiMeshInstance2D = $Particulas


func _ready() -> void:
	_posiciones.resize(MAXIMO_PARTICULAS)
	_velocidades.resize(MAXIMO_PARTICULAS)
	_tiempos.resize(MAXIMO_PARTICULAS)
	_colores.resize(MAXIMO_PARTICULAS)
	_preparar_multimesh()

	_jugador = get_tree().get_first_node_in_group("jugador")
	# El color de cada tipo de malware sale de su recurso de datos.
	for objetivo in get_tree().get_nodes_in_group("objetivos"):
		if "datos" in objetivo:
			_color_por_tipo[objetivo.datos.tipo] = objetivo.datos.color

	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)
	_jugador.get_node("Salud").danado.connect(_al_danar_jugador)


func _preparar_multimesh() -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(tamano, tamano)

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	# Hay que activarlo antes de fijar el número de instancias.
	multimesh.use_colors = true
	multimesh.mesh = quad
	multimesh.instance_count = MAXIMO_PARTICULAS
	multimesh.visible_instance_count = 0
	_malla.multimesh = multimesh


## Suelta cantidad partículas en todas direcciones desde posicion.
func estallido(posicion: Vector2, color: Color, cantidad: int, velocidad: float) -> void:
	for i in cantidad:
		# Si se llena, las nuevas se descartan: son decoración.
		if _activas >= MAXIMO_PARTICULAS:
			return
		_posiciones[_activas] = posicion
		_velocidades[_activas] = Vector2.RIGHT.rotated(randf() * TAU) * velocidad * randf_range(0.3, 1.0)
		_tiempos[_activas] = 0.0
		_colores[_activas] = color
		_activas += 1


func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	match tipo:
		"jefe":
			estallido(posicion, Color(0.75, 0.3, 1.0), 160, 520.0)
		"elite":
			estallido(posicion, Color(1.0, 0.85, 0.3), 50, 360.0)
		_:
			estallido(posicion, _color_por_tipo.get(tipo, Color.WHITE), 7, 200.0)


func _al_subir_nivel(_opciones: Array) -> void:
	estallido(_jugador.global_position, EstiloInterfaz.NEON, 40, 380.0)


func _al_danar_jugador(_cantidad: float) -> void:
	estallido(_jugador.global_position, Color(1.0, 0.25, 0.3), 10, 240.0)


func _process(delta: float) -> void:
	# Hacia atrás porque al quitar una se trae la última a su hueco.
	var i := _activas - 1
	while i >= 0:
		_tiempos[i] += delta
		if _tiempos[i] >= duracion:
			_eliminar(i)
		else:
			_posiciones[i] += _velocidades[i] * delta
			_velocidades[i] *= maxf(1.0 - frenado * delta, 0.0)
		i -= 1

	var multimesh := _malla.multimesh
	for j in _activas:
		multimesh.set_instance_transform_2d(j, Transform2D(0.0, _posiciones[j]))
		# Se apagan bajando la opacidad a lo largo de su vida.
		multimesh.set_instance_color(j, Color(_colores[j], 1.0 - _tiempos[j] / duracion))
	multimesh.visible_instance_count = _activas


func _eliminar(indice: int) -> void:
	_activas -= 1
	_posiciones[indice] = _posiciones[_activas]
	_velocidades[indice] = _velocidades[_activas]
	_tiempos[indice] = _tiempos[_activas]
	_colores[indice] = _colores[_activas]
