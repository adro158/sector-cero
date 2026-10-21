extends Node2D

## El pisotón del jefe del minuto 10: un aviso (un anillo rojo que se cierra)
## y, al acabar, el golpe contra el suelo y la jaula, un muro de datos alrededor
## de donde pisó. Mientras está cerrada nadie cruza el muro: el jugador y el
## jefe que están dentro no salen, y la horda que está fuera no entra. Después
## se rompe.
##
## Cuándo pisa lo decide el jefe (jefe.gd), que llama a empezar(). Aquí se
## llevan el tiempo, el dibujo y el muro. La horda pregunta con mantener().
##
## Va en RaizJuego después de Explosiones y antes del Jugador: así queda encima
## del suelo y debajo del jugador y de la horda (con z_index negativo quedaría
## debajo del suelo y no se vería). Está en el grupo jaula_jefe.
##
## Sin class_name: es un script de una escena, no hace falta que sea global.

const AVISO := preload("res://medios/sprites/jefe/jefe_jaula_aviso.png")
const ONDA := preload("res://medios/sprites/jefe/jefe_pisoton_onda.png")
const JAULA := preload("res://medios/sprites/jefe/jefe_jaula.png")
const ROTURA := preload("res://medios/sprites/jefe/jefe_jaula_rotura.png")
## Todas las tiras son de fotogramas de 384x384, con el centro en el medio.
const LADO := 384.0

const DURA_AVISO := 0.8
const FOTOGRAMAS_AVISO := 6
const ONDA_CADA := 0.06
const FOTOGRAMAS_ONDA := 6
const JAULA_CADA := 0.12
const FOTOGRAMAS_JAULA := 4
const ROTURA_CADA := 0.08
const FOTOGRAMAS_ROTURA := 5
## Lo que está cerrada la jaula.
const DURA_JAULA := 4.0

## El muro, como está en el dibujo: de 174 a 186 px del centro.
const RADIO_DENTRO := 174.0
const RADIO_FUERA := 186.0
## Lo que se suma por el tamaño del jugador: choca con el borde de su cuerpo.
const RADIO_JUGADOR := 12.0

enum Fase { NADA, AVISO, CERRADA, ROTURA }

var _fase := Fase.NADA
var _tiempo := 0.0
## Dónde pisó: la jaula no se mueve con el jefe.
var _centro := Vector2.ZERO
var _jugador: Node2D


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	# Después del jugador: así se le devuelve dentro en el mismo fotograma en el
	# que intenta salir, y no se le ve un instante metido en el muro.
	process_physics_priority = 1


func empezar(centro: Vector2) -> void:
	_centro = centro
	_cambiar_fase(Fase.AVISO)


## Para cuando muere el jefe: todo desaparece de golpe.
func terminar() -> void:
	_cambiar_fase(Fase.NADA)


func avisando() -> bool:
	return _fase == Fase.AVISO


## Si hay algo de la jaula en pantalla: mientras, el jefe no vuelve a pisar.
func activa() -> bool:
	return _fase != Fase.NADA


func cerrada() -> bool:
	return _fase == Fase.CERRADA


## Devuelve dónde se queda algo de ese radio que quiere ir a posicion, sin
## cruzar el muro. El muro tiene grosor: lo que está más cerca del centro que
## de fuera está dentro y no puede salir, y lo demás está fuera y no puede
## entrar. Nada se mueve tan deprisa como para cruzarlo en un solo fotograma.
func mantener(posicion: Vector2, radio_cuerpo: float) -> Vector2:
	if _fase != Fase.CERRADA:
		return posicion
	var desde_centro := posicion - _centro
	var limite_dentro := RADIO_DENTRO - radio_cuerpo
	var limite_fuera := RADIO_FUERA + radio_cuerpo
	var distancia := desde_centro.length()
	if distancia < (limite_dentro + limite_fuera) / 2.0:
		return _centro + desde_centro.limit_length(limite_dentro)
	if distancia < limite_fuera:
		return _centro + desde_centro.normalized() * limite_fuera
	return posicion


## Con el juego en pausa no se llama: la jaula se queda como está y sigue al
## reanudar.
func _physics_process(delta: float) -> void:
	if _fase == Fase.NADA:
		return

	_tiempo += delta
	match _fase:
		Fase.AVISO:
			if _tiempo >= DURA_AVISO:
				_cambiar_fase(Fase.CERRADA)
				BusEventos.jefe_ataco.emit("pisoton")
		Fase.CERRADA:
			_jugador.global_position = mantener(_jugador.global_position, RADIO_JUGADOR)
			if _tiempo >= DURA_JAULA:
				_cambiar_fase(Fase.ROTURA)
		Fase.ROTURA:
			if _tiempo >= ROTURA_CADA * FOTOGRAMAS_ROTURA:
				_cambiar_fase(Fase.NADA)
	queue_redraw()


func _cambiar_fase(nueva: Fase) -> void:
	_fase = nueva
	_tiempo = 0.0
	queue_redraw()


func _draw() -> void:
	match _fase:
		Fase.AVISO:
			# Una vez: el último fotograma, el anillo ya cerrado, justo antes del golpe.
			_tira(AVISO, mini(int(_tiempo / (DURA_AVISO / FOTOGRAMAS_AVISO)), FOTOGRAMAS_AVISO - 1))
		Fase.CERRADA:
			_tira(JAULA, int(_tiempo / JAULA_CADA) % FOTOGRAMAS_JAULA)
			# La onda del golpe sale a la vez que la jaula, por encima.
			var fotograma_onda := int(_tiempo / ONDA_CADA)
			if fotograma_onda < FOTOGRAMAS_ONDA:
				_tira(ONDA, fotograma_onda)
		Fase.ROTURA:
			_tira(ROTURA, mini(int(_tiempo / ROTURA_CADA), FOTOGRAMAS_ROTURA - 1))


## Dibuja un fotograma de una tira con su centro en el del pisotón.
func _tira(textura: Texture2D, fotograma: int) -> void:
	var lado := Vector2(LADO, LADO)
	draw_texture_rect_region(textura, Rect2(to_local(_centro) - lado / 2.0, lado), Rect2(Vector2(fotograma * LADO, 0.0), lado))
