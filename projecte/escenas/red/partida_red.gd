extends Node

## La partida en red (plan_multijugador.md, punto 5). Lo añade raiz_juego.gd
## solo si se juega en red. Cómo empieza (los jugadores de los demás y lo que
## en los clientes solo se dibuja), en preparar_red.gd; lo que pasa una vez y
## tiene que llegar (el final, las mejoras, la ruleta, las ultis), en
## sucesos_red.gd.
##
## La partida es la del anfitrión: él simula y mueve a los demás con lo que
## llega por la red (entrada_recibida), y les manda cómo va (estado_red.gd).
## Los clientes no simulan: mandan lo que pulsan y dibujan lo que llega.
##
## Sin class_name: lo crea raiz_juego.gd con preload.

const Red := preload("res://globales/red.gd")
const EstadoRed := preload("res://escenas/red/estado_red.gd")
const PrepararRed := preload("res://escenas/red/preparar_red.gd")
const SucesosRed := preload("res://escenas/red/sucesos_red.gd")
const MENU := "res://escenas/menu_principal/menu_principal.tscn"
## El estado, cada 3 pasos de física: 20 veces por segundo.
const CADA := 3
## En los clientes: sin estados durante más de esto (el anfitrión está en
## pausa eligiendo, o se ha cortado), los jugadores dejan de andar solos.
const SIN_ESTADO_MS := 150
## Lo más que va en cada estado de muertes y de golpes (_muertes, _golpes).
const MAXIMO_MUERTES := 150
const MAXIMO_GOLPES := 40

## Los jugadores por su id de la red.
var _por_id := {}
var _pasos := 0
## Lo último que avisó el bus en el anfitrión, para mandarlo con el estado.
var _reloj := []
var _experiencia := []
## En el anfitrión, las muertes y los golpes desde el último estado (van con
## el siguiente, para los efectos de los clientes). Con un tope: con un arma
## de área golpeando a decenas a la vez no hace falta mandarlos todos.
var _muertes := []
var _golpes := []
## En los clientes, cuándo llegó el último estado (Time.get_ticks_msec).
var _ultimo_estado := 0
## El menú de pausa está abierto (en red no pausa: _al_pausar).
var _menu_abierto := false
var _sucesos: Node


func _ready() -> void:
	_sucesos = SucesosRed.new()
	add_child(_sucesos)
	_preparar.call_deferred()
	BusEventos.entrada_recibida.connect(_al_recibir_entrada)
	BusEventos.estado_recibido.connect(_al_recibir_estado)
	BusEventos.jugador_desconectado.connect(_al_irse)
	BusEventos.tiempo_partida.connect(_al_cambiar_reloj)
	BusEventos.experiencia_cambiada.connect(_al_cambiar_experiencia)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.juego_pausado.connect(_al_pausar)


## Al salir de la partida (al menú), también de la red: si no, se seguiría
## conectado a una sala que ya no se ve.
func _exit_tree() -> void:
	Red.actual.salir()


func _preparar() -> void:
	var raiz := get_parent()
	_por_id = PrepararRed.jugadores(raiz, Red.actual)
	# El mismo diccionario: lo que se borre aquí al irse uno, también allí.
	_sucesos.por_id = _por_id
	_sucesos.conectar(raiz)
	if Red.actual.es_anfitrion():
		for objetivo in get_tree().get_nodes_in_group("objetivos"):
			objetivo.enemigo_danado.connect(_al_danar_enemigo)
	else:
		# Lo que se pulsa se manda en _physics_process; la ulti, al pedirla.
		PrepararRed.solo_dibujar(raiz, _por_id)


func _physics_process(_delta: float) -> void:
	var red: Node = Red.actual
	if not red.en_red():
		return
	if red.es_anfitrion():
		_pasos += 1
		if _pasos % CADA == 0 and not _por_id.is_empty():
			red.enviar_estado(EstadoRed.del_anfitrion(get_tree(), _por_id, _reloj, _experiencia, _muertes, _golpes))
			_muertes = []
			_golpes = []
		return
	# Entre un estado y el siguiente cada jugador sigue hacia donde iba; si no
	# llegan, se queda quieto en vez de irse andando.
	if Time.get_ticks_msec() - _ultimo_estado > SIN_ESTADO_MS:
		for jugador in _por_id.values():
			jugador.direccion_red = Vector2.ZERO
	var direccion := Vector2.ZERO
	var cambiar := 0
	if not _menu_abierto:
		direccion = Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
		if Input.is_action_just_pressed("cambiar_personaje"):
			cambiar = 1
		elif Input.is_action_just_pressed("personaje_anterior"):
			cambiar = -1
	red.enviar_entrada({"direccion": direccion, "cambiar": cambiar})


