extends Control

## Ruleta del cofre de los élites. Primero el cofre se abre en grande y después
## gira la ruleta hasta la mejora que ha tocado. Se acepta con click, Enter o
## espacio, y entonces avisa con mejora_seleccionada, como el panel de mejoras.
##
## El premio llega ya sorteado (ruleta_abierta): el giro solo lo enseña. Como
## en el panel de mejoras, la pausa la pone y la quita la jugabilidad.

## Escala de los dibujos de la ruleta (96x96 el disco, 112x112 el marco).
const ESCALA := 3.0
const ESCALA_COFRE := 4.0
const ESCALA_ICONO := 2.5
## Distancia del centro del disco a cada icono, en píxeles del dibujo.
const RADIO_ICONOS := 31.0
const SECTORES := 8
const GRADOS_SECTOR := 360.0 / SECTORES
const DURACION_FOTOGRAMA := 0.15
const DURACION_GIRO := 3.5
## Cada cuánto se alternan los dos marcos para que parpadeen las bombillas.
const PARPADEO := 0.15

const PanelMejoras := preload("res://escenas/interfaz/panel_mejoras.gd")

## Veces que se ha elegido cada mejora. Es el mismo diccionario del panel de
## mejoras y del HUD: hay que apuntar aquí también lo que da la ruleta.
var niveles := {}

var _premio: DatosMejora
var _parada := false
var _reloj_marco := 0.0
var _fondo: ColorRect
var _escenario: Node2D
var _cofre: Sprite2D
var _rueda: Sprite2D
var _marco: Sprite2D
var _iconos: Array[Sprite2D] = []
var _latido: Tween
var _marcos := [preload("res://medios/sprites/ruleta_marco_a.png"), preload("res://medios/sprites/ruleta_marco_b.png")]
var _nombre: Label
var _descripcion: Label
var _ayuda: Label


func _ready() -> void:
	# Se usa precisamente con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_fondo = ColorRect.new()
	_fondo.color = Color(0.0, 0.0, 0.0, 0.7)
	_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fondo.gui_input.connect(_al_tocar_fondo)
	_fondo.visible = false
	add_child(_fondo)

	# Los dibujos van en un Node2D centrado: así girar el disco es solo cambiar
	# su rotation, y todo se coloca en píxeles alrededor del centro.
	_escenario = Node2D.new()
	_fondo.add_child(_escenario)
	_cofre = _sprite(preload("res://medios/sprites/cofre.png"), ESCALA_COFRE)
	_cofre.hframes = 4
	_rueda = _sprite(preload("res://medios/sprites/ruleta_rueda.png"), ESCALA)
	for i in SECTORES:
		_iconos.append(_sprite(null, ESCALA_ICONO))
	_marco = _sprite(_marcos[0], ESCALA)
	_crear_textos()
	BusEventos.ruleta_abierta.connect(_al_abrir)


func _sprite(textura: Texture2D, escala: float) -> Sprite2D:
	var nuevo := Sprite2D.new()
	nuevo.texture = textura
	nuevo.scale = Vector2(escala, escala)
	nuevo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_escenario.add_child(nuevo)
	return nuevo


func _crear_textos() -> void:
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.offset_left = -300.0
	caja.offset_right = 300.0
	caja.offset_top = 185.0
	caja.add_theme_constant_override("separation", 6)
	_fondo.add_child(caja)

	_nombre = EstiloInterfaz.etiqueta("", 26, EstiloInterfaz.NEON)
	_descripcion = EstiloInterfaz.etiqueta("", 16)
	_ayuda = EstiloInterfaz.etiqueta("Click, Enter o espacio para aceptar", 14, EstiloInterfaz.TEXTO_SUAVE)
	_descripcion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for etiqueta in [_nombre, _descripcion, _ayuda]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)


func _al_abrir(opciones: Array, premio: DatosMejora) -> void:
	_premio = premio
	_parada = false
	for i in SECTORES:
		_iconos[i].texture = opciones[i].icono
		_iconos[i].scale = Vector2(ESCALA_ICONO, ESCALA_ICONO)
	for etiqueta in [_nombre, _descripcion, _ayuda]:
		etiqueta.visible = false
	_rueda.rotation = 0.0
	_mostrar_ruleta(false)
	_cofre.frame = 1
	_fondo.visible = true

	# El cofre se abre fotograma a fotograma y después aparece la ruleta.
	var animacion := create_tween()
	for fotograma in [2, 3]:
		animacion.tween_interval(DURACION_FOTOGRAMA)
		animacion.tween_callback(func(): _cofre.frame = fotograma)
	animacion.tween_interval(DURACION_FOTOGRAMA * 2.0)
	animacion.tween_callback(_mostrar_ruleta.bind(true))

	# El disco acaba en -(45·k) grados más unas vueltas enteras: así el sector
	# k, que en el dibujo está en -90 + 45·k, queda justo bajo la flecha de
	# arriba (-90). Frena al final (EASE_OUT) como una ruleta de verdad.
	var sector := opciones.find(premio)
	var vueltas := randi_range(3, 4)
	var final := deg_to_rad(-GRADOS_SECTOR * sector - 360.0 * vueltas)
	animacion.tween_property(_rueda, "rotation", final, DURACION_GIRO) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	animacion.tween_callback(_al_parar.bind(sector))


func _mostrar_ruleta(visible_ruleta: bool) -> void:
	_cofre.visible = not visible_ruleta
	_rueda.visible = visible_ruleta
	_marco.visible = visible_ruleta
	for icono in _iconos:
		icono.visible = visible_ruleta


func _al_parar(sector: int) -> void:
	_parada = true
	_nombre.text = _premio.nombre
	_descripcion.text = "%s\n%s" % [PanelMejoras.texto_nivel(_premio, niveles), _premio.descripcion]
	for etiqueta in [_nombre, _descripcion, _ayuda]:
		etiqueta.visible = true
	# El icono ganador late para que se vea cuál ha tocado.
	_latido = create_tween().set_loops()
	_latido.tween_property(_iconos[sector], "scale", Vector2.ONE * ESCALA_ICONO * 1.4, 0.3)
	_latido.tween_property(_iconos[sector], "scale", Vector2.ONE * ESCALA_ICONO, 0.3)


func _process(delta: float) -> void:
	if not _fondo.visible:
		return
	_escenario.position = size / 2.0
	_reloj_marco += delta
	_marco.texture = _marcos[int(_reloj_marco / PARPADEO) % 2]

	# Los iconos no giran con el disco, para que se lean siempre derechos: cada
	# fotograma se recolocan en el ángulo de su sector más el giro del disco.
	for i in SECTORES:
		var angulo := deg_to_rad(-90.0 + GRADOS_SECTOR * i) + _rueda.rotation
		_iconos[i].position = Vector2.from_angle(angulo) * RADIO_ICONOS * ESCALA


func _unhandled_input(evento: InputEvent) -> void:
	if not _parada or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		_aceptar()


func _al_tocar_fondo(evento: InputEvent) -> void:
	if _parada and evento is InputEventMouseButton and evento.pressed:
		_aceptar()


func _aceptar() -> void:
	_parada = false
	# Como en el panel de mejoras: se anota y se cierra antes de avisar, porque
	# la respuesta puede abrir enseguida el siguiente panel de la cola.
	niveles[_premio] = niveles.get(_premio, 0) + 1
	_fondo.visible = false
	# Para que el latido del ganador no siga en la siguiente ruleta.
	_latido.kill()
	BusEventos.mejora_seleccionada.emit(_premio)
