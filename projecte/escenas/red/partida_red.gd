extends Node

## La partida en red (plan_multijugador.md, punto 5). Lo añade raiz_juego.gd
## solo si se juega en red. Cómo empieza (los jugadores de los demás y lo que
## en los clientes solo se dibuja), en preparar_red.gd.
##
## La partida es la del anfitrión: él simula y mueve a los demás con lo que
## llega por la red (entrada_recibida), y les manda cómo va (estado_red.gd).
## Los clientes no simulan: mandan lo que pulsan y dibujan lo que llega. Las
## mejoras de cada uno van y vienen por la red.
##
## Sin class_name: lo crea raiz_juego.gd con preload.

const Red := preload("res://globales/red.gd")
const EstadoRed := preload("res://escenas/red/estado_red.gd")
const PrepararRed := preload("res://escenas/red/preparar_red.gd")
const MENU := "res://escenas/menu_principal/menu_principal.tscn"
## El estado, cada 3 pasos de física: 20 veces por segundo.
const CADA := 3
## Lo más que va en cada estado de muertes y de golpes (_muertes, _golpes).
const MAXIMO_MUERTES := 150
const MAXIMO_GOLPES := 40

## Los jugadores por su id de la red.
var _por_id := {}
var _pasos := 0
## Lo último que avisó el bus en el anfitrión, para mandarlo con el estado.
var _reloj := []
var _experiencia := []
## Si la partida ya se ha acabado (cada uno está en su pantalla final).
var _terminada := false
## En el anfitrión, las muertes y los golpes desde el último estado (van con
## el siguiente, para los efectos de los clientes). Con un tope: con un arma
## de área golpeando a decenas a la vez no hace falta mandarlos todos.
var _muertes := []
var _golpes := []


func _ready() -> void:
	_preparar.call_deferred()
	BusEventos.entrada_recibida.connect(_al_recibir_entrada)
	BusEventos.estado_recibido.connect(_al_recibir_estado)
	BusEventos.suceso_recibido.connect(_al_recibir_suceso)
	BusEventos.jugador_desconectado.connect(_al_irse)
	BusEventos.tiempo_partida.connect(_al_cambiar_reloj)
	BusEventos.experiencia_cambiada.connect(_al_cambiar_experiencia)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)
	BusEventos.partida_terminada.connect(_al_terminar)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


## Al salir de la partida (al menú), también de la red: si no, se seguiría
## conectado a una sala que ya no se ve.
func _exit_tree() -> void:
	Red.actual.salir()


## En el anfitrión: la partida se ha acabado, para todos. Los personajes, por
## su ruta (un recurso no viaja por la red).
func _al_terminar(estadisticas: Dictionary) -> void:
	_terminada = true
	if Red.actual.es_anfitrion():
		Red.actual.enviar_suceso("fin", [EstadoRed.fin_para_red(estadisticas)])


func _preparar() -> void:
	var raiz := get_parent()
	var niveles: Node = raiz.get_node("SistemaNiveles")
	niveles.opciones_sorteadas.connect(_al_subir_nivel)
	niveles.ruleta_sorteada.connect(_al_sortear_ruleta)
	_por_id = PrepararRed.jugadores(raiz, Red.actual)
	if Red.actual.es_anfitrion():
		for objetivo in get_tree().get_nodes_in_group("objetivos"):
			objetivo.enemigo_danado.connect(_al_danar_enemigo)
	else:
		# Lo que se pulsa se manda en _physics_process.
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
## (por su ruta: un recurso no viaja por la red). Con la señal del sistema de
## niveles y no con la del bus: si el anfitrión se queda mirando, el bus no
## avisa (no elige) y los demás se quedarían esperando en pausa.
func _al_subir_nivel() -> void:
	if not Red.actual.es_anfitrion():
		return
	var niveles: Node = get_parent().get_node("SistemaNiveles")
	for id in _por_id:
		var opciones: Array = niveles.opciones_de(_por_id[id])
		if id != 1 and not opciones.is_empty():
			Red.actual.enviar_suceso("mejoras", [id, opciones.map(func(mejora): return mejora.resource_path)])


## En el anfitrión: un cofre que ha recogido otro. Su ruleta, a él.
func _al_sortear_ruleta(jugador: Node, sectores: Array, premio: DatosMejora) -> void:
	Red.actual.enviar_suceso("ruleta", [_por_id.find_key(jugador),
		sectores.map(func(mejora): return mejora.resource_path), premio.resource_path])


## En los clientes: le toca elegir. Se pausa aquí, como al subir de nivel, y
## el panel de mejoras enseña las suyas (o la ruleta, la de su cofre).
func _al_recibir_suceso(suceso: String, datos: Array) -> void:
	if suceso == "fin":
		_terminar_aqui(datos[0])
	elif suceso in ["mejoras", "ruleta"] and datos[0] == Red.actual.mi_id():
		var opciones: Array[DatosMejora] = []
		for ruta in datos[1]:
			opciones.append(load(ruta))
		get_tree().paused = true
		if suceso == "mejoras":
			BusEventos.jugador_subio_nivel.emit(opciones)
		else:
			BusEventos.ruleta_abierta.emit(opciones, load(datos[2]))


## En los clientes: la partida del anfitrión se ha acabado. Como en la de un
## jugador, con el juego en pausa: la pantalla final lo enseña.
func _terminar_aqui(datos: Dictionary) -> void:
	get_tree().paused = true
	BusEventos.partida_terminada.emit(EstadoRed.fin_desde_red(datos))


## En los clientes: la elegida, al anfitrión (que la aplica y sigue cuando
## han elegido todos), y fuera la pausa de aquí.
func _al_elegir_mejora(mejora: DatosMejora) -> void:
	if Red.actual.en_red() and not Red.actual.es_anfitrion():
		Red.actual.enviar_entrada({"mejora": mejora.resource_path}, true)
		get_tree().paused = false


## En el anfitrión (en los clientes, las muertes las avisa estado_red.gd).
func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	if Red.actual.es_anfitrion() and _muertes.size() < MAXIMO_MUERTES:
		_muertes.append([posicion, tipo])


func _al_danar_enemigo(posicion: Vector2, cantidad: float, resistencia: float) -> void:
	if _golpes.size() < MAXIMO_GOLPES:
		_golpes.append([posicion, cantidad, resistencia])


func _al_cambiar_reloj(segundos: float, duracion: float) -> void:
	_reloj = [segundos, duracion]


func _al_cambiar_experiencia(actual: int, necesaria: int, nivel: int) -> void:
	_experiencia = [actual, necesaria, nivel]


## Se va un cliente: su personaje queda libre (decisión de Adam, 13/11). Se va
## el anfitrión: se acaba para todos.
func _al_irse(id: int) -> void:
	# Acabada la partida, cada uno sale de su pantalla final cuando quiere.
	if _terminada:
		return
	if id == 1:
		get_tree().paused = false
		Transicion.cambiar_a(MENU)
		return
	var jugador: Node = _por_id.get(id)
	if jugador != null:
		jugador.get_node("CambioPersonaje").irse()
		_por_id.erase(id)
