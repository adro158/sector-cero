extends SceneTree

## Herramienta de testeo, no forma parte del juego: juega partidas enteras sin
## nadie delante para medir el balance. Un bot huye de los enemigos cercanos,
## de los élites, de los jefes, del hielo y de la ráfaga del jefe, va a por el
## corazón y el cofre que sueltan los élites (y acepta lo que toque en la
## ruleta), recoge los fragmentos de datos cuando no hay peligro (desde el
## 16/10/2026: antes se le caducaban y subía menos de nivel que una persona),
## da vueltas si no hay nada que hacer, elige mejoras como un jugador (la
## evolución si sale y, si no, una de ataque si la hay) y cambia de personaje
## cuando el malware se ha hecho resistente a su herramienta. Con un jefe en
## juego va a por él, y si el jefe final está encerrado en su escudo, a por las
## anclas: primero las del personaje que lleva y después cambia al de la más
## cercana, porque cada una solo la rompe su herramienta. Cada minuto de partida (y al pasar a la fase 2) anota vida, nivel,
## mejoras, enemigos (en total y por tipo), herramienta y resistencias, y al
## final resume victorias, hasta dónde llega, duración media, cambios de
## personaje, cofres recogidos, personajes caídos, ultis lanzadas y eliminados
## por tipo. Cuando cae el personaje activo, sigue con el que tenga más vida, y
## lanza la ulti en cuanto la tiene llena.
##
## Uso, desde la carpeta projecte/ (--fixed-fps 60 hace que cada fotograma
## avance 1/60 s sin esperar al reloj real, así que va mucho más rápido):
##
##   Godot --headless --fixed-fps 60 --path . --script res://herramientas/simular_partidas.gd -- partidas=5
##
## Con dificultad=facil (o media, o dificil) se juega en esa dificultad; si no,
## en la media. No se guarda: las opciones del jugador no cambian. Con desde=6
## se empieza por la partida 6, con su semilla: así se pueden repartir las
## partidas entre varias copias del proyecto a la vez (partidas=5 en una y
## partidas=10 desde=6 en otra dan las mismas 10 partidas que en serie).
## Con minuto=15 (o 10) cada partida empieza en ese minuto, con el nivel y las
## mejoras de las tablas del F1, como su botón JEFE FINAL YA (o JEFE YA): para
## medir solo un jefe. Esas partidas no valen para el porcentaje de victorias.
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
## Con el jefe en juego, el bot se acerca hasta esta distancia, dentro del
## alcance del Firewall (90 más los 40 del radio del jefe).
const DISTANCIA_AL_JEFE := 120.0
## Resistencia de la herramienta activa a partir de la cual el bot cambia.
const RESISTENCIA_PARA_CAMBIAR := 0.3
## Si un jefe sigue vivo tanto tiempo después de aparecer, la partida se da por
## perdida. Sin bordes, un bot podría huir de él para siempre. Se cuenta aparte
## porque el reloj de la partida se para con el primer jefe.
const TIEMPO_MAXIMO_JEFE := 240.0
## Sin peligro cerca, va a por el fragmento más cercano dentro de esta
## distancia.
const RADIO_FRAGMENTOS := 400.0
## Se aparta de las zonas de hielo del jefe final (su radio es 60).
const RADIO_HIELO := 90.0
## Durante el torbellino del jefe final (radio 170) se queda más lejos que esto.
const RADIO_TORBELLINO := 200.0
## Se aparta de los proyectiles de la ráfaga del jefe que le vienen encima y
## están más cerca que esto.
const RADIO_RAFAGA := 80.0
## Las mejoras que prefiere el bot. Hasta el 02/10/2026 elegía al azar, pero
## con ocho mejoras en el pool, tres de ellas sin daño, eso ya no se parecía a
## jugar: se quedaba sin evoluciones y sin daño para el jefe (bitácora, sesión 7).
const MEJORAS_DE_ATAQUE := [DatosMejora.Efecto.DANO_ARMAS, DatosMejora.Efecto.CADENCIA_ARMAS, DatosMejora.Efecto.ALCANCE_ARMAS]

