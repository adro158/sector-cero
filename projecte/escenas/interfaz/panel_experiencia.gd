extends Control

## Nivel y experiencia, arriba a la izquierda del HUD: el marco del lote 9,
## con el número del nivel en el cuadro de la izquierda y la barra a la
## derecha, y «EXP 3 / 25» debajo. Se dibuja como la barra de los jefes
## (barra_jefe.gd): el relleno se recorta según la experiencia. La barra se
## llena poco a poco en lugar de saltar, y al subir de nivel destella en
## blanco y el número da un pequeño salto.
##
## Al subir de nivel el juego ya está en pausa cuando llega el aviso (se pausa
## para elegir la mejora), así que sus Tween siguen en pausa
## (TWEEN_PAUSE_PROCESS): si no, el destello no se vería hasta haber elegido.
##
## Sin class_name: el HUD lo carga con preload (ver embestida_horda.gd).

const MARCO := preload("res://medios/interfaz/experiencia_marco.png")
const RELLENO := preload("res://medios/interfaz/experiencia_relleno.png")
## Dónde empieza el relleno dentro del marco.
const ESQUINA_RELLENO := Vector2(30.0, 10.0)
const DURACION_LLENADO := 0.2
const DURACION_DESTELLO := 0.4
## Lo que crece el número del nivel en el salto.
const SALTO := 1.4

## Lo que se ve lleno de la barra, de 0 a 1. Lo mueve el Tween del llenado.
var lleno := 0.0:
	set(nuevo):
		lleno = nuevo
		queue_redraw()
## De 0 a 1: cuánto blanco lleva encima por el destello.
var destello := 0.0:
	set(nuevo):
		destello = nuevo
		queue_redraw()
## El tamaño del número, para el salto.
var escala_nivel := 1.0:
	set(nueva):
		escala_nivel = nueva
		queue_redraw()
var _nivel := 1
var _actual := 0
var _necesaria := 0
var _llenado: Tween


func _ready() -> void:
	position = Vector2(16, 16)
	size = Vector2(MARCO.get_width(), 48)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	BusEventos.experiencia_cambiada.connect(_al_cambiar_experiencia)


func _al_cambiar_experiencia(actual: int, necesaria: int, nivel: int) -> void:
	_actual = actual
	_necesaria = necesaria
	# Un llenado a medias se corta: el nuevo sale de donde se haya quedado.
	if _llenado != null:
		_llenado.kill()
	if nivel > _nivel:
		# Nivel nuevo: la barra empieza vacía y se llena con lo que sobró.
		lleno = 0.0
		_destellar()
	_nivel = nivel
	_llenado = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_llenado.tween_property(self, "lleno", float(actual) / maxf(necesaria, 1.0), DURACION_LLENADO)
	queue_redraw()


## La barra y el número se ponen blancos y vuelven a su color, y el número
## crece y vuelve a su tamaño.
func _destellar() -> void:
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel()
	tween.tween_property(self, "escala_nivel", 1.0, DURACION_DESTELLO).from(SALTO).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "destello", 0.0, DURACION_DESTELLO).from(1.0)


func _draw() -> void:
	var color := EstiloInterfaz.NEON.lerp(Color.WHITE, destello)
	draw_texture(MARCO, Vector2.ZERO, color)
	var ancho := RELLENO.get_width() * lleno
	draw_texture_rect_region(RELLENO, Rect2(ESQUINA_RELLENO, Vector2(ancho, RELLENO.get_height())), Rect2(0.0, 0.0, ancho, RELLENO.get_height()), color)

	var fuente := get_theme_default_font()
	# El número, centrado en el cuadro de 28x28; el salto crece desde su centro.
	var tamano := EstiloInterfaz.tamano_texto(16)
	draw_set_transform(Vector2(14.0, 14.0), 0.0, Vector2(escala_nivel, escala_nivel))
	draw_string(fuente, Vector2(-14.0, tamano * 0.35), str(_nivel), HORIZONTAL_ALIGNMENT_CENTER, 28.0, tamano, color)
	draw_set_transform(Vector2.ZERO)
	var debajo := "NIVEL %d   ·   EXP %d / %d" % [_nivel, _actual, _necesaria]
	var pequeno := EstiloInterfaz.tamano_texto(12)
	draw_string_outline(fuente, Vector2(30.0, 28.0 + pequeno + 2.0), debajo, HORIZONTAL_ALIGNMENT_LEFT, -1, pequeno, 4, Color(0.02, 0.04, 0.07))
	draw_string(fuente, Vector2(30.0, 28.0 + pequeno + 2.0), debajo, HORIZONTAL_ALIGNMENT_LEFT, -1, pequeno, EstiloInterfaz.TEXTO_SUAVE)
