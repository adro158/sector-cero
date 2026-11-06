extends Control

## Pantalla de victoria o derrota. Aparece con un fundido al terminar la
## partida, con el resumen, los récords batidos y dos salidas: reintentar o
## volver al menú.

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"
## Las tarjetas de datos y el equipo, y la barra del recorrido (06/11).
const ResumenFinal := preload("res://escenas/interfaz/resumen_final.gd")
const RecorridoPartida := preload("res://escenas/interfaz/recorrido_partida.gd")
## El título, con el glitch del logo del menú (lote 9).
const LogoGlitch := preload("res://escenas/menu_principal/logo_glitch.gd")
const ROTULO_VICTORIA := preload("res://medios/interfaz/rotulo_victoria.png")
const ROTULO_DERROTA := preload("res://medios/interfaz/rotulo_derrota.png")
const Entrada := preload("res://globales/entrada.gd")
const Cuenta := preload("res://globales/cuenta.gd")

var _ventana: ColorRect
var _estadisticas: Dictionary
var _fila_nombre: HBoxContainer
var _nombre: LineEdit
var _guardar: Button
var _boton_reintentar: Button


func _ready() -> void:
	# La partida termina con el juego pausado, y aun así hay que poder pulsar.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Diferido: así el gestor de guardado ya ha anotado la partida cuando se
	# pregunta qué récords se han batido, conecte quien conecte antes.
	BusEventos.partida_terminada.connect(_mostrar, CONNECT_DEFERRED)


