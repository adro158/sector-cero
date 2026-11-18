extends Control

## El apartado de skins (de Alan, 18/11): la ventana que abre el botón SKINS
## del menú, o pulsar un personaje. Tiene pestañas: ARMARIO (armario.gd, donde
## se elige la skin de cada personaje) y, apagadas hasta que se decida cómo
## van, PASE y TIENDA (issue #16). Para añadir una, se pone su contenido en
## _secciones y se enciende su botón.
##
## Sin class_name: lo crea el menú con preload, como sala_red.gd.

signal cerrado

const Armario := preload("res://escenas/skins/armario.gd")
## Las pestañas, en orden. Las que no tienen contenido salen apagadas.
const PESTANAS := ["ARMARIO", "PASE", "TIENDA"]

var _armario: VBoxContainer
## El contenido de cada pestaña que ya existe, por su nombre.
var _secciones := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("SKINS", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	_armario = Armario.new()
	_secciones = {"ARMARIO": _armario}
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 8)
	for nombre in PESTANAS:
		var existe: bool = nombre in _secciones
		var boton := EstiloInterfaz.boton(nombre if existe else nombre + " · PRONTO", func(): pass, 200)
		# La que hay, encendida en neón; las que faltan, apagadas y con «pronto».
		if existe:
			boton.add_theme_color_override("font_color", EstiloInterfaz.NEON)
		else:
			boton.disabled = true
			boton.tooltip_text = "Todavía no está: se decidirá cómo funciona."
		fila.add_child(boton)
	caja.add_child(fila)
	caja.add_child(HSeparator.new())
	caja.add_child(_armario)

	var volver := EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(volver)
	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false


## Abre las skins en el armario, con ese personaje (su índice en el armario;
## el del menú es el mismo orden).
func abrir(indice := 0) -> void:
	visible = true
	_armario.mostrar(indice)


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		get_viewport().set_input_as_handled()
