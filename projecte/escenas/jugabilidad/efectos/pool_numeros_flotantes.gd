extends Node2D

## Números de daño que suben y se desvanecen. A diferencia de los enemigos y las
## gemas no se dibujan con MultiMesh, porque un MultiMesh repite una misma malla
## y aquí cada número muestra un texto distinto. Se pintan todos desde un único
## nodo con draw_string, así que sigue siendo una sola llamada de dibujado.
##
## Desde el 24/10 (mejoras propuestas, sonido 12): con la letra del juego y
## contorno, centrados, más grandes cuanto más fuerte es el golpe, con un
## «pop» al salir y una subida que frena.

const MAXIMO_NUMEROS := 150
## Lo que dura el «pop» del principio y lo grande que se ve en él.
const DURA_POP := 0.08
const ESCALA_POP := 1.5
## El tamaño de la letra crece con el daño, hasta este tope.
const TAMANO_MAXIMO := 24
## Grosor del contorno oscuro, en píxeles.
const CONTORNO := 4
const COLOR_CONTORNO := Color(0.02, 0.04, 0.07)
## Lo más que se separan a los lados los de la horda, que salen justo encima
## del enemigo y, si no, se pintarían unos encima de otros.
const SEPARACION := 10.0

@export var duracion: float = 0.55
## Lo que sube un número en toda su vida, frenando al final.
@export var subida: float = 38.0
@export var tamano_fuente: int = 14
@export var color: Color = Color(1.0, 0.95, 0.65, 1.0)
## Hacia este color se tiñen los golpes de un arma a la que el malware resiste.
@export var color_resistido: Color = Color(1.0, 0.0, 0.15, 1.0)

## Dónde salió cada número; la subida se calcula al dibujarlo.
var _posiciones := PackedVector2Array()
var _cantidades := PackedFloat32Array()
var _resistencias := PackedFloat32Array()
var _tiempos := PackedFloat32Array()
var _activos := 0
var _fuente: Font
## Un azar propio para separarlos, con semilla fija: si gastara el de la
## partida, el simulador ya no repetiría las mismas partidas.
var _azar := RandomNumberGenerator.new()


func _ready() -> void:
	_posiciones.resize(MAXIMO_NUMEROS)
	_cantidades.resize(MAXIMO_NUMEROS)
	_resistencias.resize(MAXIMO_NUMEROS)
	_tiempos.resize(MAXIMO_NUMEROS)
	# La misma letra monoespaciada que el resto de la interfaz.
	_fuente = EstiloInterfaz.tema().default_font
	_azar.seed = 11

	for objetivo in get_tree().get_nodes_in_group("objetivos"):
		objetivo.enemigo_danado.connect(_al_danar_enemigo)


func _al_danar_enemigo(posicion: Vector2, cantidad: float, resistencia: float) -> void:
	# Al llenarse se descartan los nuevos. Con un arma de área golpeando a
	# decenas de enemigos a la vez, el tope evita llenar la pantalla de texto.
	if _activos >= MAXIMO_NUMEROS:
		return

	_posiciones[_activos] = posicion + Vector2(_azar.randf_range(-SEPARACION, SEPARACION), 0.0)
	_cantidades[_activos] = cantidad
	_resistencias[_activos] = resistencia
	_tiempos[_activos] = 0.0
	_activos += 1


func _process(delta: float) -> void:
	var i := _activos - 1

	while i >= 0:
		_tiempos[i] += delta
		if _tiempos[i] >= duracion:
			_eliminar(i)
		i -= 1

	queue_redraw()


func _eliminar(indice: int) -> void:
	_activos -= 1
	_posiciones[indice] = _posiciones[_activos]
	_cantidades[indice] = _cantidades[_activos]
	_resistencias[indice] = _resistencias[_activos]
	_tiempos[indice] = _tiempos[_activos]


func _draw() -> void:
	for i in _activos:
		var avance := _tiempos[i] / duracion
		var desvanecido := 1.0 - avance
		# Se mezcla con el rojo en la misma proporción que la resistencia: con
		# un 50% de resistencia, el número queda a medio camino.
		var tinte := color.lerp(color_resistido, _resistencias[i])
		var texto := str(roundi(_cantidades[i]))
		# Un golpe de 10 sale a 18 y uno de 100, a 22.
		var tamano := mini(tamano_fuente + roundi(4.0 * log(maxf(_cantidades[i], 1.0)) / log(10.0)), TAMANO_MAXIMO)
		if _tiempos[i] < DURA_POP:
			tamano = roundi(tamano * ESCALA_POP)
		# Sube deprisa al principio y frena: 1 - (1 - avance)².
		var subido := subida * (1.0 - (1.0 - avance) * (1.0 - avance))
		var ancho := _fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x
		var donde := _posiciones[i] - Vector2(ancho / 2.0, subido)
		draw_string_outline(_fuente, donde, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, CONTORNO, Color(COLOR_CONTORNO, desvanecido))
		draw_string(_fuente, donde, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, Color(tinte, desvanecido))
