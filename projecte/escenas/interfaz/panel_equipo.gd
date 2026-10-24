extends Control

## El equipo en el HUD. Abajo en el centro, siempre: el personaje activo, su
## herramienta y a quién se pasa con Q y con E (o cuánto falta para poder
## cambiar). A la derecha, al pulsar C: una ficha pequeña de cada personaje
## con su vida, su herramienta, la resistencia del malware contra ella, la
## carga de su ulti y si está jugando, listo o caído.
##
## Solo escucha el bus: equipo_cambiado trae la vida de todos y
## personaje_cambiado la espera hasta el siguiente cambio.

const ANCHO_FICHA := 210.0

var _estado: Array = []
var _activo := 0
var _espera := 0.0
## Carga de la ulti de cada personaje, de 0 a 1.
var _ultis: Array = []
var _linea: Label
var _panel: PanelContainer
var _fichas: Array = []
var _resistencia: Node
## Con el escudo de NÚCLEO CERO puesto, los personajes con anclas sin romper.
var _anclas: Array = []


func _ready() -> void:
	# También en pausa: al caer un personaje, el panel tiene que enseñarlo caído
	# mientras se elige quién sigue.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_linea = EstiloInterfaz.etiqueta("", 16)
	_linea.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_linea.offset_left = -620.0
	_linea.offset_right = 620.0
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
		# Cada ficha va con el retrato del personaje a su izquierda.
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 8)
		var retrato := TextureRect.new()
		retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		retrato.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		fila.add_child(retrato)
		var ficha := _crear_ficha()
		ficha.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fila.add_child(ficha)
		caja.add_child(fila)
		_fichas.append(ficha)

	_resistencia = get_tree().get_first_node_in_group("resistencia_malware")
	BusEventos.equipo_cambiado.connect(_al_cambiar_equipo)
	BusEventos.ulti_cambiada.connect(func(cargas, _activo): _ultis = cargas)
	BusEventos.personaje_cambiado.connect(func(_actual, _arma, _siguiente, espera): _espera = espera)
	BusEventos.anclas_pendientes.connect(func(personajes): _anclas = personajes)


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
	# Con el escudo de NÚCLEO CERO, de quién son las anclas que quedan: así se
	# sabe a quién cambiar sin fiarse solo del color.
	if not _anclas.is_empty():
		var nombres := PackedStringArray()
		for personaje in _anclas:
			nombres.append(personaje.nombre.to_upper())
		cambio = "ANCLAS: %s   %s" % [", ".join(nombres), cambio]
	var ulti := "      [R] ¡ULTI!" if _ulti(_activo) >= 1.0 else ""
	# Lo que resiste el malware a su herramienta, en cuanto pasa de cero: es lo
	# que dice cuándo conviene cambiar.
	var resiste := ""
	var resistencia: float = 0.0 if _resistencia == null else _resistencia.resistencia(actual.arma)
	if resistencia > 0.0:
		resiste = " (resiste %d %%)" % roundi(resistencia * 100.0)
	# Con el escudo, sin «[C] equipo»: si no, no cabe.
	var equipo := "" if not _anclas.is_empty() else "      [C] equipo"
	_linea.text = "%s · %s%s      %s%s%s" % [actual.personaje.nombre.to_upper(), actual.arma.nombre, resiste, cambio, ulti, equipo]
	_linea.add_theme_color_override("font_color", actual.personaje.color)


func _escribir_ficha(ficha: VBoxContainer, i: int) -> void:
	var datos: Dictionary = _estado[i]
	var personaje: DatosPersonaje = datos.personaje
	var estado := "CAÍDO" if datos.caido else ("ACTIVO" if i == _activo else "LISTO")
	var retrato: TextureRect = ficha.get_parent().get_child(0)
	retrato.texture = personaje.retrato
	# Caído, en gris y apagado.
	retrato.modulate = Color(0.45, 0.45, 0.45) if datos.caido else Color.WHITE
	var titulo: Label = ficha.get_child(0)
	var ulti := "ULTI LISTA" if _ulti(i) >= 1.0 else "ulti %d %%" % roundi(_ulti(i) * 100.0)
	titulo.text = "%s  %s  ·  %s" % [personaje.nombre.to_upper(), estado, ulti]
	titulo.add_theme_color_override("font_color", EstiloInterfaz.TEXTO_SUAVE if datos.caido else personaje.color)

	var barra: ProgressBar = ficha.get_child(1)
	barra.max_value = datos.maxima
	barra.value = datos.vida
	# Verde con vida, rojo con poca: como la barra sobre el personaje.
	(barra.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(1.0, 0.3, 0.3).lerp(Color(0.3, 1.0, 0.5), datos.vida / datos.maxima)

	# La resistencia se lee del nodo del malware, como el panel técnico: cambia
	# cada 20 s y no tiene señal en el bus.
	var resistencia: float = 0.0 if _resistencia == null else _resistencia.resistencia(datos.arma)
	ficha.get_child(2).text = "%d / %d · %s · resiste %d %%" % [ceili(datos.vida), ceili(datos.maxima),datos.arma.nombre, roundi(resistencia * 100.0)]


## El primer personaje vivo desde el activo, en el sentido del paso.
func _vivo_desde(paso: int) -> int:
	for salto in range(1, _estado.size()):
		var otro := posmod(_activo + paso * salto, _estado.size())
		if not _estado[otro].caido:
			return otro
	return _activo


func _ulti(indice: int) -> float:
	return _ultis[indice] if indice < _ultis.size() else 0.0


func _nombre(indice: int) -> String:
	return _estado[indice].personaje.nombre