func _mostrar(estadisticas: Dictionary) -> void:
	var victoria: bool = estadisticas.victoria
	var color := EstiloInterfaz.VICTORIA if victoria else EstiloInterfaz.DERROTA

	var caja := VBoxContainer.new()
	var titulo := LogoGlitch.new()
	titulo.tira = ROTULO_VICTORIA if victoria else ROTULO_DERROTA
	var subtitulo := EstiloInterfaz.etiqueta(
		"Has derrotado a NÚCLEO CERO. El sistema está limpio." if victoria
		else "El malware se ha apoderado del sector de arranque.", 16, EstiloInterfaz.TEXTO_SUAVE)
	caja.add_child(titulo)
	caja.add_child(subtitulo)

	# Los datos en tarjetas con su icono; la de un récord batido, resaltada
	# (06/11: antes era una rejilla de texto y un «¡NUEVO RÉCORD!» aparte).
	caja.add_child(ResumenFinal.tarjetas(estadisticas, GestorGuardado.records_batidos))

	# Dónde acabó, en la barra del recorrido, y qué hizo cada personaje. get():
	# una partida de una versión anterior no trae estas claves.
	if estadisticas.has("donde"):
		var recorrido := RecorridoPartida.new()
		recorrido.donde = estadisticas.donde
		recorrido.tiempo = estadisticas.tiempo
		recorrido.victoria = victoria
		var centro := CenterContainer.new()
		centro.add_child(recorrido)
		caja.add_child(centro)
		if not victoria:
			caja.add_child(EstiloInterfaz.etiqueta("Caíste %s" % estadisticas.donde, 16, EstiloInterfaz.TEXTO))
	if not estadisticas.get("equipo", []).is_empty():
		caja.add_child(ResumenFinal.equipo(estadisticas.equipo))
	if estadisticas.get("trucos", false):
		caja.add_child(EstiloInterfaz.etiqueta("Partida con el menú de desarrollador (F1): no cuenta para los récords ni el ranking", 13, EstiloInterfaz.TEXTO_SUAVE))

	_estadisticas = estadisticas
	# Con cuenta ya se sabe el nombre: se guarda solo (decisión de Adam,
	# 05/11). Al invitado se le sigue preguntando.
	if GestorGuardado.entra_en_ranking(estadisticas):
		var cuenta := _nombre_de_la_cuenta()
		if cuenta.is_empty():
			caja.add_child(_crear_fila_nombre())
		else:
			var puesto := GestorGuardado.anadir_al_ranking(estadisticas, cuenta)
			caja.add_child(EstiloInterfaz.etiqueta("Guardado en el ranking como %s: puesto %d" % [cuenta, puesto], 16, EstiloInterfaz.VICTORIA))

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	_boton_reintentar = EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", _reintentar, 220), "REINTENTAR  [Enter]", "REINTENTAR") as Button
	botones.add_child(_boton_reintentar)
	botones.add_child(EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", _ir_al_menu, 220), "MENÚ  [Esc]", "MENÚ  [B]"))
	caja.add_child(botones)

	for hijo in caja.get_children():
		if hijo is Label:
			hijo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_ventana = EstiloInterfaz.ventana_centrada(caja, color)
	add_child(_ventana)

	# Fundido de entrada: la pantalla aparece poco a poco en lugar de golpe.
	_ventana.modulate.a = 0.0
	create_tween().tween_property(_ventana, "modulate:a", 1.0, 0.6)
	# Con el mando no se puede escribir: el foco va a GUARDAR, que lo guarda
	# como «Anónimo».
	if _nombre != null and Entrada.con_mando:
		_guardar.grab_focus()
	elif _nombre != null:
		_nombre.grab_focus()
	else:
		_boton_reintentar.grab_focus()


## Vacío si se juega como invitado.
func _nombre_de_la_cuenta() -> String:
	if Cuenta.actual == null:
		return ""
	return Cuenta.actual.nombre


## La partida entra en el top 10: se pide un nombre para el ranking. Enter en
## el campo de texto guarda, igual que el botón.
func _crear_fila_nombre() -> HBoxContainer:
	_fila_nombre = HBoxContainer.new()
	_fila_nombre.alignment = BoxContainer.ALIGNMENT_CENTER
	_fila_nombre.add_theme_constant_override("separation", 12)
	_fila_nombre.add_child(EstiloInterfaz.etiqueta("¡Entras en el ranking! Tu nombre:", 16, EstiloInterfaz.NEON))
	_nombre = LineEdit.new()
	_nombre.max_length = 14
	_nombre.placeholder_text = "Anónimo"
	_nombre.custom_minimum_size = Vector2(200, 0)
	_nombre.text_submitted.connect(func(_texto): _guardar_en_ranking())
	_fila_nombre.add_child(_nombre)
	_guardar = EstiloInterfaz.boton("GUARDAR", _guardar_en_ranking, 130)
	_fila_nombre.add_child(_guardar)
	return _fila_nombre


func _guardar_en_ranking() -> void:
	var nombre := _nombre.text.strip_edges()
	if nombre.is_empty():
		nombre = "Anónimo"
	var puesto := GestorGuardado.anadir_al_ranking(_estadisticas, nombre)
	# La fila se cambia por el resultado y el foco pasa a reintentar.
	for hijo in _fila_nombre.get_children():
		hijo.queue_free()
	_fila_nombre.add_child(EstiloInterfaz.etiqueta("Guardado en el ranking: puesto %d" % puesto, 16, EstiloInterfaz.VICTORIA))
	_nombre = null
	_boton_reintentar.grab_focus()


func _unhandled_input(evento: InputEvent) -> void:
	if _ventana == null:
		return
	# ui_cancel: Esc y, desde el 05/11, B del mando (entrada.gd).
	if evento.is_action_pressed("ui_cancel"):
		_ir_al_menu()
	elif evento is InputEventKey and evento.pressed and (evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER):
		_reintentar()


func _reintentar() -> void:
	_guardar_si_falta()
	# Ruta vacía: recargar la escena actual.
	Transicion.cambiar_a("")


func _ir_al_menu() -> void:
	_guardar_si_falta()
	Transicion.cambiar_a(MENU_PRINCIPAL)


## Si entraba en el ranking y no se pulsó GUARDAR, se guarda igual (como
## «Anónimo» si no se escribió nombre): si no, se perdía sin avisar.
func _guardar_si_falta() -> void:
	if _nombre != null:
		_guardar_en_ranking()
