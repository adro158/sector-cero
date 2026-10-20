extends RefCounted

## Los accesos del menú de aplicaciones en Linux, como hace el juego
## (projecte/globales/icono_linux.gd), pero apuntando al lanzador. Un
## ejecutable de Linux no lleva icono dentro, y escritorios como GNOME sacan
## el de cada ventana de un fichero .desktop con su StartupWMClass (el nombre
## del proyecto de Godot):
##   - sector-cero.desktop: el que sale en el menú, abre el lanzador
##   - sector-cero-juego.desktop: escondido (NoDisplay), solo para que la
##     ventana del juego también tenga su icono
##
## El juego abierto desde el lanzador ya no escribe el suyo, pero los de la
## v1.4 sí (apuntando al juego, sin pasar por el lanzador): por eso el
## lanzador lo vuelve a escribir al arrancar y cada vez que se cierra el juego.

const Biblioteca := preload("res://biblioteca.gd")
const ICONO := preload("res://icono.png")


static func instalar() -> void:
	if OS.get_name() != "Linux" or not OS.has_feature("template"):
		return
	var datos := OS.get_environment("XDG_DATA_HOME")
	if datos.is_empty():
		datos = OS.get_environment("HOME").path_join(".local/share")
	var carpeta_iconos := datos.path_join("icons/hicolor/256x256/apps")
	var carpeta_aplicaciones := datos.path_join("applications")
	DirAccess.make_dir_recursive_absolute(carpeta_iconos)
	DirAccess.make_dir_recursive_absolute(carpeta_aplicaciones)
	var icono := carpeta_iconos.path_join("sector-cero.png")
	ICONO.get_image().save_png(icono)

	var juego := Biblioteca.carpeta_juego().path_join("SectorCero.x86_64")
	_escribir(carpeta_aplicaciones.path_join("sector-cero.desktop"), OS.get_executable_path(), icono, ProjectSettings.get_setting("application/config/name"), false)
	_escribir(carpeta_aplicaciones.path_join("sector-cero-juego.desktop"), juego, icono, "Sector Cero", true)


static func _escribir(ruta: String, ejecutable: String, icono: String, clase: String, escondido: bool) -> void:
	var lineas := [
		"[Desktop Entry]",
		"Type=Application",
		"Name=Sector Cero",
		"Comment=Eres un antivirus. Tu ordenador está infectado.",
		# Entre comillas por si la ruta tiene espacios.
		"Exec=\"%s\"" % ejecutable,
		"Icon=" + icono,
		"StartupWMClass=" + clase,
		"Categories=Game;",
		"Terminal=false",
	]
	if escondido:
		lineas.append("NoDisplay=true")
	var fichero := FileAccess.open(ruta, FileAccess.WRITE)
	if fichero != null:
		fichero.store_string("\n".join(lineas) + "\n")
