extends VBoxContainer

## La pestaña LOGROS de la ventana SKINS (de Alan, 19/11): los retos que no
## caducan (logros.gd), cada uno con su progreso y el título que da. Los
## conseguidos, en verde.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const Premios := preload("res://globales/premios.gd")
const ANCHO := 720.0
const AVANCE := Color("#00E5FF")
const HECHO := Color("#4DFF99")

var _lista: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	add_child(EstiloInterfaz.etiqueta("Retos que no caducan. Cada uno da un título para tu nombre (se elige en el perfil).", 13, EstiloInterfaz.TEXTO_SUAVE))
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(ANCHO, 400)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 6)
	desplazar.add_child(_lista)
	add_child(desplazar)


func poner_al_dia() -> void:
	for hijo in _lista.get_children():
		hijo.queue_free()
	for logro in Cartera.actual.logros():
		_lista.add_child(_fila(logro))


func _fila(logro: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(HECHO if logro.hecho else EstiloInterfaz.TEXTO_SUAVE.darkened(0.3), 8))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	var izquierda := VBoxContainer.new()
	izquierda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	izquierda.add_child(EstiloInterfaz.etiqueta(logro.texto, 16, EstiloInterfaz.TEXTO))
	var barra := ProgressBar.new()
	barra.max_value = logro.objetivo
	barra.value = logro.progreso
	barra.show_percentage = false
	barra.custom_minimum_size = Vector2(0, 8)
	for parte in [["background", Color(1.0, 1.0, 1.0, 0.08)], ["fill", HECHO if logro.hecho else AVANCE]]:
		var caja := StyleBoxFlat.new()
		caja.bg_color = parte[1]
		barra.add_theme_stylebox_override(parte[0], caja)
	izquierda.add_child(barra)
	izquierda.add_child(EstiloInterfaz.etiqueta("%d / %d" % [logro.progreso, logro.objetivo], 12, EstiloInterfaz.TEXTO_SUAVE))
	fila.add_child(izquierda)
	var titulo := EstiloInterfaz.etiqueta("«%s»" % Premios.TITULOS.get(logro.titulo, logro.titulo), 14, HECHO if logro.hecho else AVANCE)
	fila.add_child(titulo)
	panel.add_child(fila)
	return panel
