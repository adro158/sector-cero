extends Node

## Instala el juego completo de una release: descarga su .zip, saca el
## ejecutable, lo pone en lugar del actual y reinicia. Se usa cuando una versión
## nueva necesita un ejecutable más nuevo (HAY_JUEGO_NUEVO; sin esto, el botón
## abría la página de GitHub) y en el menú de versiones, para instalar
## cualquiera, también una anterior.
##
## Por qué no está en actualizador.gd: ese script lo carga el ejecutable antes
## que cualquier actualización, así que un cambio en él solo llegaría con un
## ejecutable nuevo, que es justo lo que este script sabe instalar. Este se
## carga con el resto del contenido, y por eso funciona también en ejecutables
## antiguos que ya han recibido una actualización. Por la misma razón usa del
## Actualizador solo lo que tienen todos los ejecutables desde la v0.2: estado,
## progreso, estado_cambiado y actualizar().

const DESCARGA := "user://juego_nuevo.zip"
## Lo que queda del ejecutable anterior tras instalar uno nuevo. Windows no deja
## borrar un ejecutable que está en marcha, pero sí cambiarle el nombre: se
## aparta así y se borra en el siguiente arranque.
const SUFIJO_VIEJO := ".viejo"

var _descarga: HTTPRequest
var _tamano := 0


## Lo que hacen los botones ACTUALIZAR del menú y del aviso.
static func pulsar_actualizar() -> void:
	if Actualizador.estado != Actualizador.Estado.HAY_JUEGO_NUEVO:
		Actualizador.actualizar()
		return
	# Hijo del Actualizador, que es un autoload: así no desaparece si se cambia
	# de escena a mitad de la descarga.
	var instalador: Node = load("res://globales/instalador_juego.gd").new()
	Actualizador.add_child(instalador)
	instalador.instalar()


## Al arrancar: borra el ejecutable apartado en la instalación anterior.
static func limpiar() -> void:
	var viejo := OS.get_executable_path() + SUFIJO_VIEJO
	if FileAccess.file_exists(viejo):
		DirAccess.remove_absolute(viejo)


## Para el menú de versiones: instala esa release, más nueva o más antigua.
static func instalar_version(release: Dictionary) -> void:
	var instalador: Node = load("res://globales/instalador_juego.gd").new()
	Actualizador.add_child(instalador)
	instalador.instalar(release)


## Instala la release que se le pase o, sin ninguna, la última.
func instalar(release: Dictionary = {}) -> void:
	if release.is_empty():
		release = await _ultima_release()
	# Antes de cambiar de estado: es la versión del texto "Descargando la
	# versión X..." del menú.
	Actualizador.version_nueva = release.get("tag_name", "").trim_prefix("v")
	_cambiar(Actualizador.Estado.DESCARGANDO)
	var url := _zip_de(release)
	if url == "":
		_fallar()
		return

	_descarga = HTTPRequest.new()
	_descarga.download_file = DESCARGA
	add_child(_descarga)
	_descarga.request(url, Actualizador.CABECERAS)
	var resultado: Array = await _descarga.request_completed
	_descarga.queue_free()
	_descarga = null
	var completo: bool = resultado[0] == HTTPRequest.RESULT_SUCCESS and resultado[1] == 200 \
		and FileAccess.file_exists(DESCARGA) \
		and FileAccess.open(DESCARGA, FileAccess.READ).get_length() == _tamano
	if not completo or not _sustituir_ejecutable():
		DirAccess.remove_absolute(DESCARGA)
		_fallar()
		return

	DirAccess.remove_absolute(DESCARGA)
	# El ejecutable nuevo ya trae el contenido de su versión: la actualización
	# pequeña anterior sobra (y no debe cargarse encima).
	DirAccess.remove_absolute(Actualizador.PARCHE)
	DirAccess.remove_absolute(Actualizador.VERSION_PARCHE)
	OS.set_restart_on_exit(true)
	get_tree().quit()


func _process(_delta: float) -> void:
	if _descarga == null or _descarga.get_body_size() <= 0:
		return
	var nuevo := float(_descarga.get_downloaded_bytes()) / _descarga.get_body_size()
	if roundi(nuevo * 100.0) != roundi(Actualizador.progreso * 100.0):
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


## Saca el ejecutable del .zip y lo pone en el sitio del que está en marcha.
## El .zip solo lleva un fichero: el juego con todo dentro.
func _sustituir_ejecutable() -> bool:
	var zip := ZIPReader.new()
	if zip.open(DESCARGA) != OK or zip.get_files().size() != 1:
		return false
	var contenido := zip.read_file(zip.get_files()[0])
	zip.close()

	var actual := OS.get_executable_path()
	var nuevo := actual + ".nuevo"
	var fichero := FileAccess.open(nuevo, FileAccess.WRITE)
	if fichero == null:
		# Sin permiso para escribir en la carpeta del juego.
		return false
	fichero.store_buffer(contenido)
	fichero.close()
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
