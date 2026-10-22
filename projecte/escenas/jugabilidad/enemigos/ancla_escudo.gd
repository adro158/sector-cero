extends Node2D

## Un ancla del escudo del jefe final (escudo_jefe_final.gd): un objetivo más
## para las armas, con su vida. Cada una es de un personaje y solo recibe daño
## de su herramienta (también evolucionada, y su ulti): cuenta el personaje
## que se lleva en ese momento. Las demás le sacan un 0 rojo, el color de los
## golpes a los que el malware resiste. Rota, enseña su último fotograma hasta
## que se acaba el escudo o se vuelve a cerrar. Sin class_name: la usa la
## escena del jefe final.

signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)

const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
const BarraVida := preload("res://escenas/jugabilidad/enemigos/barra_vida_enemigo.gd")
const RADIO := 24.0
## Como mucho un 0 cada tanto: el Ping que la atraviesa la toca varios
## fotogramas seguidos.
const ESPERA_CERO := 0.3
## Las mismas claves que las hojas de Dibujo.ANCLAS.
const PERSONAJES := {
	"mago": preload("res://recursos/personajes/datos/mago.tres"),
	"espadachin": preload("res://recursos/personajes/datos/espadachin.tres"),
	"segador": preload("res://recursos/personajes/datos/segador.tres"),
}

## De quién es: "mago", "espadachin" o "segador". La pone el escudo.
var herramienta := "mago"
var _vida := 0.0
var _vida_maxima := 1.0
## Si se le puede dar: aparecida y sin romper.
var _activa := false
var _rota := false
var _segundos := 0.0
var _ultimo_cero := -1.0
## El personaje que lleva el jugador ahora.
var _personaje_activo: DatosPersonaje


func _ready() -> void:
	visible = false
	BusEventos.equipo_cambiado.connect(func(personajes, activo): _personaje_activo = personajes[activo].personaje)


func activar(posicion: Vector2, vida: float, de_quien: String) -> void:
	global_position = posicion
	herramienta = de_quien
	_vida = vida
	_vida_maxima = vida
	_activa = true
	_rota = false
	visible = true


## Rota, vuelve a estar entera.
func cerrar() -> void:
	_vida = _vida_maxima
	_activa = true
	_rota = false


func ocultar() -> void:
	_activa = false
	_rota = false
	visible = false


func rota() -> bool:
	return _rota


## Misma forma que el resto de objetivos: devuelve a cuántos alcanza. Con otra
## herramienta enseña el 0 pero no cuenta como alcanzada: si contara, el robo
## de vida curaría y la resistencia del malware lo tomaría por daño. El
## proyectil del Ping la atraviesa.
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0, cono: RefCounted = null) -> int:
	if not _activa or global_position.distance_to(centro) > radio_golpe + RADIO:
		return 0
	# Fuera del cono ni el 0 rojo: no le ha llegado el golpe.
	var factor: float = 1.0 if cono == null else cono.factor(global_position, RADIO)
	if factor <= 0.0:
		return 0
	var numero_en := global_position + Vector2(randf_range(-10.0, 10.0), -36.0)
	if _personaje_activo != PERSONAJES[herramienta]:
		if _segundos - _ultimo_cero > ESPERA_CERO:
			_ultimo_cero = _segundos
			enemigo_danado.emit(numero_en, 0.0, 1.0)
		return 0
	# La resistencia es del malware, que se adapta a tu herramienta; el escudo
	# no. Las armas mandan el daño ya rebajado y aquí se deshace: si solo
	# queda un personaje y su herramienta resiste al 50 %, si no, las cuatro
	# anclas no se podían romper antes de que se cerraran (sesión 18).
	var golpe := cantidad / (1.0 - resistencia) * factor
	if cono != null:
		cono.golpes += factor
	_vida -= golpe
	enemigo_danado.emit(numero_en, golpe, 0.0)
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
	var personaje: DatosPersonaje = PERSONAJES[herramienta]
	var retrato := AtlasTexture.new()
	retrato.atlas = Dibujo.ANCLAS[herramienta]
	retrato.region = Rect2(0.0, 0.0, 48.0, 56.0)
	return {"id": 0, "nombre": "Ancla del " + personaje.nombre, "textura": retrato, "color": personaje.color,
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
	Dibujo.fotograma(self, Dibujo.ANCLAS[herramienta], 4 if _rota else int(_segundos * 8.0) % 4, 48.0, Vector2.ZERO)
	if _activa:
		BarraVida.dibujar(self, Vector2(0.0, -40.0), 44.0, 5.0, _vida / _vida_maxima, PERSONAJES[herramienta].color)
