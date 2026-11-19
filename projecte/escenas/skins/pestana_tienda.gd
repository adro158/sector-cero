extends VBoxContainer

## La pestaña TIENDA de la ventana SKINS (de Alan, 19/11; tienda.gd): arriba,
## los paquetes cifrados (uno gratis si se tiene; si no, por bits), con las
## probabilidades a la vista y lo que ha tocado; debajo, las skins C, B y A de
## cada personaje con su precio. Las S y S+ dicen en qué nivel del pase salen.
## Sin dinero real: solo bits.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const Tienda := preload("res://globales/tienda.gd")
const PERSONAJES: Array[DatosPersonaje] = [
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
const ANCHO := 720.0
const BITS := Color("#00E5FF")
const TUYA := Color("#4DFF99")

var _abrir: Button
var _resultado: Label
var _lista: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	var paquetes := HBoxContainer.new()
	paquetes.add_theme_constant_override("separation", 12)
	var texto := VBoxContainer.new()
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_child(EstiloInterfaz.etiqueta("PAQUETES CIFRADOS: una skin C, B o A al azar", 16, EstiloInterfaz.NEON))
	var probabilidades := "C %d %%  ·  B %d %%  ·  A %d %%.  Repetida: +%d, +%d o +%d bits." % [
		Tienda.PROBABILIDADES.C, Tienda.PROBABILIDADES.B, Tienda.PROBABILIDADES.A,
		Tienda.DEVUELTOS.C, Tienda.DEVUELTOS.B, Tienda.DEVUELTOS.A]
	texto.add_child(EstiloInterfaz.etiqueta(probabilidades, 13, EstiloInterfaz.TEXTO_SUAVE))
	_resultado = EstiloInterfaz.etiqueta("", 14, TUYA)
	texto.add_child(_resultado)
	paquetes.add_child(texto)
	_abrir = EstiloInterfaz.boton("", _abrir_paquete, 230)
	paquetes.add_child(_abrir)
	add_child(paquetes)
	add_child(HSeparator.new())
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(ANCHO, 330)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 6)
	desplazar.add_child(_lista)
	add_child(desplazar)


func poner_al_dia() -> void:
	var gratis: int = Cartera.actual.paquetes()
	_abrir.text = "ABRIR (GRATIS: %d)" % gratis if gratis > 0 else "ABRIR POR %d BITS" % Tienda.PRECIO_PAQUETE
	_abrir.disabled = gratis == 0 and Cartera.actual.bits() < Tienda.PRECIO_PAQUETE
	for hijo in _lista.get_children():
		hijo.queue_free()
	for personaje in PERSONAJES:
		_lista.add_child(EstiloInterfaz.etiqueta(personaje.nombre.to_upper(), 16, personaje.color))
		var fila := HFlowContainer.new()
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_theme_constant_override("h_separation", 6)
		fila.add_theme_constant_override("v_separation", 6)
		for skin in personaje.skins:
			fila.add_child(_tarjeta(personaje, skin))
		_lista.add_child(fila)


## Una skin: su retrato, su nombre y su categoría, y COMPRAR con el precio, TUYA
## o en qué nivel del pase sale.
func _tarjeta(personaje: DatosPersonaje, skin: Resource) -> PanelContainer:
	var tiene: bool = Cartera.actual.tiene_skin(personaje.nombre, skin.numero)
	var precio := Tienda.precio(personaje.nombre, skin.numero)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(TUYA if tiene else personaje.color.darkened(0.5), 6))
	var caja := VBoxContainer.new()
	caja.custom_minimum_size.x = 132
	var retrato := TextureRect.new()
	retrato.texture = skin.retrato
	retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	caja.add_child(retrato)
	caja.add_child(_centrada(skin.nombre, 13, EstiloInterfaz.TEXTO))
	caja.add_child(_centrada("CATEGORÍA " + skin.categoria, 11, EstiloInterfaz.TEXTO_SUAVE))
	if tiene:
		caja.add_child(_centrada("TUYA", 14, TUYA))
	elif precio > 0:
		var comprar := EstiloInterfaz.boton("%d BITS" % precio, _comprar.bind(personaje.nombre, skin.numero), 120)
		comprar.disabled = precio > Cartera.actual.bits()
		caja.add_child(comprar)
	else:
		caja.add_child(_centrada(Tienda.donde(personaje.nombre, skin.numero).replace("En el pase de batalla: ", "PASE: "), 11, BITS))
	panel.add_child(caja)
	return panel


func _comprar(personaje: String, numero: int) -> void:
	if Cartera.actual.comprar(personaje, numero):
		_resultado.text = "Comprada. Póntela en el ARMARIO."
		poner_al_dia()


func _abrir_paquete() -> void:
	var skin: Dictionary = Cartera.actual.abrir_paquete()
	if skin.is_empty():
		return
	_resultado.text = "¡%s! (categoría %s)" % [skin.nombre, skin.categoria] if skin.nueva \
		else "%s: repetida, +%d bits" % [skin.nombre, skin.devueltos]
	poner_al_dia()


static func _centrada(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, tamano, color)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return etiqueta
