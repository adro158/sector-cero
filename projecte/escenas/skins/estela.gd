extends Node2D

## La estela de un jugador (de Alan, 19/11; un premio del pase, premios.gd):
## un rastro de píxeles de su color por donde va andando, que se apaga
## enseguida. Es pequeña y va por debajo del personaje y de la horda para no
## tapar nada. Solo dibuja: no toca la partida.
##
## La pone cambio_personaje.gd como hija del jugador (poner_estela). Sin
## class_name: se carga con preload.

## Cuántos puntos guarda y cada cuánto se apunta uno (en píxeles andados).
const PUNTOS := 14
const CADA := 6.0
const LADO := 3.0

var color := Color.WHITE
var _puntos: Array[Vector2] = []
## Dónde estaba el jugador en el paso anterior: para saber si está quieto.
var _antes := Vector2.INF


func _ready() -> void:
	# Detrás de su jugador, pero encima del suelo: con un z por debajo de 0 se
	# quedaba bajo la arena y no se veía. top_level: las posiciones son las del
	# mundo, aunque sea hija del jugador.
	show_behind_parent = true
	top_level = true


func _physics_process(_delta: float) -> void:
	var donde: Vector2 = get_parent().global_position
	if _puntos.is_empty() or _puntos[-1].distance_to(donde) >= CADA:
		_puntos.append(donde)
		if _puntos.size() > PUNTOS:
			_puntos.pop_front()
	elif donde.is_equal_approx(_antes) and not _puntos.is_empty():
		# Quieto: la estela se va recogiendo.
		_puntos.pop_front()
	_antes = donde
	queue_redraw()


func _draw() -> void:
	# Mirando sin personaje (multijugador) no se ve el personaje: tampoco ella.
	if not get_parent().get_node("Sprite").visible:
		return
	# Los más viejos, más pequeños y más apagados. A los pies del personaje.
	for i in _puntos.size():
		var parte := float(i + 1) / _puntos.size()
		var lado := LADO * (0.5 + 0.5 * parte)
		draw_rect(Rect2(_puntos[i] + Vector2(-lado / 2.0, -lado / 2.0), Vector2(lado, lado)),
			Color(color.r, color.g, color.b, 0.6 * parte))
