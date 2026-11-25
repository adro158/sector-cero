extends VBoxContainer

## El armario: donde se elige la skin de cada personaje (de Alan, 17/11). Es
## la pestaña ARMARIO de la ventana SKINS (ventana_skins.gd, 18/11). Una
## pestaña por personaje; a la izquierda, el personaje andando con la skin que
## se está mirando (vista_skin.gd); a la derecha, todas sus skins por
## categoría, la original primero. Pinchar una la enseña; PONÉRSELA la guarda
## en la opción "skins" (GestorGuardado), que es la que leen la partida y la
## interfaz (datos_skin.gd, elegida).
##
## Sin class_name: lo crea ventana_skins.gd con preload.

const DatosSkin := preload("res://recursos/skins/datos_skin.gd")
const VistaSkin := preload("res://escenas/skins/vista_skin.gd")
const Cartera := preload("res://globales/cartera.gd")
const Tienda := preload("res://globales/tienda.gd")
## En el mismo orden que el menú (personajes_menu.gd).
const PERSONAJES: Array[DatosPersonaje] = [
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
const Piezas := preload("res://escenas/skins/piezas_cartera.gd")
const CANDADO := preload("res://medios/sprites/cartera/general/candado_grande.png")
## De la menos a la más trabajada, con su color (piezas_cartera.gd).
const CATEGORIAS := Piezas.CATEGORIAS

var _personaje: DatosPersonaje
## Lo que se está mirando: una skin o, si es la original, el propio personaje.
var _aspecto: Resource
var _pestanas: Array[Button] = []
var _vista: VBoxContainer
var _lista: VBoxContainer
## Los botones de la lista: [botón, aspecto, color y letra de su categoría].
var _botones: Array = []


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	var pestanas := HBoxContainer.new()
	pestanas.alignment = BoxContainer.ALIGNMENT_CENTER
	pestanas.add_theme_constant_override("separation", 8)
	for indice in PERSONAJES.size():
		var boton := EstiloInterfaz.boton(PERSONAJES[indice].nombre.to_upper(), _elegir_personaje.bind(indice), 180)
		boton.add_theme_color_override("font_color", PERSONAJES[indice].color)
		_pestanas.append(boton)
		pestanas.add_child(boton)
	add_child(pestanas)

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
	add_child(cuerpo)


## Enseña ese personaje (su índice en PERSONAJES), con el foco en su pestaña
## para el mando. Lo llama la ventana al abrirse.
func mostrar(indice := 0) -> void:
	_elegir_personaje(indice)
	_pestanas[indice].grab_focus()


## Si este jugador tiene esa skin (cartera.gd: la original, y las del pase, la
## tienda o un paquete). Las que no, se pueden mirar pero no ponérselas.
func disponible(de: DatosPersonaje, numero: int) -> bool:
	return Cartera.actual.tiene_skin(de.nombre, numero)


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
	_anadir_categoria("ORIGINAL", "", EstiloInterfaz.TEXTO, [_personaje])
	for categoria in CATEGORIAS:
		var suyas := _personaje.skins.filter(func(skin): return skin.categoria == categoria)
		if not suyas.is_empty():
			_anadir_categoria("CATEGORÍA " + categoria, categoria, CATEGORIAS[categoria], suyas)


## Una categoría: su chapita y su nombre, y debajo sus skins (categoria: la
## letra, o "" para la original).
func _anadir_categoria(titulo: String, categoria: String, color: Color, aspectos: Array) -> void:
	var cabecera := HBoxContainer.new()
	if categoria != "":
		var chapita := Piezas.chapita(categoria)
		chapita.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cabecera.add_child(chapita)
	cabecera.add_child(EstiloInterfaz.etiqueta(titulo, 14, color))
	_lista.add_child(cabecera)
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
		# Las que no se tienen, oscurecidas y con el candado: se miran, pero no
		# se ponen. El candado es hijo del botón, que lo deja donde se pone.
		if not disponible(_personaje, _numero_de(aspecto)):
			boton.self_modulate = Color(0.45, 0.45, 0.5)
			var candado := Piezas.dibujo(CANDADO, 1)
			candado.position = Vector2(42, 42)
			boton.add_child(candado)
			boton.tooltip_text += " · " + Tienda.donde(_personaje.nombre, _numero_de(aspecto))
		_botones.append([boton, aspecto, color, categoria if categoria != "" else "C"])
		fila.add_child(boton)
	_lista.add_child(fila)


## Enseña esa skin (o el original) en la vista, sin ponérsela todavía.
func _mirar(aspecto: Resource) -> void:
	_aspecto = aspecto
	var original := aspecto == _personaje
	_vista.mirar(aspecto.hoja, _nombre_de(aspecto),
		"ORIGINAL" if original else "CATEGORÍA " + aspecto.categoria,
		EstiloInterfaz.TEXTO if original else CATEGORIAS[aspecto.categoria],
		"El %s de siempre." % _personaje.nombre if original else _frase(aspecto),
		_numero_de(aspecto) == DatosSkin.numero_elegido(_personaje),
		disponible(_personaje, _numero_de(aspecto)))
	# El borde de la que se mira, encendido; el de las demás, apagado.
	for datos in _botones:
		var color: Color = datos[2] if datos[1] == aspecto else datos[2].darkened(0.55)
		datos[0].add_theme_stylebox_override("normal", Piezas.marco_carta(datos[3], color, 6))


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




## La frase de una skin y, si no se tiene, dónde se consigue.
func _frase(aspecto: Resource) -> String:
	if disponible(_personaje, aspecto.numero):
		return aspecto.descripcion
	return "%s\n%s" % [aspecto.descripcion, Tienda.donde(_personaje.nombre, aspecto.numero)]


## La ventana la llama al volver a la pestaña: puede haber skins nuevas
## (compradas, del pase o de un paquete).
func poner_al_dia() -> void:
	if _personaje != null:
		_elegir_personaje(PERSONAJES.find(_personaje))
