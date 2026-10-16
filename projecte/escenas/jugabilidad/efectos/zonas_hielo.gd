extends Node2D

## Las zonas de hielo que deja el jefe final al lanzar sus cristales
## (ataques_jefe_final.gd). Duran unos segundos y, mientras el jugador está
## dentro, va más lento: se reutiliza ralentizar(), como en el aura lenta de
## los élites.
##
## Va al principio de RaizJuego, como Explosiones: así el hielo queda encima
## del suelo y debajo del jugador y de la horda. Está en el grupo zonas_hielo.
## Sin class_name: es un script de una escena.

const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
const DURACION := 6.0
const RADIO := 60.0
## Fracción de velocidad que pierde el jugador dentro.
const LENTITUD := 0.4

## Cada zona: [posición en el mundo, segundos desde que se formó].
var _zonas: Array = []
var _jugador: Node2D


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")


func crear(posicion: Vector2) -> void:
	_zonas.append([posicion, 0.0])


## Para el simulador: dónde hay hielo.
func posiciones() -> Array[Vector2]:
	var resultado: Array[Vector2] = []
	for zona in _zonas:
		resultado.append(zona[0])
	return resultado


func _physics_process(delta: float) -> void:
	if _zonas.is_empty():
		return
	for zona in _zonas:
		zona[1] += delta
		if _jugador.global_position.distance_to(zona[0]) < RADIO:
			_jugador.ralentizar(LENTITUD)
	_zonas = _zonas.filter(func(zona): return zona[1] < DURACION)
	queue_redraw()


func _draw() -> void:
	for zona in _zonas:
		Dibujo.hielo(self, to_local(zona[0]), zona[1], DURACION)
