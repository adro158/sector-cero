extends Button

## Una tarjeta de la ventana JUGAR (el modo o la dificultad): un botón con la
## pieza menu_tarjeta.png (normal, encima y elegida) y dentro un dibujo, un
## título y una línea debajo. Se marca como los botones de alternar, y en un
## ButtonGroup solo queda una elegida. Coge el foco, como cualquier botón: se
## elige con el ratón, el teclado o el mando.
##
## vertical: el dibujo encima del texto (la dificultad) o a la izquierda (el
## modo). Sin class_name: la crea ventana_jugar.gd con preload.

const Piezas := preload("res://escenas/menu_principal/piezas_menu.gd")

var _detalle: Label


func _init(dibujo: TextureRect, titulo: String, detalle: String, color: Color, vertical: bool, grupo: ButtonGroup) -> void:
	toggle_mode = true
	button_group = grupo
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Apagada sin elegir; con el ratón encima o elegida, de su color.
	add_theme_stylebox_override("normal", Piezas.tarjeta(Piezas.Tarjeta.NORMAL, EstiloInterfaz.TEXTO_SUAVE))
	add_theme_stylebox_override("hover", Piezas.tarjeta(Piezas.Tarjeta.ENCIMA, color))
	for estado in ["pressed", "hover_pressed"]:
		add_theme_stylebox_override(estado, Piezas.tarjeta(Piezas.Tarjeta.ELEGIDA, color))
	add_theme_stylebox_override("focus", EstiloInterfaz.boton_estilo(EstiloInterfaz.Boton.FOCO, color))

	var caja: BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	caja.add_theme_constant_override("separation", 6 if vertical else 14)
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	caja.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 14)
	# Lo de dentro no coge el ratón: el click es del botón.
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caja)
	dibujo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(dibujo)
	var textos := VBoxContainer.new()
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var nombre := EstiloInterfaz.etiqueta(titulo, 22, color)
	_detalle = EstiloInterfaz.etiqueta(detalle, 13 if vertical else 14, EstiloInterfaz.TEXTO_SUAVE)
	for etiqueta in [nombre, _detalle]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if vertical else HORIZONTAL_ALIGNMENT_LEFT
		etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		textos.add_child(etiqueta)
	caja.add_child(textos)
	# El botón no mide su contenido solo: lo que pida la caja, más el borde.
	custom_minimum_size = Vector2(0.0, 118.0 if vertical else 72.0)


## Cambia la línea de debajo del título (CONTINUAR la pone con el resumen de
## la partida guardada, que llega después).
func poner_detalle(texto: String) -> void:
	_detalle.text = texto
