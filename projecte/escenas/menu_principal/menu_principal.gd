extends Control

## Menú de inicio: título, un resumen de cómo se juega, la mejor partida
## guardada y los botones. Las reglas completas (personajes, mejoras y
## enemigos) y el ranking están en sus propias ventanas. Enter empieza la partida y Esc sale.

const PARTIDA := "res://escenas/juego.tscn"
const PanelRanking := preload("res://escenas/interfaz/panel_ranking.gd")
const InstaladorJuego := preload("res://globales/instalador_juego.gd")
const PanelVersiones := preload("res://escenas/interfaz/panel_versiones.gd")

const RESUMEN := [
	"Eres un proceso antivirus. Te mueves; tu herramienta ataca sola.",
	"Aguanta 10 minutos contra el malware y derrota al jefe final.",
	"El malware se adapta a tu herramienta: cambia de personaje con Q y E para sorprenderle.",
]

var _reglas: PanelReglas
var _opciones: PanelOpciones
var _ranking: PanelRanking
var _versiones: PanelVersiones
var _version: Label
var _actualizar: Button
var _jugar_boton: Button


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	_crear_fondo()

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 18)
	centro.add_child(caja)

	var titulo := EstiloInterfaz.etiqueta("SECTOR CERO", 64, EstiloInterfaz.NEON)
	var lema := EstiloInterfaz.etiqueta("Defiende el sector de arranque del malware", 18, EstiloInterfaz.TEXTO_SUAVE)
	for etiqueta in [titulo, lema]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)
	# El título late despacio: una animación mínima para que la pantalla no
	# parezca congelada.
	var latido := create_tween().set_loops()
	latido.tween_property(titulo, "modulate:a", 0.6, 1.2)
	latido.tween_property(titulo, "modulate:a", 1.0, 1.2)

	caja.add_child(_panel_resumen())

	var record := EstiloInterfaz.etiqueta(_texto_record(), 15, EstiloInterfaz.VICTORIA)
	record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(record)

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 14)
	var jugar := EstiloInterfaz.boton("JUGAR  [Enter]", _jugar, 180)
	_jugar_boton = jugar
	var reglas := EstiloInterfaz.boton("REGLAS", _abrir_reglas, 160)
	var ranking := EstiloInterfaz.boton("RANKING", _abrir_ranking, 160)
	var opciones := EstiloInterfaz.boton("OPCIONES", _abrir_opciones, 160)
	for boton in [jugar, reglas, ranking, opciones]:
		botones.add_child(boton)
	# En el navegador no se puede cerrar el juego.
	if not OS.has_feature("web"):
		botones.add_child(EstiloInterfaz.boton("SALIR  [Esc]", get_tree().quit, 160))
	caja.add_child(botones)
	_crear_version(caja)

	# Al cerrar cada ventana, el foco vuelve al botón que la abrió.
	_reglas = PanelReglas.new()
	_reglas.cerrado.connect(reglas.grab_focus)
	add_child(_reglas)
	_opciones = PanelOpciones.new()
	_opciones.cerrado.connect(opciones.grab_focus)
	add_child(_opciones)
	_ranking = PanelRanking.new()
	_ranking.cerrado.connect(ranking.grab_focus)
	add_child(_ranking)
	jugar.grab_focus()


func _crear_fondo() -> void:
	# El mismo suelo de placa base que en la partida, con el mismo material.
	var suelo := ColorRect.new()
	suelo.material = load("res://escenas/arena/suelo.tres")
	suelo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(suelo)


## Versión del juego y, si hay una nueva, el botón para actualizar. Las consultas
## a GitHub las hace el Actualizador; aquí solo se enseña lo que va diciendo.
func _crear_version(caja: VBoxContainer) -> void:
	InstaladorJuego.limpiar()
	_version = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_version)
	# ACTUALIZAR solo sale si hay una versión nueva; VERSIONES, siempre: deja
	# instalar cualquiera, también una anterior.
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 14)
	_actualizar = EstiloInterfaz.boton("ACTUALIZAR", InstaladorJuego.pulsar_actualizar, 220)
	var versiones := EstiloInterfaz.boton("VERSIONES", func(): _versiones.abrir(), 180)
	fila.add_child(_actualizar)
	fila.add_child(versiones)
	caja.add_child(fila)
	_versiones = PanelVersiones.new()
	_versiones.cerrado.connect(versiones.grab_focus)
	add_child(_versiones)

	Actualizador.estado_cambiado.connect(_mostrar_version)
	_mostrar_version()
	# Los ejecutables desde la v0.6 ya buscan solos cada 5 minutos y esto no
	# cambia nada. Los anteriores solo buscan si se lo pide el menú.
	Actualizador.buscar()


func _mostrar_version() -> void:
	_version.text = Actualizador.texto()
	var estado := Actualizador.estado
	_actualizar.visible = estado in [Actualizador.Estado.HAY_ACTUALIZACION, Actualizador.Estado.HAY_JUEGO_NUEVO]
	_actualizar.text = "ACTUALIZAR"
	if estado == Actualizador.Estado.HAY_ACTUALIZACION:
		_version.add_theme_color_override("font_color", EstiloInterfaz.VICTORIA)
	# Al acabar la descarga el juego se reinicia: no se puede empezar partida.
	_jugar_boton.disabled = estado == Actualizador.Estado.DESCARGANDO


func _panel_resumen() -> PanelContainer:
	var panel := PanelContainer.new()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 6)
	panel.add_child(caja)

	caja.add_child(EstiloInterfaz.etiqueta("CÓMO SE JUEGA", 20, EstiloInterfaz.NEON))
	for linea in RESUMEN:
		caja.add_child(EstiloInterfaz.etiqueta(linea, 15))
	caja.add_child(EstiloInterfaz.etiqueta("En REGLAS tienes qué hace cada personaje, cada mejora y cada enemigo.", 14, EstiloInterfaz.TEXTO_SUAVE))
	return panel


func _texto_record() -> String:
	var partidas := int(GestorGuardado.record("partidas"))
	if partidas == 0:
		return "Todavía no hay récords: ¡a por la primera partida!"

	var tiempo := int(GestorGuardado.record("tiempo"))
	return "MEJOR PARTIDA  %02d:%02d  ·  nivel %d  ·  %d eliminados  ·  %d victorias en %d partidas" % [
		tiempo / 60, tiempo % 60, GestorGuardado.record("nivel"), GestorGuardado.record("eliminados"),
		GestorGuardado.record("victorias"), partidas]


func _abrir_reglas() -> void:
	_reglas.abrir()


func _abrir_opciones() -> void:
	_opciones.abrir()


func _abrir_ranking() -> void:
	_ranking.abrir()


func _unhandled_input(evento: InputEvent) -> void:
	# Con una ventana abierta, Enter y Esc son de ella.
	if _reglas.visible or _opciones.visible or _ranking.visible or _versiones.visible:
		return
	if not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_jugar()
	elif evento.keycode == KEY_ESCAPE and not OS.has_feature("web"):
		get_tree().quit()


func _jugar() -> void:
	if _jugar_boton.disabled:
		return
	Transicion.cambiar_a(PARTIDA)
