extends Label

## Panel técnico, no es la interfaz del juego: datos internos para probar y
## enseñar el sistema, sobre todo la resistencia del malware. Se muestra y se
## oculta con F3. Se alimenta de las señales del BusEventos y, para lo que no
## viaja por el bus (enemigos en pantalla, resistencias), de los grupos.

const COLOR := Color(0.45, 1.0, 0.65)
const ANCHO_BARRA := 10

var _vida := 0.0
var _vida_maxima := 0.0
var _experiencia := 0
var _nivel := 1
var _muertos := 0
var _tiempo := 0.0
var _ultimo_golpe := 0.0
var _terminada := false


func _ready() -> void:
	# Sigue actualizándose con el juego pausado, para poder consultarlo mientras
	# se elige una mejora.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	theme = EstiloInterfaz.tema()
	add_theme_stylebox_override("normal", EstiloInterfaz.caja(COLOR, 12))
	add_theme_color_override("font_color", COLOR)
	add_theme_font_size_override("font_size", 14)
	# Arriba a la derecha, bajo el reloj: la izquierda es del HUD.
	# Los dos bordes en el mismo punto y creciendo hacia la izquierda: el panel
	# ocupa solo lo que mide su texto.
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	offset_left = -16.0
	offset_right = -16.0
	offset_top = 16.0

	BusEventos.salud_jugador_cambiada.connect(_al_cambiar_vida)
	BusEventos.experiencia_ganada.connect(_al_ganar_experiencia)
	BusEventos.jugador_subio_nivel.connect(_al_subir_nivel)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.partida_terminada.connect(_al_terminar)


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and evento.keycode == KEY_F3:
		visible = not visible


func _process(delta: float) -> void:
	if not _terminada and not get_tree().paused:
		_tiempo += delta
	if not visible:
		return

	var lineas := [
		"PANEL TÉCNICO          F3",
		"",
		"── SISTEMA ─────────────",
		"tiempo      %02d:%02d" % [int(_tiempo) / 60, int(_tiempo) % 60],
		"fps         %d" % Engine.get_frames_per_second(),
		"",
		"── ANTIVIRUS ───────────",
		"vida        %s %3.0f" % [_barra(_vida / maxf(_vida_maxima, 1.0)), _vida],
		"nivel       %d" % _nivel,
		"experiencia %d" % _experiencia,
		"último golpe  -%.0f" % _ultimo_golpe,
		"",
		"── HORDA ───────────────",
		"en pantalla %d" % _enemigos_vivos(),
		"eliminados  %d" % _muertos,
		"",
		"── RESISTENCIA MALWARE ─",
	]

	var resistencias: Dictionary = get_tree().get_first_node_in_group("resistencia_malware").resistencias()
	if resistencias.is_empty():
		lineas.append("ninguna todavía")
	for arma in resistencias:
		# La barra llega a la mitad con el 50%, que es el máximo.
		var valor: float = resistencias[arma]
		lineas.append("%-9s %s %2d%%" % [arma.nombre, _barra(valor), roundi(valor * 100.0)])

	text = "\n".join(lineas)


## Barra de texto: bloques llenos y vacíos en proporción al valor, de 0 a 1.
func _barra(valor: float) -> String:
	var llenos := roundi(clampf(valor, 0.0, 1.0) * ANCHO_BARRA)
	return "█".repeat(llenos) + "░".repeat(ANCHO_BARRA - llenos)


func _enemigos_vivos() -> int:
	var total := 0

	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		total += gestor.vivos()

	return total


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	if _vida_maxima > 0.0 and actual < _vida:
		_ultimo_golpe = _vida - actual

	_vida = actual
	_vida_maxima = maxima


func _al_ganar_experiencia(cantidad: int) -> void:
	_experiencia += cantidad


func _al_subir_nivel(_opciones: Array) -> void:
	_nivel += 1


func _al_morir_enemigo(_posicion: Vector2, _tipo: String) -> void:
	_muertos += 1


func _al_terminar(_estadisticas: Dictionary) -> void:
	_terminada = true
