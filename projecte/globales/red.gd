extends Node

## La red del multijugador en red local (plan_multijugador.md). Un ordenador
## crea la sala (el anfitrión, id 1) y los demás se unen con su código
## (codigo_sala.gd). La red no sabe nada de la partida: manda y recibe
## mensajes y avisa por el bus (sala_cambiada, partida_en_red_empieza,
## entrada_recibida, estado_recibido, suceso_recibido y jugador_desconectado).
##
## Cada mensaje es un Array [tipo, datos] pasado a bytes con var_to_bytes y
## mandado con send_bytes (sin RPC): lo mismo que la prueba de conexión de
## Alan (escenas/red/prueba_conexion.gd). Un jugador es {id, nombre,
## personaje}: personaje, su índice en el equipo (0, 1 o 2).
##
## Lo crea Transicion al arrancar, como cuenta.gd: sin autoload nuevo, sin
## tocar project.godot ni subir EJECUTABLE_MINIMO. Sin class_name.

## Para la sala: no se ha podido conectar, o el anfitrión ha rechazado.
signal error_de_red(texto: String)

const CodigoSala := preload("res://globales/codigo_sala.gd")
const PUERTO := 7777
const MAXIMO_JUGADORES := 3
const PERSONAJES := 3

static var actual: Node

var _en_red := false
var _jugadores: Array = []
## El nombre con el que se presenta al unirse a una sala.
var _nombre := ""


func _ready() -> void:
	actual = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_disconnected.connect(_al_desconectarse)
	multiplayer.connected_to_server.connect(_al_entrar_en_la_sala)
	multiplayer.connection_failed.connect(_al_fallar)
	multiplayer.server_disconnected.connect(_al_perder_al_anfitrion)
	(multiplayer as SceneMultiplayer).peer_packet.connect(_al_recibir)


func en_red() -> bool:
	return _en_red


func es_anfitrion() -> bool:
	return _en_red and multiplayer.is_server()


## El id de este ordenador en la red (1 sin red: el que juega solo).
func mi_id() -> int:
	return multiplayer.get_unique_id() if _en_red else 1


func jugadores() -> Array:
	return _jugadores


## Abre la sala en este ordenador y devuelve su código ("" si no se puede).
func crear_sala(nombre: String) -> String:
	var peer := ENetMultiplayerPeer.new()
	# Una plaza más de las que caben: así el que sobra conecta y recibe «La
	# sala está llena», en vez de quedarse esperando a que ENet le corte.
	if peer.create_server(PUERTO, MAXIMO_JUGADORES) != OK:
		error_de_red.emit("No se puede abrir la sala: ¿hay otra abierta en este ordenador?")
		return ""
	multiplayer.multiplayer_peer = peer
	_en_red = true
	_jugadores = [{"id": 1, "nombre": nombre, "personaje": 0}]
	BusEventos.sala_cambiada.emit(_jugadores)
	return CodigoSala.de_ip(CodigoSala.ip_local())


## Se une a la sala de ese código. Contesta con sala_cambiada al entrar o con
## error_de_red.
func unirse(codigo: String, nombre: String) -> void:
	var ip := CodigoSala.a_ip(codigo)
	if ip == "":
		error_de_red.emit("Ese código no es válido: son 7 letras y números.")
		return
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(ip, PUERTO) != OK:
		error_de_red.emit("No se ha podido conectar.")
		return
	multiplayer.multiplayer_peer = peer
	_en_red = true
	_nombre = nombre


func salir() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_en_red = false
	_jugadores = []


## Pide llevar ese personaje en la sala (el anfitrión decide si está libre).
func elegir_personaje(indice: int) -> void:
	if es_anfitrion():
		_poner_personaje(1, indice)
	else:
		_mandar(["personaje", indice], 1)


## Solo el anfitrión: empieza la partida para todos.
func empezar() -> void:
	if not es_anfitrion():
		return
	_mandar(["empieza", _jugadores])
	BusEventos.partida_en_red_empieza.emit(_jugadores)


## Cliente → anfitrión, cada fotograma: lo que ha pulsado. fiable: lo que
## tiene que llegar sí o sí (la mejora elegida); lo demás, si se pierde, va
## en el siguiente fotograma.
func enviar_entrada(entrada: Dictionary, fiable := false) -> void:
	var modo := MultiplayerPeer.TRANSFER_MODE_RELIABLE if fiable else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
	_mandar(["entrada", entrada], 1, modo)


