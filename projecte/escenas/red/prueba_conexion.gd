extends SceneTree
## Prueba mínima de ENet: ¿se conectan dos ordenadores de la misma red?
## Es el punto 1 de la red en documentacio/plan_multijugador.md. No forma parte
## del juego: se lanza a mano desde la consola, con Godot y sin ventana.
##
## En el ordenador que hace de anfitrión (deja la ventana abierta):
##   Godot_console.exe --headless --path projecte -s res://escenas/red/prueba_conexion.gd -- anfitrion
## En el otro, con una de las IP que enseña el anfitrión:
##   Godot_console.exe --headless --path projecte -s res://escenas/red/prueba_conexion.gd -- unirse 192.168.1.37
##
## El cliente manda un «ping» cada segundo y el anfitrión lo devuelve: si
## llegan las respuestas, la red deja pasar el juego. Windows puede preguntar
## si se deja a Godot usar la red: hay que aceptar en el anfitrión.

const PUERTO := 7777
const MAX_CLIENTES := 2
const PINGS := 5
const ESPERA_MAXIMA := 10.0  # segundos sin conectar antes de rendirse

var es_anfitrion := false
var pings_enviados := 0
var pings_recibidos := 0
var hora_ultimo_ping := 0
var tiempo_espera := 0.0
var tiempo_desde_ping := 0.0
var conectado := false


func _initialize() -> void:
	var argumentos := OS.get_cmdline_user_args()
	if argumentos.size() >= 1 and argumentos[0] == "anfitrion":
		crear_sala()
	elif argumentos.size() >= 2 and argumentos[0] == "unirse":
		unirse(argumentos[1])
	else:
		print("Uso: -- anfitrion   o   -- unirse <IP>")
		quit(1)


func crear_sala() -> void:
	es_anfitrion = true
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PUERTO, MAX_CLIENTES)
	if error != OK:
		print("No se ha podido abrir el puerto %d (error %d)." % [PUERTO, error])
		quit(1)
		return
	preparar(peer)
	print("Sala abierta en el puerto %d (UDP). Escribe en el otro ordenador una de estas IP:" % PUERTO)
	for ip in ips_locales():
		print("  ", ip)
	print("Ctrl+C para cerrar.")


func unirse(ip: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip, PUERTO)
	if error != OK:
		print("No se ha podido crear el cliente (error %d)." % error)
		quit(1)
		return
	preparar(peer)
	print("Conectando con %s:%d..." % [ip, PUERTO])


func preparar(peer: ENetMultiplayerPeer) -> void:
	var red := get_multiplayer() as SceneMultiplayer
	red.multiplayer_peer = peer
	red.peer_connected.connect(_al_conectarse_alguien)
	red.peer_disconnected.connect(_al_irse_alguien)
	red.connected_to_server.connect(_al_conectar_con_anfitrion)
	red.connection_failed.connect(_al_fallar_conexion)
	red.peer_packet.connect(_al_recibir)


func _process(delta: float) -> bool:
	if es_anfitrion:
		return false
	if not conectado:
		tiempo_espera += delta
		if tiempo_espera > ESPERA_MAXIMA:
			print("FALLO: %d s sin respuesta del anfitrión. La red no deja pasar la conexión, o la IP o el cortafuegos no están bien." % ESPERA_MAXIMA)
			quit(1)
		return false
	tiempo_desde_ping += delta
	if tiempo_desde_ping >= 1.0 and pings_enviados < PINGS:
		tiempo_desde_ping = 0.0
		pings_enviados += 1
		hora_ultimo_ping = Time.get_ticks_msec()
		enviar("ping")
	return false


func enviar(texto: String, destino := 1) -> void:
	(get_multiplayer() as SceneMultiplayer).send_bytes(texto.to_utf8_buffer(), destino)


func _al_recibir(id: int, paquete: PackedByteArray) -> void:
	var texto := paquete.get_string_from_utf8()
	if es_anfitrion and texto == "ping":
		enviar("pong", id)
	elif texto == "pong":
		pings_recibidos += 1
		print("pong %d/%d: %d ms" % [pings_recibidos, PINGS, Time.get_ticks_msec() - hora_ultimo_ping])
		if pings_recibidos == PINGS:
			print("CONECTA: la red deja jugar entre estos dos ordenadores.")
			quit(0)


func _al_conectarse_alguien(id: int) -> void:
	if es_anfitrion:
		print("Se ha unido el jugador %d." % id)


func _al_irse_alguien(id: int) -> void:
	if es_anfitrion:
		print("Se ha ido el jugador %d." % id)


func _al_conectar_con_anfitrion() -> void:
	conectado = true
	print("Conectado al anfitrión. Mi id: %d" % get_multiplayer().get_unique_id())


func _al_fallar_conexion() -> void:
	print("FALLO: no se ha podido conectar con el anfitrión.")
	quit(1)


## Las IPv4 de este ordenador en la red local (sin la de bucle 127.x ni las 169.254.x sin red).
func ips_locales() -> Array:
	var ips := []
	for ip in IP.get_local_addresses():
		if ip.count(".") == 3 and not ip.begins_with("127.") and not ip.begins_with("169.254."):
			ips.append(ip)
	return ips
