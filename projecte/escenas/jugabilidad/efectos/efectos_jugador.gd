extends Node2D

## Los efectos que salen sobre el personaje: subir de nivel, cambiar de
## personaje (teñido del color del que entra) y curarse con el corazón de los
## élites. Es hijo del jugador, en el centro de su sprite (0, -22): le sigue y
## va encima de él. Los dibujos son tramados, así que el personaje se ve a
## través.
##
## Sin class_name: es un script de una escena, no hace falta que sea global.

const SUBIR_NIVEL := preload("res://medios/sprites/efectos/subir_nivel.png")
const CAMBIO := preload("res://medios/sprites/efectos/cambio_personaje.png")
const CURAR := preload("res://medios/sprites/efectos/curar.png")

## Cada efecto: [hoja, fotogramas, segundos por fotograma, color, segundos].
var _efectos: Array = []
## Se sube de nivel con el juego en pausa: el efecto sale al volver, cuando ya
## se ha elegido la mejora. Aunque se suban varios de golpe, sale uno.
var _subio_nivel := false
var _personaje: DatosPersonaje


func _ready() -> void:
	BusEventos.jugador_subio_nivel.connect(func(_opciones): _subio_nivel = true)
	BusEventos.personaje_cambiado.connect(_al_cambiar_personaje)


## Lo llama premios_elite.gd al recoger el corazón. El robo de vida no: cura en
## cada golpe y lo llenaría todo de cruces.
func curar() -> void:
	_efectos.append([CURAR, 6, 0.07, Color.WHITE, 0.0])


func _al_cambiar_personaje(actual: DatosPersonaje, _arma: DatosArma, _siguiente: DatosPersonaje, _espera: float) -> void:
	# La señal también llega al empezar la partida y al evolucionar la
	# herramienta, sin que entre nadie: solo sale si cambia de verdad.
	if _personaje != null and actual != _personaje:
		_efectos.append([CAMBIO, 6, 0.05, actual.color, 0.0])
	_personaje = actual


## Con el juego en pausa no se llama: los efectos se quedan quietos.
func _process(delta: float) -> void:
	if _subio_nivel:
		_subio_nivel = false
		_efectos.append([SUBIR_NIVEL, 8, 0.08, Color.WHITE, 0.0])
	if _efectos.is_empty():
		return
	for efecto in _efectos:
		efecto[4] += delta
	_efectos = _efectos.filter(func(efecto): return efecto[4] < efecto[1] * efecto[2])
	queue_redraw()


func _draw() -> void:
	for efecto in _efectos:
		var hoja: Texture2D = efecto[0]
		var lado := Vector2(hoja.get_width() / float(efecto[1]), hoja.get_height())
		var fotograma := int(efecto[4] / efecto[2])
		draw_texture_rect_region(hoja, Rect2(-lado / 2.0, lado), Rect2(Vector2(fotograma * lado.x, 0.0), lado), efecto[3])
