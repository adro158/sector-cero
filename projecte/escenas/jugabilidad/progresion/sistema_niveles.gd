extends Node

const OPCIONES_POR_NIVEL := 3

@export var pool_mejoras: DatosPoolMejoras
@export var experiencia_primer_nivel: int = 5
@export var incremento_por_nivel: float = 1.5

var _nivel := 1
var _experiencia := 0
var _objetivo: int

# Mejoras por elegir: una por cada nivel ganado y una por cada élite eliminado.
# Se ofrecen de una en una: el panel solo puede mostrar tres tarjetas a la vez.
var _mejoras_pendientes := 0

# Veces que se ha elegido cada mejora: las evoluciones piden un mínimo.
var _veces := {}
# Las evoluciones son de un solo uso: una vez elegidas no vuelven a salir. Las
# de porcentaje se pueden repetir y se acumulan.
var _agotadas: Array[DatosMejora] = []
var _jugador: Node2D
var _gestor_armas: Node
var _cambio_personaje: Node
var _salud: Salud
var _resistencia: Node
var _pool_gemas: Node


func _ready() -> void:
	_objetivo = experiencia_primer_nivel
	_jugador = get_tree().get_first_node_in_group("jugador")
	_gestor_armas = _jugador.get_node("GestorArmas")
	_cambio_personaje = _jugador.get_node("CambioPersonaje")
	_salud = _jugador.get_node("Salud")
	_resistencia = get_tree().get_first_node_in_group("resistencia_malware")
	_pool_gemas = get_tree().get_first_node_in_group("pool_gemas")

	BusEventos.experiencia_ganada.connect(_al_ganar_experiencia)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	# Diferido para que la interfaz, que está lista después, ya esté conectada.
	_avisar_experiencia.call_deferred()


func nivel() -> int:
	return _nivel


## Si hay mejoras pendientes de elegir. Mientras tanto el juego está pausado por
## este motivo y nadie más debe quitar la pausa.
func eligiendo() -> bool:
	return _mejoras_pendientes > 0


func _al_ganar_experiencia(cantidad: int) -> void:
	_experiencia += cantidad
	var ya_estaba_eligiendo := _mejoras_pendientes > 0

	# Un bucle y no un if: con muchos enemigos muriendo a la vez se puede subir
	# más de un nivel de golpe.
	while _experiencia >= _objetivo:
		_experiencia -= _objetivo
		_nivel += 1
		_objetivo = int(experiencia_primer_nivel * pow(incremento_por_nivel, _nivel - 1))
		_mejoras_pendientes += 1

	_avisar_experiencia()
	if _mejoras_pendientes > 0 and not ya_estaba_eligiendo:
		_ofrecer_mejoras()


## Matar un élite regala una mejora sin gastar experiencia: va a la misma cola
## que las de subir de nivel, pero sin subir de nivel.
func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo != "elite":
		return
	_mejoras_pendientes += 1
	if _mejoras_pendientes == 1:
		_ofrecer_mejoras()


func _avisar_experiencia() -> void:
	BusEventos.experiencia_cambiada.emit(_experiencia, _objetivo, _nivel)


func _ofrecer_mejoras() -> void:
	# La pausa la pone la jugabilidad y no el panel de mejoras: así la interfaz
	# solo tiene que mostrar las opciones y avisar de la elegida.
	get_tree().paused = true
	BusEventos.jugador_subio_nivel.emit(_sortear_opciones())


func _sortear_opciones() -> Array[DatosMejora]:
	var opciones: Array[DatosMejora] = []

	# Una evolución que ya se puede elegir sale siempre, y la primera: es el
	# premio por haber repetido su mejora. Si hay varias, de una en una.
	for evolucion in pool_mejoras.evoluciones:
		if evolucion not in _agotadas and _veces.get(evolucion.requisito, 0) >= evolucion.nivel_requisito:
			opciones.append(evolucion)
			break

	var normales := pool_mejoras.mejoras.duplicate()
	normales.shuffle()
	for mejora in normales:
		if opciones.size() < OPCIONES_POR_NIVEL:
			opciones.append(mejora)
	return opciones


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	# Si no hay ninguna mejora esperando, la elección llega repetida (por ejemplo,
	# desde dos sitios a la vez) y no debe aplicarse otra vez.
	if _mejoras_pendientes == 0:
		return

	_aplicar(mejora)
	_mejoras_pendientes -= 1

	if _mejoras_pendientes > 0:
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
			_salud.aumentar_vida_maxima(mejora.valor)
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
