extends Control

## El panel del equipo, a la derecha, al pulsar C (o Select): una ficha de cada
## personaje con su retrato, su vida, la carga de su ulti, su herramienta y lo
## que la resiste el malware. Lo de abajo en el centro (quién juega, a quién
## se pasa y cuándo) lo lleva barra_equipo.gd.
##
## Solo escucha el bus: equipo_cambiado trae la vida de todos.
##
## Desde el 13/11 se dibuja con sprites (lote del panel del equipo), en grises
## teñidos del color de cada personaje: la ficha en tres estados (activo,
## listo y caído), el marco del retrato con su luz o su glitch, iconos y
## barras finas; la de la ulti brilla al estar lista. Antes era una caja con
## texto (más pequeña desde el 05/11). Con _draw y no con nodos, como la barra
## del equipo y el F3: son muchas piezas pequeñas y dos animaciones. Por eso
## mide lo mismo con «Texto grande» (decisión de Adam, 13/11): los píxeles
## quedan enteros.

const Entrada := preload("res://globales/entrada.gd")
const FICHA := preload("res://medios/interfaz/equipo_ficha.png")
const MARCO := preload("res://medios/interfaz/equipo_retrato_marco.png")
const ACTIVO := preload("res://medios/interfaz/equipo_activo.png")
const CAIDO := preload("res://medios/interfaz/equipo_caido.png")
const ICONOS := preload("res://medios/interfaz/equipo_iconos.png")
const CABECERA := preload("res://medios/interfaz/equipo_cabecera.png")
const BARRA := preload("res://medios/interfaz/equipo_barra.png")
const RELLENO := preload("res://medios/interfaz/equipo_barra_relleno.png")
const BRILLO := preload("res://medios/interfaz/equipo_barra_brillo.png")
## Los retratos de 32x32 dibujados para ese tamaño, como en el ranking.
const RETRATOS := {
	"Espadachín": preload("res://medios/interfaz/retrato_mini_espadachin.png"),
	"Mago": preload("res://medios/interfaz/retrato_mini_mago.png"),
	"Segador": preload("res://medios/interfaz/retrato_mini_segador.png"),
}
## El orden de la tira de iconos y de la de fichas.
enum Icono { VIDA, ULTI, HERRAMIENTA, RESISTENCIA, ACTIVO, LISTO, CAIDO, EQUIPO }
enum Estado { ACTIVO, LISTO, CAIDO }
const ANCHO := 232.0
const ALTO_FICHA := 62.0
const COLOR_ULTI := Color(1.0, 0.8, 0.2)
## Desde aquí la resistencia sale en rojo: ya conviene cambiar de personaje.
const RESISTENCIA_ALTA := 0.4

var _estado: Array = []
var _activo := 0
## Carga de la ulti de cada personaje, de 0 a 1.
var _ultis: Array = []
var _resistencia: Node
## Reloj de las animaciones (la luz, el glitch y el destello).
var _segundos := 0.0
var _fichas: Array[StyleBoxTexture] = []
var _cabecera: StyleBoxTexture


func _ready() -> void:
	# También en pausa: al caer un personaje, el panel tiene que enseñarlo caído
	# mientras se elige quién sigue.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visible = false
	# La ficha, en tres trozos de 40x40 (uno por estado), de 9 trozos con
	# margen 8; la cabecera, en horizontal: 18 a la izquierda (el emblema) y 6
	# a la derecha (la punta).
	for i in 3:
		_fichas.append(_estilo(FICHA, Rect2(i * 40, 0, 40, 40), 8, 8, 8))
	_cabecera = _estilo(CABECERA, Rect2(0, 0, 64, 16), 18, 6, 0)
	_resistencia = get_tree().get_first_node_in_group("resistencia_malware")
	BusEventos.equipo_cambiado.connect(_al_cambiar_equipo)
	BusEventos.ulti_cambiada.connect(func(cargas, _activo): _ultis = cargas)


func _estilo(textura: Texture2D, region: Rect2, izquierda: int, derecha: int, arriba_y_abajo: int) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	estilo.region_rect = region
	estilo.texture_margin_left = izquierda
	estilo.texture_margin_right = derecha
	estilo.texture_margin_top = arriba_y_abajo
	estilo.texture_margin_bottom = arriba_y_abajo
	return estilo


