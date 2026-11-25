extends HBoxContainer

## La pestaña TIENDA de la ventana SKINS (de Alan, 19/11; tienda.gd). Desde el
## 25/11, con el lote de la interfaz de skins (como su montaje_tienda.png):
## - a la izquierda, el paquete cifrado latiendo, las probabilidades con sus
##   chapitas, el precio y ABRIR (uno gratis si se tiene). Al abrirlo sale la
##   animación (apertura_paquete.gd).
## - a la derecha, las skins del personaje elegido en cartas con el marco de su
##   categoría: TUYA, el precio para comprarla o en qué nivel del pase sale.
## Sin dinero real: solo bits.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const Tienda := preload("res://globales/tienda.gd")
const Piezas := preload("res://escenas/skins/piezas_cartera.gd")
const AperturaPaquete := preload("res://escenas/skins/apertura_paquete.gd")
const PERSONAJES: Array[DatosPersonaje] = [
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
const REPOSO := preload("res://medios/sprites/cartera/paquete/paquete_reposo.png")
const ICONO := preload("res://medios/sprites/bits/bits_icono.png")

var _abrir: Button
var _gratis: Label
var _resultado: Label
var _elegidos: Array[Button] = []
var _rejilla: GridContainer
var _personaje := 0
var _apertura: AperturaPaquete


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	add_child(_panel_paquete())
	var derecha := VBoxContainer.new()
	derecha.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var quienes := HBoxContainer.new()
	quienes.add_theme_constant_override("separation", 6)
	for indice in PERSONAJES.size():
		var boton := EstiloInterfaz.boton(PERSONAJES[indice].nombre.to_upper(), _elegir.bind(indice), 150)
		boton.add_theme_color_override("font_color", PERSONAJES[indice].color.darkened(0.3))
		boton.add_theme_color_override("font_disabled_color", PERSONAJES[indice].color)
		_elegidos.append(boton)
		quienes.add_child(boton)
	derecha.add_child(quienes)
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(480, 340)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rejilla = GridContainer.new()
	_rejilla.columns = 4
	_rejilla.add_theme_constant_override("h_separation", 8)
	_rejilla.add_theme_constant_override("v_separation", 8)
	desplazar.add_child(_rejilla)
	derecha.add_child(desplazar)
	add_child(derecha)
	# La apertura, en su capa: tapa toda la pantalla, por encima de la ventana
	# y por debajo del filtro CRT (capa 110).
	var capa := CanvasLayer.new()
	capa.layer = 100
	_apertura = AperturaPaquete.new()
	_apertura.cerrada.connect(poner_al_dia)
	capa.add_child(_apertura)
	add_child(capa)


## El panel del paquete: el sobre latiendo, las probabilidades y ABRIR.
func _panel_paquete() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(EstiloInterfaz.NEON, 12))
	var caja := VBoxContainer.new()
	caja.custom_minimum_size.x = 210
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	caja.add_theme_constant_override("separation", 8)
	caja.add_child(_centrada("PAQUETE CIFRADO", 16, EstiloInterfaz.NEON))
	var sobre := Piezas.Animada.new(REPOSO, Vector2(64, 64), 0.1, true)
	sobre.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(sobre)
	var probabilidades := HBoxContainer.new()
	probabilidades.alignment = BoxContainer.ALIGNMENT_CENTER
	probabilidades.add_theme_constant_override("separation", 12)
	for categoria in Tienda.PROBABILIDADES:
		var una := VBoxContainer.new()
		var chapita := Piezas.chapita(categoria, 2)
		chapita.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		una.add_child(chapita)
		una.add_child(_centrada("%d %%" % Tienda.PROBABILIDADES[categoria], 12, EstiloInterfaz.TEXTO_SUAVE))
		probabilidades.add_child(una)
	caja.add_child(probabilidades)
	_abrir = EstiloInterfaz.boton("", _abrir_paquete, 190)
	_abrir.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_abrir)
	_gratis = _centrada("", 12, EstiloInterfaz.TEXTO_SUAVE)
	caja.add_child(_gratis)
	var repetida := "Repetida: +%d, +%d o +%d bits." % [Tienda.DEVUELTOS.C, Tienda.DEVUELTOS.B, Tienda.DEVUELTOS.A]
	caja.add_child(_centrada(repetida, 11, EstiloInterfaz.TEXTO_SUAVE))
	_resultado = _centrada("", 13, Piezas.CONSEGUIDO)
	caja.add_child(_resultado)
	panel.add_child(caja)
	return panel