## En el anfitrión: lo que ha pulsado (o elegido) el de otro ordenador.
func _al_recibir_entrada(id: int, entrada: Dictionary) -> void:
	var jugador: Node = _por_id.get(id)
	if jugador == null or not Red.actual.es_anfitrion():
		return
	if entrada.has("mejora"):
		get_parent().get_node("SistemaNiveles").elegir(jugador, load(entrada.mejora))
		return
	# La ulti, con la dirección que ha apuntado allí (cero: al más cercano).
	if entrada.has("ulti"):
		# En pausa (alguien elige mejora) no: se vería y golpearía después.
		if not get_tree().paused and not jugador.get_node("CambioPersonaje").espectador() and jugador.get_node("Ultis").lista():
			jugador.get_node("Ultis").lanzar(entrada.ulti)
		return
	jugador.direccion_red = entrada.get("direccion", Vector2.ZERO)
	if entrada.get("cambiar", 0) != 0:
		jugador.get_node("CambioPersonaje").cambiar(entrada.cambiar)


## En los clientes. Acabada la partida ya no se pone nada: la pantalla final
## está encima.
func _al_recibir_estado(estado: Dictionary) -> void:
	if _por_id.is_empty() or _sucesos.terminada:
		return
	_ultimo_estado = Time.get_ticks_msec()
	# Los que ya no vienen se han ido de la partida: la desconexión de otro
	# cliente solo la ve el anfitrión. Su personaje queda libre, como allí.
	for id in _por_id.keys():
		if not estado.j.has(id):
			_por_id[id].get_node("CambioPersonaje").irse()
			_por_id.erase(id)
	EstadoRed.aplicar(get_tree(), _por_id, estado)


## En el anfitrión (en los clientes, las muertes las avisa estado_red.gd).
func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	if Red.actual.es_anfitrion() and _muertes.size() < MAXIMO_MUERTES:
		_muertes.append([posicion, tipo])


func _al_danar_enemigo(posicion: Vector2, cantidad: float, resistencia: float) -> void:
	if _golpes.size() < MAXIMO_GOLPES:
		_golpes.append([posicion, cantidad, resistencia])


## En red el menú de pausa sale pero no para nada (raiz_juego.gd). Mientras
## está abierto, el jugador de aquí se queda quieto y no cambia ni lanza la
## ulti: si no, las flechas o el mando del menú le moverían por la partida.
func _al_pausar(en_pausa: bool) -> void:
	_menu_abierto = en_pausa
	var local: Node = get_parent().get_node("Jugador")
	for parte in ["CambioPersonaje", "Ultis"]:
		local.get_node(parte).set_process_unhandled_input(not en_pausa)
	# El clic de apuntar del Mago va por _input: también fuera, y sin mira.
	local.get_node("Ultis").set_process_input(not en_pausa)
	if en_pausa:
		local.get_node("Ultis").cancelar_mira()
	# En el anfitrión se mueve con el teclado: se le para como a los de la red.
	if Red.actual.es_anfitrion():
		local.por_red = en_pausa
		local.direccion_red = Vector2.ZERO


func _al_cambiar_reloj(segundos: float, duracion: float) -> void:
	_reloj = [segundos, duracion]


func _al_cambiar_experiencia(actual: int, necesaria: int, nivel: int) -> void:
	_experiencia = [actual, necesaria, nivel]


## Se va un cliente: su personaje queda libre (decisión de Adam, 13/11). Se va
## el anfitrión: se acaba para todos.
func _al_irse(id: int) -> void:
	# Acabada la partida, cada uno sale de su pantalla final cuando quiere.
	if _sucesos.terminada:
		return
	if id == 1:
		# El aviso lo enseña la sala al volver al menú (sala_red.gd).
		Red.actual.aviso = "El anfitrión ha cerrado la partida."
		get_tree().paused = false
		Transicion.cambiar_a(MENU)
		return
	var jugador: Node = _por_id.get(id)
	if jugador == null:
		return
	jugador.get_node("CambioPersonaje").irse()
	_por_id.erase(id)
	# Si estaba eligiendo mejora (o girando su ruleta), ya no se le espera:
	# si no, la partida se quedaría en pausa para siempre.
	get_parent().get_node("SistemaNiveles").quitar(jugador)
	# Su personaje ha quedado libre: si alguien estaba mirando, vuelve con él.
	get_parent().get_node("Jugador/CambioPersonaje").volver_espectadores()
