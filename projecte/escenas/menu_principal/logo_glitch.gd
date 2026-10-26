extends TextureRect

## El logo del menú, a tamaño real, con un glitch de vez en cuando: casi todo
## el rato el fotograma 0 (el logo limpio) y, cada 2 a 5 s, los fotogramas 1,
## 2 y 3 de la tira seguidos y vuelta al 0. Es la animación mínima para que el
## menú no parezca congelado (antes el título latía).
##
## Sirve para cualquier tira de 4 fotogramas igual que la del logo: la
## pantalla final la usa con sus rótulos (lote 9), cambiando tira antes de
## añadirlo.
##
## Sin class_name: lo crean menu_principal.gd y pantalla_final.gd con preload.

## La del logo si no se dice otra.
var tira: Texture2D = preload("res://medios/interfaz/logo_sector_cero_glitch.png")
const CADA_FOTOGRAMA := 0.07
const ESPERA_MINIMA := 2.0
const ESPERA_MAXIMA := 5.0

var _atlas := AtlasTexture.new()
## Lo que mide cada fotograma: un cuarto de la tira.
var _lado := Vector2.ZERO
## Su propio azar: el de randf() es el de la partida, y el simulador lo
## necesita intacto para repetir las mismas partidas.
var _azar := RandomNumberGenerator.new()


func _ready() -> void:
	_lado = Vector2(tira.get_width() / 4.0, tira.get_height())
	_atlas.atlas = tira
	_atlas.region = Rect2(Vector2.ZERO, _lado)
	texture = _atlas
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_azar.randomize()
	_glitch()


## Espera un rato al azar, pasa los fotogramas del glitch y vuelve a empezar.
func _glitch() -> void:
	var tween := create_tween()
	tween.tween_interval(_azar.randf_range(ESPERA_MINIMA, ESPERA_MAXIMA))
	for fotograma in [1, 2, 3, 0]:
		tween.tween_callback(func() -> void: _atlas.region.position.x = _lado.x * fotograma)
		tween.tween_interval(CADA_FOTOGRAMA)
	tween.tween_callback(_glitch)
