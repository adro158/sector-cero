extends Control

## Menú de desarrollador, con F1: para probar cualquier parte del juego sin
## jugar hasta ella. Saltar a un minuto, darse mejoras, subir de nivel, ser
## invencible, llenar las ultis, sacar el jefe, un élite o los premios, revivir
## al equipo, limpiar la horda y acelerar el juego.
##
## Está en todas las versiones (decisión de Adam). Por eso, en cuanto se abre,
## la partida deja de contar para los récords y el ranking.
##
## Es una herramienta de depuración, como el panel técnico (F3): vive en la
## escena de la partida y usa los nodos de la jugabilidad directamente, por sus
## grupos y nombres, sin pasar por el bus.

const COLOR := Color(1.0, 0.75, 0.2)

var _ventana: ColorRect
var _tiempo: LineEdit
var _velocidad: Label
## Si la pausa la ha puesto este menú: al cerrarlo solo se quita esa.
var _pauso_yo := false
var _raiz: Node
var _jugador: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = EstiloInterfaz.tema()
	_raiz = get_tree().get_first_node_in_group("jugador").get_parent()
	_jugador = _raiz.get_node("Jugador")

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	caja.add_child(EstiloInterfaz.etiqueta("MENÚ DE DESARROLLADOR  [F1]", 26, COLOR))
	caja.add_child(EstiloInterfaz.etiqueta("Esta partida ya no cuenta para los récords ni para el ranking.", 13, EstiloInterfaz.TEXTO_SUAVE))

	var columnas := HBoxContainer.new()
	columnas.add_theme_constant_override("separation", 18)
	caja.add_child(columnas)
	columnas.add_child(_columna_partida())
	columnas.add_child(_columna_jugador())
	caja.add_child(EstiloInterfaz.etiqueta("MEJORAS (click para dártela)", 16, COLOR))
	caja.add_child(_rejilla_mejoras())

	_ventana = EstiloInterfaz.ventana_centrada(caja, COLOR)
	_ventana.visible = false
	add_child(_ventana)


func _columna_partida() -> VBoxContainer:
	var columna := VBoxContainer.new()
	columna.add_child(EstiloInterfaz.etiqueta("PARTIDA", 16, COLOR))
	var fila := HBoxContainer.new()
	_tiempo = LineEdit.new()
	_tiempo.placeholder_text = "7:30"
	_tiempo.custom_minimum_size.x = 90
	_tiempo.text_submitted.connect(func(_texto): _saltar())
	fila.add_child(_tiempo)
	fila.add_child(_boton("IR AL MINUTO", _saltar, 160))
	columna.add_child(fila)
	columna.add_child(_boton("JEFE YA (10:00)", func(): _director().saltar_a(600.0)))
	columna.add_child(_boton("ÉLITE AHORA", func(): _director().aparecer_elite()))
	columna.add_child(_boton("CORAZÓN Y COFRE AQUÍ", func(): _raiz.get_node("PremiosElite").soltar(_jugador.global_position + Vector2(0, 70))))
	columna.add_child(_boton("LIMPIAR LA HORDA", _limpiar_horda))
	_velocidad = EstiloInterfaz.etiqueta("Velocidad x1", 14)
	columna.add_child(_velocidad)
	var velocidades := HBoxContainer.new()
	for factor in [1.0, 2.0, 4.0]:
		velocidades.add_child(_boton("x%d" % factor, _poner_velocidad.bind(factor), 70))
	columna.add_child(velocidades)
	return columna


func _columna_jugador() -> VBoxContainer:
	var columna := VBoxContainer.new()
	columna.add_child(EstiloInterfaz.etiqueta("JUGADOR", 16, COLOR))
	columna.add_child(_boton("SUBIR UN NIVEL", _subir_nivel))
	var invencible := CheckButton.new()
	invencible.text = "Invencible"
	invencible.toggled.connect(func(activo): _jugador.get_node("Salud").invencible = activo)
	columna.add_child(invencible)
	columna.add_child(_boton("LLENAR LAS ULTIS", func(): _jugador.get_node("Ultis").llenar_todas()))
	columna.add_child(_boton("REVIVIR Y CURAR AL EQUIPO", func(): _jugador.get_node("CambioPersonaje").revivir_todos()))
	columna.add_child(_boton("CAMBIAR SIN ESPERA", func(): _jugador.get_node("CambioPersonaje").quitar_espera()))
	return columna


## Un botón por mejora y por evolución, con su icono.
func _rejilla_mejoras() -> GridContainer:
	var rejilla := GridContainer.new()
	rejilla.columns = 4
	var niveles: Node = _raiz.get_node("SistemaNiveles")
	var pool: DatosPoolMejoras = niveles.pool_mejoras
	for mejora in pool.mejoras + pool.evoluciones:
		var boton := _boton(mejora.nombre, func(): niveles.regalar(mejora), 230)
		boton.icon = mejora.icono
		boton.expand_icon = false
		rejilla.add_child(boton)
	return rejilla


func _boton(texto: String, accion: Callable, ancho: float = 240.0) -> Button:
	var boton := EstiloInterfaz.boton(texto, accion, ancho)
	boton.custom_minimum_size.y = 34
	boton.add_theme_font_size_override("font_size", 13)
	return boton


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo and evento.keycode == KEY_F1:
		get_viewport().set_input_as_handled()
		_abrir_o_cerrar()


func _abrir_o_cerrar() -> void:
	_ventana.visible = not _ventana.visible
	if _ventana.visible:
		_raiz.usar_trucos()
		# Solo se pausa si nadie lo había hecho (subida de nivel, ruleta...): al
		# cerrar, esa pausa tiene que seguir.
		_pauso_yo = not get_tree().paused
		get_tree().paused = true
	elif _pauso_yo:
		get_tree().paused = false


func _saltar() -> void:
	# "7:30" o solo segundos: "450".
	var partes := _tiempo.text.strip_edges().split(":")
	var segundos := float(partes[0]) if partes.size() == 1 else float(partes[0]) * 60.0 + float(partes[1])
	_director().saltar_a(segundos)


func _subir_nivel() -> void:
	var niveles: Node = _raiz.get_node("SistemaNiveles")
	BusEventos.experiencia_ganada.emit(niveles.experiencia_para_subir())
	# Se cierra para elegir la mejora del nivel en su panel.
	_ventana.visible = false
	_pauso_yo = false


func _limpiar_horda() -> void:
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		gestor.huir()


func _poner_velocidad(factor: float) -> void:
	Engine.time_scale = factor
	_velocidad.text = "Velocidad x%d" % factor


func _director() -> Node:
	return _raiz.get_node("DirectorOleadas")


func _exit_tree() -> void:
	# La velocidad es de todo el motor: al salir de la partida, normal.
	Engine.time_scale = 1.0
