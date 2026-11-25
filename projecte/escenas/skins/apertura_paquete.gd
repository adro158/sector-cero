extends Control

## La apertura de un paquete cifrado (de Alan, 25/11), encima de toda la
## pantalla (en su CanvasLayer, que pone pestana_tienda.gd). El paquete ya
## se ha abierto de verdad (Cartera.abrir_paquete()): esto solo enseña lo que
## ha tocado. Va así (tiempos del LEEME del lote):
## 1. Carga (0,64 s): el sobre tiembla y le salen grietas del color de la
##    categoría, una pista de lo que viene.
## 2. Estallido: se rompe en trozos, con una sacudida.
## 3. Revelación: los rayos girando, la carta que se descifra de arriba abajo
##    con el retrato y el nombre letra a letra (carta_revelada.gd) y chispas.
## Una C dura unos 2 s y una A unos 2,6 s. Un clic (o Enter, o Esc) salta al
## final; en el final, cierra.
##
## Sin class_name: la crea pestana_tienda.gd con preload.

signal cerrada

const Piezas := preload("res://escenas/skins/piezas_cartera.gd")
const CartaRevelada := preload("res://escenas/skins/carta_revelada.gd")
const RUTA := "res://medios/sprites/cartera/paquete/"
const LADO := Vector2(480.0, 440.0)
## El centro del sobre y de la carta dentro del escenario.
const CENTRO := Vector2(240.0, 175.0)
const CARGA := 0.64
const DESCIFRAR := 0.32
## Lo que dura la revelación después de descifrar la carta, por categoría.
const EXTRA := {"C": 0.86, "B": 1.1, "A": 1.46, "S": 1.6, "S+": 1.8}
const CHISPAS := {"C": 3, "B": 5, "A": 8, "S": 10, "S+": 14}

var _fondo: ColorRect
var _escenario: Control
var _rayos: Piezas.Animada
var _paquete: Piezas.Animada
var _grietas: Piezas.Animada
var _estallido: Piezas.Animada
var _carta: CartaRevelada
var _aviso: Label
var _tween: Tween
var _resultado: Dictionary
var _color: Color
var _tiempo := 0.0
var _acabada := false
## Cada apertura tiene su número: así las chispas de una anterior no salen.
var _vez := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fondo = ColorRect.new()
	_fondo.color = Color(0.02, 0.04, 0.07, 0.94)
	_fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fondo)
	_escenario = Control.new()
	_escenario.size = LADO
	_escenario.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fondo.add_child(_escenario)
	_rayos = _poner(Piezas.Animada.new(load(RUTA + "rayos.png"), Vector2(160, 160), 0.08, true))
	_paquete = _poner(Piezas.Animada.new(load(RUTA + "paquete_carga.png"), Vector2(64, 64), 0.08, false))
	_grietas = _poner(Piezas.Animada.new(load(RUTA + "paquete_carga_grietas.png"), Vector2(64, 64), 0.08, false))
	_estallido = _poner(Piezas.Animada.new(load(RUTA + "paquete_estallido.png"), Vector2(128, 128), 0.06, false))
	_carta = CartaRevelada.new()
	_carta.position = CENTRO - CartaRevelada.LADO / 2.0
	_escenario.add_child(_carta)
	_aviso = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.position = Vector2(0.0, LADO.y - 24.0)
	_aviso.size = Vector2(LADO.x, 24.0)
	_escenario.add_child(_aviso)
	visible = false


