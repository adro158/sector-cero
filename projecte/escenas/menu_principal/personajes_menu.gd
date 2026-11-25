extends HBoxContainer

## Los tres personajes en el menú principal, andando en el sitio y mirando de
## frente, al doble de tamaño, cada uno en su peana (lote del menú, 24/11).
## Usan sus hojas de andar (6 columnas de 64x72, una fila por dirección), de la
## skin que lleva cada uno. Son botones: al pulsar uno se abre el armario en
## ese personaje (elegido). Con el ratón encima (o el foco del mando), su
## peana se enciende y sale un cartel con su nombre, su herramienta y su ulti.
##
## Lo crea menu_principal.gd. Sin class_name: se carga con preload.

## Se ha pulsado ese personaje (su índice en PERSONAJES): el menú abre el
## armario (escenas/skins/armario.gd).
signal elegido(indice: int)

const DatosSkin := preload("res://recursos/skins/datos_skin.gd")
const Piezas := preload("res://escenas/menu_principal/piezas_menu.gd")
## En el mismo orden que el armario.
const PERSONAJES := [
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
const LADO := Vector2(64.0, 72.0)
const COLUMNAS := 6
## Lo mismo que en la partida (controlador_jugador.gd).
const FOTOGRAMAS_POR_SEGUNDO := 7.7
## La peana (64x20) va a x2; los pies, en el centro de su tapa (y = 7, a x2 14).
const PEANA := Vector2(64.0, 20.0)
const PIES := 14.0

## Un recorte de su hoja por personaje: se mueve de columna en columna.
var _recortes: Array[AtlasTexture] = []
var _peanas: Array[TextureRect] = []
var _carteles: Array[Control] = []
var _tiempo := 0.0


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 62)
	var fila := Direcciones8.fila(Vector2.DOWN)
	for i in PERSONAJES.size():
		var personaje: DatosPersonaje = PERSONAJES[i]
		var recorte := AtlasTexture.new()
		recorte.region = Rect2(Vector2(0.0, fila * LADO.y), LADO)
		_recortes.append(recorte)
		# El sitio de cada uno: la peana abajo y el personaje de pie encima.
		var puesto := Control.new()
		puesto.custom_minimum_size = Vector2(PEANA.x * 2.0, LADO.y * 2.0 + PEANA.y * 2.0 - PIES)
		add_child(puesto)
		var peana := Piezas.dibujo(Piezas.PEANA, 0, PEANA, 2.0, personaje.color)
		peana.position = Vector2(0.0, LADO.y * 2.0 - PIES)
		puesto.add_child(peana)
		_peanas.append(peana)
		# Un botón plano con el dibujo: se puede pulsar con ratón y con mando.
		var boton := Button.new()
		boton.flat = true
		boton.icon = recorte
		boton.expand_icon = true
		boton.size = LADO * 2.0
		boton.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		boton.pressed.connect(elegido.emit.bind(i))
		for senal in [boton.mouse_entered, boton.focus_entered, boton.mouse_exited, boton.focus_exited]:
			senal.connect(_mirar.bind(i, boton))
		puesto.add_child(boton)
		var cartel := _cartel(personaje)
		puesto.add_child(cartel)
		_carteles.append(cartel)
	_poner_hojas()
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)


## El cartel encima de la cabeza: el nombre, la herramienta y la ulti, con el
## pico apuntándole (sus 2 filas de arriba tapan el borde del cartel, así que
## el borde se abre y el pico sale de él).
func _cartel(personaje: DatosPersonaje) -> Control:
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", -2)
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.z_index = 2
	columna.visible = false
	var cartel := PanelContainer.new()
	cartel.add_theme_stylebox_override("panel", Piezas.cartel(personaje.color))
	columna.add_child(cartel)
	var textos := VBoxContainer.new()
	textos.add_theme_constant_override("separation", 2)
	cartel.add_child(textos)
	textos.add_child(EstiloInterfaz.etiqueta(personaje.nombre.to_upper(), 22, personaje.color))
	textos.add_child(EstiloInterfaz.etiqueta("Herramienta: %s" % personaje.arma.nombre, 14))
	textos.add_child(EstiloInterfaz.etiqueta("Ulti: %s" % personaje.nombre_ulti, 14))
	var pico := TextureRect.new()
	pico.texture = Piezas.CARTEL_PICO
	pico.modulate = personaje.color
	pico.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pico.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	columna.add_child(pico)
	return columna


## Al llegar o irse el ratón o el foco: encendido si tiene alguno de los dos.
## En diferido: al pasar del ratón al foco, uno se va antes de llegar el otro.
func _mirar(indice: int, boton: Button) -> void:
	(func():
		var encendido := boton.is_hovered() or boton.has_focus()
		_peanas[indice].texture.region.position.x = PEANA.x if encendido else 0.0
		var cartel := _carteles[indice]
		cartel.visible = encendido
		if encendido:
			# Centrado, con la punta del pico 10 px por debajo de la coronilla.
			cartel.reset_size()
			cartel.position = Vector2((PEANA.x * 2.0 - cartel.size.x) / 2.0, 20.0 - cartel.size.y)
	).call_deferred()


## La hoja de andar de la skin que lleva cada uno (datos_skin.gd, elegida).
func _poner_hojas() -> void:
	for i in PERSONAJES.size():
		_recortes[i].atlas = DatosSkin.elegida(PERSONAJES[i]).hoja


## Método y no lambda: el menú se borra y GestorGuardado sigue (el error del
## 13/11 con la ventana de opciones).
func _al_cambiar_opcion(clave: String, _valor: Variant) -> void:
	if clave == "skins":
		_poner_hojas()


func _process(delta: float) -> void:
	_tiempo += delta
	# Desfasados dos columnas, para que no den los pasos a la vez.
	for i in _recortes.size():
		var columna := int(_tiempo * FOTOGRAMAS_POR_SEGUNDO + i * 2) % COLUMNAS
		_recortes[i].region.position.x = columna * LADO.x
