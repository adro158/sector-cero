extends Control

## El PERFIL del menú (24/11): arriba, la cuenta (con un botón para entrar,
## crearla o verla: panel_cuenta.gd) y los récords de este ordenador; debajo,
## en pestañas, las partidas de la cuenta y el ranking de este ordenador.
## Juntos porque las partidas se guardan con la cuenta (Adam, 24/11). Hasta
## entonces el ranking tenía su ventana (panel_ranking.gd, que este sustituye)
## y las partidas estaban en la de la cuenta.
##
## Las filas son las de fila_partida.gd (06/11): medallas, victoria o derrota
## con su icono, la dificultad en un chip y, en el ranking, las de la cuenta
## resaltadas.
##
## Sin class_name: lo crea el menú con preload.

signal cerrado
## Ha pulsado el botón de la cuenta: el menú abre panel_cuenta.gd.
signal cuenta_pedida

const FilaPartida := preload("res://escenas/interfaz/fila_partida.gd")
const Cuenta := preload("res://globales/cuenta.gd")
const Dificultad := preload("res://globales/dificultad.gd")
const Piezas := preload("res://escenas/menu_principal/piezas_menu.gd")

var _quien: Label
var _boton_cuenta: Button
var _record: Label
var _pestanas: TabContainer
var _partidas: VBoxContainer
var _ranking: VBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := VBoxContainer.new()

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 14)
	_quien = EstiloInterfaz.etiqueta("", 16)
	fila.add_child(_quien)
	_boton_cuenta = EstiloInterfaz.boton("", cuenta_pedida.emit, 260)
	fila.add_child(_boton_cuenta)
	caja.add_child(fila)
	_record = EstiloInterfaz.etiqueta("", 15, EstiloInterfaz.VICTORIA)
	_record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_record)

	# Las pestañas, con el estilo de siempre (pestanas.png, en el tema).
	_pestanas = TabContainer.new()
	_pestanas.custom_minimum_size = Vector2(860.0, 330.0)
	_partidas = _pestana(_pestanas, "PARTIDAS")
	_ranking = _pestana(_pestanas, "RANKING")
	caja.add_child(_pestanas)

	var volver := EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(volver)
	add_child(EstiloInterfaz.ventana_centrada(caja, EstiloInterfaz.NEON, "PERFIL", Piezas.icono(Piezas.Icono.PERFIL)))
	visible = false


## Una pestaña con su lista de filas, que se desplaza si no cabe.
func _pestana(pestanas: TabContainer, nombre: String) -> VBoxContainer:
	var desplazable := ScrollContainer.new()
	desplazable.name = nombre
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pestanas.add_child(desplazable)
	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 4)
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desplazable.add_child(lista)
	return lista


## Se rellena al abrir, así siempre muestra lo último guardado.
func abrir() -> void:
	var nombre := _nombre_de_la_cuenta()
	_quien.text = "Juegas como invitado" if nombre.is_empty() else "Cuenta: %s" % nombre
	_boton_cuenta.text = "ENTRAR O CREAR CUENTA" if nombre.is_empty() else "TU CUENTA"
	_record.text = _texto_record()
	_poner_ranking(nombre)
	visible = true
	# El foco en las pestañas, como en las opciones: izquierda y derecha las
	# cambian y abajo baja a la lista.
	_pestanas.get_tab_bar().grab_focus()
	_poner_partidas(nombre)


func _poner_ranking(tuya: String) -> void:
	_vaciar(_ranking)
	var partidas := GestorGuardado.ranking()
	if partidas.is_empty():
		_ranking.add_child(EstiloInterfaz.etiqueta("Todavía no hay partidas en el ranking.", 16))
		return
	_ranking.add_child(FilaPartida.cabecera("#", true))
	for i in partidas.size():
		var partida: Dictionary = partidas[i]
		# Con cuenta, la partida se guarda con su nombre (pantalla_final.gd):
		# así se sabe cuáles son tuyas. Sin cuenta no se resalta ninguna.
		var resaltada: bool = not tuya.is_empty() and str(partida.nombre).to_lower() == tuya.to_lower()
		_ranking.add_child(FilaPartida.crear(partida, i, resaltada))


## Las últimas de la cuenta (las baja de Supabase: llegan un poco después).
func _poner_partidas(nombre: String) -> void:
	_vaciar(_partidas)
	if nombre.is_empty():
		_partidas.add_child(EstiloInterfaz.etiqueta("Con una cuenta, tus partidas se guardan en internet y salen aquí.", 15, EstiloInterfaz.TEXTO_SUAVE))
		return
	var cargando := EstiloInterfaz.etiqueta("Cargando...", 13, EstiloInterfaz.TEXTO_SUAVE)
	_partidas.add_child(cargando)
	var partidas: Array = await Cuenta.actual.mis_partidas()
	if not is_instance_valid(cargando):
		return
	cargando.text = "Todavía no hay partidas en esta cuenta (o no hay conexión)." if partidas.is_empty() else ""
	cargando.visible = partidas.is_empty()
	if not partidas.is_empty():
		_partidas.add_child(FilaPartida.cabecera("FECHA", false))
	for partida in partidas:
		# La fecha llega como 2026-11-05T17:30:00+00:00: el día y el mes.
		var fecha: String = partida.jugada.substr(8, 2) + "/" + partida.jugada.substr(5, 2)
		_partidas.add_child(FilaPartida.crear(partida, fecha))


func _vaciar(lista: VBoxContainer) -> void:
	for hijo in lista.get_children():
		hijo.queue_free()


## La mejor partida y cuántas se han ganado (hasta el 24/11 salía en el menú).
## La mejor es la primera del ranking, que ya va ordenado.
func _texto_record() -> String:
	var partidas := int(GestorGuardado.record("partidas"))
	if partidas == 0:
		return "Todavía no hay récords: ¡a por la primera partida!"
	var resumen := "%d victorias en %d partidas" % [GestorGuardado.record("victorias"), partidas]
	var ranking := GestorGuardado.ranking()
	if ranking.is_empty():
		return resumen
	var mejor: Dictionary = ranking[0]
	var tiempo := int(mejor.tiempo)
	var dificultad: String = Dificultad.DIFICULTADES.get(mejor.get("dificultad", "media"), Dificultad.DIFICULTADES.media).nombre
	return "MEJOR PARTIDA  %s %02d:%02d en %s  ·  nivel %d  ·  %s" % [
		"victoria" if mejor.victoria else "derrota", tiempo / 60, tiempo % 60, dificultad, mejor.nivel, resumen]


## Vacío si se juega como invitado.
func _nombre_de_la_cuenta() -> String:
	return "" if Cuenta.actual == null else Cuenta.actual.nombre


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()


## Con el mando, LB y RB cambian de pestaña, como en las opciones.
func _input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventJoypadButton or not evento.pressed:
		return
	var paso: int = {JOY_BUTTON_LEFT_SHOULDER: -1, JOY_BUTTON_RIGHT_SHOULDER: 1}.get(evento.button_index, 0)
	if paso != 0:
		_pestanas.current_tab = posmod(_pestanas.current_tab + paso, _pestanas.get_tab_count())
		_pestanas.get_tab_bar().grab_focus()
		get_viewport().set_input_as_handled()