var _partidas := 3
var _partida := 0
var _dificultad := "media"
## Segundo de la partida en el que empieza cada una (0, desde el principio).
var _empezar_en := 0.0
var _victorias := 0
var _duraciones: Array[float] = []
var _cambios := 0
var _evoluciones := 0
var _cofres := 0
var _caidas := 0
var _ultis := 0
## Partidas que llegan a la fase 2 y al jefe final.
var _fases_2 := 0
var _jefes_finales := 0
## Segundos que lleva en juego el jefe de ahora.
var _con_jefe := 0.0
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
		elif argumento.begins_with("dificultad="):
			_dificultad = argumento.split("=")[1]
		elif argumento.begins_with("desde="):
			_partida = int(argumento.split("=")[1]) - 1
		elif argumento.begins_with("minuto="):
			_empezar_en = float(argumento.split("=")[1]) * 60.0

	_bus = root.get_node("BusEventos")
	# Las partidas simuladas no son del jugador: no deben entrar en sus récords.
	# Diferido porque los autoloads aún no han hecho su _ready ni se han
	# conectado al bus.
	var guardado := root.get_node("GestorGuardado")
	_bus.partida_terminada.disconnect.call_deferred(guardado._al_terminar_partida)
	_bus.jugador_subio_nivel.connect(_al_subir_nivel)
	# La ruleta del cofre no se elige: se acepta el premio que ha tocado.
	_bus.ruleta_abierta.connect(func(_opciones, premio): _elegir.call_deferred(premio))
	_bus.arma_evolucionada.connect(func(_arma): _evoluciones += 1)
	_bus.cofre_recogido.connect(func(): _cofres += 1)
	_bus.personaje_caido.connect(_al_caer_personaje)
	_bus.enemigo_muerto.connect(func(_posicion, tipo): _eliminados_por_tipo[tipo] = _eliminados_por_tipo.get(tipo, 0) + 1)
	_bus.fase_cambiada.connect(_al_cambiar_fase)
	_bus.jefe_final_aparecio.connect(_al_aparecer_jefe_final)
	_bus.jefe_final_ataco.connect(_al_atacar_jefe_final)
	_bus.partida_terminada.connect(_al_terminar)
	physics_frame.connect(_paso)
	# Diferido: GestorGuardado lee su fichero en su _ready y borraría la
	# dificultad puesta antes.
	_empezar_partida.call_deferred()


func _empezar_partida() -> void:
	_partida += 1
	# En memoria y sin guardar en el fichero, que es el del jugador.
	root.get_node("GestorGuardado")._fichero.set_value("opciones", "dificultad", _dificultad)
	# Semilla fija por partida: la misma partida se repite igual tras un cambio,
	# así se puede comparar el antes y el después.
	seed(1000 + _partida)
	paused = false
	_terminada = false
	_siguiente_informe = _empezar_en + 60.0
	_con_jefe = 0.0
	_gestores = []
	_juego = load("res://escenas/juego.tscn").instantiate()
	root.add_child(_juego)
	_raiz = _juego.get_node("RaizJuego")
	_jugador = _raiz.get_node("Jugador")
	if _empezar_en > 0.0:
		_saltar.call_deferred()
	_raiz.get_node("JefeFinal/Escudo").roto.connect(func(): print("  escudo roto (t=%.0fs)" % _raiz.get_node("DirectorOleadas").tiempo()))
	print("\n=== PARTIDA %d ===" % _partida)


## Lo mismo que los botones JEFE YA y JEFE FINAL YA del F1. Diferido: al crear
## la partida, sus nodos aún no han hecho su _ready.
func _saltar() -> void:
	var director: Node = _raiz.get_node("DirectorOleadas")
	var fase := 2 if _empezar_en > director.config.duracion_partida else 1
	director.saltar_a(_empezar_en, fase)
	load("res://escenas/jugabilidad/depuracion/progreso_por_minuto.gd").ponerse_al_dia(_raiz.get_node("SistemaNiveles"), _empezar_en, fase)


func _al_subir_nivel(opciones: Array) -> void:
	# Si sale una evolución, siempre es la primera opción y siempre la coge. Si
	# no, una de ataque si hay alguna, y si no, cualquiera.
	var de_ataque := opciones.filter(func(mejora): return mejora.efecto in MEJORAS_DE_ATAQUE)
	var elegida: DatosMejora = de_ataque.pick_random() if not de_ataque.is_empty() else opciones.pick_random()
	if opciones[0].efecto == DatosMejora.Efecto.EVOLUCIONAR_ARMA:
		elegida = opciones[0]
	_elegir.call_deferred(elegida)


