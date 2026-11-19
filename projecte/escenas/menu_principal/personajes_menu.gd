extends HBoxContainer

## Los tres personajes en el menú principal, andando en el sitio y mirando de
## frente, al doble de tamaño: lo primero que se veía al abrir el juego era casi
## todo texto (mejoras propuestas, interfaz 6). Usan sus hojas de andar (6
## columnas de 64x72, una fila por dirección), de la skin que lleva cada uno.
## Son botones: al pulsar uno se abre el armario en ese personaje (elegido).
##
## Lo crea menu_principal.gd. Sin class_name: se carga con preload.

## Se ha pulsado ese personaje (su índice en PERSONAJES): el menú abre el
## armario (escenas/skins/armario.gd).
signal elegido(indice: int)

const DatosSkin := preload("res://recursos/skins/datos_skin.gd")
## En el mismo orden que el armario.
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
		recorte.region = Rect2(Vector2(0.0, fila * LADO.y), LADO)
		_recortes.append(recorte)
		# Un botón plano con el dibujo: se puede pulsar con ratón y con mando.
		var dibujo := Button.new()
		dibujo.flat = true
		dibujo.icon = recorte
		dibujo.expand_icon = true
		dibujo.custom_minimum_size = LADO * 2.0
		dibujo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		dibujo.tooltip_text = "Cambiar de skin"
		dibujo.pressed.connect(elegido.emit.bind(i))
		add_child(dibujo)
	_poner_hojas()
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)


## La hoja de andar de la skin que lleva cada uno (datos_skin.gd, elegida).
func _poner_hojas() -> void:
	for i in PERSONAJES.size():
		_recortes[i].atlas = DatosSkin.elegida(PERSONAJES[i]).hoja


## Método y no lambda: el menú se borra y GestorGuardado sigue (el error del
## 13/11 con la ventana de opciones).
func _al_cambiar_opcion(clave: String, _valor: Variant) -> void:
	if clave == "skins":
		_poner_hojas()


func _process(delta: float) -> void:
	_tiempo += delta
	# Desfasados dos columnas, para que no den los pasos a la vez.
	for i in _recortes.size():
		var columna := int(_tiempo * FOTOGRAMAS_POR_SEGUNDO + i * 2) % COLUMNAS
		_recortes[i].region.position.x = columna * LADO.x
