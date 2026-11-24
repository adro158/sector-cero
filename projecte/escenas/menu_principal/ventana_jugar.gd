extends Control

## Lo que sale al pulsar JUGAR en el menú (24/11): todo lo de empezar una
## partida junto. Dos tarjetas para el modo (SOLO, y EN RED, que lleva a la
## sala: sala_red.gd), tres para la dificultad (hasta entonces,
## selector_dificultad.gd; se guarda en las opciones igual), «¿Cómo se juega?»
## (las reglas) y EMPEZAR. Enter es EMPEZAR y Esc cierra.
##
## Sin class_name: lo crea el menú con preload.

signal cerrado
## Ha pulsado «¿Cómo se juega?»: el menú abre las reglas.
signal reglas_pedidas
## Ha pulsado EMPEZAR con EN RED: el menú abre la sala.
signal red_pedida

const PARTIDA := "res://escenas/juego.tscn"
const Piezas := preload("res://escenas/menu_principal/piezas_menu.gd")
const TarjetaMenu := preload("res://escenas/menu_principal/tarjeta_menu.gd")
const Dificultad := preload("res://globales/dificultad.gd")
const TarjetaNovedades := preload("res://escenas/menu_principal/tarjeta_novedades.gd")
const AMARILLO := Color(1.0, 0.85, 0.25)
## Por dificultad: la línea de su tarjeta y su color (la explicación larga, en
## dificultad.gd, sale al dejar el ratón encima).
const DIFICULTADES := {
	"facil": ["El malware aguanta menos", EstiloInterfaz.VICTORIA],
	"media": ["Como está pensado", AMARILLO],
	"dificil": ["Más vida y más daño", EstiloInterfaz.DERROTA],
}

## El modo se recuerda mientras el juego está abierto (el menú se crea de nuevo
## al volver de cada partida); la dificultad, en las opciones.
static var _en_red := false

var _solo: Button
var _red: Button
var _dificultades := {}
var _empezar: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caja := VBoxContainer.new()
	caja.custom_minimum_size.x = 700.0

	caja.add_child(EstiloInterfaz.etiqueta("MODO", 13, EstiloInterfaz.TEXTO_SUAVE))
	var modos := HBoxContainer.new()
	modos.add_theme_constant_override("separation", 16)
	var grupo_modo := ButtonGroup.new()
	_solo = TarjetaMenu.new(Piezas.dibujo(Piezas.ICONOS, Piezas.Icono.SOLO, Vector2(16, 16), 2.0, EstiloInterfaz.NEON),
		"SOLO", "Tú contra el malware", EstiloInterfaz.NEON, false, grupo_modo)
	_red = TarjetaMenu.new(Piezas.dibujo(Piezas.ICONOS, Piezas.Icono.EN_RED, Vector2(16, 16), 2.0, EstiloInterfaz.NEON),
		"EN RED", "2 o 3 jugadores", EstiloInterfaz.NEON, false, grupo_modo)
	_solo.pressed.connect(func(): _en_red = false)
	_red.pressed.connect(func(): _en_red = true)
	# En la web no hay red: ENet no funciona en el navegador.
	_red.visible = not OS.has_feature("web")
	modos.add_child(_solo)
	modos.add_child(_red)
	caja.add_child(modos)

	caja.add_child(EstiloInterfaz.etiqueta("DIFICULTAD", 13, EstiloInterfaz.TEXTO_SUAVE))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 16)
	var grupo := ButtonGroup.new()
	var i := 0
	for clave in DIFICULTADES:
		var tarjeta := TarjetaMenu.new(Piezas.dibujo(Piezas.DIFICULTAD, i, Vector2(24, 24), 2.0),
			Dificultad.DIFICULTADES[clave].nombre, DIFICULTADES[clave][0], DIFICULTADES[clave][1], true, grupo)
		tarjeta.tooltip_text = Dificultad.DIFICULTADES[clave].explicacion
		tarjeta.pressed.connect(GestorGuardado.cambiar_opcion.bind("dificultad", clave))
		_dificultades[clave] = tarjeta
		fila.add_child(tarjeta)
		i += 1
	caja.add_child(fila)

	var abajo := HBoxContainer.new()
	var ayuda := EstiloInterfaz.boton("¿Cómo se juega?", reglas_pedidas.emit, 0)
	ayuda.flat = true
	ayuda.icon = Piezas.icono(Piezas.Icono.AYUDA)
	ayuda.add_theme_color_override("font_color", EstiloInterfaz.NEON)
	ayuda.add_theme_color_override("icon_normal_color", EstiloInterfaz.NEON)
	ayuda.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	abajo.add_child(ayuda)
	var hueco := Control.new()
	hueco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	abajo.add_child(hueco)
	_empezar = Piezas.boton_grande("EMPEZAR", Piezas.Icono.JUGAR, _empezar_partida, EstiloInterfaz.VICTORIA, Piezas.VERDE_CLARO, 240.0)
	abajo.add_child(_empezar)
	caja.add_child(abajo)

	add_child(EstiloInterfaz.ventana_centrada(caja, EstiloInterfaz.NEON, "JUGAR", Piezas.icono(Piezas.Icono.JUGAR)))
	visible = false
	# Si la dificultad cambia por otro lado (al entrar en la cuenta se bajan sus
	# opciones, cuenta_opciones.gd), la tarjeta la sigue. Método y no lambda:
	# GestorGuardado vive todo el juego y esta ventana no.
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)


## El foco, en EMPEZAR: así Enter (o A) empieza con lo que había.
func abrir() -> void:
	(_red if _en_red and _red.visible else _solo).button_pressed = true
	_dificultades[Dificultad.actual()].button_pressed = true
	visible = true
	_empezar.grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


## No se puede empezar (se está descargando una actualización: al acabar, el
## juego se reinicia).
func bloquear(si: bool) -> void:
	_empezar.disabled = si


func _al_cambiar_opcion(clave: String, valor: Variant) -> void:
	if clave == "dificultad" and _dificultades.has(valor):
		_dificultades[valor].button_pressed = true


func _empezar_partida() -> void:
	if _empezar.disabled:
		return
	# Al jugar, las novedades de esta versión ya se dan por vistas.
	TarjetaNovedades.marcar_vistas()
	if _en_red:
		visible = false
		red_pedida.emit()
	else:
		Transicion.cambiar_a(PARTIDA)


## Enter es EMPEZAR aunque el foco esté en una tarjeta (en _input, antes de que
## el botón con el foco lo coja). Con el mando, A elige la tarjeta del foco.
func _input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		get_viewport().set_input_as_handled()
		_empezar_partida()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()
