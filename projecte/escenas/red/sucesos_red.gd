extends Node

## Lo que pasa una vez en la partida en red y tiene que llegar sí o sí
## (sucesos fiables de red.gd, al contrario que el estado): el final, las
## mejoras y la ruleta que le tocan a cada uno, las mejoras aplicadas y las
## ultis. Lo crea partida_red.gd, que lleva lo continuo (el estado, lo que se
## pulsa y quién se va).
##
## Sin class_name: lo crea partida_red.gd con preload.

const Red := preload("res://globales/red.gd")
const EstadoRed := preload("res://escenas/red/estado_red.gd")

## Los jugadores por su id de la red: el mismo diccionario que el de
## partida_red.gd (lo pone él al preparar la partida).
var por_id := {}
## Si la partida ya se ha acabado (cada uno está en su pantalla final).
var terminada := false


func _ready() -> void:
	BusEventos.suceso_recibido.connect(_al_recibir_suceso)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)
	BusEventos.partida_terminada.connect(_al_terminar)


## Al preparar la partida (partida_red.gd): las señales de los nodos de la
## partida, que en _ready aún no están todos.
func conectar(raiz: Node) -> void:
	var niveles: Node = raiz.get_node("SistemaNiveles")
	niveles.opciones_sorteadas.connect(_al_subir_nivel)
	niveles.ruleta_sorteada.connect(_al_sortear_ruleta)
	niveles.mejora_aplicada.connect(_al_aplicar_mejora)
	if Red.actual.es_anfitrion():
		for id in por_id:
			por_id[id].get_node("Ultis").lanzada.connect(_al_lanzar_ulti.bind(id))
	else:
		raiz.get_node("Jugador/Ultis").pedida.connect(_al_pedir_ulti)


## En el anfitrión: la partida se ha acabado, para todos. Los personajes, por
## su ruta (un recurso no viaja por la red).
func _al_terminar(estadisticas: Dictionary) -> void:
	terminada = true
	if Red.actual.es_anfitrion():
		Red.actual.enviar_suceso("fin", [EstadoRed.fin_para_red(estadisticas)])


## En el anfitrión: al subir de nivel, a cada uno de los demás sus opciones
## (por su ruta). Con la señal del sistema de niveles y no con la del bus: si
## el anfitrión se queda mirando, el bus no avisa (no elige) y los demás se
## quedarían esperando en pausa.
func _al_subir_nivel() -> void:
	if not Red.actual.es_anfitrion():
		return
	var niveles: Node = get_parent().get_parent().get_node("SistemaNiveles")
	for id in por_id:
		var opciones: Array = niveles.opciones_de(por_id[id])
		if id != 1 and not opciones.is_empty():
			Red.actual.enviar_suceso("mejoras", [id, opciones.map(func(mejora): return mejora.resource_path)])


## En el anfitrión: un cofre que ha recogido otro. Su ruleta, a él.
func _al_sortear_ruleta(jugador: Node, sectores: Array, premio: DatosMejora) -> void:
	Red.actual.enviar_suceso("ruleta", [por_id.find_key(jugador),
		sectores.map(func(mejora): return mejora.resource_path), premio.resource_path])


## En el anfitrión: una mejora aplicada a cualquiera, y la ulti que lanza
## cualquiera, a los clientes: para que se vean (la evolución, el alcance, la
## velocidad; el rayo, el giro, la tormenta).
func _al_aplicar_mejora(jugador: Node, mejora: DatosMejora) -> void:
	if Red.actual.es_anfitrion() and por_id.find_key(jugador) != null:
		Red.actual.enviar_suceso("mejora", [por_id.find_key(jugador), mejora.resource_path])


func _al_lanzar_ulti(direccion: Vector2, mini: Array, id: int) -> void:
	Red.actual.enviar_suceso("ulti", [id, direccion, mini])


## En los clientes. «mejoras» y «ruleta»: le toca elegir; se pausa aquí, como
## al subir de nivel, y el panel enseña las suyas (o la ruleta de su cofre).
func _al_recibir_suceso(suceso: String, datos: Array) -> void:
	var niveles: Node = get_parent().get_parent().get_node("SistemaNiveles")
	if suceso == "fin":
		# Como en la de un jugador, con el juego en pausa.
		get_tree().paused = true
		BusEventos.partida_terminada.emit(EstadoRed.fin_desde_red(datos[0]))
	elif suceso == "ulti" and por_id.has(datos[0]):
		por_id[datos[0]].get_node("Ultis").mostrar_lanzada(datos[1], datos[2])
	elif suceso == "mejora" and por_id.has(datos[0]):
		niveles.aplicar_desde_red(por_id[datos[0]], load(datos[1]))
	elif suceso in ["mejoras", "ruleta"] and datos[0] == Red.actual.mi_id():
		var opciones: Array[DatosMejora] = []
		for ruta in datos[1]:
			opciones.append(load(ruta))
		get_tree().paused = true
		if suceso == "mejoras":
			BusEventos.jugador_subio_nivel.emit(opciones)
		else:
			BusEventos.ruleta_abierta.emit(opciones, load(datos[2]))


## En los clientes: la elegida, al anfitrión (que la aplica y sigue cuando
## han elegido todos), y fuera la pausa de aquí.
func _al_elegir_mejora(mejora: DatosMejora) -> void:
	if Red.actual.en_red() and not Red.actual.es_anfitrion():
		Red.actual.enviar_entrada({"mejora": mejora.resource_path}, true)
		get_tree().paused = false


## En los clientes: su ulti, al anfitrión, que la lanza (si está llena allí).
func _al_pedir_ulti(direccion: Vector2) -> void:
	Red.actual.enviar_entrada({"ulti": direccion}, true)
