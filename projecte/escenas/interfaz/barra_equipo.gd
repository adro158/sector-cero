extends Control

## La barra del equipo, abajo en el centro (lote 9): una ranura con el retrato
## de cada personaje. En medio, el que juega, más arriba y encendido; a los
## lados, el anterior y el siguiente, con la letra que lleva a cada uno (Q y
## E, o LB y RB con el mando). Debajo de cada uno, su vida, y alrededor, la
## carga de su ulti, que brilla cuando está lista. Mientras no se puede
## cambiar, los de los lados se oscurecen de arriba abajo con un reloj.
## Encima, una línea con el nombre y la herramienta del que juega y, con el
## escudo de NÚCLEO CERO, de quién son las anclas que quedan.
##
## Hasta el 26/10 todo esto era una línea de texto (panel_equipo.gd).
## Solo escucha el bus. Sin class_name: lo crea hud.gd con preload.

const RANURA := preload("res://medios/interfaz/equipo_ranura.png")
const CARGA_ULTI := preload("res://medios/interfaz/equipo_ulti.png")
const ESPERA := preload("res://medios/interfaz/equipo_espera.png")
const VIDA_MARCO := preload("res://medios/interfaz/equipo_vida_marco.png")
const VIDA_RELLENO := preload("res://medios/interfaz/equipo_vida_relleno.png")
const ICONOS_AVISO := preload("res://medios/interfaz/aviso_iconos.png")
## El de las anclas en la tira de iconos de los avisos.
const ICONO_ESCUDO := 4
const COLOR_ULTI := Color(1.0, 0.8, 0.2)
const LADO := 72.0
## Lo que separa una ranura de otra y lo que sube la del que juega.
const SEPARACION := 86.0
const SUBE := 8.0
const ALTO := 158.0
## Los fotogramas de «lista» de la carga de la ulti, en bucle.
const SEGUNDOS_LISTA := 0.12

var _estado: Array = []
var _activo := 0
var _espera := 0.0
## Lo que había que esperar al cambiar: para saber qué parte queda.
var _espera_total := 1.0
var _ultis: Array = []
var _anclas: Array = []
var _con_mando := false
var _tiempo := 0.0


func _ready() -> void:
	# También en pausa: al caer un personaje se tiene que ver caído mientras se
	# elige quién sigue.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	offset_left = -320.0
	offset_right = 320.0
	offset_top = -ALTO
	offset_bottom = 0.0
	BusEventos.equipo_cambiado.connect(_al_cambiar_equipo)
	BusEventos.ulti_cambiada.connect(func(cargas, _activo): _ultis = cargas)
	BusEventos.personaje_cambiado.connect(_al_cambiar_personaje)
	BusEventos.anclas_pendientes.connect(func(personajes): _anclas = personajes)


func _al_cambiar_equipo(personajes: Array, activo: int) -> void:
	_estado = personajes
	_activo = activo


func _al_cambiar_personaje(_actual, _arma, _siguiente, espera: float) -> void:
	_espera = espera
	if espera > 0.0:
		_espera_total = espera


## Con qué se juega: el mando, o el teclado y el ratón. _input, y no
## _unhandled_input, para enterarse aunque otro se quede el evento.
func _input(evento: InputEvent) -> void:
	if evento is InputEventJoypadButton or (evento is InputEventJoypadMotion and absf(evento.axis_value) > 0.5):
		_con_mando = true
	elif evento is InputEventKey or evento is InputEventMouseButton:
		_con_mando = false


func _process(delta: float) -> void:
	# Cuenta atrás propia: se sabe cuánto faltaba al cambiar, y no avanza en
	# pausa, como el juego.
	if not get_tree().paused:
		_espera = maxf(_espera - delta, 0.0)
		_tiempo += delta
	queue_redraw()


func _draw() -> void:
	if _estado.is_empty():
		return
	_escribir_linea()
	# Siempre en el mismo orden alrededor del que juega: el anterior a la
	# izquierda y el siguiente a la derecha. Q y E van al primero vivo en ese
	# sentido, que puede ser el del otro lado si uno ha caído.
	var q := _vivo_desde(-1)
	var e := _vivo_desde(1)
	for lado in [-1, 1, 0]:
		var indice := posmod(_activo + lado, _estado.size())
		var teclas := PackedStringArray()
		if indice != _activo and indice == q:
			teclas.append(_boton("Q", "LB"))
		if indice != _activo and indice == e:
			teclas.append(_boton("E", "RB"))
		_dibujar_ranura(indice, Vector2(size.x / 2.0 - LADO / 2.0 + lado * SEPARACION, 44.0 - (SUBE if lado == 0 else 0.0)), " ".join(teclas))


