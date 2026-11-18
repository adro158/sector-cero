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
## La interfaz de la partida en red (interfaz_red.gd): la ruleta del
## cofre de un compañero. La pone partida_red.gd.
var interfaz: Node
## Las mejoras de cada jugador, por id: mejora → veces que la ha cogido. Para
## su ficha (ficha_companero.gd).
var _mejoras := {}


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
			# Después que cambio_personaje.gd, que la conecta en su _ready: al
			# llegar aquí ya ha apuntado al caído y se sabe si era el último.
			por_id[id].get_node("Salud").murio.connect(_al_caer.bind(id))
		# La ruleta del cofre del anfitrión: también a los demás, para que la vean.
		BusEventos.ruleta_abierta.connect(_al_abrir_ruleta_aqui)
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


## Las mejoras de ese jugador (mejora → veces), para su ficha.
func mejoras_de(id: int) -> Dictionary:
	return _mejoras.get(id, {})


func _apuntar(id: int, mejora: DatosMejora) -> void:
	if not _mejoras.has(id):
		_mejoras[id] = {}
	_mejoras[id][mejora] = _mejoras[id].get(mejora, 0) + 1


## En el anfitrión: un cofre que ha recogido otro. Su ruleta va a todos: él la
## gira y elige; los demás la ven en grande, sin elegir. Aquí también.
func _al_sortear_ruleta(jugador: Node, sectores: Array, premio: DatosMejora) -> void:
	var id: int = por_id.find_key(jugador)
	Red.actual.enviar_suceso("ruleta", [id, sectores.map(func(mejora): return mejora.resource_path), premio.resource_path])
	_ver_ruleta(id, sectores, premio)


## En el anfitrión: la de su propio cofre, a los demás.
func _al_abrir_ruleta_aqui(sectores: Array, premio: DatosMejora) -> void:
	Red.actual.enviar_suceso("ruleta", [1, sectores.map(func(mejora): return mejora.resource_path), premio.resource_path])


## La ruleta del cofre de un compañero, en grande y solo para mirarla.
func _ver_ruleta(id: int, sectores: Array, premio: DatosMejora) -> void:
	if por_id.has(id):
		var cambio: Node = por_id[id].get_node("CambioPersonaje")
		interfaz.ruleta.mostrar(id, cambio.nombre_red, cambio.personaje_actual().color, sectores, premio, mejoras_de(id))


## En el anfitrión: una mejora aplicada a cualquiera, y la ulti que lanza
## cualquiera, a los clientes: para que se vean (la evolución, el alcance, la
## velocidad; el rayo, el giro, la tormenta).
func _al_aplicar_mejora(jugador: Node, mejora: DatosMejora) -> void:
	if Red.actual.es_anfitrion() and por_id.find_key(jugador) != null:
		_apuntar(por_id.find_key(jugador), mejora)
		interfaz.ruleta.al_aplicar(por_id.find_key(jugador), mejora)
		Red.actual.enviar_suceso("mejora", [por_id.find_key(jugador), mejora.resource_path])


## En el anfitrión: ha caído el último del equipo. Aquí se para todo y se
## deshace con la animación de la derrota (cambio_personaje.gd); sin avisar,
## en los demás todo se quedaba congelado, con el caído aún de pie, hasta la
## pantalla final (Adam, 18/11).
func _al_caer(id: int) -> void:
	if por_id[id].get_node("CambioPersonaje")._equipo.todos_caidos():
		Red.actual.enviar_suceso("derrota", [id])


func _al_lanzar_ulti(direccion: Vector2, mini: Array, indice: int, id: int) -> void:
	Red.actual.enviar_suceso("ulti", [id, direccion, mini, indice])


## En los clientes. «mejoras» y «ruleta»: le toca elegir; se pausa aquí, como
## al subir de nivel, y el panel enseña las suyas (o la ruleta de su cofre).
func _al_recibir_suceso(suceso: String, datos: Array) -> void:
	var niveles: Node = get_parent().get_parent().get_node("SistemaNiveles")
	if suceso == "fin":
		# Como en la de un jugador, con el juego en pausa.
		get_tree().paused = true
		BusEventos.partida_terminada.emit(EstadoRed.fin_desde_red(datos[0]))
	elif suceso == "derrota" and por_id.has(datos[0]):
		# Como en el anfitrión: todo parado y el último se deshace.
		get_tree().paused = true
		por_id[datos[0]].get_node("CambioPersonaje").caer_el_ultimo()
	elif suceso == "ulti" and por_id.has(datos[0]):
		por_id[datos[0]].get_node("Ultis").mostrar_lanzada(datos[1], datos[2], datos[3])
	elif suceso == "mejora" and por_id.has(datos[0]):
		_apuntar(datos[0], load(datos[1]))
		interfaz.ruleta.al_aplicar(datos[0], load(datos[1]))
		niveles.aplicar_desde_red(por_id[datos[0]], load(datos[1]))
	elif suceso == "ruleta" and datos[0] != Red.actual.mi_id():
		var sectores: Array[DatosMejora] = []
		for ruta in datos[1]:
			sectores.append(load(ruta))
		_ver_ruleta(datos[0], sectores, load(datos[2]))
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
