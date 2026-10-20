extends Node

## El lanzador también se actualiza solo, como el juego (el Actualizador de
## projecte/globales/): cada release publica su .pck (lanzador_windows.pck y
## lanzador_linux.pck). Si es más nuevo que el que hay, lanzador.gd lo baja a
## PARCHE y abre el lanzador otra vez. Al arrancar, este autoload lo carga
## antes que nada (en _init), y todo lo demás (la pantalla, la biblioteca) sale
## ya del nuevo.
##
## Si se instala un lanzador más nuevo que el parche (con el instalador de
## otra versión), el parche viejo se borra.

const Biblioteca := preload("res://biblioteca.gd")
const PARCHE := "user://lanzador_actualizacion.pck"
const VERSION_PARCHE := "user://lanzador_actualizacion.txt"


func _init() -> void:
	if not OS.has_feature("template") or not FileAccess.file_exists(PARCHE):
		return
	var version_parche := FileAccess.get_file_as_string(VERSION_PARCHE).strip_edges()
	var version_ejecutable: String = ProjectSettings.get_setting("application/config/version", "")
	if Biblioteca._comparar(version_parche, version_ejecutable) > 0:
		ProjectSettings.load_resource_pack(PARCHE)
	else:
		DirAccess.remove_absolute(PARCHE)
		DirAccess.remove_absolute(VERSION_PARCHE)


## La versión del lanzador que está en marcha: la del parche, si se ha
## cargado uno. Con load() para leer la del parche y no la del ejecutable.
func version_actual() -> String:
	return load("res://version.gd").ACTUAL


## Si la release es más nueva que este lanzador y trae su .pck, lo baja y abre
## el lanzador otra vez. Devuelve false si no hay nada que hacer.
func actualizar_si_hay(release: Dictionary, biblioteca: Node) -> bool:
	# Un lanzador exportado a mano (versión "desarrollo") no se actualiza: si
	# no, al probarlo se cambiaría solo por el publicado.
	if not OS.has_feature("template") or version_actual() == "desarrollo" \
			or Biblioteca._comparar(release.tag_name, version_actual()) <= 0:
		return false
	var nombre := "lanzador_%s.pck" % ("windows" if OS.get_name() == "Windows" else "linux")
	for archivo in release.get("assets", []):
		if archivo.name == nombre and await biblioteca.descargar_a(archivo.browser_download_url, archivo.size, ProjectSettings.globalize_path(PARCHE)):
			FileAccess.open(VERSION_PARCHE, FileAccess.WRITE).store_string(release.tag_name)
			OS.create_process(OS.get_executable_path(), [])
			get_tree().quit()
			return true
	return false