func _dibujar_ranura(indice: int, esquina: Vector2, teclas: String) -> void:
	var datos: Dictionary = _estado[indice]
	var personaje: DatosPersonaje = datos.personaje
	var juega := indice == _activo
	var fuente := get_theme_default_font()
	var color: Color = personaje.color if juega else personaje.color.darkened(0.35)
	if datos.caido:
		color = Color(0.4, 0.4, 0.4)
	draw_texture(RANURA, esquina, color)
	var retrato := Color.WHITE if juega else Color(0.75, 0.75, 0.75)
	if datos.caido:
		retrato = Color(0.35, 0.35, 0.35)
	if personaje.retrato != null:
		draw_texture(personaje.retrato, esquina + Vector2(4.0, 4.0), retrato)

	# La carga de la ulti: un borde que se llena, y en bucle cuando está lista.
	var carga := _ulti(indice)
	var fotograma := -1
	if carga >= 1.0:
		fotograma = 8 + int(_tiempo / SEGUNDOS_LISTA) % 4
	elif carga >= 1.0 / 8.0:
		fotograma = int(carga * 8.0) - 1
	if fotograma >= 0 and not datos.caido:
		var tinte := COLOR_ULTI if juega else Color(COLOR_ULTI, 0.7)
		draw_texture_rect_region(CARGA_ULTI, Rect2(esquina - Vector2(4.0, 4.0), Vector2(80.0, 80.0)), Rect2(fotograma * 80.0, 0.0, 80.0, 80.0), tinte)

	# La vida, debajo.
	var parte: float = clampf(datos.vida / datos.maxima, 0.0, 1.0)
	var debajo := esquina + Vector2(0.0, LADO + 6.0)
	draw_texture(VIDA_MARCO, debajo)
	var ancho := VIDA_RELLENO.get_width() * parte
	draw_texture_rect_region(VIDA_RELLENO, Rect2(debajo + Vector2(2.0, 2.0), Vector2(ancho, 4.0)), Rect2(0.0, 0.0, ancho, 4.0),
		Color(1.0, 0.3, 0.3).lerp(Color(0.3, 1.0, 0.5), parte))

	var tamano := EstiloInterfaz.tamano_texto(13)
	if datos.caido:
		_texto(fuente, esquina + Vector2(0.0, 40.0), "CAÍDO", tamano, EstiloInterfaz.DERROTA)
		return
	# Esperando el cambio: se oscurece desde arriba lo que falta, con el reloj.
	if not juega and _espera > 0.0:
		var falta := clampf(_espera / _espera_total, 0.0, 1.0)
		draw_rect(Rect2(esquina + Vector2(4.0, 4.0), Vector2(64.0, 64.0 * falta)), Color(0.0, 0.0, 0.0, 0.6))
		draw_texture(ESPERA, esquina + Vector2(28.0, 18.0))
		_texto(fuente, esquina + Vector2(0.0, 52.0), "%d s" % ceili(_espera), tamano, EstiloInterfaz.TEXTO)
	elif teclas != "":
		# La letra que lleva a él, en una pestaña arriba a la izquierda.
		var caja := Rect2(esquina + Vector2(4.0, 4.0), Vector2(fuente.get_string_size(teclas, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x + 8.0, tamano + 4.0))
		draw_rect(caja, Color(0.0, 0.0, 0.0, 0.75))
		draw_string(fuente, caja.position + Vector2(4.0, tamano), teclas, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color.lightened(0.3))
	# Con el escudo, el candado en los que tienen anclas sin romper, parpadeando.
	if personaje in _anclas and int(_tiempo * 3.0) % 2 == 0:
		draw_texture_rect_region(ICONOS_AVISO, Rect2(esquina + Vector2(50.0, 6.0), Vector2(16.0, 16.0)), Rect2(ICONO_ESCUDO * 16.0, 0.0, 16.0, 16.0), personaje.color)
	if juega and carga >= 1.0:
		_texto(fuente, esquina + Vector2(0.0, LADO + 30.0), "[%s] ¡ULTI!" % _boton("R", "B"), tamano, COLOR_ULTI)


## La línea de encima: quién juega y con qué, y lo que hay que saber.
func _escribir_linea() -> void:
	var actual: Dictionary = _estado[_activo]
	var linea := "%s · %s" % [actual.personaje.nombre.to_upper(), actual.arma.nombre]
	if not _anclas.is_empty():
		var nombres := PackedStringArray()
		for personaje in _anclas:
			nombres.append(personaje.nombre.to_upper())
		linea += "      ANCLAS: " + ", ".join(nombres)
	elif _vivo_desde(1) == _activo:
		linea += "      último en pie"
	else:
		linea += "      [%s] equipo" % _boton("C", "Select")
	_texto(get_theme_default_font(), Vector2(0.0, 22.0), linea, EstiloInterfaz.tamano_texto(15), actual.personaje.color, size.x)


## Texto centrado en un ancho, con contorno oscuro para que se lea encima del
## suelo y de la horda.
func _texto(fuente: Font, donde: Vector2, texto: String, tamano: int, color: Color, ancho := LADO) -> void:
	draw_string_outline(fuente, donde, texto, HORIZONTAL_ALIGNMENT_CENTER, ancho, tamano, 6, Color(0.02, 0.04, 0.07))
	draw_string(fuente, donde, texto, HORIZONTAL_ALIGNMENT_CENTER, ancho, tamano, color)


## El primer personaje vivo desde el activo, en el sentido del paso.
func _vivo_desde(paso: int) -> int:
	for salto in range(1, _estado.size()):
		var otro := posmod(_activo + paso * salto, _estado.size())
		if not _estado[otro].caido:
			return otro
	return _activo


func _ulti(indice: int) -> float:
	return _ultis[indice] if indice < _ultis.size() else 0.0


## La tecla o, si se juega con mando, el botón.
func _boton(tecla: String, boton: String) -> String:
	return boton if _con_mando else tecla
