extends Node2D

var _tiempo := 0.0

@onready var _salud_jugador: Salud = $Jugador/Salud


func _ready() -> void:
	var aparicion: Node2D = get_tree().get_first_node_in_group("aparicion_jugador")
	$Jugador.global_position = aparicion.global_position

	_salud_jugador.vida_cambiada.connect(_al_cambiar_vida)
	_salud_jugador.murio.connect(_al_morir_jugador)


func _process(delta: float) -> void:
	_tiempo += delta


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	BusEventos.salud_jugador_cambiada.emit(actual, maxima)


func _al_morir_jugador() -> void:
	BusEventos.partida_terminada.emit({"tiempo": _tiempo})
	get_tree().paused = true
