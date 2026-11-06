extends Control

## El recorrido de la partida en la pantalla final: una barra de la fase 1 a
## NÚCLEO CERO con sus cuatro hitos y una marca que late donde acabó. Sale de
## donde (estadisticas.donde, raiz_juego.gd, _donde) y del tiempo: dentro de
## una fase, la marca avanza con lo que se aguantó de ella.
##
## Sin class_name: lo crea pantalla_final.gd con preload.

const CONFIG := preload("res://recursos/oleadas/datos/config_principal.tres")
## Los cuatro hitos de 16x16: fase 1, Kernel Panic, fase 2 y NÚCLEO CERO.
const HITOS := preload("res://medios/interfaz/recorrido_hitos.png")
## La barra (24x10, márgenes 5), su relleno (se estira) y la marca (2 x 12x14).
const BARRA := preload("res://medios/interfaz/recorrido_barra.png")
const RELLENO := preload("res://medios/interfaz/recorrido_relleno.png")
const MARCA := preload("res://medios/interfaz/recorrido_marca.png")
## Dónde cae cada hito, de 0 (el principio) a 1 (el sistema limpio).
const KERNEL_PANIC := 0.45
const NUCLEO_CERO := 0.9
const NOMBRES := ["FASE 1", "KERNEL PANIC", "FASE 2", "NÚCLEO CERO"]

var donde := ""
var tiempo := 0.0
var victoria := false
var _barra: StyleBoxTexture
var _segundos := 0.0


func _ready() -> void:
	# La pantalla final sale con el juego pausado: la marca late igual.
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var escala := EstiloInterfaz.tamano_texto(100) / 100.0
	custom_minimum_size = Vector2(560.0 * escala, 72.0 + 14.0 * escala)
	_barra = StyleBoxTexture.new()
	_barra.texture = BARRA
	_barra.set_texture_margin_all(5)


func _process(delta: float) -> void:
	_segundos += delta
	queue_redraw()


## De 0 a 1: dónde acabó la partida en la barra.
func avance() -> float:
	if victoria:
		return 1.0
	if donde.begins_with("contra NÚCLEO CERO"):
		return NUCLEO_CERO
	if donde == "contra Kernel Panic":
		return KERNEL_PANIC
	if donde == "en la fase 2":
		var en_fase := (tiempo - CONFIG.duracion_partida) / CONFIG.duracion_fase_2
		return lerpf(KERNEL_PANIC, NUCLEO_CERO, clampf(en_fase, 0.0, 1.0))
	return KERNEL_PANIC * clampf(tiempo / CONFIG.duracion_partida, 0.0, 1.0)


func _draw() -> void:
	var fuente := get_theme_default_font()
	var letra := EstiloInterfaz.tamano_texto(13)
	var izquierda := 16.0
	var ancho := size.x - 32.0
	# Arriba los hitos (al doble), debajo la marca y debajo la barra, con los
	# nombres.
	var y_barra := 52.0
	var color := EstiloInterfaz.VICTORIA if victoria else EstiloInterfaz.DERROTA
	var hasta := avance()

	draw_style_box(_barra, Rect2(izquierda, y_barra, ancho, 14.0))
	if hasta > 0.0:
		draw_texture_rect(RELLENO, Rect2(izquierda + 3.0, y_barra + 3.0, (ancho - 6.0) * hasta, 8.0), false, color)

	# Los hitos: las fases, en medio de su tramo; los jefes, en su sitio. Los
	# que ya se han pasado, encendidos.
	var posiciones := [KERNEL_PANIC / 2.0, KERNEL_PANIC, (KERNEL_PANIC + NUCLEO_CERO) / 2.0, NUCLEO_CERO]
	for i in 4:
		var x: float = izquierda + ancho * posiciones[i]
		var pasado: bool = hasta >= posiciones[i]
		var tinte := color if pasado else EstiloInterfaz.TEXTO_SUAVE
		draw_texture_rect_region(HITOS, Rect2(x - 16.0, 0.0, 32.0, 32.0), Rect2(i * 16.0, 0.0, 16.0, 16.0), tinte)
		draw_string(fuente, Vector2(x - 70.0, y_barra + 14.0 + letra + 4.0), NOMBRES[i], HORIZONTAL_ALIGNMENT_CENTER, 140.0, letra, tinte)

	# La marca, encima de la barra, latiendo a 0,4 s.
	var fotograma := int(_segundos / 0.4) % 2
	var x_marca := izquierda + ancho * hasta
	draw_texture_rect_region(MARCA, Rect2(x_marca - 6.0, y_barra - 16.0, 12.0, 14.0), Rect2(fotograma * 12.0, 0.0, 12.0, 14.0), color)
