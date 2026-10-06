extends Control

## Ventana que sale cuando cae el personaje activo y quedan otros: se elige
## quién sigue con click o con el número de su tecla (1, 2 o 3, su puesto en
## el equipo). Avisa con personaje_elegido; la pausa la pone y la quita la
## jugabilidad, como en el panel de mejoras.

var _ventana: ColorRect
var _titulo: Label
var _botones: Array[Button] = []


func _ready() -> void:
	# Se usa precisamente con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 12)
	_titulo = EstiloInterfaz.etiqueta("", 32, EstiloInterfaz.DERROTA)
	var ayuda := EstiloInterfaz.etiqueta("Elige quién sigue: click o su tecla", 14, EstiloInterfaz.TEXTO_SUAVE)
	for etiqueta in [_titulo, ayuda]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)
	for i in 3:
		var boton := EstiloInterfaz.boton("", _elegir.bind(i), 420)
		caja.add_child(boton)
		_botones.append(boton)

	_ventana = EstiloInterfaz.ventana_centrada(caja, EstiloInterfaz.DERROTA)
	_ventana.visible = false
	add_child(_ventana)
	BusEventos.personaje_caido.connect(_al_caer)


func _al_caer(personajes: Array, caido: int) -> void:
	_titulo.text = "%s HA CAÍDO" % personajes[caido].personaje.nombre.to_upper()
	var primero: Button = null
	for i in _botones.size():
		var boton := _botones[i]
		# Solo los que siguen en pie.
		boton.visible = i < personajes.size() and not personajes[i].caido
		if not boton.visible:
			continue
		var datos: Dictionary = personajes[i]
		boton.text = "[%d]  %s  ·  %d / %d de vida  ·  %s" % [i + 1, datos.personaje.nombre.to_upper(), ceili(datos.vida), datos.maxima, datos.arma.nombre]
		if primero == null:
			primero = boton
	_ventana.visible = true
	primero.grab_focus()


func _unhandled_input(evento: InputEvent) -> void:
	if not _ventana.visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode in [KEY_1, KEY_2, KEY_3]:
		get_viewport().set_input_as_handled()
		_elegir(evento.keycode - KEY_1)


func _elegir(indice: int) -> void:
	if indice >= _botones.size() or not _botones[indice].visible:
		return
	_ventana.visible = false
	BusEventos.personaje_elegido.emit(indice)
