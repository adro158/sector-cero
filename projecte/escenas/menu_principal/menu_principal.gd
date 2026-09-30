extends Control

## Menú de inicio: título, reglas del juego, las amenazas que hay y los
## controles. Enter empieza la partida y Esc sale del juego.

const PARTIDA := "res://escenas/juego.tscn"

const REGLAS := [
	"Eres un proceso antivirus. Te mueves; tus herramientas atacan solas.",
	"El malware suelta fragmentos de datos: recógelos para subir de nivel.",
	"Al subir de nivel eliges una mejora o una herramienta nueva.",
	"El malware se adapta a la herramienta que más daño le hace: sus",
	"números salen en rojo. Combina varias para que no se haga fuerte.",
	"Aguanta 10 minutos y aparecerá el jefe final. Derrótalo para ganar.",
]

const AMENAZAS := [
	["res://recursos/enemigos/sprites/bit_corrupto.png", "Bit corrupto", "numeroso"],
	["res://recursos/enemigos/sprites/paquete_perdido.png", "Paquete perdido", "rápido"],
	["res://recursos/enemigos/sprites/proceso_colgado.png", "Proceso colgado", "resistente"],
]


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

	caja.add_child(_panel_reglas())

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	var jugar := _boton("JUGAR  [Enter]", _jugar)
	botones.add_child(jugar)
	botones.add_child(_boton("SALIR  [Esc]", get_tree().quit))
	caja.add_child(botones)
	jugar.grab_focus()


func _crear_fondo() -> void:
	var base := ColorRect.new()
	base.color = Color(0.015, 0.02, 0.04)
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(base)

	# La misma placa base que en la partida, con sus mismos colores.
	var material := ShaderMaterial.new()
	material.shader = load("res://escenas/jugabilidad/depuracion/fondo_provisional.gdshader")
	material.set_shader_parameter("tamano_celda", 96.0)
	material.set_shader_parameter("color_pista", Color(0.1, 0.6, 0.45, 0.28))
	material.set_shader_parameter("color_via", Color(0.2, 0.9, 0.7, 0.55))
	material.set_shader_parameter("color_chip", Color(0.04, 0.06, 0.1, 0.92))
	material.set_shader_parameter("color_borde_chip", Color(0.25, 0.45, 0.6, 0.8))
	var placa := ColorRect.new()
	placa.material = material
	placa.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(placa)


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
	caja.add_child(EstiloInterfaz.etiqueta("Moverse: WASD, flechas o stick   ·   Pausa: Esc o P   ·   Mejoras: click o 1, 2, 3", 15))
	return panel


func _boton(texto: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(220, 48)
	boton.pressed.connect(accion)
	return boton


func _unhandled_input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed:
		return
	if evento.keycode == KEY_ENTER or evento.keycode == KEY_KP_ENTER:
		_jugar()
	elif evento.keycode == KEY_ESCAPE:
		get_tree().quit()


func _jugar() -> void:
	get_tree().change_scene_to_file(PARTIDA)
