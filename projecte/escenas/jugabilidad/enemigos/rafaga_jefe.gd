extends Node2D

## La ráfaga de datos del jefe del minuto 10: 12 proyectiles que salen en
## círculo y se esquivan por los huecos que quedan entre ellos. Cada uno hace
## daño una vez y desaparece al tocar al jugador.
##
## Cuándo dispara lo decide el jefe (jefe.gd), que llama a disparar(); en la
## segunda mitad de su vida, dos veces, la segunda girada. Aquí se llevan el
## movimiento, el dibujo y el daño.
##
## Es top_level: dibuja en coordenadas del mundo y no se mueve con el jefe. Con
## z_index 4, encima del jugador y de la horda, como el fuego de las
## explosiones. Sin class_name: lo usa la escena del jefe.

const PROYECTIL := preload("res://medios/sprites/jefe/jefe_rafaga.png")
const LADO := 16.0
const FOTOGRAMAS := 4
const SEGUNDOS_POR_FOTOGRAMA := 0.08

const CANTIDAD := 12
const VELOCIDAD := 200.0
## Segundos que vuela cada proyectil: llega a unos 400 px.
const VIDA := 2.0
## Salen un poco fuera del cuerpo del jefe, no de su centro.
const SALIDA := 30.0
## Media vuelta entre dos proyectiles (15°): la segunda ráfaga pasa por los
## huecos de la primera.
const GIRO := TAU / CANTIDAD / 2.0
## La mitad del proyectil más lo que se suma por el tamaño del jugador: pega si
## le roza, no solo si le da en el centro.
const RADIO_IMPACTO := 8.0 + 12.0
## Daño al jugador, antes de la dificultad (la aplica su salud).
const DANO := 15.0

## Cada proyectil: [posición, dirección, segundos volando].
var _proyectiles: Array = []
var _jugador: Node2D
var _salud_jugador: Salud


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")


func disparar(centro: Vector2, girada: bool) -> void:
	for i in CANTIDAD:
		var direccion := Vector2.from_angle(TAU * i / CANTIDAD + (GIRO if girada else 0.0))
		_proyectiles.append([centro + direccion * SALIDA, direccion, 0.0])
	BusEventos.jefe_ataco.emit("rafaga")


## Para cuando muere el jefe.
func vaciar() -> void:
	_proyectiles.clear()
	queue_redraw()


## Con el juego en pausa no se llama: los proyectiles se quedan quietos.
func _physics_process(delta: float) -> void:
	if _proyectiles.is_empty():
		return

	for proyectil in _proyectiles:
		proyectil[0] += proyectil[1] * VELOCIDAD * delta
		proyectil[2] += delta
		if proyectil[0].distance_to(_jugador.global_position) < RADIO_IMPACTO:
			_salud_jugador.recibir_dano(DANO)
			# Así lo retira el filtro de abajo.
			proyectil[2] = VIDA
	_proyectiles = _proyectiles.filter(func(proyectil): return proyectil[2] < VIDA)
	queue_redraw()


func _draw() -> void:
	var lado := Vector2(LADO, LADO)
	for proyectil in _proyectiles:
		var fotograma := int(proyectil[2] / SEGUNDOS_POR_FOTOGRAMA) % FOTOGRAMAS
		# El dibujo mira a la derecha: se gira hacia donde va.
		draw_set_transform(proyectil[0], proyectil[1].angle())
		draw_texture_rect_region(PROYECTIL, Rect2(-lado / 2.0, lado), Rect2(Vector2(fotograma * LADO, 0.0), lado))
	draw_set_transform(Vector2.ZERO)
