extends SceneTree

## Herramienta de testeo, no forma parte del juego: juega partidas enteras sin
## nadie delante para medir el balance. Un bot huye de los enemigos cercanos, se
## aparta de los bordes, da vueltas cuando no hay peligro y elige mejoras al
## azar. Cada minuto de partida anota vida, nivel, enemigos, armas y
## resistencias, y al final resume victorias y duración media.
##
## Uso, desde la carpeta projecte/ (--fixed-fps 60 hace que cada fotograma
## avance 1/60 s sin esperar al reloj real, así que va mucho más rápido):
##
##   Godot --headless --fixed-fps 60 --path . --script res://herramientas/simular_partidas.gd -- partidas=5
##
## Lee campos internos de los nodos (los que empiezan por _) porque necesita
## ver lo mismo que vería un jugador; en el código del juego eso no se hace.

const RADIO_PELIGRO := 260.0

var _partidas := 3
var _partida := 0
var _victorias := 0
var _duraciones: Array[float] = []
var _bus: Node
var _juego: Node
var _raiz: Node
var _jugador: Node2D
var _gestores: Array = []
var _siguiente_informe := 60.0
var _terminada := false


func _initialize() -> void:
	for argumento in OS.get_cmdline_user_args():
		if argumento.begins_with("partidas="):
			_partidas = int(argumento.split("=")[1])

	_bus = root.get_node("BusEventos")
	# Las partidas simuladas no son del jugador: no deben entrar en sus récords.
	var guardado := root.get_node("GestorGuardado")
	_bus.partida_terminada.disconnect(guardado._al_terminar_partida)
	_bus.jugador_subio_nivel.connect(_al_subir_nivel)
	_bus.partida_terminada.connect(_al_terminar)
	physics_frame.connect(_paso)
	_empezar_partida()


func _empezar_partida() -> void:
	_partida += 1
	# Semilla fija por partida: la misma partida se repite igual tras un cambio,
	# así se puede comparar el antes y el después.
	seed(1000 + _partida)
	paused = false
	_terminada = false
	_siguiente_informe = 60.0
	_gestores = []
	_juego = load("res://escenas/juego.tscn").instantiate()
	root.add_child(_juego)
	_raiz = _juego.get_node("RaizJuego")
	_jugador = _raiz.get_node("Jugador")
	print("\n=== PARTIDA %d ===" % _partida)


func _al_subir_nivel(opciones: Array) -> void:
	_elegir.call_deferred(opciones.pick_random())


func _elegir(mejora: DatosMejora) -> void:
	_bus.mejora_seleccionada.emit(mejora)


func _paso() -> void:
	# Los gestores se buscan aquí y no al crear la partida: en ese momento
	# todavía no están registrados en su grupo.
	if _gestores.is_empty():
		_gestores = get_nodes_in_group("gestor_enemigos")
	if _terminada or paused:
		return

	if _raiz.get_node("DirectorOleadas").tiempo() >= _siguiente_informe:
		_informe("t=%3ds" % int(_siguiente_informe))
		_siguiente_informe += 60.0

	_mover_bot()


func _mover_bot() -> void:
	var posicion := _jugador.global_position
	var huida := Vector2.ZERO

	# Cada enemigo cercano empuja en dirección contraria, más cuanto más cerca.
	for gestor in _gestores:
		for i in gestor.vivos():
			var diferencia: Vector2 = posicion - gestor._posiciones[i]
			var distancia := diferencia.length()
			if distancia > 0.0 and distancia < RADIO_PELIGRO:
				huida += diferencia / (distancia * distancia)

	# Del jefe se aparta con más fuerza, pero solo cuando se acerca: a media
	# distancia las armas de alcance le siguen dando.
	var jefe: Node2D = _raiz.get_node("Jefe")
	if jefe._activo:
		var diferencia := posicion - jefe.global_position
		var distancia := diferencia.length()
		if distancia > 0.0 and distancia < 170.0:
			huida += diferencia / (distancia * distancia) * 6.0

	# El mapa no tiene bordes: sin peligro cerca, da vueltas alrededor del
	# origen para no alejarse sin fin.
	var direccion := huida.normalized()
	if huida == Vector2.ZERO:
		direccion = Vector2(-posicion.y, posicion.x).normalized() * 0.6
		if posicion.length() < 50.0:
			direccion = Vector2.RIGHT

	for accion in ["mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo"]:
		Input.action_release(accion)
	if direccion.x > 0.05:
		Input.action_press("mover_derecha", direccion.x)
	elif direccion.x < -0.05:
		Input.action_press("mover_izquierda", -direccion.x)
	if direccion.y > 0.05:
		Input.action_press("mover_abajo", direccion.y)
	elif direccion.y < -0.05:
		Input.action_press("mover_arriba", -direccion.y)


func _informe(etiqueta: String) -> void:
	var vivos := 0
	for gestor in _gestores:
		vivos += gestor.vivos()

	var armas := []
	for arma in _jugador.get_node("GestorArmas").armas:
		armas.append(arma.nombre)

	var resistencias := []
	var tabla: Dictionary = _raiz.get_node("ResistenciaMalware").resistencias()
	for arma in tabla:
		resistencias.append("%s %d%%" % [arma.nombre, roundi(tabla[arma] * 100.0)])

	var salud = _jugador.get_node("Salud")
	print("%s vida=%3.0f/%3.0f nivel=%2d en_pantalla=%3d armas=%s resiste=%s" % [
		etiqueta, salud._vida, salud.vida_maxima, _raiz.get_node("SistemaNiveles").nivel(),
		vivos, armas, resistencias])


func _al_terminar(estadisticas: Dictionary) -> void:
	_terminada = true
	_informe("FINAL")
	if estadisticas.victoria:
		_victorias += 1
	_duraciones.append(estadisticas.tiempo)
	print("RESULTADO %s tiempo=%.0fs nivel=%d eliminados=%d" % [
		"VICTORIA" if estadisticas.victoria else "DERROTA", estadisticas.tiempo,
		estadisticas.nivel, estadisticas.eliminados])
	_siguiente.call_deferred()


func _siguiente() -> void:
	_juego.queue_free()
	await process_frame

	if _partida < _partidas:
		_empezar_partida()
		return

	var suma := 0.0
	for duracion in _duraciones:
		suma += duracion
	print("\nRESUMEN victorias=%d/%d duracion_media=%.0fs" % [_victorias, _partidas, suma / _partidas])
	quit()
