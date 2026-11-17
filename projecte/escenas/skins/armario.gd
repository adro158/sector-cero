extends Control

## El armario: donde se elige la skin de cada personaje (de Alan, 17/11). Una
## pestaña por personaje; a la izquierda, el personaje andando con la skin que
## se está mirando (vista_skin.gd); a la derecha, todas sus skins por
## categoría, la original primero. Pinchar una la enseña; PONÉRSELA la guarda
## en la opción "skins" (GestorGuardado), que es la que leen la partida y la
## interfaz (datos_skin.gd, elegida).
##
## Sin class_name: lo crea el menú con preload, como sala_red.gd.

signal cerrado

const DatosSkin := preload("res://recursos/skins/datos_skin.gd")
const VistaSkin := preload("res://escenas/skins/vista_skin.gd")
## En el mismo orden que el menú (personajes_menu.gd).
const PERSONAJES: Array[DatosPersonaje] = [
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
## De la menos a la más trabajada, con su color (propuesta del lote del Mago).
const CATEGORIAS := {
	"C": Color("#8A97A6"),
	"B": Color("#59D98C"),
	"A": Color("#4DA6FF"),
	"S": Color("#FFC23D"),
	"S+": Color("#FF4DD2"),
}

var _personaje: DatosPersonaje
## Lo que se está mirando: una skin o, si es la original, el propio personaje.
var _aspecto: Resource
var _pestanas: Array[Button] = []
var _vista: VBoxContainer
var _lista: VBoxContainer
## Los botones de la lista: [botón, aspecto, color de su categoría].
var _botones: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("ARMARIO", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)
	var pestanas := HBoxContainer.new()
	pestanas.alignment = BoxContainer.ALIGNMENT_CENTER
	pestanas.add_theme_constant_override("separation", 8)
	for indice in PERSONAJES.size():
		var boton := EstiloInterfaz.boton(PERSONAJES[indice].nombre.to_upper(), _elegir_personaje.bind(indice), 180)
		boton.add_theme_color_override("font_color", PERSONAJES[indice].color)
		_pestanas.append(boton)
		pestanas.add_child(boton)
	caja.add_child(pestanas)

	var cuerpo := HBoxContainer.new()
	cuerpo.add_theme_constant_override("separation", 28)
	_vista = VistaSkin.new()
	_vista.ponersela.connect(_ponersela)
	cuerpo.add_child(_vista)
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(430, 380)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	# Todo el ancho del desplazamiento: si no, las filas no saben cuánto caben.
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 6)
	desplazar.add_child(_lista)
	cuerpo.add_child(desplazar)
	caja.add_child(cuerpo)

	var volver := EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(volver)
	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false


## Abre el armario en ese personaje (su índice en PERSONAJES).
func abrir(indice := 0) -> void:
	visible = true
	_elegir_personaje(indice)
	_pestanas[indice].grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		get_viewport().set_input_as_handled()


## Si este jugador tiene esa skin. De momento todas: más adelante lo dirán el
## pase y el inventario de la cuenta (plan_cuentas.md), y aquí solo cambiará
## esta función.
func disponible(_de: DatosPersonaje, _numero: int) -> bool:
	return true


func _elegir_personaje(indice: int) -> void:
	_personaje = PERSONAJES[indice]
	for i in _pestanas.size():
		_pestanas[i].disabled = i == indice
	_rehacer_lista()
	_mirar(DatosSkin.elegida(_personaje))


## La lista, por categorías: la original y luego las skins de cada una. Solo
## al cambiar de personaje: así el foco del mando no se pierde al mirar.
func _rehacer_lista() -> void:
	for hijo in _lista.get_children():
		hijo.queue_free()
	_botones.clear()
	_anadir_categoria("ORIGINAL", EstiloInterfaz.TEXTO, [_personaje])
	for categoria in CATEGORIAS:
		var suyas := _personaje.skins.filter(func(skin): return skin.categoria == categoria)
		if not suyas.is_empty():
			_anadir_categoria("CATEGORÍA " + categoria, CATEGORIAS[categoria], suyas)


func _anadir_categoria(titulo: String, color: Color, aspectos: Array) -> void:
	_lista.add_child(EstiloInterfaz.etiqueta(titulo, 14, color))
	var fila := HFlowContainer.new()
	fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_theme_constant_override("h_separation", 6)
	fila.add_theme_constant_override("v_separation", 6)
	for aspecto in aspectos:
		var boton := Button.new()
		boton.icon = aspecto.retrato
		boton.tooltip_text = _nombre_de(aspecto)
		boton.custom_minimum_size = Vector2(76, 76)
		boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		boton.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		boton.pressed.connect(_mirar.bind(aspecto))
		boton.disabled = not disponible(_personaje, _numero_de(aspecto))
		_botones.append([boton, aspecto, color])
		fila.add_child(boton)
	_lista.add_child(fila)


## Enseña esa skin (o el original) en la vista, sin ponérsela todavía.
func _mirar(aspecto: Resource) -> void:
	_aspecto = aspecto
	var original := aspecto == _personaje
	_vista.mirar(aspecto.hoja, _nombre_de(aspecto),
		"ORIGINAL" if original else "CATEGORÍA " + aspecto.categoria,
		EstiloInterfaz.TEXTO if original else CATEGORIAS[aspecto.categoria],
		"El %s de siempre." % _personaje.nombre if original else aspecto.descripcion,
		_numero_de(aspecto) == DatosSkin.numero_elegido(_personaje),
		disponible(_personaje, _numero_de(aspecto)))
	# El borde de la que se mira, encendido; el de las demás, apagado.
	for datos in _botones:
		var color: Color = datos[2] if datos[1] == aspecto else datos[2].darkened(0.55)
		datos[0].add_theme_stylebox_override("normal", EstiloInterfaz.caja(color, 6))


func _ponersela() -> void:
	# duplicate(): la opción por defecto es una constante y no se puede cambiar.
	var elegidas: Dictionary = GestorGuardado.opcion("skins").duplicate()
	elegidas[_personaje.nombre] = _numero_de(_aspecto)
	GestorGuardado.cambiar_opcion("skins", elegidas)
	_mirar(_aspecto)


func _numero_de(aspecto: Resource) -> int:
	return 1 if aspecto == _personaje else aspecto.numero


func _nombre_de(aspecto: Resource) -> String:
	return "Original" if aspecto == _personaje else aspecto.nombre


