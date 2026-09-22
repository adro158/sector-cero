extends Node

const OPCIONES_POR_NIVEL := 3

@export var pool_mejoras: DatosPoolMejoras
@export var experiencia_primer_nivel: int = 5
@export var incremento_por_nivel: float = 1.35

var _nivel := 1
var _experiencia := 0
var _objetivo: int
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


func _al_ganar_experiencia(cantidad: int) -> void:
	_experiencia += cantidad

	# Un bucle y no un if: con muchos enemigos muriendo a la vez se puede subir
	# más de un nivel de golpe.
	while _experiencia >= _objetivo:
		_experiencia -= _objetivo
		_nivel += 1
		_objetivo = int(experiencia_primer_nivel * pow(incremento_por_nivel, _nivel - 1))
		BusEventos.jugador_subio_nivel.emit(_sortear_opciones())


func _sortear_opciones() -> Array[DatosMejora]:
	var disponibles := pool_mejoras.mejoras.duplicate()
	disponibles.shuffle()
	return disponibles.slice(0, mini(OPCIONES_POR_NIVEL, disponibles.size()))


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	match mejora.efecto:
		DatosMejora.Efecto.DANO_ARMAS:
			_gestor_armas.multiplicador_dano += mejora.valor
		DatosMejora.Efecto.CADENCIA_ARMAS:
			_gestor_armas.multiplicador_cadencia -= mejora.valor
		DatosMejora.Efecto.ALCANCE_ARMAS:
			_gestor_armas.multiplicador_alcance += mejora.valor
		DatosMejora.Efecto.VELOCIDAD_JUGADOR:
			_jugador.velocidad_maxima *= 1.0 + mejora.valor
		DatosMejora.Efecto.VIDA_MAXIMA:
			_salud.aumentar_vida_maxima(mejora.valor)
