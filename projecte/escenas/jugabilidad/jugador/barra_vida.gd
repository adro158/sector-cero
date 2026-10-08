extends Node2D

## Barra de vida sobre la cabeza del personaje. Pasa de verde a rojo según baja
## la vida, para que se lea de un vistazo sin mirar a una esquina de la pantalla.
## Debajo, más fina, la carga de su ulti: cuando está llena parpadea y avisa de
## que se lanza con R.

@export var ancho: float = 40.0
@export var alto: float = 5.0

const COLOR_ULTI := Color(1.0, 0.8, 0.2)

var _proporcion := 1.0
var _ulti := 0.0
var _tiempo := 0.0


func _ready() -> void:
	get_parent().get_node("Salud").vida_cambiada.connect(_al_cambiar_vida)
	BusEventos.ulti_cambiada.connect(_al_cambiar_ulti)


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	_proporcion = clampf(actual / maxima, 0.0, 1.0)
	queue_redraw()


func _al_cambiar_ulti(cargas: Array, activo: int) -> void:
	_ulti = cargas[activo]
	queue_redraw()


func _process(delta: float) -> void:
	# Solo hace falta redibujar sin parar para el parpadeo de la ulti llena.
	if _ulti >= 1.0:
		_tiempo += delta
		queue_redraw()


func _draw() -> void:
	var zona := Rect2(Vector2(-ancho * 0.5, 0.0), Vector2(ancho, alto))
	draw_rect(zona.grow(1.0), Color(0.0, 0.0, 0.0, 0.8))
	var color := Color(1.0, 0.25, 0.3).lerp(Color(0.3, 1.0, 0.5), _proporcion)
	draw_rect(Rect2(zona.position, Vector2(ancho * _proporcion, alto)), color)

	var ulti := Rect2(Vector2(-ancho * 0.5, alto + 2.0), Vector2(ancho, 3.0))
	draw_rect(ulti.grow(1.0), Color(0.0, 0.0, 0.0, 0.8))
	var brillo := 1.0 if _ulti < 1.0 else 0.6 + 0.4 * sin(_tiempo * 10.0)
	draw_rect(Rect2(ulti.position, Vector2(ancho * _ulti, 3.0)), Color(COLOR_ULTI, brillo))
	if _ulti >= 1.0:
		draw_string(ThemeDB.fallback_font, Vector2(ancho * 0.5 + 4.0, alto + 6.0), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(COLOR_ULTI, brillo))
