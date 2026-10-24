extends Node2D

## Los efectos que salen sobre el personaje: subir de nivel, cambiar de
## personaje (teñido del color del que entra), curarse con el corazón de los
## élites, recibir un golpe, el escudo al entrar tras una caída, evolucionar la
## herramienta y caer. Es hijo del jugador, en el centro de su sprite (0, -22):
## le sigue y va encima de él. Los dibujos son tramados, así que el personaje
## se ve a través.
##
## Sin class_name: es un script de una escena, no hace falta que sea global.

const SUBIR_NIVEL := preload("res://medios/sprites/efectos/subir_nivel.png")
const CAMBIO := preload("res://medios/sprites/efectos/cambio_personaje.png")
const CURAR := preload("res://medios/sprites/efectos/curar.png")
const GOLPE := preload("res://medios/sprites/efectos/golpe_recibido.png")
const ESCUDO := preload("res://medios/sprites/efectos/escudo_proteccion.png")
const EVOLUCION := preload("res://medios/sprites/efectos/evolucion_herramienta.png")
const CAIDA := preload("res://medios/sprites/efectos/caida_personaje.png")
const DERROTA := preload("res://medios/sprites/efectos/derrota_personaje.png")
const COLOR_GOLPE := Color(1.0, 0.25, 0.3)

## Cada efecto: [hoja, fotogramas, segundos por fotograma, color, segundos que
## lleva, segundos que dura, si se anima en pausa]. Si dura más que sus
## fotogramas, va en bucle (el escudo).
var _efectos: Array = []
## Se sube de nivel con el juego en pausa: el efecto sale al volver, cuando ya
## se ha elegido la mejora. Aunque se suban varios de golpe, sale uno.
var _subio_nivel := false
var _personaje: DatosPersonaje


func _ready() -> void:
	# Se procesa también en pausa para la caída: cambio_personaje.gd pausa el
	# juego al caer y espera a que acabe. Los demás efectos se quedan quietos
	# en pausa, como el resto de la partida.
	process_mode = Node.PROCESS_MODE_ALWAYS
	BusEventos.jugador_subio_nivel.connect(func(_opciones): _subio_nivel = true)
	BusEventos.personaje_cambiado.connect(_al_cambiar_personaje)
	get_parent().get_node("Salud").danado.connect(func(_cantidad): _anadir(GOLPE, 4, 0.05, COLOR_GOLPE))


## Lo llama premios_elite.gd al recoger el corazón. El robo de vida no: cura en
## cada golpe y lo llenaría todo de cruces.
func curar() -> void:
	_anadir(CURAR, 6, 0.07, Color.WHITE)


## Los segundos sin daño del que entra tras una caída: en bucle y de su color.
## Lo llama cambio_personaje.gd.
func escudo(color: Color, segundos: float) -> void:
	_anadir(ESCUDO, 4, 0.1, color, segundos)


## Lo llama cambio_personaje.gd al evolucionar la herramienta del que juega.
## La evolución llega con una subida de nivel: sale esta en lugar de la otra.
func evolucion(color: Color) -> void:
	_subio_nivel = false
	_anadir(EVOLUCION, 10, 0.07, color)


## Cae el personaje: la caída, o la derrota si era el último, de su color y
## animada aunque el juego esté en pausa. Se quitan los demás efectos: el golpe
## que lo ha matado se quedaría encima. Devuelve los segundos que dura, para
## que cambio_personaje.gd espere a que acabe.
func caer(color: Color, ultimo: bool) -> float:
	_efectos.clear()
	var hoja := DERROTA if ultimo else CAIDA
	var fotogramas := 12 if ultimo else 8
	_anadir(hoja, fotogramas, 0.08, color, 0.0, true)
	return fotogramas * 0.08


func _al_cambiar_personaje(actual: DatosPersonaje, _arma: DatosArma, _siguiente: DatosPersonaje, _espera: float) -> void:
	# La señal también llega al empezar la partida y al evolucionar la
	# herramienta, sin que entre nadie: solo sale si cambia de verdad.
	if _personaje != null and actual != _personaje:
		_anadir(CAMBIO, 6, 0.05, actual.color)
	_personaje = actual


## Sin duración, dura sus fotogramas una vez.
func _anadir(hoja: Texture2D, fotogramas: int, segundos_por_fotograma: float, color: Color, duracion := 0.0, en_pausa := false) -> void:
	if duracion <= 0.0:
		duracion = fotogramas * segundos_por_fotograma
	_efectos.append([hoja, fotogramas, segundos_por_fotograma, color, 0.0, duracion, en_pausa])


func _process(delta: float) -> void:
	var pausado := get_tree().paused
	if _subio_nivel and not pausado:
		_subio_nivel = false
		_anadir(SUBIR_NIVEL, 8, 0.08, Color.WHITE)
	if _efectos.is_empty():
		return
	for efecto in _efectos:
		if efecto[6] or not pausado:
			efecto[4] += delta
	_efectos = _efectos.filter(func(efecto): return efecto[4] < efecto[5])
	queue_redraw()


func _draw() -> void:
	for efecto in _efectos:
		var hoja: Texture2D = efecto[0]
		var lado := Vector2(hoja.get_width() / float(efecto[1]), hoja.get_height())
		var fotograma: int = int(efecto[4] / efecto[2]) % efecto[1]
		draw_texture_rect_region(hoja, Rect2(-lado / 2.0, lado), Rect2(Vector2(fotograma * lado.x, 0.0), lado), efecto[3])
