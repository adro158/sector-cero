class_name PanelOpciones
extends Control

## Ventana de opciones, en tres pestañas: Sonido (volúmenes y silencio al
## cambiar de ventana), Pantalla (pantalla completa, CRT, límite y contador de
## fps, aviso de versiones) y Accesibilidad (texto grande, destellos, cámara,
## vibración, números de daño y consejos). Desde el 02/11 van en pestañas
## porque en una lista ya no cabían en 720 px. Con el mando, LB y RB cambian
## de pestaña (05/11).
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
		var limites := [GestorGuardado.LIMITE_PANTALLA, 30, 60, 120, 144, 165, 180, 200, 240, 0]
		var nombres := ["la pantalla"]
		for limite in limites.slice(1, -1):
			nombres.append(str(limite))
		nombres.append("ilimitado")
		_selector(pantalla, "Límite de fps", "limite_fps", limites, nombres)
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

	var volver := EstiloInterfaz.segun_mando(EstiloInterfaz.boton("", cerrar), "VOLVER  [Esc]", "VOLVER  [B]")
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


## LB y RB cambian de pestaña estés donde estés: dentro de una, izquierda y
## derecha mueven los deslizadores y los selectores.
func _input(evento: InputEvent) -> void:
	if not visible or not evento is InputEventJoypadButton or not evento.pressed:
		return
	var paso: int = {JOY_BUTTON_LEFT_SHOULDER: -1, JOY_BUTTON_RIGHT_SHOULDER: 1}.get(evento.button_index, 0)
	if paso != 0:
		_pestanas.current_tab = posmod(_pestanas.current_tab + paso, _pestanas.get_tab_count())
		_pestanas.get_tab_bar().grab_focus()
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
	# Si la opción cambia por otro lado (las de la cuenta, cuenta_opciones.gd),
	# el deslizador la sigue, sin volver a guardarla.
	GestorGuardado.opcion_cambiada.connect(func(cambiada: String, valor: Variant):
		if cambiada == clave:
			deslizador.set_value_no_signal(valor))
	rejilla.add_child(deslizador)


func _casilla(rejilla: GridContainer, texto: String, clave: String) -> void:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var casilla := CheckButton.new()
	casilla.button_pressed = GestorGuardado.opcion(clave)
	# Solo el interruptor, sin estirarse a lo ancho de la columna.
	casilla.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	casilla.toggled.connect(func(activa: bool): GestorGuardado.cambiar_opcion(clave, activa))
	# Si la opción cambia por otro lado (F11, entrada.gd), el interruptor la
	# sigue, sin volver a guardarla.
	GestorGuardado.opcion_cambiada.connect(func(cambiada: String, valor: Variant):
		if cambiada == clave:
			casilla.set_pressed_no_signal(valor))
	rejilla.add_child(casilla)


## Una opción de varios valores: un botón con el que tiene que, al pulsarlo,
## abre la lista para elegir (Adam, 05/11: antes cada clic pasaba al
## siguiente y había que dar la vuelta entera). Con el teclado o el mando,
## aceptar abre la lista y arriba y abajo se mueven por ella; izquierda y
## derecha siguen cambiando sin abrirla.
func _selector(rejilla: GridContainer, texto: String, clave: String, valores: Array, nombres: Array) -> void:
	rejilla.add_child(EstiloInterfaz.etiqueta(texto, 18))
	var lista := OptionButton.new()
	lista.custom_minimum_size = Vector2(260, 40)
	for nombre in nombres:
		lista.add_item(nombre)
	# maxi: si el fichero trae un valor que ya no existe, se ve el primero.
	lista.select(maxi(valores.find(GestorGuardado.opcion(clave)), 0))
	lista.item_selected.connect(func(indice: int): GestorGuardado.cambiar_opcion(clave, valores[indice]))
	# Si la opción cambia por otro lado (las de la cuenta), la lista la sigue.
	# select() no avisa con item_selected: no se vuelve a guardar.
	GestorGuardado.opcion_cambiada.connect(func(cambiada: String, valor: Variant):
		if cambiada == clave:
			lista.select(maxi(valores.find(valor), 0)))
	lista.gui_input.connect(func(evento: InputEvent):
		var paso := 1 if evento.is_action_pressed("ui_right") else -1 if evento.is_action_pressed("ui_left") else 0
		if paso != 0:
			var siguiente := posmod(lista.selected + paso, valores.size())
			lista.select(siguiente)
			GestorGuardado.cambiar_opcion(clave, valores[siguiente])
			lista.accept_event())
	rejilla.add_child(lista)
