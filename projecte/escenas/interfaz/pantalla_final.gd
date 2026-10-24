extends Control

## Pantalla de victoria o derrota. Aparece con un fundido al terminar la
## partida, con el resumen, los récords batidos y dos salidas: reintentar o
## volver al menú.

const MENU_PRINCIPAL := "res://escenas/menu_principal/menu_principal.tscn"
const Dificultad := preload("res://globales/dificultad.gd")

const NOMBRES_RECORD := {
	"tiempo": "tiempo",
	"nivel": "nivel",
	"eliminados": "malware eliminado",
}

var _ventana: ColorRect
var _estadisticas: Dictionary
var _fila_nombre: HBoxContainer
var _nombre: LineEdit
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
	var titulo := EstiloInterfaz.etiqueta("SECTOR ASEGURADO" if victoria else "PROCESO ELIMINADO", 44, color)
	var subtitulo := EstiloInterfaz.etiqueta(
		"Has derrotado a NÚCLEO CERO. El sistema está limpio." if victoria
		else "El malware se ha apoderado del sector de arranque.", 16, EstiloInterfaz.TEXTO_SUAVE)
	caja.add_child(titulo)
	caja.add_child(subtitulo)

	var datos := GridContainer.new()
	datos.columns = 2
	datos.add_theme_constant_override("h_separation", 40)
	for fila in [
		["Tiempo", "%02d:%02d" % [int(estadisticas.tiempo) / 60, int(estadisticas.tiempo) % 60]],
		["Nivel", str(estadisticas.nivel)],
		["Malware eliminado", str(estadisticas.eliminados)],
		["Dificultad", Dificultad.DIFICULTADES[estadisticas.dificultad].nombre],
	]:
		datos.add_child(EstiloInterfaz.etiqueta(fila[0], 18, EstiloInterfaz.TEXTO_SUAVE))
		datos.add_child(EstiloInterfaz.etiqueta(fila[1], 18, EstiloInterfaz.TEXTO))
	var centro := CenterContainer.new()
	centro.add_child(datos)
	caja.add_child(centro)

	# Dónde acabó y qué hizo cada personaje (mejoras propuestas, jugabilidad 11 e
	# interfaz 5). get(): una partida de una versión anterior no trae estas
	# claves.
	if not victoria and estadisticas.has("donde"):
		caja.add_child(EstiloInterfaz.etiqueta("Caíste %s" % estadisticas.donde, 16, EstiloInterfaz.TEXTO))
	if not estadisticas.get("equipo", []).is_empty():
		caja.add_child(_resumen_equipo(estadisticas.equipo))
	if estadisticas.get("trucos", false):
		caja.add_child(EstiloInterfaz.etiqueta("Partida con el menú de desarrollador (F1): no cuenta para los récords ni el ranking", 13, EstiloInterfaz.TEXTO_SUAVE))

	if not GestorGuardado.records_batidos.is_empty():
		var nombres := []
		for clave in GestorGuardado.records_batidos:
			nombres.append(NOMBRES_RECORD[clave])
		var record := EstiloInterfaz.etiqueta("¡NUEVO RÉCORD! " + ", ".join(nombres), 20, EstiloInterfaz.NEON)
		caja.add_child(record)
		# Parpadea para que se vea que es una novedad.
		var latido := create_tween().set_loops()
		latido.tween_property(record, "modulate:a", 0.4, 0.5)
		latido.tween_property(record, "modulate:a", 1.0, 0.5)

	_estadisticas = estadisticas
	if GestorGuardado.entra_en_ranking(estadisticas):
		caja.add_child(_crear_fila_nombre())

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	_boton_reintentar = EstiloInterfaz.boton("REINTENTAR  [Enter]", _reintentar, 220)
	botones.add_child(_boton_reintentar)
	botones.add_child(EstiloInterfaz.boton("MENÚ  [Esc]", _ir_al_menu, 220))
	caja.add_child(botones)

	for hijo in caja.get_children():
		if hijo is Label:
			hijo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_ventana = EstiloInterfaz.ventana_centrada(caja, color)
	add_child(_ventana)

	# Fundido de entrada: la pantalla aparece poco a poco en lugar de golpe.
	_ventana.modulate.a = 0.0
	create_tween().tween_property(_ventana, "modulate:a", 1.0, 0.6)
	if _nombre != null:
		_nombre.grab_focus()
	else:
		_boton_reintentar.grab_focus()


## Una columna por personaje: su retrato (en gris si cayó) y la parte del daño
## que hizo su herramienta, en una barra de su color. Enseña que cambiar de
## personaje sirvió.
func _resumen_equipo(equipo: Array) -> HBoxContainer:
	var total := 0.0
	for datos in equipo:
		total += datos.dano
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 28)
	for datos in equipo:
		var personaje: DatosPersonaje = datos.personaje
		var columna := VBoxContainer.new()
		columna.add_theme_constant_override("separation", 4)
		var retrato := TextureRect.new()
		retrato.texture = personaje.retrato
		retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		retrato.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		retrato.modulate = Color(0.45, 0.45, 0.45) if datos.caido else Color.WHITE
		columna.add_child(retrato)
		var parte: float = datos.dano / total if total > 0.0 else 0.0
		var nombre := EstiloInterfaz.etiqueta("%s%s" % [personaje.nombre.to_upper(), "  (caído)" if datos.caido else ""], 13, personaje.color)
		nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columna.add_child(nombre)
		var barra := ProgressBar.new()
		barra.custom_minimum_size = Vector2(150, 8)
		barra.show_percentage = false
		barra.max_value = 1.0
		barra.value = parte
		var fondo := StyleBoxFlat.new()
		fondo.bg_color = Color(0.1, 0.15, 0.2)
		var relleno := StyleBoxFlat.new()
		relleno.bg_color = personaje.color
		barra.add_theme_stylebox_override("background", fondo)
		barra.add_theme_stylebox_override("fill", relleno)
		columna.add_child(barra)
		var cifra := EstiloInterfaz.etiqueta("%d %% del daño" % roundi(parte * 100.0), 13, EstiloInterfaz.TEXTO_SUAVE)
		cifra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columna.add_child(cifra)
		fila.add_child(columna)
	return fila


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
	_fila_nombre.add_child(EstiloInterfaz.boton("GUARDAR", _guardar_en_ranking, 130))
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
	if _ventana == null or not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_reintentar()
	elif evento.keycode == KEY_ESCAPE:
		_ir_al_menu()


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
