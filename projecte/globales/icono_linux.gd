extends RefCounted

## El icono en Linux. Un ejecutable de Linux no lleva icono dentro, como el
## .exe de Windows, y muchos escritorios (GNOME en Wayland, el de Ubuntu) no
## usan el icono que pone la ventana: buscan un fichero .desktop instalado
## cuyo StartupWMClass sea el nombre de la ventana, que Godot saca del nombre
## del proyecto ("Sector Cero"). Así que el juego, al arrancar, guarda su
## icono y escribe ese .desktop en la carpeta del usuario. De paso, el juego
## sale en el menú de aplicaciones.
##
## Lo llama transicion.gd, que llega con el .pck: también sirve para los
## ejecutables que se actualizaron sin bajar el juego entero.

const ICONO := "res://medios/icono/icono.png"
const NOMBRE := "sector-cero"


static func instalar() -> void:
	var datos := OS.get_environment("XDG_DATA_HOME")
	if datos.is_empty():
		datos = OS.get_environment("HOME").path_join(".local/share")
	var carpeta_iconos := datos.path_join("icons/hicolor/256x256/apps")
	var carpeta_aplicaciones := datos.path_join("applications")
	DirAccess.make_dir_recursive_absolute(carpeta_iconos)
	DirAccess.make_dir_recursive_absolute(carpeta_aplicaciones)

	var icono := carpeta_iconos.path_join(NOMBRE + ".png")
	load(ICONO).get_image().save_png(icono)

	var texto := "\n".join([
		"[Desktop Entry]",
		"Type=Application",
		"Name=Sector Cero",
		"Comment=Eres un antivirus. Tu ordenador está infectado.",
		# Entre comillas por si la ruta tiene espacios.
		"Exec=\"%s\"" % OS.get_executable_path(),
		"Icon=" + icono,
		"StartupWMClass=" + ProjectSettings.get_setting("application/config/name"),
		"Categories=Game;",
		"Terminal=false",
		"",
	])
	var ruta := carpeta_aplicaciones.path_join(NOMBRE + ".desktop")
	# Solo se escribe si ha cambiado (por ejemplo, el juego se ha movido).
	if FileAccess.file_exists(ruta) and FileAccess.get_file_as_string(ruta) == texto:
		return
	var fichero := FileAccess.open(ruta, FileAccess.WRITE)
	if fichero != null:
		fichero.store_string(texto)
