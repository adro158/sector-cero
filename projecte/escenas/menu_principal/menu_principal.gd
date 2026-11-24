extends Control

## Menú de inicio. Desde el 24/11, con menos botones y las piezas del lote del
## menú (Adam: «hay muchos botones»), como en su maqueta:
## - a la izquierda, cuatro botones grandes: JUGAR (ventana_jugar.gd: el modo,
##   la dificultad y las reglas), COLECCIÓN (las skins, de Alan), PERFIL
##   (panel_perfil.gd: la cuenta, los récords, las partidas y el ranking) y
##   OPCIONES (con la pestaña de la versión)
## - en medio, el logo y los personajes en sus peanas (personajes_menu.gd)
## - en las esquinas, la cuenta, SALIR y las novedades (tarjeta_novedades.gd)
## Enter abre JUGAR y Esc sale. Cada ventana es su script; aquí se crean y se
## conectan.

const PanelVersiones := preload("res://escenas/interfaz/panel_versiones.gd")
const PanelCuenta := preload("res://escenas/interfaz/panel_cuenta.gd")
const InstaladorJuego := preload("res://globales/instalador_juego.gd")
const Cuenta := preload("res://globales/cuenta.gd")
const SalaRed := preload("res://escenas/red/sala_red.gd")
const VentanaSkins := preload("res://escenas/skins/ventana_skins.gd")
const LogoGlitch := preload("res://escenas/menu_principal/logo_glitch.gd")
const PersonajesMenu := preload("res://escenas/menu_principal/personajes_menu.gd")
const VentanaJugar := preload("res://escenas/menu_principal/ventana_jugar.gd")
const PanelPerfil := preload("res://escenas/menu_principal/panel_perfil.gd")
const TarjetaNovedades := preload("res://escenas/menu_principal/tarjeta_novedades.gd")
const Piezas := preload("res://escenas/menu_principal/piezas_menu.gd")
## Lo que se separan de los bordes las cosas de las esquinas.
const BORDE := 24.0

var _jugar: Control
var _reglas: PanelReglas
var _opciones: PanelOpciones
var _perfil: Control
var _cuenta: Control
var _versiones: PanelVersiones
## La sala del multijugador (sala_red.gd), desde JUGAR con EN RED.
var _sala: Control
## Las skins: el armario y, más adelante, el pase y la tienda (de Alan).
var _skins: Control
var _boton_cuenta: Button
## La bienvenida de las cuentas sale una vez al abrir el juego, no cada vez
## que se vuelve al menú. Estática: dura mientras el juego está abierto.
static var _bienvenida_vista := false
## Las reglas, la cuenta o las versiones se han abierto desde otra ventana
## (JUGAR, PERFIL u OPCIONES): al cerrarlas, se vuelve a ella.
var _volver_a: Control = null


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	# Sin suavizar: las piezas son de pixel art y lo heredan todos los hijos.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var suelo := ColorRect.new()
	suelo.material = load("res://escenas/arena/suelo.tres")
	suelo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(suelo)
	var botones := _crear_centro()
	_crear_ventanas(botones)
	_crear_esquinas()
	InstaladorJuego.limpiar()
	# Al acabar una descarga el juego se reinicia: no se puede empezar partida.
	Actualizador.estado_cambiado.connect(_al_cambiar_actualizador)
	_al_cambiar_actualizador()
	# Los ejecutables desde la v0.6 ya buscan solos cada 5 minutos y esto no
	# cambia nada. Los anteriores solo buscan si se lo pide el menú.
	Actualizador.buscar()
	# Sin una sesión guardada, al abrir el juego: entrar, registrarse o jugar
	# sin cuenta. Con las cuentas sin activar (sin proyecto de Supabase), no.
	if not _bienvenida_vista and Cuenta.actual.activada() and Cuenta.actual.nombre == "":
		_bienvenida_vista = true
		_cuenta.abrir.call_deferred(true)
	botones.jugar.grab_focus()


## El logo, los personajes y los botones, colocados respecto al centro de la
## pantalla como en la maqueta (a 1280x720): con una pantalla más ancha, el
## viewport crece de lado (aspect «expand») y todo sigue en su sitio. Devuelve
## los botones, para conectarlos con sus ventanas.
func _crear_centro() -> Dictionary:
	var centro := Control.new()
	centro.set_anchors_preset(Control.PRESET_CENTER)
	add_child(centro)
	var logo := LogoGlitch.new()
	logo.position = Vector2(-166.0, -326.0)
	centro.add_child(logo)
	var personajes := PersonajesMenu.new()
	personajes.position = Vector2(-194.0, -84.0)
	centro.add_child(personajes)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	columna.position = Vector2(-592.0, -124.0)
	centro.add_child(columna)
	# Con el mando, A pulsa el botón con el foco y B no sale del juego.
	var botones := {
		"jugar": Piezas.boton_grande("JUGAR", Piezas.Icono.JUGAR, func(): _jugar.abrir(), EstiloInterfaz.VICTORIA, Piezas.VERDE_CLARO),
		"coleccion": Piezas.boton_grande("COLECCIÓN", Piezas.Icono.COLECCION, func(): _skins.abrir()),
		"perfil": Piezas.boton_grande("PERFIL", Piezas.Icono.PERFIL, func(): _perfil.abrir()),
		"opciones": Piezas.boton_grande("OPCIONES", Piezas.Icono.OPCIONES, func(): _opciones.abrir()),
	}
	for boton in botones.values():
		columna.add_child(boton)
	# Al pulsar un personaje se abre el armario en él (las skins, de Alan).
	personajes.elegido.connect(func(indice): _skins.abrir(indice))
	return botones


