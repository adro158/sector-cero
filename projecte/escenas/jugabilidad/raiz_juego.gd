extends Node2D

const Dificultad := preload("res://globales/dificultad.gd")
const TiempoGolpe := preload("res://escenas/jugabilidad/efectos/tiempo_golpe.gd")
## Segundos de negro entre la fase 1 y la 2.
const DURACION_TRANSICION := 3.0
## La parte de su vida con la que vuelven los caídos al pasar a la fase 2.
const VIDA_AL_REVIVIR := 0.5

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
	_interpolar_jugador()

	# La vida de los enemigos la multiplica cada uno al aparecer; el daño que
	# recibe el jugador, su salud.
	_salud_jugador.multiplicador_dano = Dificultad.dato("dano")
	_salud_jugador.vida_cambiada.connect(_al_cambiar_vida)
	_salud_jugador.danado.connect(BusEventos.jugador_danado.emit)
	# Cuando cae un personaje se elige otro; la partida se pierde al caer todos.
	$Jugador/CambioPersonaje.equipo_derrotado.connect(_terminar_partida.bind(false))
	# Al cumplirse el tiempo llega el jefe, y al derrotarlo empieza la fase 2.
	# Al acabar la fase 2 llega el jefe final, y se gana al derrotarlo.
	_director.llega_el_jefe.connect($Jefe.aparecer)
	$Jefe.derrotado.connect(_pasar_a_fase_2)
	_director.llega_el_jefe_final.connect($JefeFinal.aparecer)
	$JefeFinal.derrotado.connect(_terminar_partida.bind(true))
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.juego_pausado.connect(_al_pausar)
	# El frenazo de los momentos fuertes (tiempo_golpe.gd).
	add_child(TiempoGolpe.new())


## La física va a 60 pasos por segundo: en una pantalla de 144 o 240 Hz, el
## jugador y la cámara (y con ella todo el mapa) avanzaban a saltos, cada 3 o 4
## fotogramas y no siempre igual (Adam, 24/10: «se ve como lagueado»). Con la
## interpolación de física, Godot los dibuja entre un paso y el siguiente.
## Solo el jugador y sus hijos: lo demás se mueve también fuera de la física
## (tweens, partículas, la interfaz) o reordena las instancias de sus
## MultiMesh al quitar una, y así daría tirones o estelas. Se pone por código,
## y no en project.godot, para que llegue con el .pck.
func _interpolar_jugador() -> void:
	# Con la interpolación, la cámara tiene que seguirle en la física (si no,
	# Godot la cambia él solo y avisa).
	$Jugador/Camara.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	get_tree().physics_interpolation = true
	get_tree().root.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	$Jugador.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	# Recién colocado: que no se deslice desde donde estaba.
	$Jugador.reset_physics_interpolation()


func _exit_tree() -> void:
	# Fuera de la partida, como antes.
	get_tree().physics_interpolation = false
	get_tree().root.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT


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


## Para el menú de desarrollador, que no se abre durante el negro: al acabar,
## la transición quita la pausa y dejaría el juego corriendo debajo.
func en_transicion() -> bool:
	return _en_transicion


## Al derrotar al jefe ya no se gana: la pantalla se va a negro con el juego
## en pausa, detrás se quita la horda y empieza la fase 2, y vuelve la imagen.
## Nadie más puede haber pausado el juego en ese momento: con la pausa nada
## procesa, así que nada le habría dado el último golpe al jefe.
func _pasar_a_fase_2() -> void:
	if _terminada:
		return

	_en_transicion = true
	get_tree().paused = true
	BusEventos.transicion_fase.emit(DURACION_TRANSICION)
	# Los temporizadores del árbol siguen corriendo con el juego en pausa.
	await get_tree().create_timer(DURACION_TRANSICION * 0.5).timeout
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		gestor.vaciar()
	$Jugador/CambioPersonaje.revivir_caidos(VIDA_AL_REVIVIR)
	# Emite fase_cambiada: la arena, el audio y el HUD cambian detrás del negro.
	_director.empezar_fase_2()
	await get_tree().create_timer(DURACION_TRANSICION * 0.5).timeout
	_en_transicion = false
	get_tree().paused = false


func _terminar_partida(victoria: bool) -> void:
	# Que caiga el equipo y muera el jefe final en el mismo fotograma no debe
	# dar dos finales.
	if _terminada:
		return

	_terminada = true
	get_tree().paused = true

	# Las claves de este diccionario son parte del contrato con la interfaz: la
	# pantalla final y GestorGuardado las leen por nombre.
	BusEventos.partida_terminada.emit({
		"victoria": victoria,
		"tiempo": _director.tiempo(),
		"nivel": _sistema_niveles.nivel(),
		"eliminados": _eliminados,
		"personaje": $Jugador/CambioPersonaje.personaje_actual().nombre,
		"trucos": _trucos,
		"dificultad": Dificultad.actual(),
		# Para el resumen de la pantalla final: el ranking no las guarda.
		"equipo": _resumen_equipo(),
		"donde": _donde(victoria),
	})


## Cada personaje: su DatosPersonaje, si cayó y el daño que hizo su
## herramienta (la base y su evolución) en toda la partida. Enseña que cambiar
## de personaje ha servido (el elemento diferencial).
func _resumen_equipo() -> Array:
	var danos: Dictionary = $ResistenciaMalware.dano_total()
	var equipo := []
	for estado in $Jugador/CambioPersonaje.estado():
		var dano := 0.0
		for arma in danos:
			if arma == estado.personaje.arma or arma == estado.arma:
				dano += danos[arma]
		equipo.append({"personaje": estado.personaje, "caido": estado.caido, "dano": dano})
	return equipo


## Dónde ha acabado la partida, para la pantalla final.
func _donde(victoria: bool) -> String:
	if victoria:
		return "NÚCLEO CERO derrotado"
	if $Jefe.activo():
		return "contra Kernel Panic"
	if $JefeFinal.activo():
		return "contra NÚCLEO CERO (%s)" % ["rootkit gigante", "núcleo armado", "amalgama"][$JefeFinal.forma()]
	return "en la fase 2" if _director.fase() == 2 else "en la fase 1"
