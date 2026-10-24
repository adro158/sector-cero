extends HBoxContainer

## Los tres personajes en el menú principal, andando en el sitio y mirando de
## frente, al doble de tamaño: lo primero que se veía al abrir el juego era casi
## todo texto (mejoras propuestas, interfaz 6). Usan sus hojas de andar (6
## columnas de 64x72, una fila por dirección).
##
## Lo crea menu_principal.gd. Sin class_name: se carga con preload.

const PERSONAJES := [
	preload("res://recursos/personajes/datos/mago.tres"),
	preload("res://recursos/personajes/datos/espadachin.tres"),
	preload("res://recursos/personajes/datos/segador.tres"),
]
const LADO := Vector2(64.0, 72.0)
const COLUMNAS := 6
## Lo mismo que en la partida (controlador_jugador.gd).
const FOTOGRAMAS_POR_SEGUNDO := 7.7

## Un recorte de su hoja por personaje: se mueve de columna en columna.
var _recortes: Array[AtlasTexture] = []
var _tiempo := 0.0


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 56)
	var fila := Direcciones8.fila(Vector2.DOWN)
	for i in PERSONAJES.size():
		var recorte := AtlasTexture.new()
		recorte.atlas = PERSONAJES[i].hoja
		recorte.region = Rect2(Vector2(0.0, fila * LADO.y), LADO)
		_recortes.append(recorte)
		var dibujo := TextureRect.new()
		dibujo.texture = recorte
		dibujo.custom_minimum_size = LADO * 2.0
		dibujo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dibujo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		dibujo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(dibujo)


func _process(delta: float) -> void:
	_tiempo += delta
	# Desfasados dos columnas, para que no den los pasos a la vez.
	for i in _recortes.size():
		var columna := int(_tiempo * FOTOGRAMAS_POR_SEGUNDO + i * 2) % COLUMNAS
		_recortes[i].region.position.x = columna * LADO.x
