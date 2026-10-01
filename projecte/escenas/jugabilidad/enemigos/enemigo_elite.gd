extends Node2D

## Enemigo élite: más grande y resistente que la horda, con uno o dos afijos
## sorteados al aparecer (blindado, replicante, aura lenta o explosivo). Cada
## afijo se ve como un anillo de su color y su nombre va escrito encima.
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

@export var datos: DatosTipoEnemigo
@export var distancia_reciclaje: float = 1200.0

var _activo := false
var _afijos: Array[DatosAfijoElite] = []
## Tiempo que falta para explotar; cero si no está a punto de hacerlo.
var _cuenta_atras := 0.0
var _jugador: Node2D
var _salud_jugador: Salud

@onready var _sprite: Sprite2D = $Sprite
@onready var _salud: Salud = $Salud


func _ready() -> void:
	visible = false
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_sprite.texture = datos.textura
	_salud.murio.connect(_al_morir)


func activo() -> bool:
	return _activo or _cuenta_atras > 0.0


func aparecer(posicion: Vector2, afijos: Array[DatosAfijoElite]) -> void:
	global_position = posicion
	_afijos = afijos
	_salud.reiniciar(datos.vida)
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
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0) -> int:
	if not _activo or global_position.distance_to(centro) > radio_golpe + datos.tamano * 0.5:
		return 0

	var blindaje := _valor(DatosAfijoElite.Efecto.BLINDADO)
	_salud.recibir_dano(cantidad * (1.0 - blindaje))
	queue_redraw()
	enemigo_danado.emit(global_position + Vector2(randf_range(-16.0, 16.0), -30.0), cantidad * (1.0 - blindaje), resistencia)
	return 1


func mas_cercano(desde: Vector2, radio_busqueda: float) -> Vector2:
	if _activo and global_position.distance_to(desde) < radio_busqueda:
		return global_position
	return Vector2.INF


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
	BusEventos.enemigo_muerto.emit(global_position, datos.tipo)

	# El replicante suelta bits corruptos a su alrededor. El primer gestor del
	# grupo es el del bit corrupto, el primero de la escena.
	var copias := int(_valor(DatosAfijoElite.Efecto.REPLICANTE))
	var gestor = get_tree().get_first_node_in_group("gestor_enemigos")
	for i in copias:
		gestor.aparecer(global_position + Vector2.RIGHT.rotated(TAU * i / copias) * 40.0)

	# El explosivo no desaparece aún: avisa con un anillo y luego estalla.
	if _valor(DatosAfijoElite.Efecto.EXPLOSIVO) > 0.0:
		_cuenta_atras = AVISO_EXPLOSION
		_sprite.visible = false
	else:
		visible = false


func _explotar() -> void:
	if global_position.distance_to(_jugador.global_position) < RADIO_EXPLOSION:
		_salud_jugador.recibir_dano(_valor(DatosAfijoElite.Efecto.EXPLOSIVO))
	BusEventos.elite_exploto.emit(global_position)
	_sprite.visible = true
	visible = false


func _draw() -> void:
	if _cuenta_atras > 0.0:
		# Anillo de la explosión que se va llenando hasta que estalla.
		var progreso := 1.0 - _cuenta_atras / AVISO_EXPLOSION
		draw_circle(Vector2.ZERO, RADIO_EXPLOSION * progreso, Color(1.0, 0.4, 0.1, 0.25))
		draw_arc(Vector2.ZERO, RADIO_EXPLOSION, 0.0, TAU, 48, Color(1.0, 0.4, 0.1, 0.9), 2.0)
		return
	if not _activo:
		return

	if _valor(DatosAfijoElite.Efecto.AURA_LENTA) > 0.0:
		draw_circle(Vector2.ZERO, RADIO_AURA, Color(0.75, 0.45, 1.0, 0.08))
		draw_arc(Vector2.ZERO, RADIO_AURA, 0.0, TAU, 48, Color(0.75, 0.45, 1.0, 0.4), 1.5)

	var radio := datos.tamano * 0.5
	for i in _afijos.size():
		draw_arc(Vector2.ZERO, radio + 6.0 + i * 5.0, 0.0, TAU, 32, _afijos[i].color, 2.0)

	var ancho := 60.0
	var origen := Vector2(-ancho * 0.5, -radio - 16.0)
	draw_rect(Rect2(origen, Vector2(ancho, 5.0)), Color(0.05, 0.05, 0.1, 0.9))
	draw_rect(Rect2(origen, Vector2(ancho * _salud.vida() / _salud.vida_maxima, 5.0)), datos.color)
	draw_string(ThemeDB.fallback_font, origen + Vector2(-40.0, -6.0), descripcion(), HORIZONTAL_ALIGNMENT_CENTER, ancho + 80.0, 12, datos.color)
