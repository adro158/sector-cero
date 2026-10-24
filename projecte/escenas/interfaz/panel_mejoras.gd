extends Control

## Panel de subida de nivel: tres tarjetas con icono, nombre, nivel y
## descripción. Se elige con click o con las teclas 1, 2 y 3. La tarjeta de una
## evolución es de su personaje: de su color, con él dibujado con el arma nueva
## y con el borde latiendo, para que se note que no es una mejora más.
##
## La pausa la pone y la quita la jugabilidad: el panel solo muestra las
## opciones y avisa de la elegida con mejora_seleccionada.

const TarjetaEvolucion := preload("res://escenas/interfaz/tarjeta_evolucion.gd")
## Al abrirse, las tarjetas entran una detrás de otra y durante este rato no
## se puede elegir: en partida se hace click a menudo (la ficha del enemigo, la
## ulti del Mago) y un click justo al subir elegía una tarjeta sin leerla
## (mejoras propuestas, interfaz 9).
const ESPERA_ELEGIR := 0.3
const ENTRADA := 0.2
const DESFASE_ENTRADA := 0.06

## Veces que se ha elegido cada mejora. Lo comparte el HUD para su columna.
var niveles := {}

var _opciones: Array = []
var _tarjetas: Array[Button] = []
var _ventana: ColorRect
## El latido del borde de las tarjetas de evolución, mientras están a la vista.
var _latido: Tween
## Los estilos de las tarjetas de evolución de ahora, con el color de cada una.
var _bordes: Array = []
## Cuándo se abrió, en milisegundos del reloj real (el panel va en pausa).
var _abierto_en := 0


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
	# Un botón no crece con lo que lleva dentro: el tamaño tiene que dar para
	# el texto más largo, las descripciones de las evoluciones (hasta 135
	# letras), también con la fuente de Linux, que es más ancha. Con 230x260
	# se salían por abajo.
	tarjeta.custom_minimum_size = Vector2(260, 320)
	# Crece desde el centro al entrar.
	tarjeta.pivot_offset = tarjeta.custom_minimum_size / 2.0
	tarjeta.pressed.connect(_pulsar.bind(indice))

	var contenido := VBoxContainer.new()
	contenido.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 14)
	contenido.alignment = BoxContainer.ALIGNMENT_CENTER
	contenido.add_theme_constant_override("separation", 8)
	# Los hijos no se quedan los clicks: así llegan al botón.
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tarjeta.add_child(contenido)

	var tecla := EstiloInterfaz.etiqueta("[%d]" % (indice + 1), 14, EstiloInterfaz.TEXTO_SUAVE)
	var icono := TextureRect.new()
	# Del alto del personaje de la tarjeta de evolución; los iconos de 16x16
	# siguen saliendo a x4.
	icono.custom_minimum_size = TarjetaEvolucion.LADO_PERSONAJE
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
	_bordes = []
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
		_bordes.append_array(TarjetaEvolucion.vestir(tarjeta, TarjetaEvolucion.personaje_de(mejora)))

	# El borde de las de evolución late entre su color y uno más claro. El
	# panel funciona en pausa, así que su tween también.
	if _latido != null:
		_latido.kill()
	if not _bordes.is_empty():
		_latido = create_tween().set_loops()
		_latido.tween_method(_pintar_bordes, 0.0, 0.6, 0.45)
		_latido.tween_method(_pintar_bordes, 0.6, 0.0, 0.45)

	_ventana.visible = true
	_abierto_en = Time.get_ticks_msec()
	# Entran una detrás de otra, creciendo y apareciendo.
	for i in _tarjetas.size():
		var tarjeta := _tarjetas[i]
		tarjeta.scale = Vector2(0.8, 0.8)
		tarjeta.modulate.a = 0.0
		var entrada := create_tween().set_parallel()
		entrada.tween_property(tarjeta, "scale", Vector2.ONE, ENTRADA).set_delay(i * DESFASE_ENTRADA).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		entrada.tween_property(tarjeta, "modulate:a", 1.0, ENTRADA).set_delay(i * DESFASE_ENTRADA)
	# Con el foco en la primera tarjeta también se puede elegir con el mando.
	_tarjetas[0].grab_focus()


## brillo 0 es el color del personaje y 1, blanco.
func _pintar_bordes(brillo: float) -> void:
	for borde in _bordes:
		borde[0].border_color = borde[1].lerp(Color.WHITE, brillo)


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
		_pulsar(evento.keycode - KEY_1)
		get_viewport().set_input_as_handled()


## Lo que elige el jugador (click, Enter o 1, 2, 3): nada en los primeros
## ESPERA_ELEGIR segundos.
func _pulsar(indice: int) -> void:
	if Time.get_ticks_msec() - _abierto_en < ESPERA_ELEGIR * 1000.0:
		return
	_elegir(indice)


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
	if _latido != null:
		_latido.kill()
	BusEventos.mejora_seleccionada.emit(mejora)
