extends Node

## La partida en red (plan_multijugador.md, punto 5). Lo añade raiz_juego.gd
## solo si se juega en red. El jugador de la escena es el de este ordenador
## (con la cámara); los de los demás se crean aquí, sin cámara y sin teclado,
## cada uno con el personaje que eligió en la sala.
##
## En el anfitrión, los de los demás se mueven, cambian y lanzan la ulti con
## lo que llega por la red (entrada_recibida). En los clientes, cada
## fotograma se manda lo que se pulsa (red.gd, enviar_entrada).
##
## Primera tanda (13/11): todavía cada ordenador simula su partida; que los
## clientes dibujen la del anfitrión es la segunda.
##
## Sin class_name: lo crea raiz_juego.gd con preload.

const Red := preload("res://globales/red.gd")
const Dificultad := preload("res://globales/dificultad.gd")
const JUGADOR := preload("res://escenas/jugabilidad/jugador/jugador.tscn")
const MENU := "res://escenas/menu_principal/menu_principal.tscn"
## Los de los demás aparecen al lado, para no salir unos encima de otros.
const SEPARACION := 60.0

## Los jugadores por su id de la red.
var _por_id := {}


func _ready() -> void:
	_preparar.call_deferred()
	BusEventos.entrada_recibida.connect(_al_recibir_entrada)
	BusEventos.jugador_desconectado.connect(_al_irse)


func _preparar() -> void:
	var red: Node = Red.actual
	var raiz := get_parent()
	var local: Node2D = raiz.get_node("Jugador")
	# Primero el de este ordenador: al empezar lleva el primer personaje y, si
	# eligió otro, lo deja libre para los demás.
	for jugador in red.jugadores():
		if jugador.id == red.mi_id():
			_por_id[jugador.id] = local
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
		_por_id[jugador.id] = otro
	# Los jugadores no chocan entre ellos: si no, al pasar uno al lado del
	# otro, Godot los separa y uno arrastra al otro.
	for uno in _por_id.values():
		for otro in _por_id.values():
			if uno != otro:
				uno.add_collision_exception_with(otro)


## En los clientes: lo que se pulsa, cada fotograma, al anfitrión.
func _physics_process(_delta: float) -> void:
	var red: Node = Red.actual
	if not red.en_red() or red.es_anfitrion():
		return
	var cambiar := 0
	if Input.is_action_just_pressed("cambiar_personaje"):
		cambiar = 1
	elif Input.is_action_just_pressed("personaje_anterior"):
		cambiar = -1
	red.enviar_entrada({
		"direccion": Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo"),
		"cambiar": cambiar,
		"ulti": Input.is_action_just_pressed("ulti"),
	})


## En el anfitrión: lo que ha pulsado el de otro ordenador.
func _al_recibir_entrada(id: int, entrada: Dictionary) -> void:
	var jugador: Node = _por_id.get(id)
	if jugador == null or not Red.actual.es_anfitrion():
		return
	jugador.direccion_red = entrada.get("direccion", Vector2.ZERO)
	if entrada.get("cambiar", 0) != 0:
		jugador.get_node("CambioPersonaje").cambiar(entrada.cambiar)
	if entrada.get("ulti", false) and jugador.get_node("Ultis").lista():
		jugador.get_node("Ultis").lanzar()


## Se va un cliente: su personaje queda libre (decisión de Adam, 13/11). Se va
## el anfitrión: se acaba para todos.
func _al_irse(id: int) -> void:
	if id == 1:
		get_tree().paused = false
		Transicion.cambiar_a(MENU)
		return
	var jugador: Node = _por_id.get(id)
	if jugador != null:
		jugador.get_node("CambioPersonaje").irse()
		_por_id.erase(id)
