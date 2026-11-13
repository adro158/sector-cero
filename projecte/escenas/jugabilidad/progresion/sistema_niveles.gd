extends Node

const OPCIONES_POR_NIVEL := 3
## Sectores de la ruleta del cofre.
const SECTORES_RULETA := 8

@export var pool_mejoras: DatosPoolMejoras
@export var experiencia_primer_nivel: int = 5
@export var incremento_por_nivel: float = 1.5

var _nivel := 1
var _experiencia := 0
var _objetivo: int

# Mejoras por elegir, en orden de llegada: "nivel" por cada nivel ganado y
# "cofre" por cada cofre recogido. Se ofrecen de una en una, y cada una con su
# panel: las tres tarjetas para un nivel y la ruleta para un cofre.
var _pendientes: Array[String] = []

# Veces que se ha elegido cada mejora: las evoluciones piden un mínimo.
var _veces := {}
# Las evoluciones son de un solo uso: una vez elegidas no vuelven a salir. Las
# de porcentaje se pueden repetir y se acumulan.
var _agotadas: Array[DatosMejora] = []
## El jugador de este ordenador: el que elige con el panel de mejoras. Con
## varios jugadores (multijugador, 13/11), los demás eligen por la red con
## elegir() (punto 5 del plan).
var _jugador: Node2D
## Para lo que es del equipo (las evoluciones): vale el de cualquier jugador.
var _cambio_personaje: Node
## Los jugadores que aún tienen que elegir la mejora en curso: la partida
## sigue en pausa hasta que han elegido todos.
var _por_elegir: Array = []
## Las opciones de cada jugador en la subida de nivel en curso: cada uno las
## suyas (para mandarlas por la red a los demás, punto 5).
var _opciones := {}
var _resistencia: Node
var _pool_gemas: Node


func _ready() -> void:
	_objetivo = experiencia_primer_nivel
	_jugador = get_tree().get_first_node_in_group("jugador")
	_cambio_personaje = _jugador.get_node("CambioPersonaje")
	_resistencia = get_tree().get_first_node_in_group("resistencia_malware")
	_pool_gemas = get_tree().get_first_node_in_group("pool_gemas")

	BusEventos.experiencia_ganada.connect(_al_ganar_experiencia)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)
	BusEventos.cofre_recogido.connect(_anadir_pendiente.bind("cofre"))
	# Diferido para que la interfaz, que está lista después, ya esté conectada.
	_avisar_experiencia.call_deferred()


func nivel() -> int:
	return _nivel


## Si hay mejoras pendientes de elegir. Mientras tanto el juego está pausado por
## este motivo y nadie más debe quitar la pausa.
func eligiendo() -> bool:
	return not _pendientes.is_empty()


func _al_ganar_experiencia(cantidad: int) -> void:
	_experiencia += cantidad

	# Un bucle y no un if: con muchos enemigos muriendo a la vez se puede subir
	# más de un nivel de golpe.
	while _experiencia >= _objetivo:
		_experiencia -= _objetivo
		_nivel += 1
		_objetivo = int(experiencia_primer_nivel * pow(incremento_por_nivel, _nivel - 1))
		_anadir_pendiente("nivel")

	_avisar_experiencia()


## Apunta una mejora por elegir. Si no había ninguna, se ofrece ya; si no,
## espera su turno y se ofrecerá al elegir la anterior.
func _anadir_pendiente(tipo: String) -> void:
	_pendientes.append(tipo)
	if _pendientes.size() == 1:
		_ofrecer_mejoras()


## Para el menú de desarrollador: la experiencia que falta para el siguiente
## nivel.
func experiencia_para_subir() -> int:
	return _objetivo - _experiencia


## Para el menú de desarrollador: aplica una mejora sin pasar por los paneles
## y avisa para que el HUD la apunte en su columna.
func regalar(mejora: DatosMejora) -> void:
	_aplicar(mejora, _jugador)
	BusEventos.mejora_regalada.emit(mejora)


## Para el menú de desarrollador: las tres opciones que saldrían ahora al
## subir de nivel.
func opciones_de_nivel() -> Array[DatosMejora]:
	return _sortear_opciones(_jugador)


## Las opciones de un jugador en la subida de nivel en curso (vacío si no
## tiene que elegir). Para mandárselas por la red (punto 5).
func opciones_de(jugador: Node) -> Array:
	return _opciones.get(jugador, [])


## Cuántas mejoras se han aplicado en la partida, contando las repetidas.
func mejoras_aplicadas() -> int:
	var total := 0
	for mejora in _veces:
		total += _veces[mejora]
	return total


## Para el menú de desarrollador: pone ese nivel con la barra de experiencia
## vacía, sin abrir paneles. Las mejoras se dan aparte, con regalar().
func poner_nivel(nuevo: int) -> void:
	_nivel = nuevo
	_experiencia = 0
	_objetivo = int(experiencia_primer_nivel * pow(incremento_por_nivel, _nivel - 1))
	_avisar_experiencia()


func _avisar_experiencia() -> void:
	BusEventos.experiencia_cambiada.emit(_experiencia, _objetivo, _nivel)


func _ofrecer_mejoras() -> void:
	# La pausa la pone la jugabilidad y no el panel de mejoras: así la interfaz
	# solo tiene que mostrar las opciones y avisar de la elegida.
	get_tree().paused = true
	if _pendientes[0] == "cofre":
		# El premio del cofre es uno: lo recibe el de este ordenador (en red,
		# el que lo recoge, punto 5).
		_por_elegir = [_jugador]
		var sectores := _sortear_sectores()
		BusEventos.ruleta_abierta.emit(sectores, sectores.pick_random())
	else:
		# Cada jugador elige la suya, de su propio sorteo.
		_por_elegir = get_tree().get_nodes_in_group("jugador")
		_opciones.clear()
		for jugador in _por_elegir:
			_opciones[jugador] = _sortear_opciones(jugador)
		if _jugador in _opciones:
			BusEventos.jugador_subio_nivel.emit(_opciones[_jugador])


