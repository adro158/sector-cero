extends RefCounted

## Las teclas y los botones del mando dibujados (lote 9): una tira de 20x20 por
## tecla, en el orden de ORDEN. Los usan la barra del equipo (las letras que
## llevan a cada personaje) y la lista de controles de las reglas, que hasta
## el 26/10 era una línea de texto.
##
## Sin class_name: se carga con preload, como embestida_horda.gd.

const TIRA := preload("res://medios/interfaz/teclas.png")
const LADO := 20.0
## El mismo orden que la tira (lote9c.py, TECLAS).
const ORDEN := ["Q", "E", "R", "C", "W", "A", "S", "D", "P", "1", "2", "3",
	"Tab", "Esc", "Enter", "F1", "F3", "Arriba", "Abajo", "Izquierda", "Derecha",
	"RatonIzquierdo", "RatonDerecho", "MandoA", "MandoB", "MandoX", "MandoY",
	"LB", "RB", "Start", "Select", "Stick", "Cruceta"]
## Cada control: las teclas y botones que lo hacen y lo que hace.
const CONTROLES := [
	[["W", "A", "S", "D", "Arriba", "Abajo", "Izquierda", "Derecha", "Stick", "Cruceta"], "Moverse"],
	[["E", "Tab", "MandoY", "RB"], "Personaje siguiente"],
	[["Q", "LB"], "Personaje anterior"],
	[["R", "MandoB"], "Ulti (el Mago apunta con el ratón y la lanza con click)"],
	[["C", "Select"], "Ver el equipo"],
	[["Esc", "P", "Start"], "Pausa"],
	[["RatonIzquierdo", "1", "2", "3", "MandoA"], "Elegir mejora"],
	[["RatonIzquierdo", "RatonDerecho"], "Ficha del enemigo: abrir y cerrar"],
	[["F3"], "Panel técnico"],
	[["F1"], "Menú de desarrollador (la partida deja de contar para el ranking)"],
]


## Dónde está una tecla en la tira.
static func region(nombre: String) -> Rect2:
	return Rect2(ORDEN.find(nombre) * LADO, 0.0, LADO, LADO)


static func icono(nombre: String) -> AtlasTexture:
	var trozo := AtlasTexture.new()
	trozo.atlas = TIRA
	trozo.region = region(nombre)
	return trozo


## La tabla de controles de las reglas: los dibujos a la izquierda y lo que
## hacen a la derecha.
static func tabla_controles() -> GridContainer:
	var tabla := GridContainer.new()
	tabla.columns = 2
	tabla.add_theme_constant_override("h_separation", 18)
	tabla.add_theme_constant_override("v_separation", 6)
	for control in CONTROLES:
		var teclas := HBoxContainer.new()
		teclas.add_theme_constant_override("separation", 3)
		for nombre in control[0]:
			var imagen := TextureRect.new()
			imagen.texture = icono(nombre)
			imagen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			teclas.add_child(imagen)
		tabla.add_child(teclas)
		tabla.add_child(EstiloInterfaz.etiqueta(control[1], 14))
	return tabla
