extends Node

## Se ha sobrevivido el tiempo que marca la configuración: llega el jefe, desde
## fuera de la pantalla como la horda.
signal llega_el_jefe(posicion: Vector2)
## Lo mismo al acabar la fase 2, con el jefe final.
signal llega_el_jefe_final(posicion: Vector2)

const Dificultad := preload("res://globales/dificultad.gd")

@export var config: DatosConfigOleada

var _tiempo := 0.0
var _tiempo_restante := 0.0
var _jefe_en_juego := false
## 1 hasta derrotar al jefe; 2 desde entonces, hasta el jefe final.
var _fase := 1
var _siguiente_elite := 0.0
var _jugador: Node2D
var _gestores: Array[GestorEnemigos] = []
var _elites: Array[Node] = []


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_elites = get_tree().get_nodes_in_group("elites")
	_siguiente_elite = config.primer_elite

	for nodo in get_tree().get_nodes_in_group("gestor_enemigos"):
		_gestores.append(nodo)


## Segundos de partida jugados. Es el reloj de la partida: no avanza con el
## juego en pausa, porque el director tampoco se procesa.
func tiempo() -> float:
	return _tiempo


func fase() -> int:
	return _fase


## Segundo en el que llega el jefe de la fase en curso: el de la fase 1 o el
## jefe final.
func duracion() -> float:
	return config.duracion_partida if _fase == 1 else config.duracion_partida + config.duracion_fase_2


## Detrás del negro de la transición, tras derrotar al jefe. El reloj vuelve a
## duracion_partida (10:00): así la fase 2 dura siempre lo mismo, tarde lo que
## tarde el jefe, y el jefe final llega cuando lo dice el reloj.
func empezar_fase_2() -> void:
	_fase = 2
	_tiempo = config.duracion_partida
	_tiempo_restante = 0.0
	_jefe_en_juego = false
	BusEventos.tiempo_partida.emit(_tiempo, duracion())


func _physics_process(delta: float) -> void:
	var segundo_anterior := int(_tiempo)
	_tiempo += delta
	_tiempo_restante -= delta

	# Una vez por segundo basta para un reloj en pantalla.
	if int(_tiempo) != segundo_anterior:
		BusEventos.tiempo_partida.emit(_tiempo, duracion())

	# Con el jefe en juego ya no aparece más horda: el final es contra él.
	if _jefe_en_juego:
		return

	if _tiempo >= duracion():
		_jefe_en_juego = true
		# En fácil, la horda que queda huye: el final es a solas contra el jefe
		# y lo que él invoque. En media y difícil se queda.
		if Dificultad.dato("horda_huye"):
			for gestor in _gestores:
				gestor.huir()
		if _fase == 1:
			llega_el_jefe.emit(_posicion_fuera_de_pantalla())
		else:
			llega_el_jefe_final.emit(_posicion_fuera_de_pantalla())
		return

	if _tiempo >= _siguiente_elite:
		_siguiente_elite += config.intervalo_elites
		_aparecer_elite()

	if _tiempo_restante > 0.0:
		return

	_tiempo_restante = _intervalo_actual()

	var gestor := _elegir_tipo()
	if gestor != null:
		gestor.aparecer(_posicion_fuera_de_pantalla())


## Para el menú de desarrollador: salta a ese segundo de la partida, en esa
## fase, como si se hubiera llegado jugando. Los enemigos que aparezcan desde
## ahora tendrán la vida de ese minuto y el siguiente élite llega en su turno.
## Si se salta al momento del jefe de esa fase, llega en el siguiente paso.
## Devuelve false si no se puede saltar porque el jefe ya ha llegado.
func saltar_a(segundos: float, fase_salto := 1) -> bool:
	if _jefe_en_juego:
		return false
	if fase_salto == 2:
		# Sin transición: el menú recarga la partida antes de saltar.
		_fase = 2
		BusEventos.fase_cambiada.emit(2)
	_tiempo = segundos
	_tiempo_restante = 0.0
	_siguiente_elite = config.primer_elite
	while _siguiente_elite <= segundos:
		_siguiente_elite += config.intervalo_elites
	BusEventos.tiempo_partida.emit(_tiempo, duracion())
	return true


## Para el menú de desarrollador: un élite ahora, si queda alguno libre.
func aparecer_elite() -> void:
	_aparecer_elite()


func _intervalo_actual() -> float:
	var progreso := clampf(_tiempo / config.tiempo_hasta_dificultad_maxima, 0.0, 1.0)
	return lerpf(config.intervalo_inicial, config.intervalo_final, progreso)


func _elegir_tipo() -> GestorEnemigos:
	# Cada tipo tiene su propio momento de entrada en la partida, así que la
	# variedad crece sola con el tiempo sin necesidad de guionizar oleadas. Un
	# tipo que ya tiene vivos todos los que admite a la vez se salta este turno.
	var disponibles: Array[GestorEnemigos] = []

	for gestor in _gestores:
		if gestor.tiempo_aparicion() <= _tiempo and gestor.cabe_otro():
			disponibles.append(gestor)

	if disponibles.is_empty():
		return null

	return disponibles.pick_random()


## Activa el primer élite libre. Si están todos en juego, este turno se pierde:
## con tres a la vez ya hay presión de sobra.
func _aparecer_elite() -> void:
	for elite in _elites:
		if not elite.activo():
			elite.aparecer(_posicion_fuera_de_pantalla(), _sortear_afijos())
			return


func _sortear_afijos() -> Array[DatosAfijoElite]:
	var afijos := config.afijos_elite.duplicate()
	afijos.shuffle()
	var cantidad := 2 if _tiempo >= config.tiempo_dos_afijos else 1
	return afijos.slice(0, cantidad)


func _posicion_fuera_de_pantalla() -> Vector2:
	var angulo := randf() * TAU
	return _jugador.global_position + Vector2.RIGHT.rotated(angulo) * config.distancia_aparicion
