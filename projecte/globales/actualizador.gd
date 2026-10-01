extends Node

## Actualizaciones del juego desde las releases de GitHub, en dos momentos:
##
## 1. Al arrancar: si hay una actualización descargada, la carga encima del
##    juego con load_resource_pack. Es el primer autoload y lo hace en _init
##    para que todo lo que se cargue después (los demás autoloads, el menú, la
##    partida) salga ya de la versión nueva.
## 2. En el menú: pregunta a GitHub cuál es la última release y, si es más
##    nueva, el menú ofrece actualizar. Al aceptar, descarga el .pck nuevo (unos
##    pocos MB, no los 110 del ejecutable) y reinicia el juego.
##
## Solo actúa en el juego exportado (OS.has_feature("template")): jugando desde
## el proyecto, el código ya es el más nuevo.
##
## Ojo: este script no puede nombrar la clase Version. Godot cargaría version.gd
## al compilarlo, antes de aplicar la actualización, y se quedaría para siempre
## con la versión vieja. Por eso la lee con load() cuando ya está aplicada.

signal estado_cambiado

enum Estado {
	SIN_BUSCAR,
	BUSCANDO,
	AL_DIA,
	SIN_CONEXION,
	HAY_ACTUALIZACION,
	HAY_JUEGO_NUEVO,
	DESCARGANDO,
	ERROR,
}

const ULTIMA_RELEASE := "https://api.github.com/repos/adro158/sector-cero/releases/latest"
const PARCHE := "user://actualizacion.pck"
## La versión del parche descargado, para no cargarlo encima de un ejecutable
## más nuevo (si después se bajó el juego entero).
const VERSION_PARCHE := "user://actualizacion.txt"
const DESCARGA := "user://actualizacion.pck.descarga"
## GitHub rechaza las peticiones que no dicen quién las hace.
const CABECERAS := ["User-Agent: SectorCero"]

var estado := Estado.SIN_BUSCAR
var version_nueva := ""
## De 0 a 1 mientras se descarga.
var progreso := 0.0

var _url_pck := ""
var _tamano_pck := 0
## Página de la release, para bajar el juego entero si hace falta.
var _pagina := ""
var _descarga: HTTPRequest


func _init() -> void:
	if OS.has_feature("template") and FileAccess.file_exists(PARCHE):
		_cargar_parche()


func _cargar_parche() -> void:
	var version_parche := FileAccess.get_file_as_string(VERSION_PARCHE).strip_edges()
	if comparar(version_ejecutable(), version_parche) >= 0:
		DirAccess.remove_absolute(PARCHE)
		DirAccess.remove_absolute(VERSION_PARCHE)
		return
	ProjectSettings.load_resource_pack(PARCHE)


## La versión del contenido: la del parche si se ha cargado uno.
func version_actual() -> String:
	return load("res://globales/version.gd").ACTUAL


## La versión del ejecutable, que no cambia con las actualizaciones.
func version_ejecutable() -> String:
	return ProjectSettings.get_setting("application/config/version", "")


## -1 si a es anterior a b, 0 si son iguales y 1 si es posterior. Compara
## número a número: "0.10" es posterior a "0.9", que como texto no sale.
static func comparar(a: String, b: String) -> int:
	var partes_a := a.split(".")
	var partes_b := b.split(".")
	for i in maxi(partes_a.size(), partes_b.size()):
		var numero_a := int(partes_a[i]) if i < partes_a.size() else 0
		var numero_b := int(partes_b[i]) if i < partes_b.size() else 0
		if numero_a != numero_b:
			return -1 if numero_a < numero_b else 1
	return 0


## Pregunta a GitHub por la última release. Solo la primera vez que se llama:
## volver al menú no repite la consulta.
func buscar() -> void:
	# En la web el juego se baja entero cada vez: no hay nada que actualizar.
	if not OS.has_feature("template") or OS.has_feature("web") or estado != Estado.SIN_BUSCAR:
		return
	_cambiar(Estado.BUSCANDO)

	var respuesta := await _pedir(ULTIMA_RELEASE)
	# 404: todavía no hay ninguna release publicada.
	if respuesta.codigo == 404:
		_cambiar(Estado.AL_DIA)
		return
	# Primero el código: leer como JSON una respuesta vacía da un error.
	if respuesta.codigo != 200:
		_cambiar(Estado.SIN_CONEXION)
		return
	var release = JSON.parse_string(respuesta.texto)
	if release == null:
		_cambiar(Estado.SIN_CONEXION)
		return

	version_nueva = release.tag_name.trim_prefix("v")
	if comparar(version_nueva, version_actual()) <= 0:
		_cambiar(Estado.AL_DIA)
		return

	_pagina = release.html_url
	var nombre_pck := "sector_cero_%s.pck" % OS.get_name().to_lower()
	var url_info := ""
	for archivo in release.assets:
		if archivo.name == nombre_pck:
			_url_pck = archivo.browser_download_url
			_tamano_pck = archivo.size
		elif archivo.name == "version.json":
			url_info = archivo.browser_download_url

	# version.json dice qué ejecutable necesita la versión nueva. Si falta,
	# por prudencia se pide el juego entero.
	var minimo := version_nueva
	if url_info != "":
		var respuesta_info := await _pedir(url_info)
		var info = JSON.parse_string(respuesta_info.texto) if respuesta_info.codigo == 200 else null
		if info != null:
			minimo = info.ejecutable_minimo
	var basta_el_pck := _url_pck != "" and comparar(version_ejecutable(), minimo) >= 0
	_cambiar(Estado.HAY_ACTUALIZACION if basta_el_pck else Estado.HAY_JUEGO_NUEVO)


