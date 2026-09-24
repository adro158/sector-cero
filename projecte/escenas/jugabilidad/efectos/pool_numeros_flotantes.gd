extends Node2D

## Números de daño que suben y se desvanecen. A diferencia de los enemigos y las
## gemas no se dibujan con MultiMesh, porque un MultiMesh repite una misma malla
## y aquí cada número muestra un texto distinto. Se pintan todos desde un único
## nodo con draw_string, así que sigue siendo una sola llamada de dibujado.

const MAXIMO_NUMEROS := 150

@export var duracion: float = 0.55
@export var velocidad_subida: float = 70.0
@export var tamano_fuente: int = 15
@export var color: Color = Color(1.0, 0.95, 0.65, 1.0)

var _posiciones := PackedVector2Array()
var _cantidades := PackedFloat32Array()
var _tiempos := PackedFloat32Array()
var _activos := 0
var _fuente: Font


func _ready() -> void:
	_posiciones.resize(MAXIMO_NUMEROS)
	_cantidades.resize(MAXIMO_NUMEROS)
	_tiempos.resize(MAXIMO_NUMEROS)
	_fuente = ThemeDB.fallback_font

	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		gestor.enemigo_danado.connect(_al_danar_enemigo)


func _al_danar_enemigo(posicion: Vector2, cantidad: float) -> void:
	# Al llenarse se descartan los nuevos. Con un arma de área golpeando a
	# decenas de enemigos a la vez, el tope evita llenar la pantalla de texto.
	if _activos >= MAXIMO_NUMEROS:
		return

	_posiciones[_activos] = posicion
	_cantidades[_activos] = cantidad
	_tiempos[_activos] = 0.0
	_activos += 1


func _process(delta: float) -> void:
	var i := _activos - 1

	while i >= 0:
		_tiempos[i] += delta

		if _tiempos[i] >= duracion:
			_eliminar(i)
		else:
			_posiciones[i] = _posiciones[i] - Vector2(0.0, velocidad_subida * delta)

		i -= 1

	queue_redraw()


func _eliminar(indice: int) -> void:
	_activos -= 1
	_posiciones[indice] = _posiciones[_activos]
	_cantidades[indice] = _cantidades[_activos]
	_tiempos[indice] = _tiempos[_activos]


func _draw() -> void:
	for i in _activos:
		var desvanecido := 1.0 - _tiempos[i] / duracion
		draw_string(
			_fuente,
			_posiciones[i],
			str(roundi(_cantidades[i])),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			tamano_fuente,
			Color(color, desvanecido)
		)
