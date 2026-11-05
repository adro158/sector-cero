extends Control

## Ventana de la cuenta, en el menú (05/11, documentacio/plan_cuentas.md). Sin
## cuenta: usuario, contraseña, ENTRAR y CREAR CUENTA, y que sin ella se juega
## como invitado. Con cuenta: el nombre, las últimas partidas subidas y SALIR
## DE LA CUENTA. Lo que habla con el servidor lo hace globales/cuenta.gd.
##
## Sin class_name: lo crea el menú con preload.

signal cerrado

const Cuenta := preload("res://globales/cuenta.gd")
const ANCHO := 460.0

var _formulario: VBoxContainer
var _usuario: LineEdit
var _contrasena: LineEdit
var _botones: Array[Button] = []
var _dentro: VBoxContainer
var _saludo: Label
var _lista: VBoxContainer
var _estado: Label
var _volver: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("CUENTA", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)
	caja.add_child(_parrafo("Con una cuenta, tus partidas se guardan en internet. Sin ella juegas como invitado y tus récords se quedan en este ordenador.", EstiloInterfaz.TEXTO_SUAVE))

	_formulario = VBoxContainer.new()
	_formulario.add_theme_constant_override("separation", 10)
	_usuario = _campo("Usuario (3 a 14 letras, números o _)")
	_contrasena = _campo("Contraseña (al menos 6 caracteres)")
	_contrasena.secret = true
	# Enter en la contraseña entra, como el botón.
	_contrasena.text_submitted.connect(func(_texto): _enviar(false))
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 12)
	_botones.append(EstiloInterfaz.boton("ENTRAR", _enviar.bind(false), 180))
	_botones.append(EstiloInterfaz.boton("CREAR CUENTA", _enviar.bind(true), 200))
	for boton in _botones:
		fila.add_child(boton)
	_formulario.add_child(fila)
	caja.add_child(_formulario)

	_dentro = VBoxContainer.new()
	_dentro.add_theme_constant_override("separation", 6)
	_saludo = EstiloInterfaz.etiqueta("", 20, EstiloInterfaz.VICTORIA)
	_saludo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dentro.add_child(_saludo)
	_dentro.add_child(EstiloInterfaz.etiqueta("TUS ÚLTIMAS PARTIDAS", 14, EstiloInterfaz.TEXTO_SUAVE))
	_lista = VBoxContainer.new()
	_dentro.add_child(_lista)
	var salir := EstiloInterfaz.boton("SALIR DE LA CUENTA", _salir, 240)
	salir.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_dentro.add_child(salir)
	caja.add_child(_dentro)

	_estado = _parrafo("", EstiloInterfaz.DERROTA)
	caja.add_child(_estado)
	_volver = EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]") as Button
	_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(_volver)

	add_child(EstiloInterfaz.ventana_centrada(caja))
	visible = false
	BusEventos.sesion_cambiada.connect(_al_cambiar_sesion)


func _al_cambiar_sesion(_nombre: String) -> void:
	if visible:
		_mostrar()


func abrir() -> void:
	visible = true
	_estado.text = ""
	_mostrar()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()


## El formulario o la cuenta, según si se ha entrado.
func _mostrar() -> void:
	var cuenta: Node = Cuenta.actual
	var con_cuenta: bool = cuenta.nombre != ""
	_formulario.visible = not con_cuenta
	_dentro.visible = con_cuenta
	if con_cuenta:
		_saludo.text = "Has entrado como %s" % cuenta.nombre
		_volver.grab_focus()
		_cargar_partidas()
	else:
		if not cuenta.activada():
			_estado.text = "Las cuentas todavía no están activadas en este juego."
		_usuario.grab_focus()


func _enviar(crear: bool) -> void:
	for boton in _botones:
		boton.disabled = true
	_estado.add_theme_color_override("font_color", EstiloInterfaz.TEXTO_SUAVE)
	_estado.text = "Creando la cuenta..." if crear else "Entrando..."
	var cuenta: Node = Cuenta.actual
	var error: String
	if crear:
		error = await cuenta.crear_cuenta(_usuario.text.strip_edges(), _contrasena.text)
	else:
		error = await cuenta.entrar(_usuario.text.strip_edges(), _contrasena.text)
	for boton in _botones:
		boton.disabled = false
	_estado.add_theme_color_override("font_color", EstiloInterfaz.DERROTA)
	_estado.text = error
	if error == "":
		_contrasena.clear()
		_mostrar()


func _salir() -> void:
	Cuenta.actual.salir()
	_mostrar()


func _cargar_partidas() -> void:
	for hijo in _lista.get_children():
		hijo.queue_free()
	var cargando := EstiloInterfaz.etiqueta("Cargando...", 13, EstiloInterfaz.TEXTO_SUAVE)
	_lista.add_child(cargando)
	var partidas: Array = await Cuenta.actual.mis_partidas()
	if not is_instance_valid(cargando):
		return
	cargando.text = "Todavía no hay partidas en esta cuenta (o no hay conexión)." if partidas.is_empty() else ""
	cargando.visible = partidas.is_empty()
	for partida in partidas:
		var tiempo := int(partida.tiempo)
		# La fecha llega como 2026-11-05T17:30:00+00:00: el día y el mes.
		var fecha: String = partida.jugada.substr(8, 2) + "/" + partida.jugada.substr(5, 2)
		var texto := "%s   %s   %02d:%02d   nivel %d   %s" % [fecha, "VICTORIA" if partida.victoria else "derrota",
			tiempo / 60, tiempo % 60, partida.nivel, partida.dificultad]
		_lista.add_child(EstiloInterfaz.etiqueta(texto, 14, EstiloInterfaz.VICTORIA if partida.victoria else EstiloInterfaz.TEXTO))


func _campo(ayuda: String) -> LineEdit:
	var campo := LineEdit.new()
	campo.placeholder_text = ayuda
	campo.custom_minimum_size = Vector2(ANCHO, 0)
	campo.max_length = 64
	_formulario.add_child(campo)
	return campo


func _parrafo(texto: String, color: Color) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, 14, color)
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.custom_minimum_size = Vector2(ANCHO, 0)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return etiqueta
