extends Control

## Ventana de versiones del menú: todas las releases publicadas en GitHub, de
## la más nueva a la más antigua, y un botón para instalar cualquiera. Instalar
## una anterior deja jugar a versiones viejas del juego; para volver, el botón
## ACTUALIZAR o esta misma ventana (desde la v0.8).
##
## Instala el juego completo de esa versión con instalador_juego.gd: el
## ejecutable de entonces, con su contenido. Solo en el juego descargado de
## escritorio: jugando desde Godot o en la web no hay nada que instalar.
##
## Sin class_name: el menú la carga con preload (ver embestida_horda.gd).

signal cerrado

const RELEASES := "https://api.github.com/repos/adro158/sector-cero/releases?per_page=30"
const InstaladorJuego := preload("res://globales/instalador_juego.gd")

var _lista: VBoxContainer
var _estado: Label
var _volver: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 12)
	var titulo := EstiloInterfaz.etiqueta("VERSIONES", 32, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)
	_estado = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_estado)

	var desplazable := ScrollContainer.new()
	desplazable.custom_minimum_size = Vector2(620, 340)
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 8)
	desplazable.add_child(_lista)
	caja.add_child(desplazable)

	_volver = EstiloInterfaz.boton("VOLVER  [Esc]", cerrar)
	_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_volver)

	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false
	Actualizador.estado_cambiado.connect(_al_cambiar_estado)


func abrir() -> void:
	visible = true
	_volver.grab_focus()
	for hijo in _lista.get_children():
		hijo.queue_free()
	if not OS.has_feature("template") or OS.has_feature("web"):
		_estado.text = "Solo en el juego descargado: desde Godot o en la web no hay nada que instalar."
		return
	_estado.text = "Buscando las versiones publicadas..."
	_rellenar(await _pedir_releases())


func cerrar() -> void:
	visible = false
	cerrado.emit()


## Las releases de GitHub, o una lista vacía si no hay conexión.
func _pedir_releases() -> Array:
	var peticion := HTTPRequest.new()
	peticion.timeout = 8.0
	add_child(peticion)
	peticion.request(RELEASES, Actualizador.CABECERAS)
	var resultado: Array = await peticion.request_completed
	peticion.queue_free()
	if resultado[0] != HTTPRequest.RESULT_SUCCESS or resultado[1] != 200:
		return []
	var releases = JSON.parse_string(resultado[3].get_string_from_utf8())
	return releases if releases is Array else []


func _rellenar(releases: Array) -> void:
	if releases.is_empty():
		_estado.text = "No se ha podido conectar con GitHub. Inténtalo más tarde."
		return
	_estado.text = "Estás jugando la versión %s. Elige otra para instalarla; el juego se reinicia." % Actualizador.version_actual()
	for release in releases:
		# Las pruebas (prerelease) no se ofrecen: la v0.1 ni siquiera tiene el
		# zip con el nombre de ahora.
		if release.prerelease or release.draft:
			continue
		var version: String = release.tag_name.trim_prefix("v")
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 16)
		var fecha: String = release.published_at.substr(0, 10)
		var texto := EstiloInterfaz.etiqueta("v%s   ·   %s" % [version, fecha], 16)
		texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(texto)
		if version == Actualizador.version_actual():
			fila.add_child(EstiloInterfaz.etiqueta("LA QUE TIENES", 14, EstiloInterfaz.VICTORIA))
		else:
			fila.add_child(EstiloInterfaz.boton("INSTALAR", _instalar.bind(release), 160))
		_lista.add_child(fila)


func _instalar(release: Dictionary) -> void:
	for boton in _lista.find_children("*", "Button", true, false):
		boton.disabled = true
	_volver.disabled = true
	InstaladorJuego.instalar_version(release)


## Mientras descarga, el progreso; si falla, el instalador ya abre la página.
func _al_cambiar_estado() -> void:
	if visible and Actualizador.estado == Actualizador.Estado.DESCARGANDO:
		_estado.text = Actualizador.texto()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel") and not _volver.disabled:
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()
