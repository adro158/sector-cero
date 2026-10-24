extends Node

## Tiempo de golpe (hit stop): en los momentos fuertes de la partida el juego
## casi se congela unas centésimas, para que se noten. Escucha el bus: al morir
## un élite o lanzar una ulti, 0,05 s; en las furias de Kernel Panic y en los
## cambios de forma de NÚCLEO CERO, 0,1 s; al morir un jefe, 0,15 s.
##
## Lo crea raiz_juego.gd. Sin class_name: se carga con preload.

## A esta velocidad va el juego mientras dura el golpe.
const LENTO := 0.05

## La velocidad de antes del golpe: la x2 o x4 del menú F1 se respeta.
var _escala_normal := 1.0
## Golpes que aún no han acabado: si llega otro antes de que acabe el anterior,
## se vuelve a la velocidad normal cuando acaban todos.
var _pendientes := 0


func _ready() -> void:
	# El temporizador que lo devuelve a su velocidad tiene que correr también si
	# justo después se pausa el juego (al morir un jefe llega el negro).
	process_mode = Node.PROCESS_MODE_ALWAYS
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.ulti_lanzada.connect(func(_personaje): _congelar(0.05))
	BusEventos.jefe_furia_cambiada.connect(func(_furia): _congelar(0.1))
	BusEventos.jefe_final_forma_cambiada.connect(func(_forma): _congelar(0.1))


func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo == "elite":
		_congelar(0.05)
	elif tipo == "jefe":
		_congelar(0.15)


func _congelar(segundos: float) -> void:
	if _pendientes == 0:
		_escala_normal = Engine.time_scale
	_pendientes += 1
	Engine.time_scale = LENTO
	# El cuarto argumento hace que cuente en tiempo real, sin la escala: si no,
	# a 0,05 de velocidad tardaría veinte veces más.
	get_tree().create_timer(segundos, true, false, true).timeout.connect(_descongelar)


func _descongelar() -> void:
	_pendientes -= 1
	if _pendientes == 0:
		Engine.time_scale = _escala_normal


func _exit_tree() -> void:
	# Si se sale de la partida en mitad de un golpe, a su velocidad.
	if _pendientes > 0:
		Engine.time_scale = _escala_normal
