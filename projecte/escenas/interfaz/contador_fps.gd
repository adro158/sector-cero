extends Label

## El contador de fps de la opción «Contador de fps» (pestaña Pantalla): un
## texto pequeño arriba a la derecha, debajo del medidor de la resistencia.
## Para quien quiera ver cómo va el juego sin abrir el panel técnico (F3).
##
## Sin class_name: lo crea hud.gd con preload.


func _ready() -> void:
	# También en pausa: el menú de pausa se dibuja y los fps siguen contando.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	EstiloInterfaz.poner_letra(self, 14)
	add_theme_color_override("font_color", EstiloInterfaz.TEXTO_SUAVE)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	# El mismo borde derecho que el medidor (medidor_resistencia.gd), también
	# con el hueco del botón de pausa táctil.
	var hueco := 140.0 if DisplayServer.is_touchscreen_available() else 0.0
	offset_left = -136.0 - hueco
	offset_right = -16.0 - hueco
	offset_top = 58.0
	offset_bottom = 76.0
	visible = GestorGuardado.opcion("contador_fps")
	# Se puede encender y apagar desde las opciones de la pausa.
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)


func _al_cambiar_opcion(clave: String, valor: Variant) -> void:
	if clave == "contador_fps":
		visible = valor


func _process(_delta: float) -> void:
	if visible:
		text = "%d FPS" % Engine.get_frames_per_second()