func _al_cambiar_equipo(personajes: Array, activo: int) -> void:
	_estado = personajes
	_activo = activo


func _unhandled_input(evento: InputEvent) -> void:
	# C o Select (la acción la añade teclas_antiguas.gd al empezar la partida).
	if evento.is_action_pressed("ver_equipo"):
		visible = not visible


func _process(delta: float) -> void:
	_segundos += delta
	if visible and not _estado.is_empty():
		# A la derecha y a media altura: arriba está la ficha del enemigo.
		size = Vector2(ANCHO, 20.0 + _estado.size() * (ALTO_FICHA + 4.0))
		var pantalla := get_viewport_rect().size
		position = Vector2(pantalla.x - ANCHO - 16.0, (pantalla.y - size.y) * 0.5)
		queue_redraw()


func _draw() -> void:
	if _estado.is_empty():
		return
	_cabecera.modulate_color = EstiloInterfaz.NEON
	draw_style_box(_cabecera, Rect2(0, 0, ANCHO, 16))
	_icono(Vector2(2, 2), Icono.EQUIPO, EstiloInterfaz.NEON)
	# Con el mando, el botón del mando, como los demás textos.
	var cabecera := "EQUIPO  [Select]" if Entrada.con_mando else "EQUIPO  [C]"
	draw_string(EstiloInterfaz.fuente_pixel(), Vector2(22, 12), cabecera, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, EstiloInterfaz.TEXTO)
	var fuente := EstiloInterfaz.tema().default_font
	for i in _estado.size():
		_dibujar_ficha(Vector2(0, 20.0 + i * (ALTO_FICHA + 4.0)), i, fuente)


