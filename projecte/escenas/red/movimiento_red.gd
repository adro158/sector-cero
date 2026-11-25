extends RefCounted

## En los clientes, cómo se mueve lo que el anfitrión pone en su sitio con el
## estado (los élites y los jefes). Antes saltaba al sitio nuevo 20 veces por
## segundo y se veía a tirones (Adam, 18/11). Ahora va hacia él a la velocidad
## justa para llegar cuando llega el siguiente estado: se ve un estado por
## detrás (50 ms), pero sin saltos. Si el sitio nuevo está muy lejos (aparece o
## reaparece al otro lado del jugador), salta.
##
## La horda va de otra forma (gestor_enemigos.gd): son cientos en un solo
## nodo, y con sus ids se calcula la velocidad de cada uno.
##
## Uno por nodo. Sin class_name: se carga con preload.

## Lo que hay entre un estado y el siguiente: 3 pasos de física del anfitrión
## (partida_red.gd).
const INTERVALO := 3.0 / 60.0
## Más lejos que esto, salta.
const SALTO := 400.0

var _destino := Vector2.INF
var _rapidez := 0.0


## Al llegar un estado con el sitio nuevo. Devuelve dónde ponerlo ahora: donde
## está (y ya irá) o, si salta, el sitio nuevo.
func seguir(desde: Vector2, hacia: Vector2, de_golpe := false) -> Vector2:
	_destino = hacia
	if de_golpe or desde.distance_to(hacia) > SALTO:
		_rapidez = 0.0
		return hacia
	_rapidez = desde.distance_to(hacia) / INTERVALO
	return desde


## En cada paso de física: un poco más cerca, sin pasarse.
func mover(desde: Vector2, delta: float) -> Vector2:
	if _destino == Vector2.INF:
		return desde
	return desde.move_toward(_destino, _rapidez * delta)
