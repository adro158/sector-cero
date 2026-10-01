extends Control

## Menú de inicio: título, reglas del juego, las amenazas que hay, los controles
## y la mejor partida guardada. Enter empieza la partida y Esc sale del juego.

const PARTIDA := "res://escenas/juego.tscn"

const REGLAS := [
	"Eres un proceso antivirus. Te mueves; tu herramienta ataca sola.",
	"El malware suelta fragmentos de datos: recógelos para subir de nivel y elegir mejoras.",
	"Repetir una mejora tres veces hace evolucionar la herramienta de un personaje.",
	"El malware se adapta a la herramienta que más daño le hace: sus números salen en rojo.",
	"Cambia de personaje para atacarle con otra herramienta. Hay 10 s de espera entre cambios.",
	"Cada minuto llega un élite con afijos al azar. A los 10 minutos, el jefe final.",
]

const AMENAZAS := [
	["res://recursos/enemigos/sprites/bit_corrupto.png", "Bit corrupto", "numeroso"],
	["res://recursos/enemigos/sprites/paquete_perdido.png", "Paquete perdido", "rápido"],
	["res://recursos/enemigos/sprites/proceso_colgado.png", "Proceso colgado", "resistente"],
]

var _opciones: PanelOpciones


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	_crear_fondo()

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
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

	caja.add_child(_panel_reglas())

	var record := EstiloInterfaz.etiqueta(_texto_record(), 15, EstiloInterfaz.VICTORIA)
	record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(record)

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	var jugar := EstiloInterfaz.boton("JUGAR  [Enter]", _jugar, 220)
	var opciones := EstiloInterfaz.boton("OPCIONES", _abrir_opciones, 220)
	botones.add_child(jugar)
	botones.add_child(opciones)
	botones.add_child(EstiloInterfaz.boton("SALIR  [Esc]", get_tree().quit, 220))
	caja.add_child(botones)

	_opciones = PanelOpciones.new()
	_opciones.cerrado.connect(opciones.grab_focus)
	add_child(_opciones)
	jugar.grab_focus()


func _crear_fondo() -> void:
	# El mismo suelo de placa base que en la partida, con el mismo material.
	var suelo := ColorRect.new()
	suelo.material = load("res://escenas/arena/suelo.tres")
	suelo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(suelo)


func _panel_reglas() -> PanelContainer:
	var panel := PanelContainer.new()
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 6)
	panel.add_child(caja)

	caja.add_child(EstiloInterfaz.etiqueta("CÓMO SE JUEGA", 20, EstiloInterfaz.NEON))
	for regla in REGLAS:
		caja.add_child(EstiloInterfaz.etiqueta(regla, 15))

	caja.add_child(EstiloInterfaz.etiqueta("AMENAZAS", 20, EstiloInterfaz.NEON))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 28)
	for amenaza in AMENAZAS:
		var icono := TextureRect.new()
		icono.texture = load(amenaza[0])
		icono.custom_minimum_size = Vector2(40, 40)
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fila.add_child(icono)
		fila.add_child(EstiloInterfaz.etiqueta("%s\n%s" % [amenaza[1], amenaza[2]], 14))
	caja.add_child(fila)

	caja.add_child(EstiloInterfaz.etiqueta("CONTROLES", 20, EstiloInterfaz.NEON))
	caja.add_child(EstiloInterfaz.etiqueta("Moverse: WASD, flechas o stick   ·   Cambiar de personaje: Q, Tab o Y", 15))
	caja.add_child(EstiloInterfaz.etiqueta("Pausa: Esc, P o Start   ·   Mejoras: click o 1, 2, 3", 15))
	return panel


func _texto_record() -> String:
	var partidas := int(GestorGuardado.record("partidas"))
	if partidas == 0:
		return "Todavía no hay récords: ¡a por la primera partida!"

	var tiempo := int(GestorGuardado.record("tiempo"))
	return "MEJOR PARTIDA  %02d:%02d  ·  nivel %d  ·  %d eliminados  ·  %d victorias en %d partidas" % [
		tiempo / 60, tiempo % 60, GestorGuardado.record("nivel"), GestorGuardado.record("eliminados"),
		GestorGuardado.record("victorias"), partidas]


func _abrir_opciones() -> void:
	_opciones.abrir()


func _unhandled_input(evento: InputEvent) -> void:
	if _opciones.visible or not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_jugar()
	elif evento.keycode == KEY_ESCAPE:
		get_tree().quit()


func _jugar() -> void:
	Transicion.cambiar_a(PARTIDA)
