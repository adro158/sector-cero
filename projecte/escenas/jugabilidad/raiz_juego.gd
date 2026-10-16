extends Node2D

const Dificultad := preload("res://globales/dificultad.gd")
## Segundos de negro entre la fase 1 y la 2.
const DURACION_TRANSICION := 3.0

var _eliminados := 0
var _terminada := false
var _en_transicion := false
## Si se ha usado el menú de desarrollador: la partida no cuenta para los
## récords ni para el ranking.
var _trucos := false

@onready var _salud_jugador: Salud = $Jugador/Salud
@onready var _sistema_niveles: Node = $SistemaNiveles
@onready var _director: Node = $DirectorOleadas


func _ready() -> void:
	var aparicion: Node2D = get_tree().get_first_node_in_group("aparicion_jugador")
	$Jugador.global_position = aparicion.global_position

	# La vida de los enemigos la multiplica cada uno al aparecer; el daño que
	# recibe el jugador, su salud.
	_salud_jugador.multiplicador_dano = Dificultad.dato("dano")
	_salud_jugador.vida_cambiada.connect(_al_cambiar_vida)
	_salud_jugador.danado.connect(BusEventos.jugador_danado.emit)
	# Cuando cae un personaje se elige otro; la partida se pierde al caer todos.
	$Jugador/CambioPersonaje.equipo_derrotado.connect(_terminar_partida.bind(false))
	# Al cumplirse el tiempo llega el jefe, y al derrotarlo empieza la fase 2.
	_director.llega_el_jefe.connect($Jefe.aparecer)
	$Jefe.derrotado.connect(_pasar_a_fase_2)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.juego_pausado.connect(_al_pausar)


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	BusEventos.salud_jugador_cambiada.emit(actual, maxima)


func _al_morir_enemigo(_posicion: Vector2, _tipo: String) -> void:
	_eliminados += 1


func _al_pausar(en_pausa: bool) -> void:
	# El menú de pausa no puede quitar una pausa que no es suya: ni la del fin
	# de partida, ni la de elegir mejora o personaje, que se levantan solas, ni
	# la de la transición.
	if _terminada or _en_transicion or _sistema_niveles.eligiendo() or $Jugador/CambioPersonaje.eligiendo():
		return

	get_tree().paused = en_pausa


func usar_trucos() -> void:
	_trucos = true


## Al derrotar al jefe ya no se gana: la pantalla se va a negro con el juego
## en pausa, detrás se quita la horda y empieza la fase 2, y vuelve la imagen.
func _pasar_a_fase_2() -> void:
	# Si justo se está eligiendo mejora o quién sigue, se espera: esa pausa la
	# quita quien la puso, y lo haría en mitad del negro.
	while _sistema_niveles.eligiendo() or $Jugador/CambioPersonaje.eligiendo():
		await get_tree().process_frame
	if _terminada:
		return

	_en_transicion = true
	get_tree().paused = true
	BusEventos.transicion_fase.emit(DURACION_TRANSICION)
	# Los temporizadores del árbol siguen corriendo con el juego en pausa.
	await get_tree().create_timer(DURACION_TRANSICION * 0.5).timeout
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		gestor.vaciar()
	_director.empezar_fase_2()
	BusEventos.fase_cambiada.emit(2)
	await get_tree().create_timer(DURACION_TRANSICION * 0.5).timeout
	_en_transicion = false
	get_tree().paused = false


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
		"personaje": $Jugador/CambioPersonaje.personaje_actual().nombre,
		"trucos": _trucos,
		"dificultad": Dificultad.actual(),
	})
