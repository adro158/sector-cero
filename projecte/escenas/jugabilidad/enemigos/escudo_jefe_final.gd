extends Node2D

## El escudo de candado del jefe final, robado al ransomware. Al entrar en el
## núcleo armado y en la amalgama (y en la amalgama, también cada cierto
## tiempo), el jefe se encierra en una burbuja que no deja pasar el daño y
## salen 4 anclas a su alrededor, unidas a él con cadenas. Las anclas son
## objetivos con su vida (ancla_escudo.gd): cada una que se rompe pierde su
## cadena, y al romper las 4 la burbuja estalla y el jefe se queda aturdido.
##
## Las anclas son sus hijos y están en la escena desde el principio, ocultas,
## como los élites: las armas buscan sus objetivos al empezar. Sin class_name.

signal roto

const Dificultad := preload("res://globales/dificultad.gd")
const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
## Vida de cada ancla en media: se multiplica por la dificultad.
const VIDA_ANCLA := 300.0
const DISTANCIA_ANCLAS := 240.0
## Radio de la burbuja: las cadenas llegan hasta su borde.
const RADIO := 110.0
## La rotura dura 6 fotogramas de 0,1 s.
const ROTURA := 0.6

var _activo := false
## Lo que le queda a la animación de la rotura.
var _rotura := 0.0
var _segundos := 0.0

@onready var _anclas: Array[Node] = get_children()


func activo() -> bool:
	return _activo


func levantar() -> void:
	_activo = true
	# En diagonal, para que no queden tapadas por el jefe.
	for i in _anclas.size():
		var direccion := Vector2.from_angle(TAU * (i + 0.5) / _anclas.size())
		_anclas[i].activar(global_position + direccion * DISTANCIA_ANCLAS, VIDA_ANCLA * Dificultad.dato("vida"))
	BusEventos.jefe_final_ataco.emit("escudo")


## Sin animación: al morir el jefe.
func quitar() -> void:
	_activo = false
	_rotura = 0.0
	for ancla in _anclas:
		ancla.ocultar()
	queue_redraw()


func _physics_process(delta: float) -> void:
	_segundos += delta
	if _rotura > 0.0:
		_rotura -= delta
		queue_redraw()
	if not _activo:
		return
	queue_redraw()
	for ancla in _anclas:
		if not ancla.rota():
			return
	# Las cuatro rotas: la burbuja estalla.
	quitar()
	_rotura = ROTURA
	roto.emit()


func _draw() -> void:
	if _activo:
		for ancla in _anclas:
			if not ancla.rota():
				var desde := to_local(ancla.global_position)
				Dibujo.cadena(self, desde, desde.normalized() * RADIO, _segundos)
		Dibujo.fotograma(self, Dibujo.ESCUDO, int(_segundos * 8.0) % 4, 240.0, Vector2.ZERO)
	elif _rotura > 0.0:
		Dibujo.fotograma(self, Dibujo.ESCUDO_ROTURA, mini(int((ROTURA - _rotura) / 0.1), 5), 256.0, Vector2.ZERO)
