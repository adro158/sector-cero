extends SceneTree

## Herramienta de testeo, no forma parte del juego: juega partidas enteras sin
## nadie delante para medir el balance. Un bot huye de los enemigos cercanos,
## de los élites y del jefe, da vueltas cuando no hay peligro, elige mejoras al
## azar (o la evolución, si sale) y cambia de personaje cuando el malware se ha
## hecho resistente a su herramienta. Cada minuto de partida anota vida, nivel,
## enemigos (en total y por tipo), herramienta y resistencias, y al final
## resume victorias, duración media, cambios de personaje y eliminados por tipo.
##
## Uso, desde la carpeta projecte/ (--fixed-fps 60 hace que cada fotograma
## avance 1/60 s sin esperar al reloj real, así que va mucho más rápido):
##
##   Godot --headless --fixed-fps 60 --path . --script res://herramientas/simular_partidas.gd -- partidas=5
##
## Lee campos internos de los nodos (los que empiezan por _) porque necesita
## ver lo mismo que vería un jugador; en el código del juego eso no se hace.

## Solo huye de los enemigos más cerca que esto: un poco más que el alcance del
## Firewall, para dejar que entren en su anillo. Con el mapa sin bordes, un bot
## que huye de todo lo que ve no mata nada y no sube de nivel.
const RADIO_PELIGRO := 120.0
## Lo mismo con el jefe y los élites: lo justo para no tocarlos y seguir dentro
## del alcance del Firewall, que llega a 90 más el radio del enemigo.
const RADIO_PELIGRO_GRANDES := 100.0
## Resistencia de la herramienta activa a partir de la cual el bot cambia.
const RESISTENCIA_PARA_CAMBIAR := 0.3
## Si el jefe sigue vivo tanto tiempo después de aparecer, la partida se da por
## perdida. Sin bordes, un bot podría huir de él para siempre.
const TIEMPO_MAXIMO_JEFE := 240.0

var _partidas := 3
var _partida := 0
var _victorias := 0
var _duraciones: Array[float] = []
var _cambios := 0
var _evoluciones := 0
## Eliminados de cada tipo, sumando todas las partidas.
var _eliminados_por_tipo := {}
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
	# Diferido porque los autoloads aún no han hecho su _ready ni se han
	# conectado al bus.
	var guardado := root.get_node("GestorGuardado")
	_bus.partida_terminada.disconnect.call_deferred(guardado._al_terminar_partida)
	_bus.jugador_subio_nivel.connect(_al_subir_nivel)
	_bus.arma_evolucionada.connect(func(_arma): _evoluciones += 1)
	_bus.enemigo_muerto.connect(func(_posicion, tipo): _eliminados_por_tipo[tipo] = _eliminados_por_tipo.get(tipo, 0) + 1)
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
	# Si sale una evolución, siempre es la primera opción y siempre la coge.
	var elegida: DatosMejora = opciones.pick_random()
	if opciones[0].efecto == DatosMejora.Efecto.EVOLUCIONAR_ARMA:
		elegida = opciones[0]
	_elegir.call_deferred(elegida)


func _elegir(mejora: DatosMejora) -> void:
	_bus.mejora_seleccionada.emit(mejora)


func _paso() -> void:
	# Los gestores se buscan aquí y no al crear la partida: en ese momento
	# todavía no están registrados en su grupo.
	if _gestores.is_empty():
		_gestores = get_nodes_in_group("gestor_enemigos")
	if _terminada or paused:
		return

	var director := _raiz.get_node("DirectorOleadas")
	if director.tiempo() >= _siguiente_informe:
		_informe("t=%3ds" % int(_siguiente_informe))
		_siguiente_informe += 60.0
	if director.tiempo() > director.config.duracion_partida + TIEMPO_MAXIMO_JEFE:
		print("TIEMPO AGOTADO contra el jefe")
		_raiz._terminar_partida(false)
		return

	_cambiar_si_resiste()
	_mover_bot()


func _cambiar_si_resiste() -> void:
	var arma: DatosArma = _jugador.get_node("GestorArmas").armas[0]
	if _raiz.get_node("ResistenciaMalware").resistencia(arma) >= RESISTENCIA_PARA_CAMBIAR:
		if _jugador.get_node("CambioPersonaje").cambiar():
			_cambios += 1


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

	# De los élites y del jefe se aparta con más fuerza, pero solo cuando se
	# acercan: a media distancia las armas de alcance les siguen dando.
	var grandes: Array = get_nodes_in_group("elites")
	grandes.append(_raiz.get_node("Jefe"))
	for enemigo in grandes:
		var diferencia: Vector2 = posicion - enemigo.global_position
		var distancia := diferencia.length()
		# Un élite explosivo que ya ha muerto avisa con su anillo: sale de él.
		var explotando: bool = "_cuenta_atras" in enemigo and enemigo._cuenta_atras > 0.0
		if explotando and distancia > 0.0 and distancia < 160.0:
			huida += diferencia / (distancia * distancia) * 12.0
		elif enemigo._activo and distancia > 0.0 and distancia < RADIO_PELIGRO_GRANDES:
			huida += diferencia / (distancia * distancia) * 6.0

	# El mapa no tiene bordes: sin peligro cerca, da vueltas alrededor del
	# origen para no alejarse sin fin. Con el jefe en juego, va a por él: el
	# jefe es más lento que el jugador y, si no, no se encontrarían nunca.
	var direccion := huida.normalized()
	var jefe: Node2D = _raiz.get_node("Jefe")
	if huida == Vector2.ZERO and jefe._activo:
		direccion = (jefe.global_position - posicion).normalized()
	elif huida == Vector2.ZERO:
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
	var por_tipo := []
	for gestor in _gestores:
		vivos += gestor.vivos()
		por_tipo.append("%s %d" % [gestor.datos.tipo, gestor.vivos()])

	var resistencias := []
	var tabla: Dictionary = _raiz.get_node("ResistenciaMalware").resistencias()
	for arma in tabla:
		resistencias.append("%s %d%%" % [arma.nombre, roundi(tabla[arma] * 100.0)])

	var salud = _jugador.get_node("Salud")
	print("%s vida=%3.0f/%3.0f nivel=%2d en_pantalla=%3d arma=%s resiste=%s" % [
		etiqueta, salud._vida, salud.vida_maxima, _raiz.get_node("SistemaNiveles").nivel(),
		vivos, _jugador.get_node("GestorArmas").armas[0].nombre, resistencias])
	print("        por tipo: %s" % ", ".join(por_tipo))


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
	print("\nRESUMEN victorias=%d/%d duracion_media=%.0fs cambios_personaje=%d evoluciones=%d" % [
		_victorias, _partidas, suma / _partidas, _cambios, _evoluciones])
	print("ELIMINADOS POR TIPO %s" % _eliminados_por_tipo)
	quit()
