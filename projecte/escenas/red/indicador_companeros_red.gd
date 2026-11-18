extends Node2D

## En la partida en red: el nombre de cada jugador encima de su personaje (el
## de la sala, que es el de la cuenta si se ha entrado) y, si un compañero
## está fuera de la pantalla, una flecha en el borde que apunta hacia él, con
## su nombre y el color de su personaje (peticiones de Adam, 17/11).
##
## Sin class_name: lo crea partida_red.gd con preload.

const Red := preload("res://globales/red.gd")
## Separación de la flecha con el borde de la pantalla.
const MARGEN := 36.0
## La flecha (16x16) está dibujada mirando a la derecha: se gira hacia él y
## se dibuja al doble.
const FLECHA := preload("res://medios/interfaz/red_flecha.png")
const TAMANO_FLECHA := 32.0
## La placa del nombre: 3 trozos de 8, 32 y 8 px, y 14 de alto. El nombre va
## en la fuente pixel a 11, que cabe justo en su hueco de 10 px.
const PLACA := preload("res://medios/interfaz/red_placa.png")
const LADO_PLACA := 8.0
const ALTO_PLACA := 14.0
const TAMANO_NOMBRE := 11
## Lo que sube el nombre desde los pies del personaje (mide 72 px de alto).
const ALTURA_NOMBRE := 78.0

var _partida: Node


func _init(partida: Node) -> void:
	_partida = partida


func _ready() -> void:
	# Se dibuja en el mundo (no en una capa de la interfaz), encima de la
	# partida: así toda la interfaz (el HUD, las mejoras, la pausa) le tapa.
	z_index = 50
	z_as_relative = false
	# La flecha y la placa son pixel art: sin suavizar.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _process(_delta: float) -> void:
	queue_redraw()


## Se calcula en la pantalla y se dibuja en el mundo: a_mundo pasa de una a
## otro (lo contrario de lo que hace la cámara).
func _draw() -> void:
	var local: Node = _partida.get_parent().get_node("Jugador")
	var pantalla := get_viewport_rect().size
	var del_mundo := get_viewport().get_canvas_transform()
	var a_mundo := del_mundo.affine_inverse()
	var fuente := EstiloInterfaz.fuente_pixel()
	for jugador in _partida.jugadores():
		var cambio: Node = jugador.get_node("CambioPersonaje")
		# Mirando no tiene personaje: no hay nada que señalar.
		if cambio.espectador():
			continue
		var color: Color = cambio.personaje_actual().color
		var nombre := _nombre(jugador)
		var donde: Vector2 = del_mundo * jugador.global_position
		var dentro := Rect2(Vector2.ZERO, pantalla).grow(-MARGEN).has_point(donde)
		if dentro:
			_texto(fuente, nombre, jugador.global_position - Vector2(0.0, ALTURA_NOMBRE), color)
		elif jugador != local:
			_flecha(fuente, nombre, donde, pantalla, color, a_mundo)


## La flecha en el borde, donde la línea del centro de la pantalla al
## compañero corta el borde, y su nombre al lado, hacia dentro.
func _flecha(fuente: Font, nombre: String, donde: Vector2, pantalla: Vector2, color: Color, a_mundo: Transform2D) -> void:
	var centro := pantalla / 2.0
	var hacia := (donde - centro).normalized()
	var medio := centro - Vector2(MARGEN, MARGEN)
	# Lo que hay que alargar la dirección hasta tocar el borde (el lado más cercano).
	var escala := minf(medio.x / maxf(absf(hacia.x), 0.001), medio.y / maxf(absf(hacia.y), 0.001))
	var punta := centro + hacia * escala
	draw_set_transform(a_mundo * (punta - hacia * TAMANO_FLECHA / 2.0), hacia.angle(), Vector2(2.0, 2.0))
	draw_texture(FLECHA, Vector2(-8.0, -8.0), color)
	draw_set_transform(Vector2.ZERO)
	_texto(fuente, nombre, a_mundo * (punta - hacia * (TAMANO_FLECHA + 12.0)), color)


## Centrado en ese punto (la línea de las letras), encima de su placa, que
## hace de fondo oscuro para que se lea sobre la horda.
func _texto(fuente: Font, texto: String, punto: Vector2, color: Color) -> void:
	var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANO_NOMBRE).x
	var caja := Rect2(punto - Vector2(ancho / 2.0 + LADO_PLACA + 1.0, 10.0), Vector2(ancho + LADO_PLACA * 2.0 + 2.0, ALTO_PLACA))
	caja.position = caja.position.round()
	_placa(caja, color)
	draw_string(fuente, caja.position + Vector2(LADO_PLACA + 1.0, 10.0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANO_NOMBRE, color)


## La placa de 3 trozos: los lados tal cual y el centro estirado a lo que mida
## el nombre.
func _placa(caja: Rect2, color: Color) -> void:
	var medio := caja.size.x - LADO_PLACA * 2.0
	draw_texture_rect_region(PLACA, Rect2(caja.position, Vector2(LADO_PLACA, ALTO_PLACA)), Rect2(0.0, 0.0, LADO_PLACA, ALTO_PLACA), color)
	draw_texture_rect_region(PLACA, Rect2(caja.position + Vector2(LADO_PLACA, 0.0), Vector2(medio, ALTO_PLACA)), Rect2(LADO_PLACA, 0.0, 32.0, ALTO_PLACA), color)
	draw_texture_rect_region(PLACA, Rect2(caja.position + Vector2(LADO_PLACA + medio, 0.0), Vector2(LADO_PLACA, ALTO_PLACA)), Rect2(40.0, 0.0, LADO_PLACA, ALTO_PLACA), color)


## El nombre con el que entró en la sala.
func _nombre(jugador: Node) -> String:
	var id: int = _partida.id_de(jugador)
	for datos in Red.actual.jugadores():
		if datos.id == id:
			return datos.nombre
	return ""
