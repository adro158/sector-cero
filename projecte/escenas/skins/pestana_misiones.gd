extends VBoxContainer

## La pestaña MISIONES de la ventana SKINS (de Alan, 19/11): las 3 diarias y
## las 3 semanales de ahora (Cartera.misiones()), cada una con su progreso y lo
## que da en bits y en puntos del pase; las hechas, con «HECHA». Una diaria sin
## hacer se puede cambiar por otra, una vez al día (CAMBIAR). Debajo, la racha.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const Recompensa := preload("res://globales/recompensa.gd")
const ANCHO := 720.0
const BITS := Color("#00E5FF")
const HECHA := Color("#4DFF99")
const ICONO_GRANDE := preload("res://medios/sprites/bits/bits_icono_grande.png")

var _lista: VBoxContainer
var _racha: Label


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(ANCHO, 400)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 6)
	desplazar.add_child(_lista)
	add_child(desplazar)
	_racha = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_racha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_racha)


## La ventana la llama al enseñar la pestaña: las misiones pueden haber
## cambiado (otra partida, otro día).
func poner_al_dia() -> void:
	for hijo in _lista.get_children():
		hijo.queue_free()
	var misiones: Array = Cartera.actual.misiones()
	_titulo("DIARIAS · se renuevan cada día")
	for mision in misiones.filter(func(m): return m.tipo == "diaria"):
		_lista.add_child(_fila(mision))
	_titulo("SEMANALES · se renuevan cada lunes")
	for mision in misiones.filter(func(m): return m.tipo == "semanal"):
		_lista.add_child(_fila(mision))
	var dias: int = Cartera.actual.racha()
	_racha.text = "Racha: %d %s. La primera partida de cada día da +%d bits por día seguido (hasta +%d); fallar un día no quita nada." % [
		dias, "día" if dias == 1 else "días", Recompensa.RACHA_POR_DIA, Recompensa.RACHA_MAXIMA]


func _titulo(texto: String) -> void:
	_lista.add_child(EstiloInterfaz.etiqueta(texto, 14, EstiloInterfaz.NEON))


## Una misión: el texto y su barra a la izquierda; lo que da y CAMBIAR o
## HECHA a la derecha.
func _fila(mision: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(HECHA if mision.hecha else EstiloInterfaz.TEXTO_SUAVE.darkened(0.3), 8))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	var izquierda := VBoxContainer.new()
	izquierda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	izquierda.add_child(EstiloInterfaz.etiqueta(mision.texto, 16, EstiloInterfaz.TEXTO))
	var barra := ProgressBar.new()
	barra.max_value = mision.objetivo
	barra.value = mision.progreso
	barra.show_percentage = false
	barra.custom_minimum_size = Vector2(0, 8)
	# Con fondo, para que se vea también a cero.
	barra.add_theme_stylebox_override("background", _caja_plana(Color(1.0, 1.0, 1.0, 0.08)))
	barra.add_theme_stylebox_override("fill", _caja_plana(HECHA if mision.hecha else BITS))
	izquierda.add_child(barra)
	izquierda.add_child(EstiloInterfaz.etiqueta("%d / %d" % [mision.progreso, mision.objetivo], 12, EstiloInterfaz.TEXTO_SUAVE))
	fila.add_child(izquierda)
	# La moneda grande (lote_bits) delante de lo que da.
	var moneda := TextureRect.new()
	moneda.texture = ICONO_GRANDE
	moneda.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	moneda.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	fila.add_child(moneda)
	var premio := EstiloInterfaz.etiqueta("+%d bits\n+%d pase" % [mision.bits, mision.puntos], 14, BITS)
	premio.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fila.add_child(premio)
	if mision.hecha:
		fila.add_child(EstiloInterfaz.etiqueta("HECHA", 16, HECHA))
	elif mision.tipo == "diaria":
		var cambiar := EstiloInterfaz.boton("CAMBIAR", _cambiar.bind(mision.id), 120)
		cambiar.disabled = not Cartera.actual.puede_cambiar()
		cambiar.tooltip_text = "Cambia esta misión por otra. Una vez al día." if not cambiar.disabled else "Ya has cambiado una hoy."
		fila.add_child(cambiar)
	panel.add_child(fila)
	return panel


static func _caja_plana(color: Color) -> StyleBoxFlat:
	var caja := StyleBoxFlat.new()
	caja.bg_color = color
	return caja


func _cambiar(id: String) -> void:
	if Cartera.actual.cambiar_mision(id):
		poner_al_dia()
