extends Control

## Ventana de versiones del menú: todas las releases publicadas en GitHub, de
## la más nueva a la más antigua. La que se está jugando sale como tal. Las
## demás se descargan con INSTALAR a la biblioteca de instalador_juego.gd, sin
## cambiar de versión, y quedan como INSTALADA: CAMBIAR pasa a ella (el juego
## se reinicia) y BORRAR la quita. Está también en las versiones anteriores,
## que se volvieron a publicar con esta ventana, para poder cambiar desde
## cualquiera.
##
## Lo que se instala es el juego completo de esa versión: el ejecutable de
## entonces, con su contenido. Solo en el juego descargado de escritorio:
## jugando desde Godot o en la web no hay nada que instalar.
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
	_estado.text = "Estás jugando la versión %s. INSTALAR la descarga sin cambiar de versión;\nCAMBIAR la abre (el juego se reinicia). Cada una ocupa unos 100 MB." % Actualizador.version_actual()
	for release in releases:
		# Las pruebas (prerelease) no se ofrecen: la v0.1 ni siquiera tiene el
		# zip con el nombre de ahora.
		if release.prerelease or release.draft:
			continue
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 16)
		var fecha: String = release.published_at.substr(0, 10)
		var texto := EstiloInterfaz.etiqueta("%s   ·   %s" % [release.tag_name, fecha], 16)
		texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(texto)
		_lista.add_child(fila)
		_poner_botones(fila, release)


## Lo que sale a la derecha de una versión: si es la que se juega, si ya está
## instalada o si hay que descargarla. Se vuelve a llamar cuando cambia.
func _poner_botones(fila: HBoxContainer, release: Dictionary) -> void:
	for hijo in fila.get_children().slice(1):
		hijo.queue_free()
	var version: String = release.tag_name.trim_prefix("v")
	if version == Actualizador.version_actual():
		fila.add_child(EstiloInterfaz.etiqueta("LA QUE TIENES", 14, EstiloInterfaz.VICTORIA))
	elif InstaladorJuego.instalada(version):
		fila.add_child(EstiloInterfaz.etiqueta("INSTALADA", 14, EstiloInterfaz.NEON))
		fila.add_child(EstiloInterfaz.boton("CAMBIAR", _cambiar.bind(release), 130))
		fila.add_child(EstiloInterfaz.boton("BORRAR", _borrar.bind(fila, release), 110))
	else:
		fila.add_child(EstiloInterfaz.boton("INSTALAR", _instalar.bind(fila, release), 160))


## Descarga la versión a la biblioteca y nada más: se sigue en esta. Una
## descarga cada vez, porque todas usan el mismo fichero temporal.
func _instalar(fila: HBoxContainer, release: Dictionary) -> void:
	if _actualizando():
		return
	_bloquear(true)
	for hijo in fila.get_children().slice(1):
		hijo.queue_free()
	var aviso := EstiloInterfaz.etiqueta("DESCARGANDO  0 %", 14, EstiloInterfaz.NEON)
	fila.add_child(aviso)
	var instalador := InstaladorJuego.descargar_version(release)
	instalador.progreso.connect(func(fraccion): aviso.text = "DESCARGANDO  %d %%" % roundi(fraccion * 100.0))
	var bien: bool = await instalador.descargada
	_bloquear(false)
	_poner_botones(fila, release)
	if bien:
		_estado.text = "La %s ya está instalada: CAMBIAR la abre (el juego se reinicia)." % release.tag_name
	else:
		_estado.text = "No se ha podido descargar la %s. Inténtalo otra vez." % release.tag_name


## Pasa a una versión ya instalada: el juego se reinicia con ella.
func _cambiar(release: Dictionary) -> void:
	if _actualizando():
		return
	_bloquear(true)
	_estado.text = "Cambiando a la %s. El juego se reinicia..." % release.tag_name
	InstaladorJuego.instalar_version(release)
	# Si ha ido bien, el juego ya se está cerrando y el estado sigue en
	# DESCARGANDO. Si no (la carpeta del juego no deja escribir), el instalador
	# lo ha devuelto a como estaba: la ventana se desbloquea y lo dice.
	if Actualizador.estado != Actualizador.Estado.DESCARGANDO:
		_bloquear(false)
		_estado.text = "No se ha podido cambiar a la %s: la carpeta del juego no deja escribir." % release.tag_name


## Borra la versión de la biblioteca: su fila vuelve a ofrecer INSTALAR.
func _borrar(fila: HBoxContainer, release: Dictionary) -> void:
	InstaladorJuego.borrar(release.tag_name.trim_prefix("v"))
	_poner_botones(fila, release)
	_volver.grab_focus()


## Mientras se descarga una actualización (ACTUALIZAR), no se instala ni se
## cambia nada: las dos cosas a la vez se pisarían.
func _actualizando() -> bool:
	if Actualizador.estado != Actualizador.Estado.DESCARGANDO:
		return false
	_estado.text = "Espera a que termine la actualización que se está descargando."
	return true


func _bloquear(bloqueado: bool) -> void:
	for boton in _lista.find_children("*", "Button", true, false):
		boton.disabled = bloqueado
	_volver.disabled = bloqueado
	# El botón pulsado desaparece al rehacer su fila: el foco vuelve a VOLVER
	# para que con el teclado o el mando se pueda seguir y salir.
	if not bloqueado:
		_volver.grab_focus()


func _unhandled_input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventKey:
		return
	# Con la ventana abierta, ninguna tecla llega al menú de debajo: Enter
	# empezaría una partida y Esc saldría del juego. Así no hace falta tocar el
	# menú, ni en esta versión ni en las anteriores.
	get_viewport().set_input_as_handled()
	if evento.is_action_pressed("ui_cancel") and not _volver.disabled:
		cerrar()
