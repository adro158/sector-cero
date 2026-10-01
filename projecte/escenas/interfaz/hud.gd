extends Control

## HUD de la partida: nivel y experiencia arriba a la izquierda, reloj y cuenta
## atrás hasta el jefe arriba en el centro, y la columna de mejoras elegidas a
## la izquierda. La vida va en una barra sobre el propio personaje.
##
## Solo escucha señales del BusEventos. Los niveles de cada mejora los anota el
## panel de mejoras al elegir, en un diccionario que comparten los dos.

var niveles_mejora := {}

var _etiqueta_nivel: Label
var _barra_experiencia: ProgressBar
var _etiqueta_experiencia: Label
var _etiqueta_tiempo: Label
var _etiqueta_jefe: Label
var _columna: VBoxContainer
var _iconos := {}
var _personaje: Label
var _aviso: Label
var _efecto_aviso: Tween
var _actual: DatosPersonaje
var _siguiente: DatosPersonaje
var _espera := 0.0


func _process(delta: float) -> void:
	if _actual == null:
		return
	# Cuenta atrás propia: se sabe cuánto faltaba al cambiar y el HUD, como el
	# juego, no avanza en pausa.
	_espera = maxf(_espera - delta, 0.0)
	var estado := "[Q] cambiar a %s" % _siguiente.nombre if _espera <= 0.0 else "%s en %d s" % [_siguiente.nombre, ceili(_espera)]
	_personaje.text = "%s · %s      %s" % [_actual.nombre.to_upper(), _actual.arma.nombre, estado]


func _al_cambiar_personaje(actual: DatosPersonaje, siguiente: DatosPersonaje, espera: float) -> void:
	_actual = actual
	_siguiente = siguiente
	_espera = espera
	_personaje.add_theme_color_override("font_color", actual.color)


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crear_experiencia()
	_crear_reloj()

	_columna = VBoxContainer.new()
	_columna.position = Vector2(16, 104)
	_columna.add_theme_constant_override("separation", 6)
	add_child(_columna)

	_personaje = EstiloInterfaz.etiqueta("", 16)
	_personaje.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_personaje.offset_left = -300.0
	_personaje.offset_right = 300.0
	_personaje.offset_top = -44.0
	_personaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_personaje)

	_aviso = EstiloInterfaz.etiqueta("", 26)
	_aviso.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_aviso.offset_left = -400.0
	_aviso.offset_right = 400.0
	_aviso.offset_top = 100.0
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.modulate.a = 0.0
	add_child(_aviso)

	$PanelMejoras.niveles = niveles_mejora
	BusEventos.elite_aparecio.connect(func(descripcion): _avisar("ÉLITE: " + descripcion, Color(1.0, 0.85, 0.3)))
	BusEventos.jefe_aparecio.connect(func(): _avisar("¡JEFE FINAL!", EstiloInterfaz.DERROTA))
	BusEventos.personaje_cambiado.connect(_al_cambiar_personaje)
	BusEventos.experiencia_cambiada.connect(_al_cambiar_experiencia)
	BusEventos.tiempo_partida.connect(_al_pasar_tiempo)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)


func _crear_experiencia() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 16)
	panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(EstiloInterfaz.NEON, 10))
	add_child(panel)

	var caja := VBoxContainer.new()
	panel.add_child(caja)
	_etiqueta_nivel = EstiloInterfaz.etiqueta("NIVEL 1", 20, EstiloInterfaz.NEON)
	caja.add_child(_etiqueta_nivel)

	_barra_experiencia = ProgressBar.new()
	_barra_experiencia.custom_minimum_size = Vector2(240, 10)
	_barra_experiencia.show_percentage = false
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(0.1, 0.15, 0.2)
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = EstiloInterfaz.NEON
	_barra_experiencia.add_theme_stylebox_override("background", fondo)
	_barra_experiencia.add_theme_stylebox_override("fill", relleno)
	caja.add_child(_barra_experiencia)

	_etiqueta_experiencia = EstiloInterfaz.etiqueta("EXP 0 / 0", 12, EstiloInterfaz.TEXTO_SUAVE)
	caja.add_child(_etiqueta_experiencia)


func _crear_reloj() -> void:
	var caja := VBoxContainer.new()
	# Anclado al centro de arriba: los offsets son relativos a ese punto.
	caja.set_anchors_preset(Control.PRESET_CENTER_TOP)
	caja.offset_left = -100.0
	caja.offset_right = 100.0
	caja.offset_top = 12.0
	add_child(caja)

	_etiqueta_tiempo = EstiloInterfaz.etiqueta("00:00", 30, EstiloInterfaz.TEXTO)
	_etiqueta_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_etiqueta_tiempo)
	_etiqueta_jefe = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_etiqueta_jefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_etiqueta_jefe)


func _al_cambiar_experiencia(actual: int, necesaria: int, nivel: int) -> void:
	_etiqueta_nivel.text = "NIVEL %d" % nivel
	_barra_experiencia.max_value = necesaria
	_barra_experiencia.value = actual
	_etiqueta_experiencia.text = "EXP %d / %d" % [actual, necesaria]


func _al_pasar_tiempo(segundos: float, duracion: float) -> void:
	_etiqueta_tiempo.text = _formato(segundos)
	if segundos < duracion:
		_etiqueta_jefe.text = "JEFE EN %s" % _formato(duracion - segundos)
	else:
		_etiqueta_jefe.text = "¡JEFE FINAL!"
		_etiqueta_jefe.add_theme_color_override("font_color", EstiloInterfaz.DERROTA)


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	if not _iconos.has(mejora):
		var icono := IconoMejora.new()
		icono.mejora = mejora
		_columna.add_child(icono)
		_iconos[mejora] = icono
	_iconos[mejora].poner_nivel(niveles_mejora.get(mejora, 1))


## Mensaje grande arriba en el centro que se desvanece a los pocos segundos.
func _avisar(texto: String, color: Color) -> void:
	_aviso.text = texto
	_aviso.add_theme_color_override("font_color", color)
	# Un aviso nuevo sustituye al anterior aunque no se haya apagado.
	if _efecto_aviso != null:
		_efecto_aviso.kill()
	_aviso.modulate.a = 1.0
	_efecto_aviso = create_tween()
	_efecto_aviso.tween_interval(2.0)
	_efecto_aviso.tween_property(_aviso, "modulate:a", 0.0, 1.0)


static func _formato(segundos: float) -> String:
	return "%02d:%02d" % [int(segundos) / 60, int(segundos) % 60]
