extends Node

## Instala el juego completo de una versión: pone su ejecutable en lugar del
## actual y reinicia. Se usa cuando una versión nueva necesita un ejecutable
## más nuevo (HAY_JUEGO_NUEVO; sin esto, el botón abría la página de GitHub) y
## en el menú de versiones, para cambiar a cualquiera, también una anterior.
##
## Biblioteca de versiones: cada ejecutable que se descarga, y el que había
## antes de cambiar, se guarda en user://versiones/<versión>/. En el menú de
## versiones, INSTALAR solo descarga a la biblioteca (descargar_version) y
## CAMBIAR es lo único que pasa a otra versión (instalar_version): copiarla de
## ahí es al momento. Lo pidió Adam el 14/10/2026: antes INSTALAR también
## cambiaba y reiniciaba. Cada una ocupa unos 100 MB; el menú deja borrarlas.
##
## Por qué no está en actualizador.gd: ese script lo carga el ejecutable antes
## que cualquier actualización, así que un cambio en él solo llegaría con un
## ejecutable nuevo, que es justo lo que este script sabe instalar. Este se
## carga con el resto del contenido, y por eso funciona también en ejecutables
## antiguos que ya han recibido una actualización. Por la misma razón usa del
## Actualizador solo lo que tienen todos los ejecutables desde la v0.2: estado,
## progreso, version_nueva, estado_cambiado, actualizar(), version_actual(),
## version_ejecutable() y sus constantes.

const DESCARGA := "user://juego_nuevo.zip"
const BIBLIOTECA := "user://versiones/"
## Lo que queda del ejecutable anterior tras instalar uno nuevo. Windows no deja
## borrar un ejecutable que está en marcha, pero sí cambiarle el nombre: se
## aparta así y se borra en el siguiente arranque.
const SUFIJO_VIEJO := ".viejo"

## Para el menú de versiones: cómo va una descarga a la biblioteca y cómo acaba.
signal progreso(fraccion: float)
signal descargada(bien: bool)

var _descarga: HTTPRequest
var _tamano := 0
var _progreso := 0.0
## Dónde se descarga el .zip. Las descargas a la biblioteca usan uno por
## versión: así no pisan el de un ACTUALIZAR que esté bajando a la vez.
var _temporal := DESCARGA
## Si este instalador es el que cambia de juego (ACTUALIZAR o CAMBIAR). Solo
## entonces su progreso sale en el texto del menú.
var _instalando := false


## Lo que hacen los botones ACTUALIZAR del menú y del aviso.
static func pulsar_actualizar() -> void:
	if Actualizador.estado != Actualizador.Estado.HAY_JUEGO_NUEVO:
		Actualizador.actualizar()
		return
	instalar_version({})


## Para el menú de versiones: cambia a esa release, más nueva o más antigua.
## Sin release, la última.
static func instalar_version(release: Dictionary) -> void:
	# Hijo del Actualizador, que es un autoload: así no desaparece si se cambia
	# de escena a mitad de la descarga.
	var instalador: Node = load("res://globales/instalador_juego.gd").new()
	Actualizador.add_child(instalador)
	instalador.instalar(release)


## Para el menú de versiones: deja esa versión en la biblioteca, sin cambiar a
## ella. Devuelve el instalador para seguir sus señales.
static func descargar_version(release: Dictionary) -> Node:
	var instalador: Node = load("res://globales/instalador_juego.gd").new()
	Actualizador.add_child(instalador)
	# Diferido: así quien la pide se conecta a las señales antes de que empiece.
	instalador.descargar.call_deferred(release)
	return instalador


## Al arrancar: borra el ejecutable apartado en la instalación anterior.
static func limpiar() -> void:
	var viejo := OS.get_executable_path() + SUFIJO_VIEJO
	if FileAccess.file_exists(viejo):
		DirAccess.remove_absolute(viejo)


## Dónde se guarda el ejecutable de esa versión en la biblioteca.
static func ruta_guardada(version: String) -> String:
	return BIBLIOTECA + version + "/" + OS.get_executable_path().get_file()


static func instalada(version: String) -> bool:
	return FileAccess.file_exists(ruta_guardada(version))


## Borra de la biblioteca una versión guardada, para liberar espacio.
static func borrar(version: String) -> void:
	DirAccess.remove_absolute(ruta_guardada(version))
	DirAccess.remove_absolute(BIBLIOTECA + version)


func instalar(release: Dictionary) -> void:
	if release.is_empty():
		release = await _ultima_release()
	var version: String = release.get("tag_name", "").trim_prefix("v")
	var estado_antes := Actualizador.estado
	var version_antes := Actualizador.version_nueva
	var ya_estaba := instalada(version)
	_instalando = true
	# Antes de cambiar de estado: es la versión del texto "Descargando la
	# versión X..." del menú.
	Actualizador.version_nueva = version
	_cambiar(Actualizador.Estado.DESCARGANDO)
	_guardar_actual()

	if not ya_estaba and not await _descargar(release, version):
		_fallar()
		return
	if not _sustituir_ejecutable(ruta_guardada(version)):
		if ya_estaba:
			# CAMBIAR desde la biblioteca, sin permiso para escribir en la
			# carpeta del juego: no hay ninguna página que abrir. Todo queda
			# como estaba y el menú de versiones lo dice.
			Actualizador.version_nueva = version_antes
			_cambiar(estado_antes)
			queue_free()
			return
		_fallar()
		return

	# El ejecutable que entra ya trae el contenido de su versión: la
	# actualización pequeña anterior sobra (y no debe cargarse encima).
	DirAccess.remove_absolute(Actualizador.PARCHE)
	DirAccess.remove_absolute(Actualizador.VERSION_PARCHE)
	OS.set_restart_on_exit(true)
	get_tree().quit()


