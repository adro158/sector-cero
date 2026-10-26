extends PanelContainer

## Los avisos grandes del HUD, arriba en el centro, en cola: antes, un aviso
## nuevo borraba al anterior al momento, y el «ÉLITE ELIMINADO: RECOGE EL
## CORAZÓN Y EL COFRE» podía no verse si llegaba otro (mejoras propuestas,
## interfaz 11). Cada aviso se ve al menos MINIMO segundos antes de dar paso
## al siguiente; los urgentes (jefes, furias, la fase 2) se ponen los primeros.
## Con el juego en pausa se quedan como estén.
##
## Desde el lote 9 van sobre una banda de 9 trozos con flechas en las puntas,
## teñida con el color del aviso, y con un icono a la izquierda (el jefe, la
## evolución, la fase 2, el élite, el escudo o el malware que se adapta).
##
## Lo crea hud.gd. Sin class_name: se carga con preload.

const BANDA := preload("res://medios/interfaz/aviso_banda.png")
const ICONOS := preload("res://medios/interfaz/aviso_iconos.png")
const ICONO_MALWARE := preload("res://medios/interfaz/resistencia_icono.png")
## El orden de la tira de iconos (aviso_iconos.png).
enum Icono { JEFE, EVOLUCION, FASE, ELITE, ESCUDO, MALWARE, NINGUNO }

## Lo que se ve un aviso si no hay otro esperando, y lo que tarda en apagarse.
const DURA := 3.0
const APAGADO := 1.0
## Lo mínimo que se ve un aviso aunque haya otro esperando.
const MINIMO := 1.5
## Si se juntan más, se tiran los más viejos que no son urgentes.
const MAXIMO_EN_COLA := 4
## A partir de este ancho, el texto pasa a dos líneas.
const ANCHO_MAXIMO := 760.0

## Cada aviso: [texto, color, urgente, icono].
var _cola: Array = []
## Segundos que lleva el aviso de ahora (-1 si no hay ninguno).
var _tiempo := -1.0
var _banda := StyleBoxTexture.new()
var _icono := TextureRect.new()
var _texto := Label.new()


func _ready() -> void:
	_banda.texture = BANDA
	_banda.texture_margin_left = 16.0
	_banda.texture_margin_right = 16.0
	_banda.texture_margin_top = 8.0
	_banda.texture_margin_bottom = 8.0
	_banda.content_margin_left = 26.0
	_banda.content_margin_right = 26.0
	_banda.content_margin_top = 6.0
	_banda.content_margin_bottom = 6.0
	add_theme_stylebox_override("panel", _banda)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Centrado arriba y creciendo hacia los dos lados según el texto. Debajo
	# de las barras de los jefes, que van de 62 a 102.
	set_anchors_preset(Control.PRESET_CENTER_TOP)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	offset_top = 108.0

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	add_child(fila)
	# El icono de 16x16, al doble.
	_icono.custom_minimum_size = Vector2(32.0, 32.0)
	_icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(_icono)
	EstiloInterfaz.poner_letra(_texto, 24)
	# Con contorno: la banda es medio transparente y debajo está la horda.
	_texto.add_theme_constant_override("outline_size", 8)
	_texto.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.07))
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(_texto)
	modulate.a = 0.0


func avisar(texto: String, color: Color, urgente := false, icono := Icono.NINGUNO) -> void:
	if urgente:
		# Delante de los que no lo son, pero detrás de otros urgentes.
		var donde := 0
		while donde < _cola.size() and _cola[donde][2]:
			donde += 1
		_cola.insert(donde, [texto, color, true, icono])
	else:
		_cola.append([texto, color, false, icono])
	while _cola.size() > MAXIMO_EN_COLA:
		var viejo := _cola.size() - 1
		for i in _cola.size():
			if not _cola[i][2]:
				viejo = i
				break
		_cola.remove_at(viejo)


func _process(delta: float) -> void:
	if _tiempo >= 0.0:
		_tiempo += delta
	var otro_esperando := not _cola.is_empty()
	if _tiempo < 0.0 or _tiempo >= DURA or (otro_esperando and _tiempo >= MINIMO):
		if not otro_esperando:
			_tiempo = -1.0
			modulate.a = 0.0
			return
		_mostrar(_cola.pop_front())
		_tiempo = 0.0
	# Entero hasta el último segundo, y se apaga.
	modulate.a = clampf((DURA - _tiempo) / APAGADO, 0.0, 1.0)


func _mostrar(aviso: Array) -> void:
	var color: Color = aviso[1]
	_texto.text = aviso[0]
	_texto.add_theme_color_override("font_color", color)
	# La banda, del color del aviso pero oscurecida, para que el texto destaque.
	_banda.modulate_color = color.lerp(Color.WHITE, 0.15)
	_icono.visible = aviso[3] != Icono.NINGUNO
	_icono.modulate = color
	if aviso[3] == Icono.MALWARE:
		_icono.texture = ICONO_MALWARE
	elif aviso[3] != Icono.NINGUNO:
		var trozo := AtlasTexture.new()
		trozo.atlas = ICONOS
		trozo.region = Rect2(aviso[3] * 16.0, 0.0, 16.0, 16.0)
		_icono.texture = trozo
	# Los largos, en dos líneas; los cortos, en una y la banda a su medida.
	var ancho := _texto.get_theme_font("font").get_string_size(_texto.text, HORIZONTAL_ALIGNMENT_LEFT, -1, _texto.get_theme_font_size("font_size")).x
	if ancho > ANCHO_MAXIMO:
		_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_texto.custom_minimum_size.x = ANCHO_MAXIMO
	else:
		_texto.autowrap_mode = TextServer.AUTOWRAP_OFF
		_texto.custom_minimum_size.x = 0.0
	# Que el contenedor vuelva a medirse con el texto nuevo y se recentre.
	reset_size()
	offset_left = -size.x / 2.0
	offset_right = size.x / 2.0
