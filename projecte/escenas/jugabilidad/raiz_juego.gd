extends Node2D

var _tiempo := 0.0
var _terminada := false

@onready var _salud_jugador: Salud = $Jugador/Salud
@onready var _sistema_niveles: Node = $SistemaNiveles


func _ready() -> void:
	var aparicion: Node2D = get_tree().get_first_node_in_group("aparicion_jugador")
	$Jugador.global_position = aparicion.global_position

	_salud_jugador.vida_cambiada.connect(_al_cambiar_vida)
	_salud_jugador.murio.connect(_al_morir_jugador)
	BusEventos.juego_pausado.connect(_al_pausar)


func _process(delta: float) -> void:
	_tiempo += delta


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	BusEventos.salud_jugador_cambiada.emit(actual, maxima)


func _al_pausar(en_pausa: bool) -> void:
	# El menú de pausa no puede quitar una pausa que no es suya: ni la del fin
	# de partida ni la de elegir mejora, que se levanta sola al elegir.
	if _terminada or _sistema_niveles.eligiendo():
		return

	get_tree().paused = en_pausa


func _al_morir_jugador() -> void:
	_terminada = true
	BusEventos.partida_terminada.emit({"tiempo": _tiempo})
	get_tree().paused = true
