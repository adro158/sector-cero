extends Node

## La partida en red (plan_multijugador.md, punto 5). Lo añade raiz_juego.gd
## solo si se juega en red. El jugador de la escena es el de este ordenador
## (con la cámara); los de los demás se crean aquí, sin cámara y sin teclado,
## cada uno con el personaje que eligió en la sala.
##
## La partida es la del anfitrión: él simula y mueve a los demás con lo que
## llega por la red (entrada_recibida), y les manda cómo va (estado_red.gd).
## Los clientes no simulan: mandan lo que pulsan y dibujan lo que llega. Las
## mejoras de cada uno van y vienen por la red.
##
## Sin class_name: lo crea raiz_juego.gd con preload.

const Red := preload("res://globales/red.gd")
const EstadoRed := preload("res://escenas/red/estado_red.gd")
const Dificultad := preload("res://globales/dificultad.gd")
const JUGADOR := preload("res://escenas/jugabilidad/jugador/jugador.tscn")
const MENU := "res://escenas/menu_principal/menu_principal.tscn"
## Los de los demás aparecen al lado, para no salir unos encima de otros.
const SEPARACION := 60.0
## El estado, cada 3 pasos de física: 20 veces por segundo.
const CADA := 3

## Los jugadores por su id de la red.
var _por_id := {}
var _pasos := 0
## Lo último que avisó el bus en el anfitrión, para mandarlo con el estado.
var _reloj := []
var _experiencia := []


func _ready() -> void:
	_preparar.call_deferred()
	BusEventos.entrada_recibida.connect(_al_recibir_entrada)
	BusEventos.estado_recibido.connect(_al_recibir_estado)
	BusEventos.suceso_recibido.connect(_al_recibir_suceso)
	BusEventos.jugador_desconectado.connect(_al_irse)
	BusEventos.tiempo_partida.connect(_al_cambiar_reloj)
	BusEventos.experiencia_cambiada.connect(_al_cambiar_experiencia)
	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)


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
	if not red.es_anfitrion():
		_solo_dibujar(raiz)


## En los clientes no se simula: las oleadas paradas, la horda y los
## fragmentos solo se dibujan y los jugadores (también el de aquí) van donde
## dice el anfitrión. Lo que se pulsa se manda en _physics_process.
func _solo_dibujar(raiz: Node) -> void:
	raiz.get_node("DirectorOleadas").process_mode = Node.PROCESS_MODE_DISABLED
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		gestor.solo_dibujar = true
	get_tree().get_first_node_in_group("pool_gemas").solo_dibujar = true
	for jugador in _por_id.values():
		jugador.por_red = true


func _physics_process(_delta: float) -> void:
	var red: Node = Red.actual
	if not red.en_red():
		return
	if red.es_anfitrion():
		_pasos += 1
		if _pasos % CADA == 0 and not _por_id.is_empty():
			red.enviar_estado(EstadoRed.del_anfitrion(get_tree(), _por_id, _reloj, _experiencia))
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


## En el anfitrión: lo que ha pulsado (o elegido) el de otro ordenador.
func _al_recibir_entrada(id: int, entrada: Dictionary) -> void:
	var jugador: Node = _por_id.get(id)
	if jugador == null or not Red.actual.es_anfitrion():
		return
	if entrada.has("mejora"):
		get_parent().get_node("SistemaNiveles").elegir(jugador, load(entrada.mejora))
		return
	jugador.direccion_red = entrada.get("direccion", Vector2.ZERO)
	if entrada.get("cambiar", 0) != 0:
		jugador.get_node("CambioPersonaje").cambiar(entrada.cambiar)
	if entrada.get("ulti", false) and jugador.get_node("Ultis").lista():
		jugador.get_node("Ultis").lanzar()


func _al_recibir_estado(estado: Dictionary) -> void:
	if not _por_id.is_empty():
		EstadoRed.aplicar(get_tree(), _por_id, estado)


## En el anfitrión: al subir de nivel, a cada uno de los demás sus opciones
## (por su ruta: un recurso no viaja por la red).
func _al_subir_nivel(_opciones: Array) -> void:
	if not Red.actual.es_anfitrion():
		return
	var niveles: Node = get_parent().get_node("SistemaNiveles")
	for id in _por_id:
		var opciones: Array = niveles.opciones_de(_por_id[id])
		if id != 1 and not opciones.is_empty():
			Red.actual.enviar_suceso("mejoras", [id, opciones.map(func(mejora): return mejora.resource_path)])


## En los clientes: le toca elegir. Se pausa aquí, como al subir de nivel, y
## el panel de mejoras enseña las suyas.
func _al_recibir_suceso(suceso: String, datos: Array) -> void:
	if suceso == "mejoras" and datos[0] == Red.actual.mi_id():
		var opciones: Array[DatosMejora] = []
		for ruta in datos[1]:
			opciones.append(load(ruta))
		get_tree().paused = true
		BusEventos.jugador_subio_nivel.emit(opciones)


## En los clientes: la elegida, al anfitrión (que la aplica y sigue cuando
## han elegido todos), y fuera la pausa de aquí.
func _al_elegir_mejora(mejora: DatosMejora) -> void:
	if Red.actual.en_red() and not Red.actual.es_anfitrion():
		Red.actual.enviar_entrada({"mejora": mejora.resource_path}, true)
		get_tree().paused = false


func _al_cambiar_reloj(segundos: float, duracion: float) -> void:
	_reloj = [segundos, duracion]


func _al_cambiar_experiencia(actual: int, necesaria: int, nivel: int) -> void:
	_experiencia = [actual, necesaria, nivel]


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
