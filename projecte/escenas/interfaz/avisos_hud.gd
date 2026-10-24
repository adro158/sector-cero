extends Label

## Los avisos grandes del HUD, arriba en el centro, en cola: antes, un aviso
## nuevo borraba al anterior al momento, y el «ÉLITE ELIMINADO: RECOGE EL
## CORAZÓN Y EL COFRE» podía no verse si llegaba otro (mejoras propuestas,
## interfaz 11). Cada aviso se ve al menos MINIMO segundos antes de dar paso
## al siguiente; los urgentes (jefes, furias, la fase 2) se ponen los primeros.
## Con el juego en pausa se quedan como estén.
##
## Lo crea hud.gd. Sin class_name: se carga con preload.

## Lo que se ve un aviso si no hay otro esperando, y lo que tarda en apagarse.
const DURA := 3.0
const APAGADO := 1.0
## Lo mínimo que se ve un aviso aunque haya otro esperando.
const MINIMO := 1.5
## Si se juntan más, se tiran los más viejos que no son urgentes.
const MAXIMO_EN_COLA := 4

## Cada aviso: [texto, color, urgente].
var _cola: Array = []
## Segundos que lleva el aviso de ahora (-1 si no hay ninguno).
var _tiempo := -1.0


func _ready() -> void:
	add_theme_font_size_override("font_size", EstiloInterfaz.tamano_texto(26))
	# Con contorno: va encima de la placa base y de la horda.
	add_theme_constant_override("outline_size", 8)
	add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.07))
	set_anchors_preset(Control.PRESET_CENTER_TOP)
	offset_left = -420.0
	offset_right = 420.0
	# Debajo de las barras de los jefes, que van de 62 a 102.
	offset_top = 108.0
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0


func avisar(texto: String, color: Color, urgente := false) -> void:
	if urgente:
		# Delante de los que no lo son, pero detrás de otros urgentes.
		var donde := 0
		while donde < _cola.size() and _cola[donde][2]:
			donde += 1
		_cola.insert(donde, [texto, color, true])
	else:
		_cola.append([texto, color, false])
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
		var siguiente: Array = _cola.pop_front()
		text = siguiente[0]
		add_theme_color_override("font_color", siguiente[1])
		_tiempo = 0.0
	# Entero hasta el último segundo, y se apaga.
	modulate.a = clampf((DURA - _tiempo) / APAGADO, 0.0, 1.0)