## Anfitrión → clientes, unas 20 veces por segundo: si se pierde uno, el
## siguiente ya trae lo de ahora, así que no hace falta que llegue.
func enviar_estado(estado: Dictionary) -> void:
	_mandar(["estado", estado], 0, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED)


## Anfitrión → clientes: algo que ha pasado, que sí tiene que llegar.
func enviar_suceso(suceso: String, datos: Array) -> void:
	_mandar(["suceso", suceso, datos])


## destino 0: a todos.
func _mandar(mensaje: Array, destino := 0, modo := MultiplayerPeer.TRANSFER_MODE_RELIABLE) -> void:
	if _en_red:
		(multiplayer as SceneMultiplayer).send_bytes(var_to_bytes(mensaje), destino, modo)


func _al_recibir(id: int, bytes: PackedByteArray) -> void:
	var mensaje: Variant = bytes_to_var(bytes)
	if not mensaje is Array or mensaje.is_empty():
		return
	match mensaje[0]:
		"hola":
			_al_saludar(id, mensaje[1], mensaje[2])
		"rechazo":
			salir()
			error_de_red.emit(mensaje[1])
		"sala":
			_jugadores = mensaje[1]
			BusEventos.sala_cambiada.emit(_jugadores)
		"personaje":
			if es_anfitrion():
				_poner_personaje(id, mensaje[1])
		"empieza":
			BusEventos.partida_en_red_empieza.emit(mensaje[1])
		"entrada":
			BusEventos.entrada_recibida.emit(id, mensaje[1])
		"estado":
			BusEventos.estado_recibido.emit(mensaje[1])
		"suceso":
			BusEventos.suceso_recibido.emit(mensaje[1], mensaje[2])


## Al conectar, el cliente se presenta con su nombre y su versión.
func _al_entrar_en_la_sala() -> void:
	_mandar(["hola", _nombre, Version.ACTUAL], 1)


## En el anfitrión: entra si tiene la misma versión y queda sitio, con el
## primer personaje libre.
func _al_saludar(id: int, nombre: String, version: String) -> void:
	if not es_anfitrion():
		return
	if version != Version.ACTUAL:
		_rechazar(id, "La sala es de la versión %s y tú tienes la %s." % [Version.ACTUAL, version])
		return
	var libre := _primer_personaje_libre()
	if _jugadores.size() >= MAXIMO_JUGADORES or libre == -1:
		_rechazar(id, "La sala está llena.")
		return
	_jugadores.append({"id": id, "nombre": nombre, "personaje": libre})
	_avisar_sala()


func _rechazar(id: int, texto: String) -> void:
	_mandar(["rechazo", texto], id)
	# Un momento después, para que le llegue el mensaje antes de cortar.
	get_tree().create_timer(0.5).timeout.connect(func(): multiplayer.multiplayer_peer.disconnect_peer(id))


## Si está libre (y existe), ese jugador pasa a llevarlo.
func _poner_personaje(id: int, indice: int) -> void:
	if indice < 0 or indice >= PERSONAJES:
		return
	for jugador in _jugadores:
		if jugador.personaje == indice and jugador.id != id:
			return
	for jugador in _jugadores:
		if jugador.id == id:
			jugador.personaje = indice
	_avisar_sala()


func _primer_personaje_libre() -> int:
	for indice in PERSONAJES:
		if not _jugadores.any(func(jugador): return jugador.personaje == indice):
			return indice
	return -1


## El anfitrión manda la lista a todos y la avisa aquí.
func _avisar_sala() -> void:
	_mandar(["sala", _jugadores])
	BusEventos.sala_cambiada.emit(_jugadores)


## Se ha ido un cliente: sale de la sala y su personaje queda libre.
func _al_desconectarse(id: int) -> void:
	# El rechazado (versión distinta, sala llena) nunca entró en la sala.
	if not es_anfitrion() or not _jugadores.any(func(jugador): return jugador.id == id):
		return
	_jugadores = _jugadores.filter(func(jugador): return jugador.id != id)
	_avisar_sala()
	BusEventos.jugador_desconectado.emit(id)


func _al_fallar() -> void:
	salir()
	error_de_red.emit("No se ha podido conectar con esa sala.")


## Se ha ido el anfitrión: se acaba para todos.
func _al_perder_al_anfitrion() -> void:
	salir()
	BusEventos.jugador_desconectado.emit(1)