func descargar(release: Dictionary) -> void:
	var version: String = release.get("tag_name", "").trim_prefix("v")
	_temporal = "user://version_%s.zip" % version
	var bien: bool = instalada(version) or await _descargar(release, version)
	descargada.emit(bien)
	queue_free()


## Guarda en la biblioteca el ejecutable que está en marcha, si no está ya,
## para poder volver a él sin descargarlo.
func _guardar_actual() -> void:
	var version := Actualizador.version_ejecutable()
	if version == "" or instalada(version):
		return
	DirAccess.make_dir_recursive_absolute(BIBLIOTECA + version)
	DirAccess.copy_absolute(OS.get_executable_path(), ruta_guardada(version))


## Descarga el .zip de la release y deja su ejecutable en la biblioteca.
func _descargar(release: Dictionary, version: String) -> bool:
	var url := _zip_de(release)
	if url == "":
		return false
	_descarga = HTTPRequest.new()
	_descarga.download_file = _temporal
	# Media hora como mucho (el juego pesa unos 40 MB): si la conexión se
	# cuelga, se da por fallida en lugar de esperar para siempre.
	_descarga.timeout = 1800.0
	add_child(_descarga)
	_descarga.request(url, Actualizador.CABECERAS)
	var resultado: Array = await _descarga.request_completed
	_descarga.queue_free()
	_descarga = null
	var completo: bool = resultado[0] == HTTPRequest.RESULT_SUCCESS and resultado[1] == 200 \
		and FileAccess.file_exists(_temporal) \
		and FileAccess.open(_temporal, FileAccess.READ).get_length() == _tamano
	var bien := completo and _sacar_del_zip(version)
	DirAccess.remove_absolute(_temporal)
	return bien


## El .zip solo lleva un fichero: el juego con todo dentro.
func _sacar_del_zip(version: String) -> bool:
	var zip := ZIPReader.new()
	if zip.open(_temporal) != OK or zip.get_files().size() != 1:
		return false
	var contenido := zip.read_file(zip.get_files()[0])
	zip.close()
	DirAccess.make_dir_recursive_absolute(BIBLIOTECA + version)
	var fichero := FileAccess.open(ruta_guardada(version), FileAccess.WRITE)
	if fichero == null:
		return false
	fichero.store_buffer(contenido)
	fichero.close()
	return true


func _process(_delta: float) -> void:
	if _descarga == null or _descarga.get_body_size() <= 0:
		return
	var nuevo := float(_descarga.get_downloaded_bytes()) / _descarga.get_body_size()
	if roundi(nuevo * 100.0) == roundi(_progreso * 100.0):
		return
	_progreso = nuevo
	progreso.emit(nuevo)
	# Al instalar (ACTUALIZAR, o CAMBIAR sin tenerla), también en el texto del
	# menú. Solo descargando a la biblioteca, el estado no cambia: se puede
	# seguir jugando.
	if _instalando:
		Actualizador.progreso = nuevo
		Actualizador.estado_cambiado.emit()


## La última release publicada, o un diccionario vacío si no se ha podido saber.
func _ultima_release() -> Dictionary:
	var peticion := HTTPRequest.new()
	peticion.timeout = 8.0
	add_child(peticion)
	peticion.request(Actualizador.ULTIMA_RELEASE, Actualizador.CABECERAS)
	var resultado: Array = await peticion.request_completed
	peticion.queue_free()
	if resultado[0] != HTTPRequest.RESULT_SUCCESS or resultado[1] != 200:
		return {}
	var release = JSON.parse_string(resultado[3].get_string_from_utf8())
	return release if release is Dictionary else {}


## El .zip de esta plataforma en la release, como "SectorCero_v0.8_windows.zip".
## Devuelve su dirección, o "" si no está.
func _zip_de(release: Dictionary) -> String:
	var final := "_%s.zip" % OS.get_name().to_lower()
	for archivo in release.get("assets", []):
		if archivo.name.ends_with(final):
			_tamano = archivo.size
			return archivo.browser_download_url
	return ""


## Pone una copia del ejecutable de la biblioteca en el sitio del que está en
## marcha.
func _sustituir_ejecutable(origen: String) -> bool:
	var actual := OS.get_executable_path()
	var nuevo := actual + ".nuevo"
	if DirAccess.copy_absolute(origen, nuevo) != OK:
		# Sin permiso para escribir en la carpeta del juego.
		return false
	if OS.get_name() == "Linux":
		# rwxr-xr-x (0755 en octal): sin permiso de ejecución no arrancaría.
		FileAccess.set_unix_permissions(nuevo, 493)

	# Primero se aparta el actual y después se pone el nuevo en su sitio. Si lo
	# segundo falla, se devuelve el actual a su nombre para no dejar el juego
	# sin ejecutable.
	DirAccess.remove_absolute(actual + SUFIJO_VIEJO)
	if DirAccess.rename_absolute(actual, actual + SUFIJO_VIEJO) != OK:
		DirAccess.remove_absolute(nuevo)
		return false
	if DirAccess.rename_absolute(nuevo, actual) != OK:
		DirAccess.rename_absolute(actual + SUFIJO_VIEJO, actual)
		DirAccess.remove_absolute(nuevo)
		return false
	return true


## Si algo falla (sin conexión, sin permiso en la carpeta), queda el camino de
## antes: con el estado HAY_JUEGO_NUEVO, actualizar() abre la página de la
## release para descargar el juego a mano.
func _fallar() -> void:
	_cambiar(Actualizador.Estado.HAY_JUEGO_NUEVO)
	Actualizador.actualizar()
	queue_free()


func _cambiar(estado: int) -> void:
	Actualizador.estado = estado
	Actualizador.estado_cambiado.emit()
