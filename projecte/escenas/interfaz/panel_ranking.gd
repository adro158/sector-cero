extends Control

## Ventana del ranking en el menú: las 10 mejores partidas de este ordenador,
## con el orden de GestorGuardado (victorias de la más rápida a la más lenta y
## después derrotas de la que más aguantó).
##
## Sin class_name: el menú la carga con preload (ver embestida_horda.gd).

signal cerrado

const Dificultad := preload("res://globales/dificultad.gd")
## Oro, plata y bronce en fila, de 16x16: los tres primeros puestos (lote 9).
const MEDALLAS := preload("res://medios/interfaz/medallas_ranking.png")
## Los mini retratos de 32x32 (lote 9), por el nombre que guarda el ranking.
const MINI_RETRATOS := {
	"Espadachín": preload("res://medios/interfaz/retrato_mini_espadachin.png"),
	"Mago": preload("res://medios/interfaz/retrato_mini_mago.png"),
	"Segador": preload("res://medios/interfaz/retrato_mini_segador.png"),
}
const COLUMNAS := ["#", "NOMBRE", "RESULTADO", "TIEMPO", "NIVEL", "ELIMINADOS", "PERSONAJE", "DIFICULTAD"]

var _tabla: GridContainer
var _volver: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("RANKING", 32, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	_tabla = GridContainer.new()
	_tabla.columns = COLUMNAS.size()
	_tabla.add_theme_constant_override("h_separation", 28)
	_tabla.add_theme_constant_override("v_separation", 8)
	var centro := CenterContainer.new()
	centro.add_child(_tabla)
	caja.add_child(centro)

	_volver = EstiloInterfaz.boton("VOLVER  [Esc]", cerrar)
	_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_volver)

	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false


## Se rellena al abrir, así siempre muestra lo último guardado.
func abrir() -> void:
	for hijo in _tabla.get_children():
		hijo.queue_free()
	var partidas := GestorGuardado.ranking()
	if partidas.is_empty():
		_tabla.columns = 1
		_tabla.add_child(EstiloInterfaz.etiqueta("Todavía no hay partidas en el ranking.", 16))
	else:
		_tabla.columns = COLUMNAS.size()
		for columna in COLUMNAS:
			_tabla.add_child(EstiloInterfaz.etiqueta(columna, 14, EstiloInterfaz.TEXTO_SUAVE))
	for i in partidas.size():
		var partida: Dictionary = partidas[i]
		var color := EstiloInterfaz.VICTORIA if partida.victoria else EstiloInterfaz.TEXTO
		var tiempo := int(partida.tiempo)
		_tabla.add_child(_puesto(i, color))
		for texto in [partida.nombre, "Victoria" if partida.victoria else "Derrota",
				"%02d:%02d" % [tiempo / 60, tiempo % 60], str(partida.nivel), str(partida.eliminados)]:
			_tabla.add_child(_celda(texto, color))
		_tabla.add_child(_personaje(partida.personaje, color))
		_tabla.add_child(_celda(Dificultad.DIFICULTADES[partida.get("dificultad", "media")].nombre, color))

	visible = true
	_volver.grab_focus()


## El puesto: una medalla para los tres primeros y el número para los demás.
func _puesto(i: int, color: Color) -> Control:
	if i >= 3:
		return _celda(str(i + 1), color)
	var medalla := AtlasTexture.new()
	medalla.atlas = MEDALLAS
	medalla.region = Rect2(i * 16.0, 0.0, 16.0, 16.0)
	var icono := TextureRect.new()
	icono.texture = medalla
	icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icono.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	return icono


## Un texto de una fila, centrado en su altura: la fila es más alta que el
## texto por el mini retrato.
func _celda(texto: String, color: Color) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, 16, color)
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return etiqueta


## El personaje con el que acabó: su mini retrato y su nombre.
func _personaje(nombre: String, color: Color) -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 8)
	if MINI_RETRATOS.has(nombre):
		var retrato := TextureRect.new()
		retrato.texture = MINI_RETRATOS[nombre]
		retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fila.add_child(retrato)
	var etiqueta := EstiloInterfaz.etiqueta(nombre, 16, color)
	etiqueta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(etiqueta)
	return fila


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()
