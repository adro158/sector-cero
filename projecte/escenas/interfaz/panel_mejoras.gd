extends Control

## Panel de subida de nivel: tres tarjetas con icono, nombre, nivel y
## descripción. Se elige con click o con las teclas 1, 2 y 3.
##
## La pausa la pone y la quita la jugabilidad: el panel solo muestra las
## opciones y avisa de la elegida con mejora_seleccionada.

## Veces que se ha elegido cada mejora. Lo comparte el HUD para su columna.
var niveles := {}

var _opciones: Array = []
var _tarjetas: Array[Button] = []
var _ventana: ColorRect


func _ready() -> void:
	# Se usa precisamente con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("SUBIDA DE NIVEL", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)
	var ayuda := EstiloInterfaz.etiqueta("Elige una mejora: click o teclas 1, 2 y 3", 14, EstiloInterfaz.TEXTO_SUAVE)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(ayuda)

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 16)
	caja.add_child(fila)
	for i in 3:
		var tarjeta := _crear_tarjeta(i)
		fila.add_child(tarjeta)
		_tarjetas.append(tarjeta)

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	_ventana.visible = false
	add_child(_ventana)
	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)


func _crear_tarjeta(indice: int) -> Button:
	var tarjeta := Button.new()
	tarjeta.custom_minimum_size = Vector2(230, 260)
	tarjeta.pressed.connect(_elegir.bind(indice))

	var contenido := VBoxContainer.new()
	contenido.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 14)
	contenido.alignment = BoxContainer.ALIGNMENT_CENTER
	contenido.add_theme_constant_override("separation", 8)
	# Los hijos no se quedan los clicks: así llegan al botón.
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tarjeta.add_child(contenido)

	var tecla := EstiloInterfaz.etiqueta("[%d]" % (indice + 1), 14, EstiloInterfaz.TEXTO_SUAVE)
	var icono := TextureRect.new()
	icono.custom_minimum_size = Vector2(64, 64)
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var nombre := EstiloInterfaz.etiqueta("", 18, EstiloInterfaz.NEON)
	var nivel := EstiloInterfaz.etiqueta("", 13, EstiloInterfaz.VICTORIA)
	var descripcion := EstiloInterfaz.etiqueta("", 14)
	descripcion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	for hijo in [tecla, icono, nombre, nivel, descripcion]:
		hijo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if hijo is Label:
			hijo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		contenido.add_child(hijo)
	return tarjeta


func _al_subir_nivel(opciones: Array) -> void:
	_opciones = opciones
	for i in _tarjetas.size():
		var tarjeta := _tarjetas[i]
		tarjeta.visible = i < opciones.size()
		if i >= opciones.size():
			continue

		var mejora: DatosMejora = opciones[i]
		var contenido := tarjeta.get_child(0)
		contenido.get_child(1).texture = mejora.icono
		contenido.get_child(2).text = mejora.nombre
		contenido.get_child(3).text = texto_nivel(mejora, niveles)
		contenido.get_child(4).text = mejora.descripcion

	_ventana.visible = true
	# Con el foco en la primera tarjeta también se puede elegir con el mando.
	_tarjetas[0].grab_focus()


## "NUEVA", "NIVEL 1 → 2" o "EVOLUCIÓN". Estática porque la usa también la
## ruleta del cofre, con el mismo diccionario de niveles.
static func texto_nivel(mejora: DatosMejora, niveles: Dictionary) -> String:
	if mejora.efecto == DatosMejora.Efecto.EVOLUCIONAR_ARMA:
		return "EVOLUCIÓN"
	var actual: int = niveles.get(mejora, 0)
	if actual == 0:
		return "NUEVA"
	return "NIVEL %d → %d" % [actual, actual + 1]


func _unhandled_input(evento: InputEvent) -> void:
	if not _ventana.visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode in [KEY_1, KEY_2, KEY_3]:
		_elegir(evento.keycode - KEY_1)
		get_viewport().set_input_as_handled()


func _elegir(indice: int) -> void:
	if indice >= _opciones.size():
		return

	# Se anota el nivel y se cierra antes de avisar: si quedan niveles
	# pendientes, la respuesta a la señal vuelve a abrir el panel con las
	# opciones del siguiente, y tiene que ver ya el nivel actualizado.
	var mejora: DatosMejora = _opciones[indice]
	niveles[mejora] = niveles.get(mejora, 0) + 1
	_opciones = []
	_ventana.visible = false
	BusEventos.mejora_seleccionada.emit(mejora)