## Enseña lo que ha tocado: {personaje, numero, categoria, nueva, devueltos}.
func empezar(resultado: Dictionary) -> void:
	_vez += 1
	_resultado = resultado
	_color = Piezas.CATEGORIAS.get(resultado.categoria, Color.WHITE)
	_carta.preparar(resultado, _color)
	_rayos.self_modulate = _color
	_grietas.self_modulate = _color
	_rayos.modulate.a = 0.0
	_grietas.modulate.a = 0.0
	_rayos.visible = false
	_estallido.visible = false
	_carta.visible = false
	_paquete.visible = true
	_grietas.visible = true
	_paquete.empezar()
	_grietas.empezar()
	_aviso.text = "Pulsa para saltar"
	_tiempo = 0.0
	_acabada = false
	visible = true
	# Las grietas, desde el fotograma 5 de la carga (0,32 s).
	_tween = create_tween()
	_tween.tween_interval(0.32)
	_tween.tween_property(_grietas, "modulate:a", 1.0, 0.24)
	_tween.tween_interval(CARGA - 0.56)
	_tween.tween_callback(_estallar)
	_tween.tween_interval(0.18)
	_tween.tween_callback(_revelar)
	for paso in range(1, 5):
		_tween.tween_interval(DESCIFRAR / 4.0)
		_tween.tween_callback(_carta.descifrar.bind(paso))
	_tween.tween_callback(_carta.descifrar_nombre.bind(EXTRA.get(resultado.categoria, 1.0) * 0.6))
	_tween.tween_interval(EXTRA.get(resultado.categoria, 1.0))
	_tween.tween_callback(_terminar)


func _estallar() -> void:
	_paquete.visible = false
	_grietas.visible = false
	_estallido.visible = true
	_estallido.empezar()


func _revelar() -> void:
	_rayos.visible = true
	_rayos.empezar()
	create_tween().tween_property(_rayos, "modulate:a", 1.0, 0.25)
	_carta.visible = true
	var grande: bool = _resultado.categoria in ["A", "S", "S+"]
	var hoja: Texture2D = load(RUTA + ("chispa_grande.png" if grande else "chispa_pequena.png"))
	for i in CHISPAS.get(_resultado.categoria, 3):
		get_tree().create_timer(randf_range(0.1, 0.9)).timeout.connect(_chispa.bind(hoja, grande, _vez))


## El final: todo en su sitio, también si se ha saltado.
func _terminar() -> void:
	if _tween != null:
		_tween.kill()
	_acabada = true
	_paquete.visible = false
	_grietas.visible = false
	_estallido.visible = false
	if not _rayos.visible:
		_rayos.visible = true
		_rayos.empezar()
	_rayos.modulate.a = 1.0
	_carta.visible = true
	_carta.terminar()
	_aviso.text = "Pulsa para seguir"


## Una chispa alrededor de la carta, por fuera de su borde, teñida.
func _chispa(hoja: Texture2D, grande: bool, vez: int) -> void:
	if vez != _vez or not visible:
		return
	var chispa := Piezas.Animada.new(hoja, Vector2(16, 16) if grande else Vector2(8, 8), 0.07, false)
	chispa.self_modulate = _color
	var angulo := randf() * TAU
	chispa.position = CENTRO + Vector2(cos(angulo) * 120.0, sin(angulo) * 150.0) - chispa.size / 2.0
	chispa.acabada.connect(chispa.queue_free)
	_escenario.add_child(chispa)


func _process(delta: float) -> void:
	if not visible:
		return
	_tiempo += delta
	# El temblor: 1-3 px al final de la carga y 4 px al estallar.
	var sacudida := 0.0
	if _paquete.visible and _tiempo > CARGA * 0.5:
		sacudida = lerpf(1.0, 3.0, (_tiempo - CARGA * 0.5) / (CARGA * 0.5))
	elif _estallido.visible and _estallido.cuadro() < 3:
		sacudida = 4.0
	var temblor := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * roundf(sacudida)
	_escenario.position = ((_fondo.size - LADO) / 2.0).round() + temblor.round()


func _input(evento: InputEvent) -> void:
	if not visible:
		return
	var pulsado: bool = (evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT) \
		or evento.is_action_pressed("ui_accept") or evento.is_action_pressed("ui_cancel")
	if not pulsado:
		return
	get_viewport().set_input_as_handled()
	if _acabada:
		visible = false
		cerrada.emit()
	else:
		_terminar()


func _poner(animada: Piezas.Animada) -> Piezas.Animada:
	animada.position = CENTRO - animada.custom_minimum_size / 2.0
	animada.visible = false
	_escenario.add_child(animada)
	return animada