func _elegir(mejora: DatosMejora) -> void:
	_bus.mejora_seleccionada.emit(mejora)


## Cuando cae el personaje activo, sigue el que tenga más vida.
func _al_caer_personaje(personajes: Array, caido: int) -> void:
	_caidas += 1
	print("  cae %s (t=%.0fs, %s)" % [personajes[caido].personaje.nombre, _raiz.get_node("DirectorOleadas").tiempo(), _donde()])
	var mejor := -1
	for i in personajes.size():
		if not personajes[i].caido and (mejor == -1 or personajes[i].vida > personajes[mejor].vida):
			mejor = i
	_bus.personaje_elegido.emit.call_deferred(mejor)


func _al_cambiar_fase(_fase: int) -> void:
	_fases_2 += 1
	_con_jefe = 0.0
	_informe("FASE 2")


func _al_aparecer_jefe_final() -> void:
	_jefes_finales += 1
	_con_jefe = 0.0


## Lo único que se apunta de sus ataques es el escudo, que avisa igual al
## levantarse que al volver a cerrarse las anclas rotas.
func _al_atacar_jefe_final(ataque: String) -> void:
	if ataque == "escudo":
		print("  escudo levantado o cerrado otra vez (t=%.0fs)" % _raiz.get_node("DirectorOleadas").tiempo())


func _paso() -> void:
	# La primera partida empieza diferida: puede pasar un fotograma sin ella.
	if _raiz == null:
		return
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
	var jefe: Node = _raiz.get_node("Jefe")
	var jefe_final: Node = _raiz.get_node("JefeFinal")
	if jefe._activo or jefe_final.activo():
		_con_jefe += _raiz.get_physics_process_delta_time()
	if _con_jefe > TIEMPO_MAXIMO_JEFE:
		var salud: Node = jefe_final.get_node("Salud") if jefe_final.activo() else jefe.get_node("Salud")
		print("TIEMPO AGOTADO contra %s (le quedan %.0f de %.0f de vida)" % [
			"el jefe final" if jefe_final.activo() else "el jefe", salud.vida(), salud.vida_maxima])
		_raiz._terminar_partida(false)
		return

	# Con el escudo del jefe final, el personaje lo decide el ancla; si no, la
	# resistencia.
	var ancla := _ancla_a_romper(jefe_final)
	if ancla != null:
		_cambiar_a(_personaje_de(ancla))
	else:
		_cambiar_si_resiste()
	# La ulti, en cuanto está llena.
	var ultis: Node = _jugador.get_node("Ultis")
	if ultis.lista():
		ultis.lanzar()
		_ultis += 1
	_mover_bot()


func _cambiar_si_resiste() -> void:
	var arma: DatosArma = _jugador.get_node("GestorArmas").armas[0]
	if _raiz.get_node("ResistenciaMalware").resistencia(arma) >= RESISTENCIA_PARA_CAMBIAR:
		if _jugador.get_node("CambioPersonaje").cambiar():
			_cambios += 1


