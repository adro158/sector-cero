extends Node2D

## Lo vistoso de Kernel Panic, el jefe del minuto 10 (jefe.gd): baja en una
## columna de datos, al enfurecerse suelta una onda roja con rayos y al morir
## se agrieta y explota. Lleva sus tiempos, su dibujo y el tirón de la cámara,
## y avisa al jefe con aparecido y con acabo_de_morir.
##
## Es el hijo Efectos del jefe, con z_index 4: encima del jugador y de la
## horda. Con el juego en pausa no avanza. Sin class_name: lo usa la escena
## del jefe.

signal aparecido
signal acabo_de_morir

## Una columna de datos que cae, el golpe en el suelo y un anillo con runas:
## 10 fotogramas de 288x528, con los pies del jefe en (144, 384).
const APARICION := preload("res://medios/sprites/jefe/jefe_aparicion.png")
const FOTOGRAMAS_APARICION := 10
const APARICION_CADA := 0.1
const PIES_APARICION := Vector2(144.0, 384.0)
## La columna llega al suelo en el fotograma 3: ahí tiembla la pantalla y
## empieza a verse el jefe.
const GOLPE_APARICION := 0.3
## Toda la aparición: los 10 fotogramas y un momento quieto.
const DURA_APARICION := 1.2

## Un destello y una onda roja con rayos al enfurecerse: 8 de 320x320.
const FURIA := preload("res://medios/sprites/jefe/jefe_furia.png")
const FOTOGRAMAS_FURIA := 8
const FURIA_CADA := 0.07

## Se agrieta, un destello en rombo y una explosión morada: 12 de 320x320.
const MUERTE := preload("res://medios/sprites/jefe/jefe_muerte.png")
const FOTOGRAMAS_MUERTE := 12
const MUERTE_CADA := 0.08
## Desde el destello (fotograma 3) ya no se ve su cuerpo.
const MUERTE_SIN_CUERPO := 3 * MUERTE_CADA

## La furia y la muerte salen del centro de su cuerpo: el offset de su Sprite.
const CUERPO := Vector2(0.0, -42.0)
## El tirón de la cámara al aparecer y al enfurecerse; al morir, más.
const SACUDIDA := 10.0

enum Que { NADA, APARICION, MUERTE }

var _que := Que.NADA
var _tiempo := 0.0
## Segundos desde que se enfureció (-1 si no se está dibujando la onda).
var _tiempo_furia := -1.0
var _jugador: Node2D

@onready var _sprite: Sprite2D = get_parent().get_node("Sprite")


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")


func aparicion() -> void:
	_empezar(Que.APARICION)
	_sprite.modulate.a = 0.0


func furia() -> void:
	_tiempo_furia = 0.0
	_jugador.sacudir(SACUDIDA)


func muerte() -> void:
	_empezar(Que.MUERTE)
	_tiempo_furia = -1.0
	_jugador.sacudir(SACUDIDA * 1.5)


func _empezar(que: Que) -> void:
	_que = que
	_tiempo = 0.0
	_sprite.visible = true


func _physics_process(delta: float) -> void:
	if _tiempo_furia >= 0.0:
		_tiempo_furia += delta
		if _tiempo_furia >= FOTOGRAMAS_FURIA * FURIA_CADA:
			_tiempo_furia = -1.0
	if _que == Que.NADA:
		queue_redraw()
		return

	_tiempo += delta
	if _que == Que.APARICION:
		_sprite.modulate.a = _opacidad_aparicion()
		if _tiempo >= GOLPE_APARICION and _tiempo - delta < GOLPE_APARICION:
			_jugador.sacudir(SACUDIDA)
		if _tiempo >= DURA_APARICION:
			_que = Que.NADA
			aparecido.emit()
	else:
		_sprite.visible = _tiempo < MUERTE_SIN_CUERPO
		if _tiempo >= FOTOGRAMAS_MUERTE * MUERTE_CADA:
			_que = Que.NADA
			acabo_de_morir.emit()
	queue_redraw()


## Nada hasta el golpe y luego, parpadeando como una imagen que se carga, cada
## vez más.
func _opacidad_aparicion() -> float:
	if _tiempo < GOLPE_APARICION:
		return 0.0
	var avance := clampf((_tiempo - GOLPE_APARICION) / (DURA_APARICION - GOLPE_APARICION - 0.2), 0.0, 1.0)
	if avance < 1.0 and int(_tiempo * 30.0) % 3 == 0:
		return avance * 0.6
	return avance


func _draw() -> void:
	match _que:
		Que.APARICION:
			_fotograma(APARICION, FOTOGRAMAS_APARICION, APARICION_CADA, _tiempo, -PIES_APARICION)
		Que.MUERTE:
			_fotograma(MUERTE, FOTOGRAMAS_MUERTE, MUERTE_CADA, _tiempo, CUERPO - Vector2(160.0, 160.0))
	if _tiempo_furia >= 0.0:
		_fotograma(FURIA, FOTOGRAMAS_FURIA, FURIA_CADA, _tiempo_furia, CUERPO - Vector2(160.0, 160.0))


## El fotograma que toca de una tira que se ve una vez, con su esquina ahí.
func _fotograma(hoja: Texture2D, fotogramas: int, cada: float, segundos: float, esquina: Vector2) -> void:
	var fotograma := mini(int(segundos / cada), fotogramas - 1)
	var lado := Vector2(hoja.get_width() / float(fotogramas), hoja.get_height())
	draw_texture_rect_region(hoja, Rect2(esquina, lado), Rect2(Vector2(fotograma * lado.x, 0.0), lado))
