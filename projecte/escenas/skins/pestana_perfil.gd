extends VBoxContainer

## La pestaña PERFIL de la ventana SKINS (de Alan, 19/11): lo que lleva puesto
## el jugador de lo que ha conseguido en el pase y los logros (premios.gd): su
## título, el marco de la placa del nombre (en red), la estela, el icono (el
## retrato de una skin que se tiene) y el tema de color del filtro CRT. Arriba,
## cómo se ve la placa; debajo, una fila por tipo con lo que se tiene y
## NINGUNO. Se guarda en la opción "perfil", que va con la cuenta y en red.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const Premios := preload("res://globales/premios.gd")
const PERSONAJES := ["Mago", "Espadachín", "Segador"]
const TITULOS := {"titulo": "TÍTULO", "marco": "MARCO DE LA PLACA (en red)", "estela": "ESTELA",
	"icono": "ICONO", "tema": "TEMA DEL FILTRO CRT"}
const ANCHO := 720.0

var _placa: PanelContainer
var _nombre: Label
var _titulo: Label
var _icono: TextureRect
var _lista: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	var arriba := HBoxContainer.new()
	arriba.alignment = BoxContainer.ALIGNMENT_CENTER
	arriba.add_theme_constant_override("separation", 12)
	_icono = TextureRect.new()
	_icono.custom_minimum_size = Vector2(32, 32)
	_icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	arriba.add_child(_icono)
	_placa = PanelContainer.new()
	var nombres := VBoxContainer.new()
	_nombre = EstiloInterfaz.etiqueta("", 16, EstiloInterfaz.TEXTO)
	_titulo = EstiloInterfaz.etiqueta("", 12, EstiloInterfaz.TEXTO_SUAVE)
	nombres.add_child(_nombre)
	nombres.add_child(_titulo)
	_placa.add_child(nombres)
	arriba.add_child(_placa)
	add_child(arriba)
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(ANCHO, 360)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 4)
	desplazar.add_child(_lista)
	add_child(desplazar)


func poner_al_dia() -> void:
	var puesto := Premios.perfil(Cartera.actual)
	_nombre.text = _nombre_cuenta()
	_titulo.text = "«%s»" % Premios.TITULOS[puesto.titulo] if puesto.titulo != "" else "sin título"
	_placa.add_theme_stylebox_override("panel", EstiloInterfaz.caja(Premios.color("marco", puesto.marco, EstiloInterfaz.NEON), 10))
	_icono.texture = Premios.textura_icono(puesto.icono) if puesto.icono != "" else null
	for hijo in _lista.get_children():
		hijo.queue_free()
	for tipo in Premios.DE_PERFIL:
		_lista.add_child(EstiloInterfaz.etiqueta(TITULOS[tipo], 14, EstiloInterfaz.NEON))
		var fila := HFlowContainer.new()
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_theme_constant_override("h_separation", 6)
		fila.add_theme_constant_override("v_separation", 6)
		fila.add_child(_opcion(tipo, "", "NINGUNO", puesto[tipo] == ""))
		for id in _que_tiene(tipo):
			fila.add_child(_opcion(tipo, id, _nombre_de(tipo, id), puesto[tipo] == id))
		if _que_tiene(tipo).is_empty():
			fila.add_child(EstiloInterfaz.etiqueta("Aún no tienes: salen en el pase y en los logros.", 12, EstiloInterfaz.TEXTO_SUAVE))
		_lista.add_child(fila)


## Lo que se tiene de un tipo: sus ids. Los iconos, la original y las skins
## conseguidas de cada personaje.
func _que_tiene(tipo: String) -> Array:
	if tipo != "icono":
		return Cartera.actual.conseguidos(tipo)
	var iconos := []
	for personaje in PERSONAJES:
		for numero in range(1, 13):
			if Cartera.actual.tiene_skin(personaje, numero):
				iconos.append("%s:%d" % [personaje, numero])
	return iconos


## Un botón de lo que se puede llevar; el icono, con su retrato y sin texto.
func _opcion(tipo: String, id: String, texto: String, puesto: bool) -> Button:
	var es_icono := tipo == "icono" and id != ""
	var boton := EstiloInterfaz.boton("" if es_icono else texto, _poner.bind(tipo, id), 52.0 if es_icono else 0.0)
	if es_icono:
		boton.icon = Premios.textura_icono(id)
		boton.tooltip_text = texto
	var color := Premios.color(tipo, id, EstiloInterfaz.NEON)
	boton.add_theme_color_override("font_color", color if id != "" else EstiloInterfaz.TEXTO_SUAVE)
	boton.add_theme_stylebox_override("normal", EstiloInterfaz.caja(color if puesto else color.darkened(0.6), 8))
	return boton


func _nombre_de(tipo: String, id: String) -> String:
	if tipo == "titulo":
		return Premios.TITULOS.get(id, id)
	if tipo == "icono":
		return id.replace(":", " ")
	return Premios.LISTAS[tipo][id].nombre


func _poner(tipo: String, id: String) -> void:
	# duplicate(): la opción por defecto es una constante y no se puede cambiar.
	var puesto: Dictionary = GestorGuardado.opcion("perfil").duplicate()
	puesto[tipo] = id
	GestorGuardado.cambiar_opcion("perfil", puesto)
	poner_al_dia()


## El nombre que sale en la placa: el de la cuenta o «Jugador».
static func _nombre_cuenta() -> String:
	var cuenta: Node = load("res://globales/cuenta.gd").actual
	return cuenta.nombre if cuenta != null and cuenta.nombre != "" else "Jugador"