## Cambia hacia ese personaje por el camino más corto (con Q o con E). Si aún
## hay que esperar para cambiar, lo vuelve a intentar en el siguiente paso.
func _cambiar_a(personaje: DatosPersonaje) -> void:
	var cambio: Node = _jugador.get_node("CambioPersonaje")
	var actual: int = cambio.indice_actual()
	var destino: int = cambio.personajes.find(personaje)
	if destino == -1 or destino == actual or cambio._caidos[destino]:
		return
	var paso := 1 if posmod(destino - actual, cambio.personajes.size()) == 1 else -1
	if cambio.cambiar(paso):
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

	# De los élites y de los jefes se aparta con más fuerza, pero solo cuando
	# se acercan: a media distancia las armas de alcance les siguen dando.
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
	var jefe_final: Node2D = _raiz.get_node("JefeFinal")
	var hasta_jefe_final := posicion - jefe_final.global_position
	if jefe_final.activo() and hasta_jefe_final.length() > 0.0 and hasta_jefe_final.length() < RADIO_PELIGRO_GRANDES:
		huida += hasta_jefe_final / hasta_jefe_final.length_squared() * 6.0
	# Del hielo también, como de un enemigo.
	for zona in _raiz.get_node("ZonasHielo").posiciones():
		var diferencia: Vector2 = posicion - zona
		if diferencia.length() > 0.0 and diferencia.length() < RADIO_HIELO:
			huida += diferencia / diferencia.length_squared() * 6.0

	# De la ráfaga del jefe se aparta de lado, como una persona que busca el
	# hueco: hacia el lado de la trayectoria del proyectil en el que ya está.
	for proyectil in _raiz.get_node("Jefe/Rafaga")._proyectiles:
		var diferencia: Vector2 = posicion - proyectil[0]
		if diferencia.length() > 0.0 and diferencia.length() < RADIO_RAFAGA and diferencia.dot(proyectil[1]) > 0.0:
			var lado: Vector2 = proyectil[1].orthogonal()
			if diferencia.dot(lado) < 0.0:
				lado = -lado
			huida += lado / diferencia.length() * 6.0

	# El mapa no tiene bordes: sin peligro cerca, da vueltas alrededor del
	# origen para no alejarse sin fin.
	var direccion := huida.normalized()
	var jefe: Node2D = _raiz.get_node("Jefe")
	var objetivo := _jefe_al_que_ir(jefe, jefe_final)
	var fragmento := _fragmento_mas_cercano(posicion)
	# El corazón y el cofre de los élites hay que ir a buscarlos: el bot va a
	# por el más cercano sin dejar de apartarse de lo que tenga encima.
	var premio := _premio_mas_cercano(posicion)
	if premio != Vector2.INF:
		direccion = ((premio - posicion).normalized() + huida.normalized() * 0.7).normalized()
	# Con un jefe en juego, va a por él de la misma forma. Hasta la sesión 11
	# solo iba cuando no tenía a nadie cerca, pero con la horda que se queda
	# (media y difícil) no llegaba nunca y se le acababa el tiempo.
	# Del torbellino del jefe final sale en cuanto ve el aviso, como una
	# persona, y no vuelve hasta que acaba.
	elif _ataque_del_jefe_final(jefe_final) == "torbellino" and posicion.distance_to(jefe_final.global_position) < RADIO_TORBELLINO:
		direccion = (posicion - jefe_final.global_position).normalized()
	elif objetivo != Vector2.INF and _ataque_del_jefe_final(jefe_final) != "torbellino":
		if posicion.distance_to(objetivo) > DISTANCIA_AL_JEFE:
			direccion = ((objetivo - posicion).normalized() + huida.normalized() * 0.7).normalized()
	# Los fragmentos, solo sin peligro cerca. Probado el 16/10/2026: si va a
	# por ellos con horda alrededor (aunque sea solo a por los que tiene al
	# lado), sube antes de nivel pero se mete en la horda y muere entre el
	# minuto 3 y el 6.
	elif huida == Vector2.ZERO and fragmento != Vector2.INF:
		direccion = (fragmento - posicion).normalized()
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


## El ataque que está haciendo el jefe final ("" si ninguno o si no está).
func _ataque_del_jefe_final(jefe_final: Node2D) -> String:
	return jefe_final.get_node("Ataques")._ataque if jefe_final.activo() else ""


## A dónde ir con un jefe en juego: el jefe o, si el jefe final está dentro
## de su escudo, el ancla que toca romper. Vector2.INF si no hay jefe.
func _jefe_al_que_ir(jefe: Node2D, jefe_final: Node2D) -> Vector2:
	if jefe._activo:
		return jefe.global_position
	if not jefe_final.activo():
		return Vector2.INF
	var ancla := _ancla_a_romper(jefe_final)
	return ancla.global_position if ancla != null else jefe_final.global_position


## Con el escudo del jefe final puesto, el ancla sin romper que toca: la más
## cercana de las del personaje que lleva y, si no le queda ninguna, la más
## cercana de las demás (y cambia a su personaje). null si no hay escudo. Hasta
## el 22/10/2026 iba a la más cercana sin cambiar de personaje: cada ancla solo
## la rompe su herramienta (desde la sesión 17), así que perdía siempre ahí.
func _ancla_a_romper(jefe_final: Node) -> Node2D:
	if not jefe_final.activo() or not jefe_final.get_node("Escudo").activo():
		return null
	var actual: DatosPersonaje = _jugador.get_node("CambioPersonaje").personaje_actual()
	var posicion := _jugador.global_position
	var mejor: Node2D = null
	var mejor_es_suya := false
	for ancla in jefe_final.get_node("Escudo").get_children():
		if not ancla._activa:
			continue
		var es_suya := _personaje_de(ancla) == actual
		var mas_cerca: bool = mejor == null or posicion.distance_to(ancla.global_position) < posicion.distance_to(mejor.global_position)
		if mejor == null or (es_suya and not mejor_es_suya) or (es_suya == mejor_es_suya and mas_cerca):
			mejor = ancla
			mejor_es_suya = es_suya
	return mejor


