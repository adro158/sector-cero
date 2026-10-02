extends PanelContainer

## Ficha del enemigo, como en el League of Legends: al pinchar en un enemigo
## sale arriba a la derecha con su nombre, la vida que le queda, el daño que
## hace al tocarte, su velocidad y su resistencia a tu herramienta actual. Se
## actualiza en cada fotograma y se cierra al morir el enemigo o con click
## derecho.
##
## No conoce los gestores ni los élites: recorre el grupo objetivos y les pide
## su ficha (ficha_en y ficha), igual que las armas les piden danar_en_area.
##
## Sin class_name: el HUD la carga con preload (ver embestida_horda.gd).

## Distancia, en el mundo, a la que un click todavía cuenta como encima del
## enemigo: la horda es pequeña y se mueve.
const RADIO_CLICK := 30.0

var _objetivo: Node
var _id := -1
var _arma: DatosArma
var _retrato: TextureRect
var _nombre: Label
var _barra: ProgressBar
## El relleno de la barra, del color de cada enemigo.
var _relleno := StyleBoxFlat.new()
var _vida: Label
var _datos: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	offset_left = -16.0
	offset_right = -16.0
	offset_top = 16.0
	custom_minimum_size = Vector2(300, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", EstiloInterfaz.caja(EstiloInterfaz.NEON, 12))

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	add_child(fila)
	_retrato = TextureRect.new()
	_retrato.custom_minimum_size = Vector2(56, 56)
	_retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fila.add_child(_retrato)

	var textos := VBoxContainer.new()
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(textos)
	_nombre = EstiloInterfaz.etiqueta("", 16)
	_barra = ProgressBar.new()
	_barra.custom_minimum_size = Vector2(0, 10)
	_barra.show_percentage = false
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(0.1, 0.15, 0.2)
	_barra.add_theme_stylebox_override("background", fondo)
	_barra.add_theme_stylebox_override("fill", _relleno)
	_vida =EstiloInterfaz.etiqueta("", 13)
	_datos = EstiloInterfaz.etiqueta("", 12, EstiloInterfaz.TEXTO_SUAVE)
	for hijo in [_nombre, _barra, _vida, _datos]:
		textos.add_child(hijo)
	textos.add_child(EstiloInterfaz.etiqueta("Click derecho: cerrar", 11, EstiloInterfaz.TEXTO_SUAVE))

	visible = false
	BusEventos.personaje_cambiado.connect(func(_actual, arma, _siguiente, _espera): _arma = arma)
	BusEventos.arma_evolucionada.connect(func(arma): _arma = arma)


func _unhandled_input(evento: InputEvent) -> void:
	if not evento is InputEventMouseButton or not evento.pressed:
		return
	if evento.button_index == MOUSE_BUTTON_RIGHT:
		_cerrar()
	elif evento.button_index == MOUSE_BUTTON_LEFT:
		# De la pantalla al mundo: la inversa de la transformación de la cámara.
		var punto: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * evento.position
		_elegir(punto)


func _elegir(punto: Vector2) -> void:
	var mejor := {}
	for objetivo in get_tree().get_nodes_in_group("objetivos"):
		var candidata: Dictionary = objetivo.ficha_en(punto, RADIO_CLICK)
		if not candidata.is_empty() and (mejor.is_empty() or candidata.distancia < mejor.distancia):
			mejor = candidata
			_objetivo = objetivo
	if mejor.is_empty():
		return
	_id = mejor.id
	_mostrar(mejor)
	visible = true


func _process(_delta: float) -> void:
	if not visible:
		return
	var ficha: Dictionary = _objetivo.ficha(_id) if is_instance_valid(_objetivo) else {}
	if ficha.is_empty():
		_cerrar()
	else:
		_mostrar(ficha)


func _mostrar(ficha: Dictionary) -> void:
	_retrato.texture = ficha.textura
	_nombre.text = ficha.nombre
	_nombre.add_theme_color_override("font_color", ficha.color)
	_barra.max_value = ficha.vida_maxima
	_barra.value = ficha.vida
	_relleno.bg_color = ficha.color
	_vida.text = "Vida %d / %d" % [ceili(ficha.vida), roundi(ficha.vida_maxima)]
	_datos.text = "Daño al tocarte %d · Velocidad %d\n%s" % [roundi(ficha.dano), roundi(ficha.velocidad), _texto_resistencia()]


## La resistencia del malware a la herramienta que llevas ahora: es la misma
## para todos los enemigos, pero aquí se ve sin abrir el panel técnico.
func _texto_resistencia() -> String:
	var resistencia_malware := get_tree().get_first_node_in_group("resistencia_malware")
	if _arma == null or resistencia_malware == null:
		return ""
	return "Resiste a tu %s: %d %%" % [_arma.nombre, roundi(resistencia_malware.resistencia(_arma) * 100.0)]


func _cerrar() -> void:
	visible = false
	_objetivo = null
	_id = -1
