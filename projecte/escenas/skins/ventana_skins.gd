extends Control

## El apartado de skins (de Alan, 18/11): la ventana que abre el botón SKINS
## del menú, o pulsar un personaje. Arriba, los bits que se tienen; debajo, las
## pestañas: ARMARIO (armario.gd, la skin de cada personaje), PERFIL
## (pestana_perfil.gd: título, marco, estela, icono y tema), MISIONES
## (pestana_misiones.gd), PASE (pestana_pase.gd), LOGROS (pestana_logros.gd) y
## TIENDA (pestana_tienda.gd). Una pestaña nueva se enciende poniéndola en
## _secciones.
##
## Sin class_name: lo crea el menú con preload, como sala_red.gd.

signal cerrado

const Armario := preload("res://escenas/skins/armario.gd")
const PestanaMisiones := preload("res://escenas/skins/pestana_misiones.gd")
const PestanaPase := preload("res://escenas/skins/pestana_pase.gd")
const PestanaLogros := preload("res://escenas/skins/pestana_logros.gd")
const PestanaTienda := preload("res://escenas/skins/pestana_tienda.gd")
const PestanaPerfil := preload("res://escenas/skins/pestana_perfil.gd")
## Las pestañas, en orden. Las que no tienen contenido salen apagadas.
const PESTANAS := ["ARMARIO", "PERFIL", "MISIONES", "PASE", "LOGROS", "TIENDA"]
const ContadorBits := preload("res://escenas/skins/contador_bits.gd")
const Piezas := preload("res://escenas/skins/piezas_cartera.gd")

var _armario: VBoxContainer
## El contenido de cada pestaña que ya existe, por su nombre.
var _secciones := {}
var _botones := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	var cabecera := HBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("SKINS", 36, EstiloInterfaz.NEON)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabecera.add_child(titulo)
	# Los bits que se tienen: la moneda girando y el número (contador_bits.gd).
	cabecera.add_child(ContadorBits.new())
	caja.add_child(cabecera)

	_armario = Armario.new()
	_secciones = {"ARMARIO": _armario, "PERFIL": PestanaPerfil.new(), "MISIONES": PestanaMisiones.new(), "PASE": PestanaPase.new(),
		"LOGROS": PestanaLogros.new(), "TIENDA": PestanaTienda.new()}
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 6)
	for nombre in PESTANAS:
		var existe: bool = nombre in _secciones
		var boton := EstiloInterfaz.boton(nombre if existe else nombre + " · PRONTO", _ver.bind(nombre), 130)
		boton.icon = Piezas.icono_pestana(nombre)
		if not existe:
			boton.disabled = true
			boton.tooltip_text = "Todavía no está."
		_botones[nombre] = boton
		fila.add_child(boton)
	caja.add_child(fila)
	caja.add_child(HSeparator.new())
	for nombre in _secciones:
		caja.add_child(_secciones[nombre])

	var volver := EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(volver)
	# Detrás de todo, la rejilla de circuito del lote (piezas_cartera.gd): el
	# PanelContainer pone sus hijos uno encima de otro, del tamaño de la caja.
	var con_fondo := PanelContainer.new()
	con_fondo.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	con_fondo.add_child(Piezas.fondo())
	con_fondo.add_child(caja)
	var exterior := VBoxContainer.new()
	exterior.add_child(con_fondo)
	add_child(EstiloInterfaz.ventana_centrada(exterior))
	visible = false


## Abre las skins en el armario, con ese personaje (su índice en el armario;
## el del menú es el mismo orden).
func abrir(indice := 0) -> void:
	visible = true
	_ver("ARMARIO")
	_armario.mostrar(indice)


func cerrar() -> void:
	visible = false
	cerrado.emit()


## Enseña esa pestaña: la suya se ve elegida (en neón) y las demás, normales.
func _ver(nombre: String) -> void:
	for otra in _secciones:
		_secciones[otra].visible = otra == nombre
		_botones[otra].add_theme_color_override("font_color", EstiloInterfaz.NEON if otra == nombre else EstiloInterfaz.TEXTO_SUAVE)
		_botones[otra].add_theme_color_override("icon_normal_color", EstiloInterfaz.NEON if otra == nombre else EstiloInterfaz.TEXTO_SUAVE)
	if _secciones[nombre].has_method("poner_al_dia"):
		_secciones[nombre].poner_al_dia()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		get_viewport().set_input_as_handled()
