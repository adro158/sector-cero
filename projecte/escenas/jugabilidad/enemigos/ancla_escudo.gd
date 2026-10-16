extends Node2D

## Un ancla del escudo del jefe final (escudo_jefe_final.gd): un objetivo más
## para las armas, con su vida. Rota, enseña su último fotograma hasta que se
## acaba el escudo. Sin class_name: la usa la escena del jefe final.

signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)

const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
const BarraVida := preload("res://escenas/jugabilidad/enemigos/barra_vida_enemigo.gd")
const RADIO := 24.0
const COLOR := Color(1.0, 0.3, 0.4)

var _vida := 0.0
var _vida_maxima := 1.0
## Si se le puede dar: aparecida y sin romper.
var _activa := false
var _rota := false
var _segundos := 0.0


func _ready() -> void:
	visible = false


func activar(posicion: Vector2, vida: float) -> void:
	global_position = posicion
	_vida = vida
	_vida_maxima = vida
	_activa = true
	_rota = false
	visible = true


func ocultar() -> void:
	_activa = false
	_rota = false
	visible = false


func rota() -> bool:
	return _rota


## Misma forma que el resto de objetivos: devuelve a cuántos alcanza.
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0) -> int:
	if not _activa or global_position.distance_to(centro) > radio_golpe + RADIO:
		return 0
	_vida -= cantidad
	enemigo_danado.emit(global_position + Vector2(randf_range(-10.0, 10.0), -36.0), cantidad, resistencia)
	if _vida <= 0.0:
		_activa = false
		_rota = true
	return 1


func ficha_en(punto: Vector2, radio_busqueda: float) -> Dictionary:
	var distancia := global_position.distance_to(punto)
	if not _activa or distancia > radio_busqueda + RADIO:
		return {}
	var resultado := ficha(0)
	resultado.distancia = distancia
	return resultado


func ficha(_id: int) -> Dictionary:
	if not _activa:
		return {}
	var retrato := AtlasTexture.new()
	retrato.atlas = Dibujo.ANCLA
	retrato.region = Rect2(0.0, 0.0, 48.0, 56.0)
	return {"id": 0, "nombre": "Ancla del escudo", "textura": retrato, "color": COLOR,
		"vida": _vida, "vida_maxima": _vida_maxima, "dano": 0.0, "velocidad": 0.0}


func mas_cercano(desde: Vector2, radio_busqueda: float) -> Vector2:
	if _activa and global_position.distance_to(desde) < radio_busqueda:
		return global_position
	return Vector2.INF


func _process(delta: float) -> void:
	if not visible:
		return
	_segundos += delta
	queue_redraw()


func _draw() -> void:
	# Brilla con los fotogramas 0-3; el 4 es el ancla rota.
	Dibujo.fotograma(self, Dibujo.ANCLA, 4 if _rota else int(_segundos * 8.0) % 4, 48.0, Vector2.ZERO)
	if _activa:
		BarraVida.dibujar(self, Vector2(0.0, -40.0), 44.0, 5.0, _vida / _vida_maxima, COLOR)