func _dibujar_ficha(esquina: Vector2, i: int, fuente: Font) -> void:
	var datos: Dictionary = _estado[i]
	var personaje: DatosPersonaje = datos.personaje
	var estado: int = Estado.CAIDO if datos.caido else (Estado.ACTIVO if i == _activo else Estado.LISTO)
	var color: Color = EstiloInterfaz.TEXTO_SUAVE if datos.caido else personaje.color

	var ficha: StyleBoxTexture = _fichas[estado]
	ficha.modulate_color = color
	draw_style_box(ficha, Rect2(esquina, Vector2(ANCHO, ALTO_FICHA)))

	# El retrato con su marco; el activo, con la luz que da vueltas; el caído,
	# en gris y con la grieta y el glitch encima, en rojo.
	var marco := esquina + Vector2(9, 11)
	draw_texture(MARCO, marco, color)
	draw_texture(RETRATOS.get(personaje.nombre, personaje.retrato), marco + Vector2(4, 4), Color(0.45, 0.45, 0.45) if datos.caido else Color.WHITE)
	if estado == Estado.ACTIVO:
		var fotograma := int(_segundos / 0.1) % 4
		draw_texture_rect_region(ACTIVO, Rect2(marco - Vector2(2, 2), Vector2(44, 44)), Rect2(fotograma * 44, 0, 44, 44), color)
	elif estado == Estado.CAIDO:
		var fotograma := int(_segundos / 0.12) % 3
		draw_texture_rect_region(CAIDO, Rect2(marco + Vector2(4, 4), Vector2(32, 32)), Rect2(fotograma * 32, 0, 32, 32), EstiloInterfaz.DERROTA)

	# Nombre y estado.
	var x := esquina.x + 58.0
	var y := esquina.y
	_icono(Vector2(x, y + 6), [Icono.ACTIVO, Icono.LISTO, Icono.CAIDO][estado], color)
	draw_string(EstiloInterfaz.fuente_pixel(), Vector2(x + 16, y + 16), personaje.nombre.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)
	draw_string(fuente, Vector2(esquina.x + ANCHO - 70.0, y + 16), ["ACTIVO", "LISTO", "CAÍDO"][estado], HORIZONTAL_ALIGNMENT_RIGHT, 60, 10, EstiloInterfaz.TEXTO_SUAVE)

	# Vida: de rojo a verde, como la barra sobre el personaje.
	var vida: float = datos.vida / maxf(datos.maxima, 1.0)
	_icono(Vector2(x, y + 21), Icono.VIDA, color)
	_barra(Vector2(x + 16, y + 23), 100.0, vida, Color(1.0, 0.3, 0.3).lerp(Color(0.3, 1.0, 0.5), vida), false)
	draw_string(fuente, Vector2(x + 122, y + 30), "%d/%d" % [ceili(datos.vida), ceili(datos.maxima)], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, EstiloInterfaz.TEXTO)

	# Ulti: dorada; llena, con el destello que la recorre.
	var ulti := _ulti(i)
	var lista := ulti >= 1.0
	_icono(Vector2(x, y + 34), Icono.ULTI, COLOR_ULTI if lista else color)
	_barra(Vector2(x + 16, y + 36), 100.0, ulti, COLOR_ULTI, lista)
	draw_string(fuente, Vector2(x + 122, y + 43), "LISTA" if lista else "%d %%" % roundi(ulti * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLOR_ULTI if lista else EstiloInterfaz.TEXTO_SUAVE)

	# Herramienta y lo que la resiste el malware (cambia cada 20 s y no tiene
	# señal en el bus: se lee del nodo, como el panel técnico).
	var resistencia: float = 0.0 if _resistencia == null else _resistencia.resistencia(datos.arma)
	var alta := resistencia >= RESISTENCIA_ALTA
	_icono(Vector2(x, y + 47), Icono.HERRAMIENTA, color)
	_texto_que_quepa(fuente, Vector2(x + 16, y + 57), datos.arma.nombre, 88.0, EstiloInterfaz.TEXTO_SUAVE)
	_icono(Vector2(x + 108, y + 47), Icono.RESISTENCIA, EstiloInterfaz.DERROTA if alta else color)
	draw_string(fuente, Vector2(x + 122, y + 57), "%d %%" % roundi(resistencia * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, EstiloInterfaz.DERROTA if alta else EstiloInterfaz.TEXTO)


## Un texto de letra 10 que encoge hasta caber en ancho: los nombres largos
## («Análisis heurístico», «Firewall perimetral») pisaban el escudo de la
## resistencia. Como los valores del panel técnico.
func _texto_que_quepa(fuente: Font, posicion: Vector2, texto: String, ancho: float, color: Color) -> void:
	var tamano := 10
	while tamano > 7 and fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x > ancho:
		tamano -= 1
	draw_string(fuente, posicion, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)


func _icono(posicion: Vector2, icono: int, color: Color) -> void:
	draw_texture_rect_region(ICONOS, Rect2(posicion, Vector2(12, 12)), Rect2(icono * 12, 0, 12, 12), color)


## Barra fina: el marco en 3 trozos (3 px a cada lado), el relleno recortado
## a lo que haya y, si está llena, el destello encima.
func _barra(posicion: Vector2, ancho: float, proporcion: float, color: Color, brillo: bool) -> void:
	draw_texture_rect_region(BARRA, Rect2(posicion, Vector2(3, 7)), Rect2(0, 0, 3, 7))
	draw_texture_rect_region(BARRA, Rect2(posicion + Vector2(3, 0), Vector2(ancho - 6.0, 7)), Rect2(3, 0, 58, 7))
	draw_texture_rect_region(BARRA, Rect2(posicion + Vector2(ancho - 3.0, 0), Vector2(3, 7)), Rect2(61, 0, 3, 7))
	var lleno := roundf((ancho - 4.0) * clampf(proporcion, 0.0, 1.0))
	if lleno > 0.0:
		draw_texture_rect_region(RELLENO, Rect2(posicion + Vector2(2, 2), Vector2(lleno, 3)), Rect2(0, 0, minf(lleno, 60.0), 3), color)
	if brillo:
		var fotograma := int(_segundos / 0.06) % 6
		draw_texture_rect_region(BRILLO, Rect2(posicion + Vector2(2, 2), Vector2(ancho - 4.0, 3)), Rect2(fotograma * 60, 0, 60, 3))


func _ulti(indice: int) -> float:
	return _ultis[indice] if indice < _ultis.size() else 0.0
