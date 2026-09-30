extends Node

const OPCIONES_POR_NIVEL := 3

@export var pool_mejoras: DatosPoolMejoras
@export var experiencia_primer_nivel: int = 5
@export var incremento_por_nivel: float = 1.35

var _nivel := 1
var _experiencia := 0
var _objetivo: int

# Niveles ganados cuyas mejoras aún no se han elegido. Se ofrecen de uno en uno:
# el panel de mejoras solo puede mostrar tres tarjetas a la vez.
var _niveles_pendientes := 0

# Las mejoras de un solo uso, como desbloquear un arma, dejan de sortearse una
# vez elegidas. Las de porcentaje se pueden repetir y se acumulan.
var _agotadas: Array[DatosMejora] = []
var _jugador: Node2D
var _gestor_armas: Node
var _salud: Salud


func _ready() -> void:
	_objetivo = experiencia_primer_nivel
	_jugador = get_tree().get_first_node_in_group("jugador")
	_gestor_armas = _jugador.get_node("GestorArmas")
	_salud = _jugador.get_node("Salud")

	BusEventos.experiencia_ganada.connect(_al_ganar_experiencia)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)
	# Diferido para que la interfaz, que está lista después, ya esté conectada.
	_avisar_experiencia.call_deferred()


func nivel() -> int:
	return _nivel


## Si hay mejoras pendientes de elegir. Mientras tanto el juego está pausado por
## este motivo y nadie más debe quitar la pausa.
func eligiendo() -> bool:
	return _niveles_pendientes > 0


func _al_ganar_experiencia(cantidad: int) -> void:
	_experiencia += cantidad
	var ya_estaba_eligiendo := _niveles_pendientes > 0

	# Un bucle y no un if: con muchos enemigos muriendo a la vez se puede subir
	# más de un nivel de golpe.
	while _experiencia >= _objetivo:
		_experiencia -= _objetivo
		_nivel += 1
		_objetivo = int(experiencia_primer_nivel * pow(incremento_por_nivel, _nivel - 1))
		_niveles_pendientes += 1

	_avisar_experiencia()
	if _niveles_pendientes > 0 and not ya_estaba_eligiendo:
		_ofrecer_mejoras()


func _avisar_experiencia() -> void:
	BusEventos.experiencia_cambiada.emit(_experiencia, _objetivo, _nivel)


func _ofrecer_mejoras() -> void:
	# La pausa la pone la jugabilidad y no el panel de mejoras: así la interfaz
	# solo tiene que mostrar las opciones y avisar de la elegida.
	get_tree().paused = true
	BusEventos.jugador_subio_nivel.emit(_sortear_opciones())


func _sortear_opciones() -> Array[DatosMejora]:
	var disponibles: Array[DatosMejora] = []

	for mejora in pool_mejoras.mejoras:
		if mejora not in _agotadas:
			disponibles.append(mejora)

	disponibles.shuffle()
	return disponibles.slice(0, mini(OPCIONES_POR_NIVEL, disponibles.size()))


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	# Si no hay ningún nivel esperando, la elección llega repetida (por ejemplo,
	# desde dos sitios a la vez) y no debe aplicarse otra vez.
	if _niveles_pendientes == 0:
		return

	_aplicar(mejora)
	_niveles_pendientes -= 1

	if _niveles_pendientes > 0:
		_ofrecer_mejoras()
	else:
		get_tree().paused = false


func _aplicar(mejora: DatosMejora) -> void:
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
			_salud.aumentar_vida_maxima(mejora.valor)
		DatosMejora.Efecto.NUEVA_ARMA:
			_gestor_armas.anadir_arma(mejora.arma)
			_agotadas.append(mejora)
