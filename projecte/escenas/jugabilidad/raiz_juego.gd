extends Node2D

var _eliminados := 0
var _terminada := false

@onready var _salud_jugador: Salud = $Jugador/Salud
@onready var _sistema_niveles: Node = $SistemaNiveles
@onready var _director: Node = $DirectorOleadas


func _ready() -> void:
	var aparicion: Node2D = get_tree().get_first_node_in_group("aparicion_jugador")
	$Jugador.global_position = aparicion.global_position

	_salud_jugador.vida_cambiada.connect(_al_cambiar_vida)
	_salud_jugador.murio.connect(_terminar_partida.bind(false))
	# Al cumplirse el tiempo llega el jefe, y se gana al derrotarlo.
	_director.llega_el_jefe.connect($Jefe.aparecer)
	$Jefe.derrotado.connect(_terminar_partida.bind(true))
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.juego_pausado.connect(_al_pausar)


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	BusEventos.salud_jugador_cambiada.emit(actual, maxima)


func _al_morir_enemigo(_posicion: Vector2, _tipo: String) -> void:
	_eliminados += 1


func _al_pausar(en_pausa: bool) -> void:
	# El menú de pausa no puede quitar una pausa que no es suya: ni la del fin
	# de partida ni la de elegir mejora, que se levanta sola al elegir.
	if _terminada or _sistema_niveles.eligiendo():
		return

	get_tree().paused = en_pausa


func _terminar_partida(victoria: bool) -> void:
	# Morir y superar el tiempo en el mismo fotograma no debe dar dos finales.
	if _terminada:
		return

	_terminada = true
	get_tree().paused = true

	# Las claves de este diccionario son parte del contrato con la interfaz:
	# la pantalla de resultados y los récords de Alan las leen por nombre.
	BusEventos.partida_terminada.emit({
		"victoria": victoria,
		"tiempo": _director.tiempo(),
		"nivel": _sistema_niveles.nivel(),
		"eliminados": _eliminados,
	})
