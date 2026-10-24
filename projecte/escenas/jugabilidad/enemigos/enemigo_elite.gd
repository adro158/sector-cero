extends Node2D

## Enemigo élite: más grande y resistente que la horda, con uno o dos afijos
## sorteados al aparecer (blindado, replicante, aura lenta o explosivo). Cada
## afijo se ve con su efecto, de su color (dibujo_elite.gd): las placas del
## Blindado encima del rootkit, y las copias del Replicante, el anillo helado
## del Aura lenta y la mecha del Explosivo detrás. Los nombres de los afijos
## van escritos encima. Al morir se parte en trozos en su sitio, salvo el
## Explosivo, que avisa y estalla.
##
## Como el jefe, es un nodo y no una posición en un MultiMesh: hay muy pocos a
## la vez y cada uno se comporta distinto. Hay unos cuantos en la escena desde
## el principio, ocultos, y el director activa uno libre cada cierto tiempo:
## así las armas, que buscan sus objetivos al empezar, ya los conocen.

signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)

const RADIO_AURA := 150.0
const RADIO_EXPLOSION := 130.0
## Segundos de aviso entre la muerte de un explosivo y su explosión.
const AVISO_EXPLOSION := 0.8
const BarraVida := preload("res://escenas/jugabilidad/enemigos/barra_vida_enemigo.gd")
const Dificultad := preload("res://globales/dificultad.gd")
const SpriteDestello := preload("res://escenas/jugabilidad/enemigos/sprite_destello.gd")
const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_elite.gd")

@export var datos: DatosTipoEnemigo
@export var distancia_reciclaje: float = 1200.0

var _activo := false
var _afijos: Array[DatosAfijoElite] = []
## Tiempo que falta para explotar; cero si no está a punto de hacerlo.
var _cuenta_atras := 0.0
## Tiempo que le queda a su muerte; cero si no está muriendo.
var _muerte := 0.0
## Nivel del jugador: como la horda, aparece con más vida cuanto más alto.
var _nivel := 1
var _segundos := 0.0
## Segundos de su animación en reposo.
var _tiempo := 0.0
var _jugador: Node2D
var _salud_jugador: Salud
## Lo que va encima del rootkit (las placas del Blindado): un hijo creado al
## empezar, que se dibuja desde aquí con su señal draw.
var _encima: Node2D

@onready var _sprite: SpriteDestello = $Sprite
@onready var _salud: Salud = $Salud


func _ready() -> void:
	visible = false
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_sprite.texture = Dibujo.REPOSO
	_sprite.hframes = Dibujo.FOTOGRAMAS_REPOSO
	# Después del Sprite en la lista de hijos: se dibuja encima de él.
	_encima = Node2D.new()
	add_child(_encima)
	_encima.draw.connect(_dibujar_encima)
	_salud.murio.connect(_al_morir)
	BusEventos.experiencia_cambiada.connect(func(_actual, _necesaria, nivel): _nivel = nivel)
	BusEventos.tiempo_partida.connect(func(segundos, _duracion): _segundos = segundos)


func activo() -> bool:
	return _activo or _cuenta_atras > 0.0 or _muerte > 0.0


func aparecer(posicion: Vector2, afijos: Array[DatosAfijoElite]) -> void:
	global_position = posicion
	_afijos = afijos
	# Cada uno empieza su animación en un punto distinto, para que no brillen
	# todos a la vez. Sale de dónde aparece y no de randf(), que gastaría
	# números del azar de la partida.
	_tiempo = fmod(absf(posicion.x + posicion.y), Dibujo.VUELTA)
	_salud.reiniciar(datos.vida_para(_nivel, _segundos) * Dificultad.dato("vida"))
	_activo = true
	visible = true
	queue_redraw()
	BusEventos.elite_aparecio.emit(descripcion())


## Los nombres de sus afijos, para el aviso del HUD y la etiqueta.
func descripcion() -> String:
	var nombres := []
	for afijo in _afijos:
		nombres.append(afijo.nombre.to_upper())
	return " + ".join(nombres)


## Misma forma que la horda y el jefe: devuelve a cuántos alcanza.
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0, cono: RefCounted = null) -> int:
	if not _activo or global_position.distance_to(centro) > radio_golpe + datos.tamano * 0.5:
		return 0
	if cono != null:
		var factor: float = cono.factor(global_position, datos.tamano * 0.5)
		if factor <= 0.0:
			return 0
		cantidad *= factor
		cono.golpes += factor

	var blindaje := _valor(DatosAfijoElite.Efecto.BLINDADO)
	_salud.recibir_dano(cantidad * (1.0 - blindaje))
	_sprite.destellar()
	queue_redraw()
	enemigo_danado.emit(global_position + Vector2(randf_range(-16.0, 16.0), -30.0), cantidad * (1.0 - blindaje), resistencia)
	return 1


## Para la ficha que sale al pincharlo, como en los gestores de la horda. Solo
## hay uno por nodo, así que su id siempre es 0.
func ficha_en(punto: Vector2, radio: float) -> Dictionary:
	var distancia := global_position.distance_to(punto)
	if not _activo or distancia > radio + datos.tamano * 0.5:
		return {}
	var resultado := ficha(0)
	resultado.distancia = distancia
	return resultado


