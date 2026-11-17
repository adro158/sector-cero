extends RefCounted

## Cómo empieza la partida en red (partida_red.gd): los jugadores de los demás
## y, en los clientes, todo lo que solo se dibuja. Aparte de partida_red.gd
## para que ese no pase de ~200 líneas.
##
## Sin class_name: se carga con preload.

const EstadoRed := preload("res://escenas/red/estado_red.gd")
const Dificultad := preload("res://globales/dificultad.gd")
const JUGADOR := preload("res://escenas/jugabilidad/jugador/jugador.tscn")
## Los de los demás aparecen al lado, para no salir unos encima de otros.
const SEPARACION := 60.0


## El jugador de la escena es el de este ordenador (con la cámara); los de los
## demás se crean aquí, sin cámara y sin teclado, cada uno con el personaje
## que eligió en la sala. Devuelve los jugadores por su id de la red.
static func jugadores(raiz: Node, red: Node) -> Dictionary:
	var por_id := {}
	var local: Node2D = raiz.get_node("Jugador")
	# Primero el de este ordenador: al empezar lleva el primer personaje y, si
	# eligió otro, lo deja libre para los demás.
	for jugador in red.jugadores():
		if jugador.id == red.mi_id():
			por_id[jugador.id] = local
			local.get_node("CambioPersonaje").tomar(jugador.personaje)
	var orden := 1
	for jugador in red.jugadores():
		if jugador.id == red.mi_id():
			continue
		var otro: Node2D = JUGADOR.instantiate()
		otro.name = "Jugador%d" % jugador.id
		raiz.add_child(otro)
		otro.global_position = local.global_position + Vector2(SEPARACION * orden, 0.0)
		orden += 1
		# Sin cámara (la de la pantalla es la del de este ordenador) y sin
		# teclado: se mueve con lo que llega por la red.
		otro.get_node("Camara").enabled = false
		otro.por_red = true
		for parte in ["CambioPersonaje", "Ultis"]:
			otro.get_node(parte).set_process_unhandled_input(false)
			otro.get_node(parte).set_process_input(false)
		otro.get_node("Salud").multiplicador_dano = Dificultad.dato("dano")
		otro.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
		otro.reset_physics_interpolation()
		otro.get_node("CambioPersonaje").tomar(jugador.personaje)
		por_id[jugador.id] = otro
	# Los jugadores no chocan entre ellos: si no, al pasar uno al lado del
	# otro, Godot los separa y uno arrastra al otro.
	for uno in por_id.values():
		for otro in por_id.values():
			if uno != otro:
				uno.add_collision_exception_with(otro)
	return por_id


## En los clientes no se simula: las oleadas paradas, la horda, los élites,
## los jefes y sus ataques, los premios y los fragmentos solo se dibujan, y
## los jugadores (también el de aquí) van donde dice el anfitrión.
static func solo_dibujar(raiz: Node, por_id: Dictionary) -> void:
	raiz.get_node("DirectorOleadas").process_mode = Node.PROCESS_MODE_DISABLED
	for grupo in ["gestor_enemigos", "elites"]:
		for enemigo in raiz.get_tree().get_nodes_in_group(grupo):
			enemigo.solo_dibujar = true
	# Los de estado_red.gd (salvo el hielo, que no hace daño).
	for ruta in EstadoRed.RAIZ:
		if ruta != "ZonasHielo":
			raiz.get_node(ruta).solo_dibujar = true
	for ancla in raiz.get_node("JefeFinal/Escudo").get_children():
		ancla.solo_dibujar = true
	raiz.get_tree().get_first_node_in_group("pool_gemas").solo_dibujar = true
	# Y las ultis: su carga llega del anfitrión y la propia se le pide a él.
	for jugador in por_id.values():
		jugador.por_red = true
		jugador.get_node("Ultis").solo_dibujar = true