## Lo que hace el botón del menú: descargar el .pck nuevo o, si no basta, abrir
## la página de la release para bajar el juego entero.
func actualizar() -> void:
	if estado == Estado.HAY_JUEGO_NUEVO:
		OS.shell_open(_pagina)
		return
	if estado != Estado.HAY_ACTUALIZACION:
		return

	_cambiar(Estado.DESCARGANDO)
	_descarga = HTTPRequest.new()
	_descarga.download_file = DESCARGA
	add_child(_descarga)
	_descarga.request(_url_pck, CABECERAS)
	var resultado: Array = await _descarga.request_completed
	_descarga.queue_free()
	_descarga = null

	# Se comprueba el tamaño: un fichero a medias no se debe cargar nunca.
	var completo: bool = resultado[0] == HTTPRequest.RESULT_SUCCESS and resultado[1] == 200 \
		and FileAccess.file_exists(DESCARGA) \
		and FileAccess.open(DESCARGA, FileAccess.READ).get_length() == _tamano_pck
	if not completo:
		DirAccess.remove_absolute(DESCARGA)
		_cambiar(Estado.ERROR)
		return

	# Se descarga con otro nombre y solo se renombra al terminar, para que un
	# corte a mitad no deje un parche roto en su sitio.
	DirAccess.remove_absolute(PARCHE)
	DirAccess.rename_absolute(DESCARGA, PARCHE)
	FileAccess.open(VERSION_PARCHE, FileAccess.WRITE).store_string(version_nueva)
	# Al cerrarse, Godot vuelve a abrir el juego, que cargará el parche nuevo.
	OS.set_restart_on_exit(true)
	get_tree().quit()


## Frase para el menú según el estado.
func texto() -> String:
	match estado:
		Estado.BUSCANDO:
			return "Versión %s · buscando actualizaciones..." % version_actual()
		Estado.AL_DIA:
			return "Versión %s · al día" % version_actual()
		Estado.SIN_CONEXION:
			return "Versión %s · no se ha podido comprobar si hay actualizaciones" % version_actual()
		Estado.HAY_ACTUALIZACION:
			return "Versión %s · ¡nueva versión %s disponible!" % [version_actual(), version_nueva]
		Estado.HAY_JUEGO_NUEVO:
			return "Versión %s · la versión %s necesita descargar el juego completo" % [version_actual(), version_nueva]
		Estado.DESCARGANDO:
			return "Descargando la versión %s... %d %%" % [version_nueva, roundi(progreso * 100.0)]
		Estado.ERROR:
			return "No se ha podido descargar la actualización. Inténtalo más tarde."
	# Jugando desde el proyecto no se busca nada.
	if not OS.has_feature("template"):
		return "Versión de desarrollo"
	return "Versión %s" % version_actual()


func _process(_delta: float) -> void:
	if _descarga == null or _descarga.get_body_size() <= 0:
		return
	var nuevo := float(_descarga.get_downloaded_bytes()) / _descarga.get_body_size()
	# Se avisa al menú solo cuando cambia el porcentaje entero.
	if roundi(nuevo * 100.0) != roundi(progreso * 100.0):
		progreso = nuevo
		estado_cambiado.emit()


## Hace una petición y espera la respuesta: el código HTTP (0 si no hubo
## conexión) y el cuerpo como texto.
func _pedir(url: String) -> Dictionary:
	var peticion := HTTPRequest.new()
	peticion.timeout = 8.0
	add_child(peticion)
	peticion.request(url, CABECERAS)
	var resultado: Array = await peticion.request_completed
	peticion.queue_free()
	var conecto: bool = resultado[0] == HTTPRequest.RESULT_SUCCESS
	return {
		"codigo": resultado[1] if conecto else 0,
		"texto": resultado[3].get_string_from_utf8() if conecto else "",
	}


func _cambiar(nuevo: Estado) -> void:
	estado = nuevo
	estado_cambiado.emit()
