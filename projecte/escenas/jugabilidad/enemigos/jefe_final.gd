extends Node2D

## Jefe final, NÚCLEO CERO. Llega a las 15:00, al acabar la fase 2, y
## derrotarlo es la victoria. Junta todo el juego y tiene tres formas: rootkit
## gigante, núcleo armado y amalgama. Al cruzar el 66 % y el 33 % de vida se
## transforma, y en cada forma cuesta más matarlo: recibe menos daño y ataca
## más deprisa.
##
## Aquí van las formas, la vida, el movimiento, la transformación y la muerte.
##
## Como el primer jefe, está en la escena desde el principio, oculto, y para
## las armas es un objetivo más (grupo objetivos). Sin class_name: lo carga su
## escena.

signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)
signal derrotado

enum Estado { OCULTO, LUCHANDO, TRANSFORMANDO, ATURDIDO, MURIENDO }

const Dificultad := preload("res://globales/dificultad.gd")
const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
const SpriteDestello := preload("res://escenas/jugabilidad/enemigos/sprite_destello.gd")

## Una entrada por forma: 0 rootkit gigante, 1 núcleo armado y 2 amalgama.
const DANO_RECIBIDO: Array[float] = [1.0, 0.75, 0.6]
const VELOCIDAD: Array[float] = [60.0, 75.0, 90.0]
const FOTOGRAMAS_POR_SEGUNDO: Array[float] = [8.0, 10.0, 12.0]
## La fracción de vida a la que pasa a la forma siguiente.
const UMBRALES: Array[float] = [0.66, 0.33]
## Cada forma es una fila de 6 fotogramas en la hoja.
const FOTOGRAMAS_FORMA := 6

## Segundos de la transformación (8 fotogramas de 0,1 s: en el 4 ya es la
## forma nueva) y de la muerte (12 de 0,08 s).
const TRANSFORMACION := 0.8
const MUERTE := 0.96
## Se acerca hasta esta distancia del jugador y ahí se queda.
const DISTANCIA := 220.0

@export var radio: float = 64.0
@export var dano_contacto: float = 25.0
## Mapa sin fin: si el jugador se aleja tanto, reaparece más cerca.
@export var distancia_reciclaje: float = 1200.0

var _estado := Estado.OCULTO
var _forma := 0
var _tiempo_estado := 0.0
## Si en esta transformación ya ha cambiado de forma (pasa a mitad).
var _forma_cambiada := false
## Reloj de la animación de reposo y de la flotación.
var _segundos := 0.0
var _jugador: Node2D
var _salud_jugador: Salud

@onready var _sprite: SpriteDestello = $Sprite
@onready var _salud: Salud = $Salud


func _ready() -> void:
	visible = false
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_salud.murio.connect(_al_morir)
	_salud.vida_cambiada.connect(BusEventos.jefe_final_vida_cambiada.emit)


func aparecer(posicion: Vector2) -> void:
	global_position = posicion
	# La vida de la escena es la de la dificultad media.
	_salud.reiniciar(_salud.vida_maxima * Dificultad.dato("vida"))
	_forma = 0
	_cambiar_estado(Estado.LUCHANDO)
	visible = true
	_sprite.visible = true
	BusEventos.jefe_final_aparecio.emit()


## Si recibe daño y las armas pueden apuntarle.
func activo() -> bool:
	return _estado == Estado.LUCHANDO or _estado == Estado.ATURDIDO


func forma() -> int:
	return _forma


## Para el menú de desarrollador: le quita la vida justa para la forma
## siguiente.
func siguiente_forma() -> void:
	if activo() and _forma < UMBRALES.size():
		_salud.poner(_salud.vida_maxima * UMBRALES[_forma], _salud.vida_maxima)
		_transformar()


## Misma forma que el resto de objetivos: devuelve a cuántos alcanza.
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0) -> int:
	if not activo() or global_position.distance_to(centro) > radio_golpe + radio:
		return 0

	var dano := cantidad * DANO_RECIBIDO[_forma]
	# Un golpe no se salta una forma: se queda en la vida a la que cambia.
	var limite := _salud.vida_maxima * UMBRALES[_forma] if _forma < UMBRALES.size() else 0.0
	dano = minf(dano, _salud.vida() - limite)
	_salud.recibir_dano(dano)
	_sprite.destellar()
	enemigo_danado.emit(global_position + Vector2(randf_range(-30.0, 30.0), -70.0), dano, resistencia)
	if activo() and _forma < UMBRALES.size() and _salud.vida() <= limite:
		_transformar()
	return 1