func poner_al_dia() -> void:
	var gratis: int = Cartera.actual.paquetes()
	_abrir.text = "ABRIR" if gratis > 0 else "ABRIR  %d" % Tienda.PRECIO_PAQUETE
	_abrir.icon = null if gratis > 0 else ICONO
	_abrir.disabled = gratis == 0 and Cartera.actual.bits() < Tienda.PRECIO_PAQUETE
	_gratis.text = "gratis: tienes %d" % gratis if gratis > 0 else "o gánalos en el pase"
	_elegir(_personaje)


## Las cartas de ese personaje (su índice en PERSONAJES).
func _elegir(indice: int) -> void:
	_personaje = indice
	for i in _elegidos.size():
		_elegidos[i].disabled = i == indice
	for hijo in _rejilla.get_children():
		hijo.queue_free()
	for skin in PERSONAJES[indice].skins:
		_rejilla.add_child(_carta(PERSONAJES[indice], skin))


## Una skin: su chapita, su retrato en el marco de su categoría, su nombre y
## TUYA, el precio (comprar) o en qué nivel del pase sale.
func _carta(personaje: DatosPersonaje, skin: Resource) -> VBoxContainer:
	var tiene: bool = Cartera.actual.tiene_skin(personaje.nombre, skin.numero)
	var precio := Tienda.precio(personaje.nombre, skin.numero)
	var carta := VBoxContainer.new()
	carta.custom_minimum_size.x = 110
	carta.add_theme_constant_override("separation", 2)
	var marco := PanelContainer.new()
	marco.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var color: Color = Piezas.CATEGORIAS[skin.categoria]
	marco.add_theme_stylebox_override("panel", Piezas.marco_carta(skin.categoria, color if tiene else color.darkened(0.35)))
	var retrato := Piezas.dibujo(skin.retrato, 1)
	marco.add_child(retrato)
	carta.add_child(marco)
	# La chapita, en la esquina del retrato: hija suya, que no es un
	# contenedor y la deja donde se pone.
	var chapita := Piezas.chapita(skin.categoria)
	chapita.position = Vector2(-4, -6)
	retrato.add_child(chapita)
	carta.add_child(_centrada(skin.nombre, 12, EstiloInterfaz.TEXTO))
	if tiene:
		carta.add_child(_centrada("TUYA", 14, Piezas.CONSEGUIDO))
	elif precio > 0:
		var comprar := EstiloInterfaz.boton("%d" % precio, _comprar.bind(personaje.nombre, skin.numero), 104)
		comprar.icon = ICONO
		comprar.disabled = precio > Cartera.actual.bits()
		carta.add_child(comprar)
	else:
		carta.add_child(_centrada(Tienda.donde(personaje.nombre, skin.numero).replace("En el pase de batalla: ", "PASE: "), 11, Piezas.BITS))
	return carta


func _comprar(personaje: String, numero: int) -> void:
	if Cartera.actual.comprar(personaje, numero):
		_resultado.text = "Comprada. Póntela en el ARMARIO."
		poner_al_dia()


## Se abre de verdad y luego se enseña: la animación solo cuenta lo que tocó.
func _abrir_paquete() -> void:
	var skin: Dictionary = Cartera.actual.abrir_paquete()
	if skin.is_empty():
		return
	_resultado.text = ""
	_apertura.empezar(skin)


static func _centrada(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, tamano, color)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return etiqueta