func ficha(_id: int) -> Dictionary:
	if not _activo:
		return {}
	return {"id": 0, "nombre": "%s · %s" % [datos.nombre, descripcion()], "textura": datos.textura,
		"color": datos.color, "vida": _salud.vida(), "vida_maxima": _salud.vida_maxima,
		"dano": datos.dano_contacto, "velocidad": datos.velocidad}


func mas_cercano(desde: Vector2, radio_busqueda: float) -> Vector2:
	if _activo and global_position.distance_to(desde) < radio_busqueda:
		return global_position
	return Vector2.INF


## Con el juego en pausa no se llama: la animación se queda quieta.
func _process(delta: float) -> void:
	if _muerte > 0.0:
		_muerte -= delta
		queue_redraw()
		if _muerte <= 0.0:
			_sprite.visible = true
			visible = false
			z_index = 0
		return
	if not _activo:
		return
	_tiempo += delta
	_sprite.frame = Dibujo.fotograma_reposo(_tiempo)
	# Los efectos de los afijos están animados.
	queue_redraw()
	_encima.queue_redraw()


func _physics_process(delta: float) -> void:
	if _cuenta_atras > 0.0:
		_cuenta_atras -= delta
		queue_redraw()
		if _cuenta_atras <= 0.0:
			_explotar()
		return
	if not _activo:
		return

	var hacia_jugador := _jugador.global_position - global_position
	# Mapa sin fin: si se queda muy atrás, reaparece al otro lado del jugador.
	if hacia_jugador.length() > distancia_reciclaje:
		global_position = _jugador.global_position + hacia_jugador * 0.6
		hacia_jugador = _jugador.global_position - global_position

	global_position += hacia_jugador.normalized() * datos.velocidad * delta
	var distancia := hacia_jugador.length()
	if distancia < datos.tamano * 0.5 + 16.0:
		_salud_jugador.recibir_dano(datos.dano_contacto)
	var lentitud := _valor(DatosAfijoElite.Efecto.AURA_LENTA)
	if lentitud > 0.0 and distancia < RADIO_AURA:
		_jugador.ralentizar(lentitud)


## El valor del afijo con ese efecto, o 0 si este élite no lo tiene.
func _valor(efecto: DatosAfijoElite.Efecto) -> float:
	for afijo in _afijos:
		if afijo.efecto == efecto:
			return afijo.valor
	return 0.0


func _al_morir() -> void:
	_activo = false
	# Al morir suelta su experiencia y cuenta como eliminado, como la horda.
	# El premio (corazón y cofre) lo suelta premios_elite.gd al oír esta señal.
	BusEventos.enemigo_muerto.emit(global_position, datos.tipo)

	# El replicante suelta bits corruptos a su alrededor. El primer gestor del
	# grupo es el del bit corrupto, el primero de la escena.
	var copias := int(_valor(DatosAfijoElite.Efecto.REPLICANTE))
	var gestor = get_tree().get_first_node_in_group("gestor_enemigos")
	for i in copias:
		gestor.aparecer(global_position + Vector2.RIGHT.rotated(TAU * i / copias) * 40.0)

	# El explosivo no desaparece aún: avisa con un anillo y luego estalla.
	# Los demás se parten en trozos en su sitio y luego desaparecen. Mientras,
	# encima de la horda, como la explosión.
	_sprite.visible = false
	if _valor(DatosAfijoElite.Efecto.EXPLOSIVO) > 0.0:
		_cuenta_atras = AVISO_EXPLOSION
	else:
		_muerte = Dibujo.DURA_MUERTE
		z_index = 4


func _explotar() -> void:
	if global_position.distance_to(_jugador.global_position) < RADIO_EXPLOSION:
		_salud_jugador.recibir_dano(_valor(DatosAfijoElite.Efecto.EXPLOSIVO))
	BusEventos.elite_exploto.emit(global_position)
	_sprite.visible = true
	visible = false


func _draw() -> void:
	if _cuenta_atras > 0.0:
		Dibujo.aviso_explosion(self, _cuenta_atras, AVISO_EXPLOSION, RADIO_EXPLOSION)
		return
	if _muerte > 0.0:
		Dibujo.muerte(self, Dibujo.DURA_MUERTE - _muerte)
		return
	if not _activo:
		return

	# Detrás del rootkit: este _draw va antes que el Sprite, que es su hijo.
	Dibujo.afijos_detras(self, _afijos, _tiempo)

	var arriba := Vector2(0.0, -datos.tamano * 0.5 - 20.0)
	BarraVida.dibujar(self, arriba, 70.0, 7.0, _salud.vida() / _salud.vida_maxima, datos.color)
	# Caja de texto de 240 px centrada: caben dos afijos con nombre largo.
	draw_string(ThemeDB.fallback_font, Vector2(-120.0, arriba.y - 6.0), descripcion(), HORIZONTAL_ALIGNMENT_CENTER, 240.0, 12, datos.color)
	Dibujo.iconos(self, _afijos, arriba.y - 38.0)


func _dibujar_encima() -> void:
	if _activo:
		Dibujo.afijos_encima(_encima, _afijos, _tiempo)