## El personaje cuya herramienta rompe esa ancla, de la tabla PERSONAJES de su
## script. Se lee de la que ya está en la partida: con un preload aquí, el
## script del ancla se compilaría antes que los autoloads y fallaría (y con
## él, las armas al pegarle).
func _personaje_de(ancla: Node) -> DatosPersonaje:
	return ancla.get_script().get_script_constant_map()["PERSONAJES"][ancla.herramienta]


## El fragmento de datos más cercano dentro de RADIO_FRAGMENTOS, o Vector2.INF.
func _fragmento_mas_cercano(posicion: Vector2) -> Vector2:
	var gemas: Node = _raiz.get_node("PoolGemas")
	var mejor := Vector2.INF
	var mejor_distancia := RADIO_FRAGMENTOS
	for i in gemas._vivas:
		var distancia := posicion.distance_to(gemas._posiciones[i])
		if distancia < mejor_distancia:
			mejor_distancia = distancia
			mejor = gemas._posiciones[i]
	return mejor


## Dónde está el premio más cercano en el suelo, o Vector2.INF si no hay.
func _premio_mas_cercano(posicion: Vector2) -> Vector2:
	var mejor := Vector2.INF
	for premio in _raiz.get_node("PremiosElite").get_children():
		# El "+N" del corazón y los premios que ya se están recogiendo, no.
		if not premio is Sprite2D or premio.has_meta("recogido"):
			continue
		var suelo: Vector2 = premio.get_meta("suelo")
		if mejor == Vector2.INF or posicion.distance_to(suelo) < posicion.distance_to(mejor):
			mejor = suelo
	return mejor


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
	var niveles := _raiz.get_node("SistemaNiveles")
	print("%s vida=%3.0f/%3.0f nivel=%2d mejoras=%2d en_pantalla=%3d arma=%s resiste=%s" % [
		etiqueta, salud._vida, salud.vida_maxima, niveles.nivel(), niveles.mejoras_aplicadas(),
		vivos, _jugador.get_node("GestorArmas").armas[0].nombre, resistencias])
	print("        por tipo: %s" % ", ".join(por_tipo))


func _al_terminar(estadisticas: Dictionary) -> void:
	_terminada = true
	_informe("FINAL")
	if estadisticas.victoria:
		_victorias += 1
	_duraciones.append(estadisticas.tiempo)
	print("RESULTADO %s tiempo=%.0fs nivel=%d eliminados=%d donde=%s" % [
		"VICTORIA" if estadisticas.victoria else "DERROTA", estadisticas.tiempo,
		estadisticas.nivel, estadisticas.eliminados, "jefe final derrotado" if estadisticas.victoria else _donde()])
	_siguiente.call_deferred()


## Por dónde va la partida: fase 1, jefe, fase 2 o jefe final (y en qué forma).
func _donde() -> String:
	var jefe_final: Node = _raiz.get_node("JefeFinal")
	if _raiz.get_node("Jefe")._activo:
		return "jefe"
	if jefe_final.visible:
		return "jefe final (%s)" % ["rootkit gigante", "núcleo armado", "amalgama"][jefe_final.forma()]
	if _raiz.get_node("DirectorOleadas").fase() == 2:
		return "fase 2"
	return "fase 1"


func _siguiente() -> void:
	_juego.queue_free()
	await process_frame

	if _partida < _partidas:
		_empezar_partida()
		return

	var suma := 0.0
	for duracion in _duraciones:
		suma += duracion
	print("\nRESUMEN dificultad=%s victorias=%d/%d fase_2=%d jefe_final=%d duracion_media=%.0fs cambios_personaje=%d evoluciones=%d cofres=%d caidas=%d ultis=%d" % [
		_dificultad, _victorias, _duraciones.size(), _fases_2, _jefes_finales, suma / _duraciones.size(), _cambios, _evoluciones, _cofres, _caidas, _ultis])
	print("ELIMINADOS POR TIPO %s" % _eliminados_por_tipo)
	quit()
