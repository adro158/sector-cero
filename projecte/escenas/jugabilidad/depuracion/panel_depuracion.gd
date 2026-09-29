extends Label

## Panel de desarrollo, no es la interfaz del juego. Se alimenta únicamente de
## las señales del BusEventos, sin tocar ningún nodo: si aquí se puede pintar
## todo, está demostrado que la interfaz de Alan tiene la información que
## necesita. Se muestra y se oculta con F3.
##
## Mientras la interfaz de Alan no esté terminada, este panel hace de sustituto
## provisional: se elige mejora con las teclas 1, 2 y 3 y se pausa con la acción
## pausar. Emite las mismas señales que emitirá su interfaz, así que la
## jugabilidad no distingue de dónde llegan. Cuando su menú de pausa exista,
## hay que quitar la pausa de aquí: si no, cada pulsación se aplicaría dos veces.

var _vida := 0.0
var _vida_maxima := 0.0
var _experiencia := 0
var _nivel := 1
var _muertos := 0
var _tiempo := 0.0
var _ultimo_golpe := 0.0
var _terminada := false
var _opciones: Array = []


func _ready() -> void:
	# Tiene que seguir atendiendo al teclado con el juego pausado, que es
	# precisamente cuando se eligen las mejoras.
	process_mode = Node.PROCESS_MODE_ALWAYS

	BusEventos.salud_jugador_cambiada.connect(_al_cambiar_vida)
	BusEventos.experiencia_ganada.connect(_al_ganar_experiencia)
	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.partida_terminada.connect(_al_terminar)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausar") and not _terminada:
		BusEventos.juego_pausado.emit(not get_tree().paused)
		return

	if not evento is InputEventKey or not evento.pressed or evento.echo:
		return

	if evento.keycode == KEY_F3:
		visible = not visible
	elif evento.keycode in [KEY_1, KEY_2, KEY_3]:
		_elegir(evento.keycode - KEY_1)


func _elegir(indice: int) -> void:
	if indice >= _opciones.size():
		return

	# Se vacía antes de emitir: si quedan niveles pendientes, la respuesta a
	# esta señal trae las opciones del siguiente en el acto, y vaciar después
	# las borraría.
	var mejora: DatosMejora = _opciones[indice]
	_opciones = []
	BusEventos.mejora_seleccionada.emit(mejora)


func _process(delta: float) -> void:
	if not _terminada and not get_tree().paused:
		_tiempo += delta

	var lineas := [
		"F3 oculta este panel",
		"tiempo      %d:%02d" % [int(_tiempo) / 60, int(_tiempo) % 60],
		"vida        %.0f / %.0f" % [_vida, _vida_maxima],
		"nivel       %d" % _nivel,
		"experiencia %d" % _experiencia,
		"eliminados  %d" % _muertos,
		"en pantalla %d" % _enemigos_vivos(),
		"fps         %d" % Engine.get_frames_per_second(),
		"ultimo golpe recibido  %.0f" % _ultimo_golpe,
	]

	if not _opciones.is_empty():
		lineas.append("")
		lineas.append("SUBIDA DE NIVEL: elige con 1, 2 o 3")
		for i in _opciones.size():
			lineas.append("%d  %s" % [i + 1, _opciones[i].nombre])
	elif get_tree().paused and not _terminada:
		lineas.append("")
		lineas.append("PAUSA: Esc o P para seguir")

	text = "\n".join(lineas)


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


func _al_subir_nivel(opciones: Array) -> void:
	_nivel += 1
	_opciones = opciones


func _al_morir_enemigo(_posicion: Vector2, _tipo: String) -> void:
	_muertos += 1


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
