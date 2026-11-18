extends Node

## En la partida en red: parar la partida votando (petición de Adam, 17/11).
## Hasta entonces, en red el menú de pausa salía pero no paraba nada. Ahora,
## quien pulsa Esc pide parar; los demás votan SÍ o NO (votacion_red.gd); si
## dicen todos que sí, se para para todos, y se sigue cuando quien la pidió
## pulsa CONTINUAR. Si alguien dice que no, sigue como antes: el menú abierto,
## pero sin parar.
##
## Lo lleva el anfitrión: le llegan las peticiones y los votos (las suyas,
## directas; las de los clientes, como entradas fiables) y avisa a todos con el
## suceso «votacion»: [quien la pide (-1: ninguna), los votos por id, estado].
## Lo crea partida_red.gd.
##
## Sin class_name: lo crea partida_red.gd con preload.

const Red := preload("res://globales/red.gd")
const VotacionRed := preload("res://escenas/red/votacion_red.gd")

enum Estado { VOTANDO, PARADA, RECHAZADA, TERMINADA }

var _partida: Node
var _vista: Control
## En el anfitrión: quién la ha pedido (-1: nadie) y el voto de cada uno de
## los demás (VotacionRed.Voto), por id.
var _pide := -1
var _votos := {}
## Si este ordenador está parado por la votación.
var _parado := false


func _init(partida: Node, vista: Control) -> void:
	_partida = partida
	_vista = vista


func _ready() -> void:
	_vista.votado.connect(_al_votar_aqui)
	BusEventos.suceso_recibido.connect(_al_recibir_suceso)
	BusEventos.juego_pausado.connect(_al_abrir_menu)


## Esc en este ordenador (el menú de pausa avisa con juego_pausado): true abre
## el menú y pide parar; false lo cierra (CONTINUAR) y, si la pidió él, sigue.
func _al_abrir_menu(abierto: bool) -> void:
	if not Red.actual.es_anfitrion():
		Red.actual.enviar_entrada({"pausa": abierto}, true)
	elif abierto:
		pedir(1)
	else:
		seguir(1)


## En el anfitrión: lo que llega de los clientes (partida_red.gd).
func entrada(id: int, datos: Dictionary) -> void:
	if datos.get("pausa", false):
		pedir(id)
	elif datos.has("pausa"):
		seguir(id)
	elif datos.has("voto"):
		votar(id, datos.voto)


## En el anfitrión. No mientras ya hay una, ni mientras alguien elige mejora
## (la partida ya está parada esperándole).
func pedir(id: int) -> void:
	var niveles: Node = _partida.get_parent().get_node("SistemaNiveles")
	if _pide != -1 or niveles.eligiendo() or _partida.terminada():
		return
	_pide = id
	_votos.clear()
	for otro in _partida.ids():
		if otro != id:
			_votos[otro] = VotacionRed.Voto.PENDIENTE
	_comprobar()


func votar(id: int, si: bool) -> void:
	if _pide == -1 or not _votos.has(id):
		return
	_votos[id] = VotacionRed.Voto.SI if si else VotacionRed.Voto.NO
	_comprobar()


## Quien la pidió cierra su menú: se sigue (o se cancela si aún votaban).
func seguir(id: int) -> void:
	if id != _pide:
		return
	_pide = -1
	_avisar(id, Estado.TERMINADA)


## Se ha ido un jugador (partida_red.gd): su voto ya no cuenta, y si era quien
## la pidió, se acaba.
func quitar(id: int) -> void:
	if id == _pide:
		seguir(id)
	elif _votos.erase(id):
		_comprobar()


## Con un no, se acaba; con todos que sí, se para. Y se avisa a todos.
func _comprobar() -> void:
	var estado := Estado.VOTANDO
	if VotacionRed.Voto.NO in _votos.values():
		estado = Estado.RECHAZADA
	elif not VotacionRed.Voto.PENDIENTE in _votos.values():
		estado = Estado.PARADA
	_avisar(_pide, estado)
	if estado == Estado.RECHAZADA:
		_pide = -1


func _avisar(id: int, estado: Estado) -> void:
	var votos := []
	for otro in _votos:
		votos.append([otro, _votos[otro]])
	Red.actual.enviar_suceso("votacion", [id, votos, estado])
	_poner(id, votos, estado)


func _al_recibir_suceso(suceso: String, datos: Array) -> void:
	if suceso == "votacion":
		_poner(datos[0], datos[1], datos[2])


## En todos (también en el anfitrión): se para o se sigue, y se enseña.
func _poner(id: int, votos: Array, estado: Estado) -> void:
	var parar := estado == Estado.PARADA
	if parar != _parado:
		_parado = parar
		get_tree().paused = parar
	if estado == Estado.TERMINADA:
		_vista.hide()
		return
	var nombre: String = _partida.nombre_de_id(id)
	var titulo := "%s quiere parar la partida" % nombre
	if estado == Estado.PARADA:
		titulo = "Partida parada: %s pulsa CONTINUAR para seguir" % nombre
	elif estado == Estado.RECHAZADA:
		titulo = "No se para: alguien ha dicho que no"
	var lista := []
	var mio: int = VotacionRed.Voto.SI
	for datos in votos:
		lista.append({"nombre": _partida.nombre_de_id(datos[0]), "voto": datos[1], "anfitrion": datos[0] == 1})
		if datos[0] == Red.actual.mi_id():
			mio = datos[1]
	var puedo_votar: bool = estado == Estado.VOTANDO and mio == VotacionRed.Voto.PENDIENTE
	_vista.mostrar(titulo, lista, puedo_votar, estado == Estado.RECHAZADA)


func _al_votar_aqui(si: bool) -> void:
	if Red.actual.es_anfitrion():
		votar(1, si)
	else:
		Red.actual.enviar_entrada({"voto": si}, true)
