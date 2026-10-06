extends Control

## El equipo en el HUD. Abajo en el centro, siempre: el personaje activo, su
## herramienta y a quién se pasa con Q y con E (o cuánto falta para poder
## cambiar). A la derecha, al pulsar C: una ficha pequeña de cada personaje
## con su vida, su herramienta, la resistencia del malware contra ella y si
## está jugando, listo o caído.
##
## Solo escucha el bus: equipo_cambiado trae la vida de todos y
## personaje_cambiado la espera hasta el siguiente cambio.

const ANCHO_FICHA := 210.0

var _estado: Array = []
var _activo := 0
var _espera := 0.0
var _linea: Label
var _panel: PanelContainer
var _fichas: Array = []
var _resistencia: Node


func _ready() -> void:
	# También en pausa: al caer un personaje, el panel tiene que enseñarlo caído
	# mientras se elige quién sigue.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_linea = EstiloInterfaz.etiqueta("", 16)
	_linea.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_linea.offset_left = -400.0
	_linea.offset_right = 400.0
	_linea.offset_top = -44.0
	_linea.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_linea)

	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(Color(EstiloInterfaz.NEON, 0.5), 10))
	# A la derecha y a media altura: arriba está la ficha del enemigo y abajo
	# el panel técnico (F3).
	_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_panel.offset_right = -16.0
	_panel.visible = false
	add_child(_panel)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 8)
	_panel.add_child(caja)
	caja.add_child(EstiloInterfaz.etiqueta("EQUIPO  [C]", 12, EstiloInterfaz.TEXTO_SUAVE))
	for i in 3:
		var ficha := _crear_ficha()
		caja.add_child(ficha)
		_fichas.append(ficha)

	_resistencia = get_tree().get_first_node_in_group("resistencia_malware")
	BusEventos.equipo_cambiado.connect(_al_cambiar_equipo)
	BusEventos.personaje_cambiado.connect(func(_actual, _arma, _siguiente, espera): _espera = espera)


## Una ficha: nombre y estado, barra de vida y una línea de datos.
func _crear_ficha() -> VBoxContainer:
	var ficha := VBoxContainer.new()
	ficha.add_theme_constant_override("separation", 2)
	ficha.custom_minimum_size.x = ANCHO_FICHA
	ficha.add_child(EstiloInterfaz.etiqueta("", 13))
	var barra := ProgressBar.new()
	barra.custom_minimum_size = Vector2(ANCHO_FICHA, 6)
	barra.show_percentage = false
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(0.1, 0.15, 0.2)
	barra.add_theme_stylebox_override("background", fondo)
	barra.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	ficha.add_child(barra)
	ficha.add_child(EstiloInterfaz.etiqueta("", 11, EstiloInterfaz.TEXTO_SUAVE))
	return ficha


func _al_cambiar_equipo(personajes: Array, activo: int) -> void:
	_estado = personajes
	_activo = activo


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo and evento.physical_keycode == KEY_C:
		_panel.visible = not _panel.visible


func _process(delta: float) -> void:
	if _estado.is_empty():
		return
	# Cuenta atrás propia: se sabe cuánto faltaba al cambiar, y no avanza en
	# pausa, como el juego.
	if not get_tree().paused:
		_espera = maxf(_espera - delta, 0.0)
	_escribir_linea()
	if _panel.visible:
		for i in _fichas.size():
			_escribir_ficha(_fichas[i], i)


func _escribir_linea() -> void:
	var actual: Dictionary = _estado[_activo]
	var anterior := _vivo_desde(-1)
	var siguiente := _vivo_desde(1)
	var cambio := ""
	if siguiente == _activo:
		cambio = "último en pie"
	elif _espera > 0.0:
		cambio = "cambio en %d s" % ceili(_espera)
	else:
		cambio = "[Q] %s  ·  %s [E]" % [_nombre(anterior), _nombre(siguiente)]
	_linea.text = "%s · %s      %s      [C] equipo" % [actual.personaje.nombre.to_upper(), actual.arma.nombre, cambio]
	_linea.add_theme_color_override("font_color", actual.personaje.color)


func _escribir_ficha(ficha: VBoxContainer, i: int) -> void:
	var datos: Dictionary = _estado[i]
	var personaje: DatosPersonaje = datos.personaje
	var estado := "CAÍDO" if datos.caido else ("ACTIVO" if i == _activo else "LISTO")
	var titulo: Label = ficha.get_child(0)
	titulo.text = "%s  %s" % [personaje.nombre.to_upper(), estado]
	titulo.add_theme_color_override("font_color", EstiloInterfaz.TEXTO_SUAVE if datos.caido else personaje.color)

	var barra: ProgressBar = ficha.get_child(1)
	barra.max_value = datos.maxima
	barra.value = datos.vida
	# Verde con vida, rojo con poca: como la barra sobre el personaje.
	(barra.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(1.0, 0.3, 0.3).lerp(Color(0.3, 1.0, 0.5), datos.vida / datos.maxima)

	# La resistencia se lee del nodo del malware, como el panel técnico: cambia
	# cada 20 s y no tiene señal en el bus.
	var resistencia: float = 0.0 if _resistencia == null else _resistencia.resistencia(datos.arma)
	ficha.get_child(2).text = "%d / %d · %s · resiste %d %%" % [ceili(datos.vida), datos.maxima, datos.arma.nombre, roundi(resistencia * 100.0)]


## El primer personaje vivo desde el activo, en el sentido del paso.
func _vivo_desde(paso: int) -> int:
	for salto in range(1, _estado.size()):
		var otro := posmod(_activo + paso * salto, _estado.size())
		if not _estado[otro].caido:
			return otro
	return _activo


func _nombre(indice: int) -> String:
	return _estado[indice].personaje.nombre
