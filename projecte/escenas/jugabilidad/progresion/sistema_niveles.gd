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
var _jugador: Node2D
var _gestor_armas: Node
var _cambio_personaje: Node
var _resistencia: Node
var _pool_gemas: Node


func _ready() -> void:
	_objetivo = experiencia_primer_nivel
	_jugador = get_tree().get_first_node_in_group("jugador")
	_gestor_armas = _jugador.get_node("GestorArmas")
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


func _avisar_experiencia() -> void:
	BusEventos.experiencia_cambiada.emit(_experiencia, _objetivo, _nivel)


func _ofrecer_mejoras() -> void:
	# La pausa la pone la jugabilidad y no el panel de mejoras: así la interfaz
	# solo tiene que mostrar las opciones y avisar de la elegida.
	get_tree().paused = true
	if _pendientes[0] == "cofre":
		var sectores := _sortear_sectores()
		BusEventos.ruleta_abierta.emit(sectores, sectores.pick_random())
	else:
		BusEventos.jugador_subio_nivel.emit(_sortear_opciones())


func _sortear_opciones() -> Array[DatosMejora]:
	var opciones: Array[DatosMejora] = []

	# Una evolución que ya se puede elegir sale siempre, y la primera: es el
	# premio por haber repetido su mejora. Si hay varias, de una en una.
	var evolucion := _evolucion_disponible()
	if evolucion != null:
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


## La primera evolución que ya se puede elegir, o null si no hay ninguna.
func _evolucion_disponible() -> DatosMejora:
	for evolucion in pool_mejoras.evoluciones:
		if evolucion not in _agotadas and _veces.get(evolucion.requisito, 0) >= evolucion.nivel_requisito:
			return evolucion
	return null


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	# Si no hay ninguna mejora esperando, la elección llega repetida (por ejemplo,
	# desde dos sitios a la vez) y no debe aplicarse otra vez.
	if _pendientes.is_empty():
		return

	_aplicar(mejora)
	_pendientes.pop_front()

	if not _pendientes.is_empty():
		_ofrecer_mejoras()
	else:
		get_tree().paused = false


func _aplicar(mejora: DatosMejora) -> void:
	_veces[mejora] = _veces.get(mejora, 0) + 1

	match mejora.efecto:
		DatosMejora.Efecto.DANO_ARMAS:
			_gestor_armas.multiplicador_dano += mejora.valor
		DatosMejora.Efecto.CADENCIA_ARMAS:
			# Se multiplica en lugar de restar: restando, tras unas cuantas
			# mejoras el tiempo entre disparos llegaría a cero o a negativo y el
			# arma dispararía en cada fotograma. Así cada mejora quita un
			# porcentaje de lo que queda y nunca se llega a cero.
			_gestor_armas.multiplicador_cadencia *= 1.0 - mejora.valor
		DatosMejora.Efecto.ALCANCE_ARMAS:
			_gestor_armas.multiplicador_alcance += mejora.valor
		DatosMejora.Efecto.VELOCIDAD_JUGADOR:
			_jugador.velocidad_maxima *= 1.0 + mejora.valor
		DatosMejora.Efecto.VIDA_MAXIMA:
			_cambio_personaje.aumentar_vida_maxima(mejora.valor)
		DatosMejora.Efecto.EVOLUCIONAR_ARMA:
			_cambio_personaje.evolucionar(mejora.arma_base, mejora.arma)
			_agotadas.append(mejora)
		DatosMejora.Efecto.ADAPTACION_MALWARE:
			# Lo que gana el malware en cada análisis, multiplicado como la
			# cadencia: cada vez que se elige queda un 30 % menos de lo que había.
			_resistencia.aumento *= 1.0 - mejora.valor
		DatosMejora.Efecto.ESPERA_CAMBIO:
			_cambio_personaje.reducir_espera(mejora.valor)
		DatosMejora.Efecto.RADIO_IMAN:
			_pool_gemas.radio_iman *= 1.0 + mejora.valor
