extends VBoxContainer

## Elegir la dificultad en el menú principal: tres botones, de los que solo
## uno está marcado, y debajo qué cambia. Se guarda en las opciones, así que la
## siguiente vez sale la misma.
##
## Sin class_name: el menú lo carga con preload (ver embestida_horda.gd).

const Dificultad := preload("res://globales/dificultad.gd")
const COLORES := {
	"facil": EstiloInterfaz.VICTORIA,
	"media": EstiloInterfaz.NEON,
	"dificil": EstiloInterfaz.DERROTA,
}

var _botones := {}
var _explicacion: Label


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 10)
	fila.add_child(EstiloInterfaz.etiqueta("DIFICULTAD", 16, EstiloInterfaz.TEXTO_SUAVE))
	# Con un ButtonGroup, marcar un botón desmarca los otros.
	var grupo := ButtonGroup.new()
	for clave in Dificultad.DIFICULTADES:
		var boton := EstiloInterfaz.boton(Dificultad.DIFICULTADES[clave].nombre, _elegir.bind(clave), 130)
		boton.toggle_mode = true
		boton.button_group = grupo
		boton.add_theme_color_override("font_pressed_color", COLORES[clave])
		_botones[clave] = boton
		fila.add_child(boton)
	add_child(fila)

	_explicacion = EstiloInterfaz.etiqueta("", 14)
	_explicacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_explicacion)
	_mostrar(Dificultad.actual())


func _elegir(clave: String) -> void:
	GestorGuardado.cambiar_opcion("dificultad", clave)
	_mostrar(clave)


func _mostrar(clave: String) -> void:
	_botones[clave].button_pressed = true
	_explicacion.text = Dificultad.DIFICULTADES[clave].explicacion
	_explicacion.add_theme_color_override("font_color", COLORES[clave])
