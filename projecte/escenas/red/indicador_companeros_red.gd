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
const TAMANO_FLECHA := 14.0
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


func _process(_delta: float) -> void:
	queue_redraw()


## Se calcula en la pantalla y se dibuja en el mundo: a_mundo pasa de una a
## otro (lo contrario de lo que hace la cámara).
func _draw() -> void:
	var local: Node = _partida.get_parent().get_node("Jugador")
	var pantalla := get_viewport_rect().size
	var del_mundo := get_viewport().get_canvas_transform()
	var a_mundo := del_mundo.affine_inverse()
	var fuente := EstiloInterfaz.tema().default_font
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
	var lado := hacia.orthogonal() * TAMANO_FLECHA * 0.6
	var base := punta - hacia * TAMANO_FLECHA
	draw_colored_polygon(PackedVector2Array([a_mundo * punta, a_mundo * (base + lado), a_mundo * (base - lado)]), color)
	_texto(fuente, nombre, a_mundo * (punta - hacia * (TAMANO_FLECHA + 16.0)), color)


## Centrado en ese punto, con contorno oscuro para que se lea sobre la horda.
func _texto(fuente: Font, texto: String, punto: Vector2, color: Color) -> void:
	var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	var esquina := punto - Vector2(ancho / 2.0, 0.0)
	draw_string_outline(fuente, esquina, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color(0.02, 0.04, 0.07))
	draw_string(fuente, esquina, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)


## El nombre con el que entró en la sala.
func _nombre(jugador: Node) -> String:
	var id: int = _partida.id_de(jugador)
	for datos in Red.actual.jugadores():
		if datos.id == id:
			return datos.nombre
	return ""
