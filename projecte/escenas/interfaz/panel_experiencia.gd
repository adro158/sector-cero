extends PanelContainer

## Nivel y experiencia, arriba a la izquierda del HUD. La barra se llena poco a
## poco en lugar de saltar, y al subir de nivel destellan la barra y la
## etiqueta del nivel, que además da un pequeño salto.
##
## Al subir de nivel el juego ya está en pausa cuando llega el aviso (se pausa
## para elegir la mejora), así que sus Tween siguen en pausa
## (TWEEN_PAUSE_PROCESS): si no, el destello no se vería hasta haber elegido.
##
## Sin class_name: el HUD lo carga con preload (ver embestida_horda.gd).

const DURACION_LLENADO := 0.2
const DURACION_DESTELLO := 0.4
## Lo que crece la etiqueta del nivel en el salto.
const SALTO := 1.3

var _etiqueta_nivel: Label
var _barra: ProgressBar
## El relleno de la barra: es lo que se pone blanco al destellar.
var _relleno := StyleBoxFlat.new()
var _etiqueta_experiencia: Label
var _nivel := 1
var _llenado: Tween


func _ready() -> void:
	position = Vector2(16, 16)
	add_theme_stylebox_override("panel", EstiloInterfaz.caja(EstiloInterfaz.NEON, 10))
	var caja := VBoxContainer.new()
	add_child(caja)
	_etiqueta_nivel = EstiloInterfaz.etiqueta("NIVEL 1", 20, EstiloInterfaz.NEON)
	caja.add_child(_etiqueta_nivel)

	_barra = ProgressBar.new()
	_barra.custom_minimum_size = Vector2(240, 10)
	_barra.show_percentage = false
	# Sin escalones: con los de un punto, el llenado iría a saltos.
	_barra.step = 0.0
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(0.1, 0.15, 0.2)
	_relleno.bg_color = EstiloInterfaz.NEON
	_barra.add_theme_stylebox_override("background", fondo)
	_barra.add_theme_stylebox_override("fill", _relleno)
	caja.add_child(_barra)

	_etiqueta_experiencia = EstiloInterfaz.etiqueta("EXP 0 / 0", 12, EstiloInterfaz.TEXTO_SUAVE)
	caja.add_child(_etiqueta_experiencia)
	BusEventos.experiencia_cambiada.connect(_al_cambiar_experiencia)


func _al_cambiar_experiencia(actual: int, necesaria: int, nivel: int) -> void:
	_etiqueta_nivel.text = "NIVEL %d" % nivel
	_etiqueta_experiencia.text = "EXP %d / %d" % [actual, necesaria]
	# Un llenado a medias se corta: el nuevo sale de donde se haya quedado.
	if _llenado != null:
		_llenado.kill()
	if nivel > _nivel:
		# Nivel nuevo: la barra empieza vacía y se llena con lo que sobró.
		_barra.value = 0.0
		_destellar()
	_nivel = nivel
	_barra.max_value = necesaria
	_llenado = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_llenado.tween_property(_barra, "value", float(actual), DURACION_LLENADO)


## La barra y la etiqueta se ponen blancas y vuelven a su color, y la etiqueta
## crece y vuelve a su tamaño desde su borde izquierdo, para no salirse del
## panel.
func _destellar() -> void:
	_etiqueta_nivel.pivot_offset = Vector2(0.0, _etiqueta_nivel.size.y / 2.0)
	_etiqueta_nivel.scale = Vector2(SALTO, SALTO)
	_etiqueta_nivel.add_theme_color_override("font_color", Color.WHITE)
	_relleno.bg_color = Color.WHITE
	var destello := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel()
	destello.tween_property(_etiqueta_nivel, "scale", Vector2.ONE, DURACION_DESTELLO) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	destello.tween_property(_etiqueta_nivel, "theme_override_colors/font_color", EstiloInterfaz.NEON, DURACION_DESTELLO)
	destello.tween_property(_relleno, "bg_color", EstiloInterfaz.NEON, DURACION_DESTELLO)
