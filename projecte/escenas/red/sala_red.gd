extends Control

## La sala del multijugador, en el menú (EN RED). Sin sala: el nombre, CREAR
## SALA, y el código con UNIRSE. En la sala: el código (el anfitrión lo dicta
## a los demás), los jugadores con su personaje, los botones para elegir
## personaje (los de otros, apagados), EMPEZAR (solo el anfitrión, con dos o
## más) y SALIR DE LA SALA. Lo que habla con la red lo hace globales/red.gd.
##
## Sin class_name: lo crea el menú con preload.

signal cerrado

const Red := preload("res://globales/red.gd")
const CodigoSala := preload("res://globales/codigo_sala.gd")
const Cuenta := preload("res://globales/cuenta.gd")
## En el orden del equipo (cambio_personaje.gd): el índice es el personaje.
const PERSONAJES: Array[DatosPersonaje] = [
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
const ANCHO := 460.0

var _inicio: VBoxContainer
var _nombre: LineEdit
var _codigo: LineEdit
var _sala: VBoxContainer
var _titulo_sala: Label
var _lista: VBoxContainer
var _elegir: Array[Button] = []
var _empezar: Button
var _estado: Label
var _volver: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("JUGAR EN RED", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)
	caja.add_child(_parrafo("De 2 a 3 jugadores en la misma red (la de clase o la de casa). Uno crea la sala y los demás se unen con su código.", EstiloInterfaz.TEXTO_SUAVE))

	_inicio = VBoxContainer.new()
	_inicio.add_theme_constant_override("separation", 10)
	_nombre = _campo(_inicio, "Tu nombre en la sala", 14)
	_inicio.add_child(EstiloInterfaz.boton("CREAR SALA", _crear, ANCHO))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 10)
	_codigo = _campo(fila, "Código de la sala (7 letras)", 9)
	_codigo.custom_minimum_size.x = ANCHO - 170.0
	_codigo.text_submitted.connect(func(_texto): _unirse())
	fila.add_child(EstiloInterfaz.boton("UNIRSE", _unirse, 160))
	_inicio.add_child(fila)
	caja.add_child(_inicio)

	_sala = VBoxContainer.new()
	_sala.add_theme_constant_override("separation", 8)
	_titulo_sala = EstiloInterfaz.etiqueta("", 22, EstiloInterfaz.VICTORIA)
	_titulo_sala.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sala.add_child(_titulo_sala)
	_lista = VBoxContainer.new()
	_sala.add_child(_lista)
	var personajes := HBoxContainer.new()
	personajes.add_theme_constant_override("separation", 8)
	for indice in PERSONAJES.size():
		var boton := EstiloInterfaz.boton(PERSONAJES[indice].nombre.to_upper(), _elegir_personaje.bind(indice), 148)
		_elegir.append(boton)
		personajes.add_child(boton)
	_sala.add_child(personajes)
	_empezar = EstiloInterfaz.boton("EMPEZAR", _empezar_partida, ANCHO)
	_sala.add_child(_empezar)
	_sala.add_child(EstiloInterfaz.boton("SALIR DE LA SALA", _salir_de_la_sala, ANCHO))
	caja.add_child(_sala)

	_estado = _parrafo("", EstiloInterfaz.DERROTA)
	caja.add_child(_estado)
	_volver = EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_volver)

	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false
	# Métodos y no lambdas: la red y el bus viven todo el juego y este panel
	# no (el error del 13/11 con la ventana de opciones).
	Red.actual.connect("error_de_red", _al_fallar)
	BusEventos.sala_cambiada.connect(_al_cambiar_sala)
	BusEventos.partida_en_red_empieza.connect(_al_empezar)
	BusEventos.jugador_desconectado.connect(_al_irse_alguien)


func abrir() -> void:
	visible = true
	_estado.text = ""
	if _nombre.text == "":
		_nombre.text = Cuenta.actual.nombre if Cuenta.actual.nombre != "" else "Jugador"
	_mostrar()


func cerrar() -> void:
	# Al volver al menú se sale de la sala: si no, seguiría abierta sin verla.
	_salir_de_la_sala()
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		get_viewport().set_input_as_handled()


func _crear() -> void:
	var codigo: String = Red.actual.crear_sala(_nombre.text.strip_edges())
	if codigo == "" and Red.actual.en_red():
		_estado.text = "No se ha encontrado la red local: los demás no podrán unirse."
	_mostrar()


func _unirse() -> void:
	_estado.add_theme_color_override("font_color", EstiloInterfaz.TEXTO_SUAVE)
	_estado.text = "Conectando..."
	Red.actual.unirse(_codigo.text, _nombre.text.strip_edges())


func _empezar_partida() -> void:
	Red.actual.empezar()


func _elegir_personaje(indice: int) -> void:
	Red.actual.elegir_personaje(indice)


func _salir_de_la_sala() -> void:
	Red.actual.salir()
	_mostrar()


func _al_fallar(texto: String) -> void:
	_estado.add_theme_color_override("font_color", EstiloInterfaz.DERROTA)
	_estado.text = texto
	_mostrar()


func _al_cambiar_sala(_jugadores: Array) -> void:
	_estado.text = ""
	_mostrar()


func _al_irse_alguien(id: int) -> void:
	if id == 1 and visible:
		_al_fallar("El anfitrión ha cerrado la sala.")


## Hasta que la partida se pueda jugar sincronizada (el punto 5 del plan), la
## sala solo junta a los jugadores: no empieza partidas sueltas en cada
## ordenador.
func _al_empezar(_jugadores: Array) -> void:
	_estado.add_theme_color_override("font_color", EstiloInterfaz.TEXTO_SUAVE)
	_estado.text = "La sala funciona. La partida en red todavía no está lista: falta sincronizarla (punto 5 del plan)."


## Sin sala, el formulario; en la sala, quién está, con qué personaje y los
## botones.
func _mostrar() -> void:
	var red: Node = Red.actual
	var en_sala: bool = red.en_red() and not red.jugadores().is_empty()
	_inicio.visible = not red.en_red()
	_sala.visible = en_sala
	if not en_sala:
		return
	var codigo := CodigoSala.de_ip(CodigoSala.ip_local())
	_titulo_sala.text = "CÓDIGO  %s" % CodigoSala.bonito(codigo) if red.es_anfitrion() else "Estás en la sala"
	for hijo in _lista.get_children():
		hijo.queue_free()
	var ocupados := []
	for jugador in red.jugadores():
		var personaje: DatosPersonaje = PERSONAJES[jugador.personaje]
		ocupados.append(jugador.personaje)
		var tu: String = "  (tú)" if jugador.id == red.mi_id() else ""
		_lista.add_child(EstiloInterfaz.etiqueta("%s  ·  %s%s" % [jugador.nombre, personaje.nombre, tu], 16, personaje.color))
	for indice in _elegir.size():
		_elegir[indice].disabled = indice in ocupados
	_empezar.visible = red.es_anfitrion()
	_empezar.disabled = red.jugadores().size() < 2


func _campo(padre: Control, ayuda: String, largo: int) -> LineEdit:
	var campo := LineEdit.new()
	campo.placeholder_text = ayuda
	campo.max_length = largo
	campo.custom_minimum_size = Vector2(ANCHO, 0)
	padre.add_child(campo)
	return campo


func _parrafo(texto: String, color: Color) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, 14, color)
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.custom_minimum_size = Vector2(ANCHO, 0)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return etiqueta
