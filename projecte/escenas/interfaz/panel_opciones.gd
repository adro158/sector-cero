class_name PanelOpciones
extends Control

## Ventana de opciones, en tres pestañas: Sonido (volúmenes y silencio al
## cambiar de ventana), Pantalla (pantalla completa, CRT, límite y contador de
## fps, aviso de versiones) y Accesibilidad (texto grande, destellos, cámara,
## vibración, números de daño y consejos). Desde el 02/11 van en pestañas
## porque en una lista ya no cabían en 720 px.
## La usan el menú principal y el menú de pausa. Cada cambio se guarda en el
## momento a través de GestorGuardado, que también lo aplica.

signal cerrado

var _ventana: ColorRect
var _pestanas: TabContainer


func _ready() -> void:
	# Desde el menú de pausa se abre con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Anclajes y tamaño a la vez: con solo set_anchors_preset el panel se quedaba
	# en 0x0 y la ventana salía centrada en la esquina de arriba a la izquierda.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("OPCIONES", 36, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	_pestanas = TabContainer.new()
	# Del alto de la pestaña más larga: si no, la ventana cambiaría de tamaño
	# (y de sitio, porque va centrada) al pasar de una a otra.
	_pestanas.use_hidden_tabs_for_min_size = true
	caja.add_child(_pestanas)

	var sonido := _pestana("Sonido")
	_deslizador(sonido, "General", "volumen_general")
	_deslizador(sonido, "Música", "volumen_musica")
	_deslizador(sonido, "Efectos", "volumen_efectos")
	_casilla(sonido, "Silencio al cambiar de ventana", "silenciar_sin_foco")

	var pantalla := _pestana("Pantalla")
	_casilla(pantalla, "Pantalla completa", "pantalla_completa")
	_casilla(pantalla, "Filtro CRT", "crt")
	# En la web manda el navegador: el límite no haría nada.
	if not OS.has_feature("web"):
		_selector(pantalla, "Límite de fps", "limite_fps",
			[GestorGuardado.LIMITE_PANTALLA, 60, 144, 0], ["la pantalla", "60", "144", "sin límite"])
	_casilla(pantalla, "Contador de fps", "contador_fps")
	# Desde el lanzador y en la web el juego no busca versiones: la casilla no
	# haría nada.
	if not "--desde-lanzador" in OS.get_cmdline_user_args() and not OS.has_feature("web"):
		_casilla(pantalla, "Avisar de versiones nuevas", "avisar_versiones")

	var accesibilidad := _pestana("Accesibilidad")
	_casilla(accesibilidad, "Texto grande", "texto_grande")
	_casilla(accesibilidad, "Reducir destellos", "reducir_destellos")
	_casilla(accesibilidad, "Sacudir la cámara", "sacudir_camara")
	_casilla(accesibilidad, "Vibración del mando", "vibracion")
	_selector(accesibilidad, "Números de daño", "numeros_dano",
		["todos", "rojos", "ninguno"], ["todos", "solo los rojos", "ninguno"])
	_casilla(accesibilidad, "Consejos (primeras partidas)", "consejos")

	var volver := EstiloInterfaz.boton("VOLVER  [Esc]", cerrar)
	caja.add_child(volver)

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	add_child(_ventana)
	visible = false


## Con el foco en las pestañas: con el mando o las flechas, izquierda y
## derecha cambian de pestaña y abajo entra en sus opciones.
func abrir() -> void:
	visible = true
	_pestanas.current_tab = 0
	_pestanas.get_tab_bar().grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría o quitaría la pausa.
		get_viewport().set_input_as_handled()


## Una pestaña: una rejilla de dos columnas, el nombre y su control.
func _pestana(nombre: String) -> GridContainer:
	var rejilla := GridContainer.new()
	rejilla.name = nombre
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 24)
	rejilla.add_theme_constant_override("v_separation", 14)
	_pestanas.add_child(rejilla)
	return rejilla


func _deslizador(rejilla: GridContainer, texto: String, clave: String) -> void:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var deslizador := HSlider.new()
	deslizador.custom_minimum_size = Vector2(260, 24)
	deslizador.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	deslizador.max_value = 1.0
	deslizador.step = 0.05
	deslizador.value = GestorGuardado.opcion(clave)
	deslizador.value_changed.connect(func(valor: float): GestorGuardado.cambiar_opcion(clave, valor))
	rejilla.add_child(deslizador)


func _casilla(rejilla: GridContainer, texto: String, clave: String) -> void:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var casilla := CheckButton.new()
	casilla.button_pressed = GestorGuardado.opcion(clave)
	# Solo el interruptor, sin estirarse a lo ancho de la columna.
	casilla.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	casilla.toggled.connect(func(activa: bool): GestorGuardado.cambiar_opcion(clave, activa))
	rejilla.add_child(casilla)


## Una opción de varios valores: un botón con el que tiene, y al pulsarlo pasa
## al siguiente (después del último, vuelve al primero). Sirve igual con el
## ratón que con el mando, sin lista desplegable.
func _selector(rejilla: GridContainer, texto: String, clave: String, valores: Array, nombres: Array) -> void:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var boton := Button.new()
	boton.custom_minimum_size = Vector2(260, 40)
	var escribir := func():
		# maxi: si el fichero trae un valor que ya no existe, se ve el primero.
		boton.text = "<  %s  >" % nombres[maxi(valores.find(GestorGuardado.opcion(clave)), 0)]
	escribir.call()
	boton.pressed.connect(func():
		var siguiente: int = (valores.find(GestorGuardado.opcion(clave)) + 1) % valores.size()
		GestorGuardado.cambiar_opcion(clave, valores[siguiente])
		escribir.call())
	rejilla.add_child(boton)