## Para la ficha que sale al pincharlo, como en los demás enemigos.
func ficha_en(punto: Vector2, radio_busqueda: float) -> Dictionary:
	var distancia := global_position.distance_to(punto)
	if not activo() or distancia > radio_busqueda + radio:
		return {}
	var resultado := ficha(0)
	resultado.distancia = distancia
	return resultado


func ficha(_id: int) -> Dictionary:
	if not activo():
		return {}
	# El primer fotograma de la forma que tiene ahora.
	var retrato := AtlasTexture.new()
	retrato.atlas = _sprite.texture
	retrato.region = Rect2(0.0, _forma * 192.0, 192.0, 192.0)
	return {"id": 0, "nombre": "NÚCLEO CERO", "textura": retrato, "color": Color(1.0, 0.8, 0.3),
		"vida": _salud.vida(), "vida_maxima": _salud.vida_maxima, "dano": dano_contacto,
		"velocidad": VELOCIDAD[_forma]}


func mas_cercano(desde: Vector2, radio_busqueda: float) -> Vector2:
	if activo() and global_position.distance_to(desde) < radio_busqueda:
		return global_position
	return Vector2.INF


func _physics_process(delta: float) -> void:
	if _estado == Estado.OCULTO:
		return

	_segundos += delta
	_tiempo_estado += delta
	match _estado:
		Estado.LUCHANDO:
			_luchar(delta)
		Estado.TRANSFORMANDO:
			if not _forma_cambiada and _tiempo_estado >= TRANSFORMACION * 0.5:
				_forma_cambiada = true
				_forma += 1
				BusEventos.jefe_final_forma_cambiada.emit(_forma)
			if _tiempo_estado >= TRANSFORMACION:
				_cambiar_estado(Estado.LUCHANDO)
		Estado.MURIENDO:
			if _tiempo_estado >= MUERTE:
				_estado = Estado.OCULTO
				visible = false
				derrotado.emit()
				return

	if activo() and global_position.distance_to(_jugador.global_position) < radio + 16.0:
		_salud_jugador.recibir_dano(dano_contacto)
	_animar()
	queue_redraw()


func _luchar(delta: float) -> void:
	var hacia_jugador := _jugador.global_position - global_position
	if hacia_jugador.length() > distancia_reciclaje:
		global_position = _jugador.global_position - hacia_jugador.normalized() * DISTANCIA * 2.0
	elif hacia_jugador.length() > DISTANCIA:
		global_position += hacia_jugador.normalized() * VELOCIDAD[_forma] * delta


## Se corta lo que estuviera haciendo y es invulnerable mientras dura.
func _transformar() -> void:
	_cambiar_estado(Estado.TRANSFORMANDO)
	_forma_cambiada = false
	_temblar()


func _cambiar_estado(nuevo: Estado) -> void:
	_estado = nuevo
	_tiempo_estado = 0.0


## Flota: sube y baja un poco, y repite los 6 fotogramas de reposo de su fila.
func _animar() -> void:
	var columna := int(_segundos * FOTOGRAMAS_POR_SEGUNDO[_forma]) % FOTOGRAMAS_FORMA
	_sprite.frame = _forma * FOTOGRAMAS_FORMA + columna
	_sprite.position.y = sin(_segundos * 2.0) * 4.0


## La cámara da unos tirones. Siempre los mismos: así no gasta números del
## azar de la partida.
func _temblar() -> void:
	var camara := get_viewport().get_camera_2d()
	if camara == null:
		return
	var temblor := create_tween()
	for desplazamiento in [Vector2(10, -6), Vector2(-8, 7), Vector2(7, 5), Vector2(-6, -8), Vector2(3, 4), Vector2.ZERO]:
		temblor.tween_property(camara, "offset", desplazamiento, 0.05)


func _draw() -> void:
	# El sprite va detrás (show_behind_parent): esto se dibuja encima de él.
	if _estado == Estado.TRANSFORMANDO:
		Dibujo.fotograma(self, Dibujo.TRANSFORMACION, mini(int(_tiempo_estado / 0.1), 7), 256.0, Vector2.ZERO)
	elif _estado == Estado.MURIENDO:
		Dibujo.fotograma(self, Dibujo.MUERTE, mini(int(_tiempo_estado / 0.08), 11), 320.0, Vector2.ZERO)


func _al_morir() -> void:
	_cambiar_estado(Estado.MURIENDO)
	# La muerte ya trae al jefe rompiéndose.
	_sprite.visible = false
	_temblar()
	BusEventos.enemigo_muerto.emit(global_position, "jefe")
