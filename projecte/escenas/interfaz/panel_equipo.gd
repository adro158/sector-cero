extends Control

## El panel del equipo, a la derecha, al pulsar C: una ficha pequeña de cada
## personaje con su vida, su herramienta, la resistencia del malware contra
## ella, la carga de su ulti y si está jugando, listo o caído. Lo de abajo en
## el centro (quién juega, a quién se pasa y cuándo) lo lleva barra_equipo.gd;
## hasta el 26/10 era una línea de texto de este script.
##
## Solo escucha el bus: equipo_cambiado trae la vida de todos.

const ANCHO_FICHA := 210.0

var _estado: Array = []
var _activo := 0
## Carga de la ulti de cada personaje, de 0 a 1.
var _ultis: Array = []
var _panel: PanelContainer
var _fichas: Array = []
var _resistencia: Node


func _ready() -> void:
	# También en pausa: al caer un personaje, el panel tiene que enseñarlo caído
	# mientras se elige quién sigue.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

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
	# C o Select (la acción la añade teclas_antiguas.gd al empezar la partida).
	if evento.is_action_pressed("ver_equipo"):
		_panel.visible = not _panel.visible


func _process(_delta: float) -> void:
	if _estado.is_empty():
		return
	if _panel.visible:
		for i in _fichas.size():
			_escribir_ficha(_fichas[i], i)


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


func _ulti(indice: int) -> float:
	return _ultis[indice] if indice < _ultis.size() else 0.0
