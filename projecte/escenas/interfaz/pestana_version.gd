extends GridContainer

## La pestaña VERSIÓN de las opciones, solo en el menú (24/11; hasta entonces
## estaba debajo del menú): la versión del juego y, si hay una nueva,
## ACTUALIZAR; y VERSIONES, que abre su ventana (versiones_pedidas). Abierto
## desde el lanzador, las versiones las lleva él, y en la web no hay nada que
## instalar: ahí solo sale la versión. Las consultas a GitHub las hace el
## Actualizador; aquí solo se enseña lo que va diciendo.
##
## Sin class_name: la crea panel_opciones.gd con preload.

signal versiones_pedidas

const InstaladorJuego := preload("res://globales/instalador_juego.gd")

var _version: Label
var _actualizar: Button
var _hay_nueva: Label
## Si este juego enseña ACTUALIZAR y VERSIONES. Se mira el argumento aquí y no
## se le pregunta al Actualizador: el de un ejecutable viejo no tendría esa
## función.
var _con_versiones := true


## El nombre, antes de entrar en las pestañas: es el título de la suya.
func _init() -> void:
	name = "Versión"


func _ready() -> void:
	columns = 2
	add_theme_constant_override("h_separation", 24)
	add_theme_constant_override("v_separation", 14)
	_con_versiones = not "--desde-lanzador" in OS.get_cmdline_user_args() and not OS.has_feature("web")
	add_child(EstiloInterfaz.etiqueta("Versión", 16))
	_version = EstiloInterfaz.etiqueta("", 16, EstiloInterfaz.TEXTO_SUAVE)
	add_child(_version)
	_hay_nueva = EstiloInterfaz.etiqueta("Hay una nueva", 16)
	add_child(_hay_nueva)
	_actualizar = EstiloInterfaz.boton("ACTUALIZAR", InstaladorJuego.pulsar_actualizar, 220)
	add_child(_actualizar)
	if _con_versiones:
		add_child(EstiloInterfaz.etiqueta("Cualquier versión", 16))
		add_child(EstiloInterfaz.boton("VERSIONES", versiones_pedidas.emit, 220))
	Actualizador.estado_cambiado.connect(_mostrar)
	_mostrar()


func _mostrar() -> void:
	_version.text = Actualizador.texto()
	var hay := _con_versiones and Actualizador.estado in [Actualizador.Estado.HAY_ACTUALIZACION, Actualizador.Estado.HAY_JUEGO_NUEVO]
	_actualizar.visible = hay
	_hay_nueva.visible = hay
	if Actualizador.estado == Actualizador.Estado.HAY_ACTUALIZACION:
		_version.add_theme_color_override("font_color", EstiloInterfaz.VICTORIA)