## Las ventanas. Al cerrar cada una, el foco vuelve al botón que la abrió.
func _crear_ventanas(botones: Dictionary) -> void:
	_jugar = VentanaJugar.new()
	_jugar.cerrado.connect(botones.jugar.grab_focus)
	add_child(_jugar)
	_opciones = PanelOpciones.new()
	_opciones.con_version = true
	_opciones.cerrado.connect(botones.opciones.grab_focus)
	add_child(_opciones)
	_perfil = PanelPerfil.new()
	_perfil.cerrado.connect(botones.perfil.grab_focus)
	add_child(_perfil)
	_skins = VentanaSkins.new()
	_skins.cerrado.connect(botones.coleccion.grab_focus)
	add_child(_skins)
	# La sala, desde JUGAR con EN RED: al cerrarla, al menú.
	_sala = SalaRed.new()
	_sala.cerrado.connect(botones.jugar.grab_focus)
	_jugar.red_pedida.connect(_sala.abrir)
	add_child(_sala)
	# Las que se abren desde otra ventana, después: así quedan encima.
	_reglas = PanelReglas.new()
	_reglas.cerrado.connect(_al_cerrar_desde.bind(botones.jugar))
	_jugar.reglas_pedidas.connect(_abrir_desde.bind(_jugar, _reglas.abrir))
	add_child(_reglas)
	_cuenta = PanelCuenta.new()
	_cuenta.cerrado.connect(_al_cerrar_desde.bind(botones.jugar))
	_perfil.cuenta_pedida.connect(_abrir_desde.bind(_perfil, func(): _cuenta.abrir()))
	add_child(_cuenta)
	_versiones = PanelVersiones.new()
	_versiones.cerrado.connect(_al_cerrar_desde.bind(botones.opciones))
	_opciones.versiones_pedidas.connect(_abrir_desde.bind(_opciones, _versiones.abrir))
	add_child(_versiones)


## Arriba a la derecha, la cuenta; abajo a la izquierda, SALIR (no en la web:
## en el navegador no se puede cerrar el juego); abajo a la derecha, las
## novedades. Debajo de las ventanas en el árbol: ellas tapan la pantalla.
func _crear_esquinas() -> void:
	_boton_cuenta = Button.new()
	_boton_cuenta.add_theme_stylebox_override("normal", Piezas.cuenta(false, EstiloInterfaz.TEXTO_SUAVE))
	for estado in ["hover", "pressed", "focus"]:
		_boton_cuenta.add_theme_stylebox_override(estado, Piezas.cuenta(true, EstiloInterfaz.NEON))
	_boton_cuenta.custom_minimum_size = Vector2(150.0, 20.0)
	_boton_cuenta.pressed.connect(func(): _cuenta.abrir())
	_poner_en_esquina(_boton_cuenta, true, false)
	_escribir_cuenta(Cuenta.actual.nombre)
	BusEventos.sesion_cambiada.connect(_escribir_cuenta)
	if not OS.has_feature("web"):
		var salir := EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", get_tree().quit, 130.0), "SALIR  [Esc]", "SALIR") as Button
		salir.icon = Piezas.icono(Piezas.Icono.SALIR)
		_poner_en_esquina(salir, false, true)
	_poner_en_esquina(TarjetaNovedades.new(), true, true)


## En una esquina, a BORDE de los lados, y debajo de las ventanas en el árbol.
## Crece hacia dentro desde la esquina: así no hace falta saber lo que mide.
func _poner_en_esquina(nodo: Control, derecha: bool, abajo: bool) -> void:
	add_child(nodo)
	move_child(nodo, 2)
	nodo.anchor_left = 1.0 if derecha else 0.0
	nodo.anchor_right = nodo.anchor_left
	nodo.anchor_top = 1.0 if abajo else 0.0
	nodo.anchor_bottom = nodo.anchor_top
	var x := -BORDE if derecha else BORDE
	var y := -BORDE if abajo else BORDE
	nodo.offset_left = x
	nodo.offset_right = x
	nodo.offset_top = y
	nodo.offset_bottom = y
	nodo.grow_horizontal = Control.GROW_DIRECTION_BEGIN if derecha else Control.GROW_DIRECTION_END
	nodo.grow_vertical = Control.GROW_DIRECTION_BEGIN if abajo else Control.GROW_DIRECTION_END


func _escribir_cuenta(nombre: String) -> void:
	_boton_cuenta.text = "invitado" if nombre == "" else nombre


func _al_cambiar_actualizador() -> void:
	_jugar.bloquear(Actualizador.estado == Actualizador.Estado.DESCARGANDO)


## Desde una ventana se abre otra: la primera se esconde y, al cerrar la
## segunda, vuelve.
func _abrir_desde(desde: Control, abrir: Callable) -> void:
	desde.visible = false
	_volver_a = desde
	abrir.call()


## Al cerrar las reglas, la cuenta o las versiones: a la ventana de la que
## venían o, si se abrieron solas (la cuenta, desde su esquina o la
## bienvenida), al botón del menú.
func _al_cerrar_desde(boton: Button) -> void:
	if _volver_a != null:
		var ventana := _volver_a
		_volver_a = null
		ventana.abrir()
	else:
		boton.grab_focus()


func _unhandled_input(evento: InputEvent) -> void:
	# Con una ventana abierta, Enter y Esc son de ella.
	for ventana in [_jugar, _reglas, _opciones, _perfil, _cuenta, _versiones, _sala, _skins]:
		if ventana.visible:
			return
	if not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_jugar.abrir()
	elif evento.keycode == KEY_ESCAPE and not OS.has_feature("web"):
		get_tree().quit()