func _sortear_opciones(jugador: Node) -> Array[DatosMejora]:
	var opciones: Array[DatosMejora] = []

	# Una evolución que ya se puede elegir sale siempre, y la primera: es el
	# premio por haber repetido su mejora. Si hay varias, de una en una. Con
	# varios jugadores, solo a uno (_para_quien): si no, la elegirían dos.
	var evolucion := _evolucion_disponible()
	if evolucion != null and _para_quien(evolucion) == jugador:
		opciones.append(evolucion)

	var normales := pool_mejoras.mejoras.duplicate()
	normales.shuffle()
	for mejora in normales:
		if opciones.size() < OPCIONES_POR_NIVEL:
			opciones.append(mejora)
	return opciones


## Los 8 sectores de la ruleta: las mejoras normales, repetidas si hay menos
## de 8. Si hay una evolución disponible, ocupa el lugar de una de ellas.
func _sortear_sectores() -> Array[DatosMejora]:
	var sectores: Array[DatosMejora] = []
	while sectores.size() < SECTORES_RULETA:
		sectores.append(pool_mejoras.mejoras[sectores.size() % pool_mejoras.mejoras.size()])
	var evolucion := _evolucion_disponible()
	if evolucion != null:
		sectores[randi() % SECTORES_RULETA] = evolucion
	return sectores


## La primera evolución que ya se puede elegir, o null si no hay ninguna. La
## de un personaje caído no sale: si se le revive (F1), vuelve a salir sola.
func _evolucion_disponible() -> DatosMejora:
	for evolucion in pool_mejoras.evoluciones:
		if evolucion not in _agotadas and _veces.get(evolucion.requisito, 0) >= evolucion.nivel_requisito \
				and _cambio_personaje.puede_evolucionar(evolucion.arma_base):
			return evolucion
	return null


## A quién se le ofrece una evolución: al jugador que lleva esa herramienta
## o, si está en el banquillo, al primero. Con uno solo, siempre a él.
func _para_quien(evolucion: DatosMejora) -> Node:
	var jugadores := get_tree().get_nodes_in_group("jugador")
	for jugador in jugadores:
		if jugador.get_node("GestorArmas").armas[0] == evolucion.arma_base:
			return jugador
	return jugadores[0] if not jugadores.is_empty() else null


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	elegir(_jugador, mejora)


## Aplica la mejora que ha elegido un jugador: el de este ordenador desde el
## panel; los demás, por la red (punto 5). Cuando han elegido todos, se ofrece
## la siguiente pendiente o se quita la pausa.
func elegir(jugador: Node, mejora: DatosMejora) -> void:
	# Si ese jugador no tiene nada que elegir, la elección llega repetida (por
	# ejemplo, desde dos sitios a la vez) y no debe aplicarse otra vez.
	if _pendientes.is_empty() or jugador not in _por_elegir:
		return

	_aplicar(mejora, jugador)
	_por_elegir.erase(jugador)
	# Los que se han quedado sin personaje mientras tanto ya no eligen.
	_por_elegir = _por_elegir.filter(func(otro): return otro.is_in_group("jugador"))
	if not _por_elegir.is_empty():
		return
	_pendientes.pop_front()

	if not _pendientes.is_empty():
		_ofrecer_mejoras()
	else:
		get_tree().paused = false


## Las del arma, la velocidad y la espera son del jugador que la elige; la
## vida máxima, las evoluciones, la adaptación y el imán, de todo el equipo.
func _aplicar(mejora: DatosMejora, jugador: Node) -> void:
	_veces[mejora] = _veces.get(mejora, 0) + 1
	var gestor_armas: Node = jugador.get_node("GestorArmas")
	var cambio_personaje: Node = jugador.get_node("CambioPersonaje")

	match mejora.efecto:
		DatosMejora.Efecto.DANO_ARMAS:
			gestor_armas.multiplicador_dano += mejora.valor
		DatosMejora.Efecto.CADENCIA_ARMAS:
			# Se multiplica en lugar de restar: restando, tras unas cuantas
			# mejoras el tiempo entre disparos llegaría a cero o a negativo y el
			# arma dispararía en cada fotograma. Así cada mejora quita un
			# porcentaje de lo que queda y nunca se llega a cero.
			gestor_armas.multiplicador_cadencia *= 1.0 - mejora.valor
		DatosMejora.Efecto.ALCANCE_ARMAS:
			gestor_armas.multiplicador_alcance += mejora.valor
		DatosMejora.Efecto.VELOCIDAD_JUGADOR:
			jugador.velocidad_maxima *= 1.0 + mejora.valor
		DatosMejora.Efecto.VIDA_MAXIMA:
			cambio_personaje.aumentar_vida_maxima(mejora.valor)
		DatosMejora.Efecto.EVOLUCIONAR_ARMA:
			cambio_personaje.evolucionar(mejora.arma_base, mejora.arma)
			_agotadas.append(mejora)
		DatosMejora.Efecto.ADAPTACION_MALWARE:
			# Lo que gana el malware en cada análisis, multiplicado como la
			# cadencia: cada vez que se elige queda un 30 % menos de lo que había.
			_resistencia.aumento *= 1.0 - mejora.valor
		DatosMejora.Efecto.ESPERA_CAMBIO:
			cambio_personaje.reducir_espera(mejora.valor)
		DatosMejora.Efecto.RADIO_IMAN:
			_pool_gemas.radio_iman *= 1.0 + mejora.valor
