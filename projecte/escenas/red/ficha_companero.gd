extends PanelContainer

## En la partida en red: la ficha de un compañero, como la del enemigo
## (ficha_enemigo.gd). Al pinchar en él sale arriba a la derecha con su
## retrato, su nombre, el personaje que lleva y sus mejoras, cada una con las
## veces que la ha cogido (petición de Adam, 18/11). Se pone al día sola y se
## cierra con click derecho.
##
## La abre ficha_enemigo.gd (un compañero gana a los enemigos: se pincha a
## propósito y casi siempre tiene horda alrededor) llamando a abrir_en(); por
## eso está en el grupo ficha_companero.
##
## Sin class_name: lo crea interfaz_red.gd con preload.

## Como el RADIO_CLICK de la ficha del enemigo, pero con el cuerpo del jugador.
const RADIO_CLICK := 30.0
## El centro del cuerpo, por encima de los pies (el sprite sube 22 px).
const CENTRO := Vector2(0.0, -22.0)
## Los iconos de las mejoras (16x16), al doble, como en la columna del HUD.
const LADO := 32.0
const SEPARACION := 6.0
const POR_FILA := 6

var _partida: Node
## El jugador del que se enseña la ficha (null si está cerrada).
var _jugador: Node
var _retrato: TextureRect
var _nombre: Label
var _personaje: Label
var _rejilla: Control
var _color := Color.WHITE
## Las mejoras de ese jugador: mejora → veces.
var _mejoras := {}


func _init(partida: Node) -> void:
	_partida = partida


func _ready() -> void:
	add_to_group("ficha_companero")
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	offset_left = -16.0
	offset_right = -16.0
	offset_top = 16.0
	custom_minimum_size = Vector2(300, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 10)
	add_child(columna)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	columna.add_child(fila)
	_retrato = TextureRect.new()
	_retrato.custom_minimum_size = Vector2(48, 48)
	_retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fila.add_child(_retrato)
	var textos := VBoxContainer.new()
	fila.add_child(textos)
	_nombre = EstiloInterfaz.etiqueta("", 16)
	_personaje = EstiloInterfaz.etiqueta("", 12, EstiloInterfaz.TEXTO_SUAVE)
	textos.add_child(_nombre)
	textos.add_child(_personaje)
	_rejilla = Control.new()
	_rejilla.draw.connect(_dibujar_mejoras)
	columna.add_child(_rejilla)
	columna.add_child(EstiloInterfaz.etiqueta("Click derecho: cerrar", 11, EstiloInterfaz.TEXTO_SUAVE))
	visible = false


## Si en punto (en el mundo) hay un compañero, enseña su ficha y devuelve true.
func abrir_en(punto: Vector2) -> bool:
	var local: Node = _partida.get_parent().get_node("Jugador")
	for jugador in _partida.jugadores():
		if jugador == local or jugador.get_node("CambioPersonaje").espectador():
			continue
		if (jugador.global_position + CENTRO).distance_to(punto) < RADIO_CLICK:
			_jugador = jugador
			visible = true
			_poner_al_dia()
			return true
	return false


func cerrar() -> void:
	visible = false
	_jugador = null


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_RIGHT:
		cerrar()


func _process(_delta: float) -> void:
	if not visible:
		return
	# Se ha ido de la partida: fuera.
	if not is_instance_valid(_jugador) or not _jugador in _partida.jugadores():
		cerrar()
		return
	_poner_al_dia()


## Lo que puede haber cambiado: el personaje que lleva y sus mejoras.
func _poner_al_dia() -> void:
	var personaje: DatosPersonaje = _jugador.get_node("CambioPersonaje").personaje_actual()
	var mejoras: Dictionary = _partida.mejoras_de(_jugador)
	var numero := 0
	for mejora in mejoras:
		numero += mejoras[mejora]
	_color = personaje.color
	add_theme_stylebox_override("panel", EstiloInterfaz.caja(_color, 12))
	_retrato.texture = personaje.retrato
	_nombre.text = _jugador.get_node("CambioPersonaje").nombre_red
	_nombre.add_theme_color_override("font_color", _color)
	_personaje.text = "%s · %d mejoras" % [personaje.nombre, numero]
	_mejoras = mejoras
	var filas := maxi(1, ceili(mejoras.size() / float(POR_FILA)))
	_rejilla.custom_minimum_size = Vector2(POR_FILA * (LADO + SEPARACION) - SEPARACION, filas * (LADO + SEPARACION) - SEPARACION)
	_rejilla.queue_redraw()


## Cada mejora, su icono en una casilla del color del personaje y, si la ha
## cogido más de una vez, cuántas.
func _dibujar_mejoras() -> void:
	var fuente := EstiloInterfaz.fuente_pixel()
	var i := 0
	for mejora in _mejoras:
		var esquina := Vector2(i % POR_FILA, floori(i / float(POR_FILA))) * (LADO + SEPARACION)
		var casilla := Rect2(esquina, Vector2(LADO, LADO))
		var evolucion: bool = mejora.efecto == DatosMejora.Efecto.EVOLUCIONAR_ARMA
		_rejilla.draw_rect(casilla, Color(0.0, 0.0, 0.0, 0.5))
		_rejilla.draw_rect(casilla, _color if evolucion else Color(_color, 0.5), false, 2.0 if evolucion else 1.0)
		_rejilla.draw_texture_rect(mejora.icono, casilla, false)
		if _veces(mejora) > 1:
			var texto := str(_veces(mejora))
			_rejilla.draw_string_outline(fuente, esquina + Vector2(LADO - 12.0, LADO + 2.0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 4, Color.BLACK)
			_rejilla.draw_string(fuente, esquina + Vector2(LADO - 12.0, LADO + 2.0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		i += 1


## Las veces que ha cogido esa mejora.
func _veces(mejora: DatosMejora) -> int:
	return _mejoras.get(mejora, 0)
