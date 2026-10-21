extends Control

## El lanzador de Sector Cero, como el de Minecraft: se elige la versión en el
## desplegable (si no está, se descarga en ese momento) y JUGAR abre el juego
## instalado con el contenido de esa versión. Mientras se juega, el lanzador
## se queda minimizado, y al cerrar el juego vuelve a salir para elegir otra.
##
## La versión elegida se recuerda para la próxima vez.

const Estilo := preload("res://estilo.gd")
const Biblioteca := preload("res://biblioteca.gd")
const IconoLinux := preload("res://icono_linux.gd")
## Arriba, de lado a lado: el logo, los tres personajes y NÚCLEO CERO al fondo.
const CABECERA := preload("res://cabecera.png")
const ALTO_CABECERA := 260
const AJUSTES := "user://lanzador.cfg"

## Las versiones del desplegable, en el mismo orden: diccionarios de release
## de GitHub (sin conexión, solo con tag_name).
var _releases: Array = []
var _biblioteca: Node
var _versiones: OptionButton
var _novedades: Label
var _estado: Label
var _jugar: Button
## El proceso del juego abierto, para saber cuándo se cierra.
var _partida := -1
var _vigilar: Timer


func _ready() -> void:
	theme = Estilo.tema()
	_biblioteca = Biblioteca.new()
	add_child(_biblioteca)
	_biblioteca.progreso.connect(func(fraccion): _estado.text = "Descargando...  %d %%" % roundi(fraccion * 100.0))
	_vigilar = Timer.new()
	_vigilar.wait_time = 0.5
	_vigilar.timeout.connect(_comprobar_partida)
	add_child(_vigilar)
	_construir()
	IconoLinux.instalar()
	_cargar_versiones()


func _construir() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.04, 0.07)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right", "top", "bottom"]:
		margen.add_theme_constant_override("margin_" + lado, 32)
	# Lo demás va debajo de la cabecera.
	margen.add_theme_constant_override("margin_top", ALTO_CABECERA + 20)
	add_child(margen)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 20)
	margen.add_child(columna)

	# La cabecera, a tamaño real: la ventana mide 960 de ancho, como ella.
	var cabecera := TextureRect.new()
	cabecera.texture = CABECERA
	cabecera.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cabecera.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	cabecera.set_anchors_preset(Control.PRESET_TOP_WIDE)
	cabecera.offset_bottom = ALTO_CABECERA
	add_child(cabecera)

	# En medio: las novedades de la versión elegida (el texto de su release).
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var desplazable := ScrollContainer.new()
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_novedades = Estilo.etiqueta("", 15)
	_novedades.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_novedades.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desplazable.add_child(_novedades)
	panel.add_child(desplazable)
	columna.add_child(panel)

	# Abajo: la versión, el estado y JUGAR.
	var pie := HBoxContainer.new()
	pie.add_theme_constant_override("separation", 16)
	pie.add_child(Estilo.etiqueta("VERSIÓN", 16, Estilo.TEXTO_SUAVE))
	_versiones = OptionButton.new()
	_versiones.custom_minimum_size = Vector2(300, 56)
	_versiones.item_selected.connect(_al_elegir)
	pie.add_child(_versiones)
	_estado = Estilo.etiqueta("", 15, Estilo.TEXTO_SUAVE)
	_estado.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Los textos largos bajan de línea en vez de echar JUGAR de la ventana.
	_estado.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pie.add_child(_estado)
	_jugar = Button.new()
	_jugar.text = "JUGAR"
	_jugar.custom_minimum_size = Vector2(220, 56)
	_jugar.add_theme_font_size_override("font_size", 24)
	_jugar.pressed.connect(_pulsar_jugar)
	pie.add_child(_jugar)
	columna.add_child(pie)


func _cargar_versiones() -> void:
	_jugar.disabled = true
	_estado.text = "Buscando las versiones..."
	_releases = await _biblioteca.pedir_releases()
	# Si hay un lanzador más nuevo, se baja y se vuelve a abrir solo.
	if not _releases.is_empty() and await ActualizadorLanzador.actualizar_si_hay(_releases[0], _biblioteca):
		return
	if _releases.is_empty():
		# Sin conexión: las que ya están descargadas.
		for version in _biblioteca.descargadas():
			_releases.append({"tag_name": version})
	if _releases.is_empty():
		_estado.text = "Sin conexión y sin ninguna versión descargada."
		return

	var ajustes := ConfigFile.new()
	ajustes.load(AJUSTES)
	var elegida: String = ajustes.get_value("lanzador", "version", _releases[0].tag_name)
	var indice := 0
	for i in _releases.size():
		_versiones.add_item(_nombre(i))
		if _releases[i].tag_name == elegida:
			indice = i
	_versiones.select(indice)
	_al_elegir(indice)


## Cómo sale una versión en el desplegable.
func _nombre(indice: int) -> String:
	var version: String = _releases[indice].tag_name
	var texto := version + ("  (la última)" if indice == 0 else "")
	return texto if _biblioteca.descargada(version) else texto + "  · descargar"


func _al_elegir(indice: int) -> void:
	var release: Dictionary = _releases[indice]
	var ajustes := ConfigFile.new()
	ajustes.load(AJUSTES)
	ajustes.set_value("lanzador", "version", release.tag_name)
	ajustes.save(AJUSTES)

	var notas: String = release.get("body", "")
	_novedades.text = "NOVEDADES DE LA %s\n\n%s" % [release.tag_name.to_upper(), notas if notas != "" else "(sin notas)"]

	if _biblioteca.descargada(release.tag_name):
		_listo()
		return
	# Una descarga cada vez: mientras, no se puede cambiar de versión ni jugar.
	_jugar.disabled = true
	_versiones.disabled = true
	var bien: bool = await _biblioteca.descargar(release)
	_versiones.disabled = false
	_versiones.set_item_text(indice, _nombre(indice))
	if bien:
		_listo()
	else:
		_estado.text = "No se ha podido descargar. Mira la conexión y elígela otra vez."


func _listo() -> void:
	_jugar.disabled = false
	_estado.text = "Lista para jugar"
	if _biblioteca.lista_guardada:
		_estado.text += "\n(GitHub no contesta: lista guardada)"


func _pulsar_jugar() -> void:
	var version: String = _releases[_versiones.selected].tag_name
	_partida = _biblioteca.jugar(version)
	if _partida < 0:
		_estado.text = "No se ha podido abrir el juego. ¿Está instalado junto al lanzador?"
		return
	_estado.text = "Jugando a la %s" % version
	get_window().mode = Window.MODE_MINIMIZED
	_vigilar.start()


## Cada medio segundo mientras se juega: al cerrar el juego, el lanzador
## vuelve a salir.
func _comprobar_partida() -> void:
	if OS.is_process_running(_partida):
		return
	_vigilar.stop()
	# Por si el juego (una v1.4) ha cambiado el acceso del menú por el suyo.
	IconoLinux.instalar()
	get_window().mode = Window.MODE_WINDOWED
	get_window().grab_focus()
	_listo()
