extends Node2D

## El escudo de candado del jefe final, robado al ransomware. Al entrar en el
## núcleo armado y en la amalgama (y en la amalgama, también cada cierto
## tiempo), el jefe se encierra en una burbuja que no deja pasar el daño y
## salen 4 anclas a su alrededor, unidas a él con cadenas. Las anclas son
## objetivos con su vida (ancla_escudo.gd): cada una que se rompe pierde su
## cadena, y al romper las 4 la burbuja estalla y el jefe se queda aturdido.
## Cada ancla es de un personaje y solo la rompe su herramienta, así que hay
## que ir cambiando: mientras está el escudo, cambiar no tiene espera. Si pasan
## 30 s sin romper ninguna, las rotas se vuelven a cerrar. Hasta el 22/10
## (sesión 18) eran 800 de vida, 12 s y con la espera de siempre, y el bot del
## simulador no las rompía nunca: le quita a un ancla unos 50 de vida por
## segundo. Y hasta la noche del 22/10 los 30 s contaban desde la primera rota,
## y en difícil (con más vida) se cerraba mientras se rompía la segunda.
##
## Las anclas son sus hijos y están en la escena desde el principio, ocultas,
## como los élites: las armas buscan sus objetivos al empezar. Sin class_name.

signal roto

const Dificultad := preload("res://globales/dificultad.gd")
const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
const Ancla := preload("res://escenas/jugabilidad/enemigos/ancla_escudo.gd")
## Vida de cada ancla antes de la dificultad: se multiplica por su
## vida_anclas.
const VIDA_ANCLA := 300.0
## Lo que hay para romper la siguiente desde que se rompe una.
const TIEMPO_PARA_ROMPER := 30.0
## De quién es cada ancla, por su posición en la lista de personajes vivos:
## con tres, a-b-c-b, y ninguna queda junto a otra de su color (están en
## círculo, así que la última toca a la primera). Con dos sale a-b-a-b y con
## uno, las cuatro suyas.
const REPARTO: Array[int] = [0, 1, 2, 1]
const DISTANCIA_ANCLAS := 240.0
## Radio de la burbuja: las cadenas llegan hasta su borde.
const RADIO := 110.0
## La rotura dura 6 fotogramas de 0,1 s.
const ROTURA := 0.6

var _activo := false
## Lo que le queda a la animación de la rotura.
var _rotura := 0.0
var _segundos := 0.0
## Las anclas rotas y los segundos desde que se rompió la última (0 si no hay
## ninguna rota).
var _rotas := 0
var _desde_ultima_rota := 0.0
## Las claves de los personajes que no han caído, como en Ancla.PERSONAJES.
var _vivos: Array = Ancla.PERSONAJES.keys()
## Lo último que se avisó con anclas_pendientes, para avisar solo al cambiar.
var _pendientes: Array = []

@onready var _anclas: Array[Node] = get_children()
## El equipo del jugador: con el escudo puesto se cambia de personaje sin
## espera, para poder ir a por cada ancla con el suyo.
var _cambio_personaje: Node


func _ready() -> void:
	_cambio_personaje = get_tree().get_first_node_in_group("jugador").get_node("CambioPersonaje")
	BusEventos.equipo_cambiado.connect(_al_cambiar_equipo)


func activo() -> bool:
	return _activo


func levantar() -> void:
	_activo = true
	_cambio_personaje.sin_espera = true
	_rotas = 0
	_desde_ultima_rota = 0.0
	# Barajados, para que no salgan siempre en el mismo sitio.
	var orden := _vivos.duplicate()
	orden.shuffle()
	# En diagonal, para que no queden tapadas por el jefe.
	for i in _anclas.size():
		var direccion := Vector2.from_angle(TAU * (i + 0.5) / _anclas.size())
		var de_quien: String = orden[REPARTO[i] % orden.size()]
		_anclas[i].activar(global_position + direccion * DISTANCIA_ANCLAS, VIDA_ANCLA * Dificultad.dato("vida_anclas"), de_quien)
	BusEventos.jefe_final_ataco.emit("escudo")


## Sin animación: al morir el jefe.
func quitar() -> void:
	_activo = false
	_cambio_personaje.sin_espera = false
	_rotura = 0.0
	for ancla in _anclas:
		ancla.ocultar()
	_avisar_pendientes()
	queue_redraw()


## Los personajes con anclas sin romper (ninguno sin escudo), al bus si han
## cambiado.
func _avisar_pendientes() -> void:
	var pendientes: Array = []
	if _activo:
		for ancla in _anclas:
			var personaje: DatosPersonaje = Ancla.PERSONAJES[ancla.herramienta]
			if not ancla.rota() and not personaje in pendientes:
				pendientes.append(personaje)
	if pendientes != _pendientes:
		_pendientes = pendientes
		BusEventos.anclas_pendientes.emit(pendientes)


func _physics_process(delta: float) -> void:
	_segundos += delta
	if _rotura > 0.0:
		_rotura -= delta
		queue_redraw()
	if not _activo:
		return
	queue_redraw()
	var rotas := 0
	for ancla in _anclas:
		if ancla.rota():
			rotas += 1
	if rotas == _anclas.size():
		# Las cuatro rotas: la burbuja estalla.
		quitar()
		_rotura = ROTURA
		roto.emit()
	elif rotas > 0:
		# Cada una que se rompe vuelve a dar todo el tiempo para la siguiente.
		if rotas > _rotas:
			_desde_ultima_rota = 0.0
		_desde_ultima_rota += delta
		if _desde_ultima_rota >= TIEMPO_PARA_ROMPER:
			for ancla in _anclas:
				if ancla.rota():
					ancla.cerrar()
			rotas = 0
			_desde_ultima_rota = 0.0
			# Suena como al levantar el escudo.
			BusEventos.jefe_final_ataco.emit("escudo")
	_rotas = rotas
	_avisar_pendientes()


## Si cae un personaje con el escudo puesto, sus anclas pasan a otro: si no,
## no habría forma de romperlas.
func _al_cambiar_equipo(personajes: Array, _indice_activo: int) -> void:
	_vivos = []
	for estado in personajes:
		if not estado.caido:
			_vivos.append(Ancla.PERSONAJES.find_key(estado.personaje))
	if _vivos.is_empty():
		return
	for ancla in _anclas:
		if not ancla.herramienta in _vivos:
			ancla.herramienta = _vivos.pick_random()


func _draw() -> void:
	if _activo:
		for ancla in _anclas:
			if not ancla.rota():
				var desde := to_local(ancla.global_position)
				Dibujo.cadena(self, desde, desde.normalized() * RADIO, _segundos, Dibujo.CADENAS[ancla.herramienta])
		Dibujo.fotograma(self, Dibujo.ESCUDO, int(_segundos * 8.0) % 4, 240.0, Vector2.ZERO)
	elif _rotura > 0.0:
		Dibujo.fotograma(self, Dibujo.ESCUDO_ROTURA, mini(int((ROTURA - _rotura) / 0.1), 5), 256.0, Vector2.ZERO)
