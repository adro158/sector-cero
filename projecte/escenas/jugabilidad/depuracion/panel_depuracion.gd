extends Label

## Panel de desarrollo, no es la interfaz del juego. Se alimenta únicamente de
## las señales del BusEventos, sin tocar ningún nodo: si aquí se puede pintar
## todo, está demostrado que la interfaz de Alan tiene la información que
## necesita. Se muestra y se oculta con F3.

var _vida := 0.0
var _vida_maxima := 0.0
var _experiencia := 0
var _nivel := 1
var _muertos := 0
var _tiempo := 0.0
var _ultimo_golpe := 0.0
var _terminada := false


func _ready() -> void:
	BusEventos.salud_jugador_cambiada.connect(_al_cambiar_vida)
	BusEventos.experiencia_ganada.connect(_al_ganar_experiencia)
	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.partida_terminada.connect(_al_terminar)


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and evento.keycode == KEY_F3:
		visible = not visible


func _process(delta: float) -> void:
	if not _terminada:
		_tiempo += delta

	text = "\n".join([
		"F3 oculta este panel",
		"tiempo      %d:%02d" % [int(_tiempo) / 60, int(_tiempo) % 60],
		"vida        %.0f / %.0f" % [_vida, _vida_maxima],
		"nivel       %d" % _nivel,
		"experiencia %d" % _experiencia,
		"eliminados  %d" % _muertos,
		"en pantalla %d" % _enemigos_vivos(),
		"fps         %d" % Engine.get_frames_per_second(),
		"ultimo golpe recibido  %.0f" % _ultimo_golpe,
	])


func _enemigos_vivos() -> int:
	var total := 0

	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		total += gestor.vivos()

	return total


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	if _vida_maxima > 0.0 and actual < _vida:
		_ultimo_golpe = _vida - actual

	_vida = actual
	_vida_maxima = maxima


func _al_ganar_experiencia(cantidad: int) -> void:
	_experiencia += cantidad


func _al_subir_nivel(_opciones: Array) -> void:
	_nivel += 1


func _al_morir_enemigo(_posicion: Vector2, _tipo: String) -> void:
	_muertos += 1


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
