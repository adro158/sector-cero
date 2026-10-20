extends Node

## Las versiones del juego: cuáles hay publicadas en GitHub, cuáles están ya
## descargadas y cómo se abre una.
##
## El juego instalado (la carpeta juego/, junto al lanzador) es el motor de
## Godot sin contenido. Lo que cambia de una versión a otra es su contenido,
## el .pck que cada release publica (entre 1 y 2 MB). Godot abre solo el .pck
## que está junto al ejecutable y se llama como él, así que jugar a una
## versión es copiar su .pck ahí y abrir el juego. Funciona con todas las
## versiones porque todas se hicieron con el mismo Godot (4.7.2).
##
## No vale pasarle el .pck al abrirlo (--main-pack): los ejecutables
## exportados de Godot no lo admiten.

signal progreso(fraccion: float)

const RELEASES := "https://api.github.com/repos/adro158/sector-cero/releases?per_page=100"
const CABECERAS := ["User-Agent: SectorCero-Lanzador"]
## Las versiones descargadas: un .pck por versión, como "v1.2.pck".
const CARPETA := "user://versiones/"

## La última lista de releases que contestó GitHub (ver pedir_releases).
const LISTA := "user://releases.json"

## Si la lista que ha dado pedir_releases es la guardada y no la de ahora.
var lista_guardada := false
var _descarga: HTTPRequest
var _tamano := 0


## Las releases que se pueden jugar, de la más nueva a la más antigua. Las
## pruebas (prerelease) no se ofrecen.
##
## Si GitHub no contesta, la última lista que se consiguió (lista_guardada
## pasa a true). Pasa sin conexión, pero también con conexión: GitHub solo
## deja 60 consultas por hora a cada red, y en el instituto todos salen por
## la misma (le pasó al probarlo, 20/10). Bajar los .pck no cuenta para ese
## límite, así que con la lista guardada se puede seguir eligiendo versión.
func pedir_releases() -> Array:
	var peticion := HTTPRequest.new()
	peticion.timeout = 8.0
	add_child(peticion)
	peticion.request(RELEASES, CABECERAS)
	var resultado: Array = await peticion.request_completed
	peticion.queue_free()
	var texto := ""
	lista_guardada = resultado[0] != HTTPRequest.RESULT_SUCCESS or resultado[1] != 200
	if lista_guardada:
		if FileAccess.file_exists(LISTA):
			texto = FileAccess.get_file_as_string(LISTA)
	else:
		texto = resultado[3].get_string_from_utf8()
		FileAccess.open(LISTA, FileAccess.WRITE).store_string(texto)
	if texto.is_empty():
		return []
	var releases = JSON.parse_string(texto)
	if not releases is Array:
		return []
	return releases.filter(func(release): return not release.prerelease and not release.draft and not _pck_de(release).is_empty())


## Las versiones que ya están descargadas, de la más nueva a la más antigua.
## Es lo que se ofrece sin conexión.
func descargadas() -> Array:
	var versiones := []
	if not DirAccess.dir_exists_absolute(CARPETA):
		return versiones
	for fichero in DirAccess.get_files_at(CARPETA):
		if fichero.ends_with(".pck"):
			versiones.append(fichero.get_basename())
	versiones.sort_custom(func(a, b): return _comparar(a, b) > 0)
	return versiones


func descargada(version: String) -> bool:
	return FileAccess.file_exists(_ruta(version))


## Baja el .pck de la release a la biblioteca. Devuelve si ha ido bien.
func descargar(release: Dictionary) -> bool:
	var pck := _pck_de(release)
	DirAccess.make_dir_recursive_absolute(CARPETA)
	return await descargar_a(pck.browser_download_url, pck.size, _ruta(release.tag_name))


## Baja un fichero de ese tamaño a destino. Primero a un fichero aparte: si se
## corta a medias, no queda uno roto que parezca descargado. También la usa el
## actualizador del lanzador.
func descargar_a(url: String, tamano: int, destino: String) -> bool:
	_tamano = tamano
	var temporal := destino + ".descarga"
	_descarga = HTTPRequest.new()
	_descarga.download_file = temporal
	_descarga.timeout = 600.0
	add_child(_descarga)
	_descarga.request(url, CABECERAS)
	var resultado: Array = await _descarga.request_completed
	_descarga.queue_free()
	_descarga = null
	var bien: bool = resultado[0] == HTTPRequest.RESULT_SUCCESS and resultado[1] == 200 \
		and FileAccess.file_exists(temporal) and FileAccess.open(temporal, FileAccess.READ).get_length() == tamano
	if bien:
		DirAccess.remove_absolute(destino)
		DirAccess.rename_absolute(temporal, destino)
	else:
		DirAccess.remove_absolute(temporal)
	return bien


## Abre el juego instalado con el contenido de esa versión. Devuelve el
## número del proceso, o -1 si no se ha podido.
func jugar(version: String) -> int:
	var juego := carpeta_juego()
	var motor := juego.path_join("SectorCero.exe" if OS.get_name() == "Windows" else "SectorCero.x86_64")
	if not FileAccess.file_exists(motor):
		return -1
	if DirAccess.copy_absolute(_ruta(version), juego.path_join("SectorCero.pck")) != OK:
		return -1
	# Todas las versiones guardan sus datos en la misma carpeta. Si una más
	# nueva dejó ahí una actualización descargada, una antigua la cargaría al
	# arrancar: se borra antes de abrir cualquiera.
	var datos_juego := OS.get_user_data_dir().get_base_dir().path_join("Sector Cero")
	DirAccess.remove_absolute(datos_juego.path_join("actualizacion.pck"))
	DirAccess.remove_absolute(datos_juego.path_join("actualizacion.txt"))
	# Lo que va detrás de "--" lo lee el juego: las versiones nuevas saben así
	# que las ha abierto el lanzador.
	return OS.create_process(motor, ["--", "--desde-lanzador"])


## Dónde está instalado el juego: la carpeta juego/ junto al lanzador.
static func carpeta_juego() -> String:
	return OS.get_executable_path().get_base_dir().path_join("juego")


func _process(_delta: float) -> void:
	if _descarga != null and _tamano > 0:
		progreso.emit(float(_descarga.get_downloaded_bytes()) / _tamano)


## La dirección y el tamaño del .pck de esta plataforma en la release, o un
## diccionario vacío si no lo tiene.
func _pck_de(release: Dictionary) -> Dictionary:
	var nombre := "sector_cero_%s.pck" % ("windows" if OS.get_name() == "Windows" else "linux")
	for archivo in release.get("assets", []):
		if archivo.name == nombre:
			return {"browser_download_url": archivo.browser_download_url, "size": archivo.size}
	return {}


## Ruta del sistema y no "user://": la usan funciones del sistema de ficheros
## que trabajan con rutas absolutas.
func _ruta(version: String) -> String:
	return ProjectSettings.globalize_path(CARPETA + version + ".pck")


## Positivo si la versión a es más nueva que b ("v1.10" va después de "v1.9").
static func _comparar(a: String, b: String) -> int:
	var partes_a := a.trim_prefix("v").split(".")
	var partes_b := b.trim_prefix("v").split(".")
	for i in maxi(partes_a.size(), partes_b.size()):
		var numero_a := int(partes_a[i]) if i < partes_a.size() else 0
		var numero_b := int(partes_b[i]) if i < partes_b.size() else 0
		if numero_a != numero_b:
			return numero_a - numero_b
	return 0
