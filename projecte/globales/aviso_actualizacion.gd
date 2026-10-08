extends CanvasLayer

## Aviso de versión nueva que sale solo, en cualquier pantalla (menú o
## partida), cuando el Actualizador encuentra una release más nueva en GitHub.
## Deja elegir: ACTUALIZAR (descarga y reinicia) o AHORA NO (se cierra y no
## vuelve a salir para esa versión; el botón del menú sigue ahí).
##
## Lo crea el Actualizador y solo existe en el juego exportado. Sin class_name:
## así este script viaja en el .pck de las actualizaciones como uno más.

const InstaladorJuego := preload("res://globales/instalador_juego.gd")

var _panel: PanelContainer
var _titulo: Label
var _texto: Label
var _actualizar: Button
var _ahora_no: Button
## La versión a la que se ha dicho "ahora no", para no insistir con ella.
var _descartada := ""


func _ready() -> void:
	# Por encima del juego y del filtro CRT, para que se lea bien; por debajo
	# del fundido entre escenas.
	layer = 115
	# Tiene que funcionar también con el juego en pausa (subida de nivel).
	process_mode = Node.PROCESS_MODE_ALWAYS

	_panel = PanelContainer.new()
	_panel.theme = EstiloInterfaz.tema()
	_panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(EstiloInterfaz.VICTORIA, 16))
	# Arriba en el centro, debajo del reloj de la partida.
	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.offset_top = 84.0
	_panel.visible = false
	add_child(_panel)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 8)
	_panel.add_child(caja)
	_titulo = EstiloInterfaz.etiqueta("", 20, EstiloInterfaz.VICTORIA)
	_texto = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	for etiqueta in [_titulo, _texto]:
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 12)
	caja.add_child(botones)
	_actualizar = EstiloInterfaz.boton("ACTUALIZAR", InstaladorJuego.pulsar_actualizar, 180)
	_ahora_no = EstiloInterfaz.boton("AHORA NO", _descartar, 140)
	for boton in [_actualizar, _ahora_no]:
		# Solo con el ratón: si cogieran el foco, Enter o las flechas de la
		# partida pulsarían el botón sin querer.
		boton.focus_mode = Control.FOCUS_NONE
		botones.add_child(boton)

	Actualizador.estado_cambiado.connect(_mostrar)


func _mostrar() -> void:
	var estado: int = Actualizador.estado
	if estado in [Actualizador.Estado.HAY_ACTUALIZACION, Actualizador.Estado.HAY_JUEGO_NUEVO]:
		if Actualizador.version_nueva == _descartada or not GestorGuardado.opcion("avisar_versiones"):
			return
		var juego_nuevo: bool = estado == Actualizador.Estado.HAY_JUEGO_NUEVO
		_titulo.text = "NUEVA VERSIÓN %s DISPONIBLE" % Actualizador.version_nueva
		_texto.text = "Se descarga el juego completo y se reinicia." if juego_nuevo else "Se descarga en unos segundos y el juego se reinicia."
		if _en_partida():
			_texto.text += "\nSe perderá la partida en curso."
		_actualizar.visible = true
		_ahora_no.visible = true
		_aparecer()
	elif estado == Actualizador.Estado.DESCARGANDO:
		_texto.text = Actualizador.texto()
		_actualizar.visible = false
		_ahora_no.visible = false
	elif estado == Actualizador.Estado.ERROR:
		_texto.text = Actualizador.texto()
		_ahora_no.visible = true


func _aparecer() -> void:
	if _panel.visible:
		return
	_panel.visible = true
	_panel.modulate.a = 0.0
	create_tween().tween_property(_panel, "modulate:a", 1.0, 0.4)


func _descartar() -> void:
	_descartada = Actualizador.version_nueva
	_panel.visible = false


## Hay una partida en marcha si existe el jugador.
func _en_partida() -> bool:
	return get_tree().get_first_node_in_group("jugador") != null
