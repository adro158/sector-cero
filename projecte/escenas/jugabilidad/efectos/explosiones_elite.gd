extends Node2D

## Explosión de los rootkit explosivos: escucha elite_exploto y dibuja la
## animación donde ha estallado, y debajo la quemadura que deja en el suelo.
## Solo es dibujo: el daño, el radio y el aviso los pone enemigo_elite.gd.
##
## Va el primero en RaizJuego: así la quemadura queda encima del suelo pero
## debajo del jugador y de la horda. La explosión se dibuja en el hijo Fuego,
## con z_index 4, para que salga encima de los enemigos (las chispas, z 5, y los
## números, z 10, siguen por encima).
##
## Sin class_name: es un script de una escena, no hace falta que sea global.

const EXPLOSION := preload("res://medios/sprites/explosion/rootkit_explosion.png")
const QUEMADURA := preload("res://medios/sprites/explosion/rootkit_quemadura.png")
const FOTOGRAMAS := 12
const SEGUNDOS_POR_FOTOGRAMA := 0.05
## Segundos que dura la quemadura; en el último se va borrando.
const DURA_QUEMADURA := 4.0

## Cada explosión: [posición en el mundo, segundos desde que estalló].
var _explosiones: Array = []

@onready var _fuego: Node2D = $Fuego


func _ready() -> void:
	BusEventos.elite_exploto.connect(func(posicion: Vector2): _explosiones.append([posicion, 0.0]))
	# Fuego no tiene script propio: se dibuja desde aquí con su señal draw.
	_fuego.draw.connect(_dibujar_fuego)


## Con el juego en pausa no se llama: la explosión se queda quieta y sigue al
## reanudar.
func _process(delta: float) -> void:
	if _explosiones.is_empty():
		return
	for explosion in _explosiones:
		explosion[1] += delta
	_explosiones = _explosiones.filter(func(explosion): return explosion[1] < DURA_QUEMADURA)
	queue_redraw()
	_fuego.queue_redraw()


func _draw() -> void:
	for explosion in _explosiones:
		var segundos: float = explosion[1]
		var opacidad := clampf(DURA_QUEMADURA - segundos, 0.0, 1.0)
		draw_texture(QUEMADURA, to_local(explosion[0]) - Vector2(64.0, 64.0), Color(1.0, 1.0, 1.0, opacidad))


func _dibujar_fuego() -> void:
	for explosion in _explosiones:
		var segundos: float = explosion[1]
		var fotograma := int(segundos / SEGUNDOS_POR_FOTOGRAMA)
		if fotograma < FOTOGRAMAS:
			var esquina := _fuego.to_local(explosion[0]) - Vector2(144.0, 144.0)
			_fuego.draw_texture_rect_region(EXPLOSION, Rect2(esquina, Vector2(288.0, 288.0)), Rect2(fotograma * 288.0, 0.0, 288.0, 288.0))
