extends HBoxContainer

## La pista del pase de batalla (de Alan, 25/11; la usa pestana_pase.gd): los
## 30 niveles en fila, cada uno en su casilla, unidos por el conector, como
## placas en un circuito (lote de la interfaz de skins). Se desplaza con la
## rueda, con las flechas de los lados y con el mando (las flechas cogen el
## foco). Las casillas:
## - casilla.png: bloqueada, siguiente o conseguida, con el icono del premio
## - casilla_s.png y casilla_s_mas.png: los niveles con una skin S o S+, con
##   su retrato; casilla_30.png, el último
## Encima, el candado o el check.
##
## Sin class_name: la crea pestana_pase.gd con preload.

const Piezas := preload("res://escenas/skins/piezas_cartera.gd")
const PaseBatalla := preload("res://globales/pase_batalla.gd")
const Tienda := preload("res://globales/tienda.gd")
const Premios := preload("res://globales/premios.gd")
const RUTA := "res://medios/sprites/cartera/pase/"
const CASILLA := preload(RUTA + "casilla.png")
const CASILLA_S := preload(RUTA + "casilla_s.png")
const CASILLA_S_MAS := preload(RUTA + "casilla_s_mas.png")
const CASILLA_30 := preload(RUTA + "casilla_30.png")
const CONECTOR := preload(RUTA + "conector.png")
const CANDADO := preload(RUTA + "candado.png")
const CHECK := preload(RUTA + "check.png")
const NIVEL_SUBIDO := preload(RUTA + "nivel_subido.png")
## Lo que se mueve la pista con cada flecha.
const PASO := 300.0
const ALTO_NUMERO := 22.0

var _desplazar: ScrollContainer
var _fila: HBoxContainer
## La casilla de cada nivel (el 1 en el índice 0).
var _casillas: Array[Control] = []


func _ready() -> void:
	add_theme_constant_override("separation", 4)
	add_child(_flecha("<", -PASO))
	_desplazar = ScrollContainer.new()
	_desplazar.custom_minimum_size = Vector2(640, 220)
	_desplazar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Sin barra vertical: así la rueda del ratón mueve la pista de lado.
	_desplazar.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_fila = HBoxContainer.new()
	_fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_fila.add_theme_constant_override("separation", 0)
	_desplazar.add_child(_fila)
	add_child(_desplazar)
	add_child(_flecha(">", PASO))


## Rehace la pista con el nivel que se tiene (0 sin ninguno).
func poner(actual: int) -> void:
	for hijo in _fila.get_children():
		hijo.queue_free()
	_casillas.clear()
	for nivel in range(1, PaseBatalla.NIVELES + 1):
		if nivel > 1:
			_fila.add_child(_conector(nivel <= actual))
		_fila.add_child(_columna(nivel, actual))


## Mueve la pista para que ese nivel quede en medio (cuando ya está colocada).
func centrar(nivel: int) -> void:
	await get_tree().process_frame
	var casilla := _casillas[clampi(nivel, 1, _casillas.size()) - 1]
	var columna := casilla.get_parent() as Control
	_desplazar.scroll_horizontal = int(columna.position.x + columna.size.x / 2.0 - _desplazar.size.x / 2.0)


## El destello de nivel subido encima de la casilla de ese nivel.
func destello(nivel: int) -> void:
	var casilla := _casillas[clampi(nivel, 1, _casillas.size()) - 1]
	var animada := Piezas.Animada.new(NIVEL_SUBIDO, Vector2(72, 80), 0.07, false)
	animada.self_modulate = Piezas.CONSEGUIDO
	animada.position = (casilla.size - animada.size) / 2.0
	animada.acabada.connect(animada.queue_free)
	casilla.add_child(animada)


## Un nivel: su casilla con el premio y, debajo, su número.
func _columna(nivel: int, actual: int) -> VBoxContainer:
	var premio := PaseBatalla.premio(nivel)
	var estado := 2 if nivel <= actual else (1 if nivel == actual + 1 else 0)
	var color: Color = [EstiloInterfaz.TEXTO_SUAVE.darkened(0.3), EstiloInterfaz.NEON, Piezas.CONSEGUIDO][estado]
	var columna := VBoxContainer.new()
	columna.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columna.add_theme_constant_override("separation", 0)
	# Cada tipo de casilla: su hoja, su lado y dónde va el dibujo del premio.
	var hoja: Texture2D = CASILLA
	var lado := Vector2(48, 56)
	var donde := Vector2(8, 12)
	if nivel == PaseBatalla.NIVELES:
		hoja = CASILLA_30
		lado = Vector2(72, 90)
		donde = Vector2(20, 32)
	elif premio.tipo == "skin":
		var skin: Resource = Tienda.DATOS[premio.personaje].skin(premio.numero)
		hoja = CASILLA_S_MAS if skin.categoria == "S+" else CASILLA_S
		lado = Vector2(56, 72)
		donde = Vector2(12, 22)
	var casilla := Piezas.dibujo(Piezas.fotograma(hoja, estado, lado))
	casilla.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var dibujo: TextureRect
	if premio.tipo == "skin":
		dibujo = Piezas.dibujo(Tienda.DATOS[premio.personaje].skin(premio.numero).retrato_mini, 2)
		dibujo.self_modulate = Color.WHITE if estado > 0 else Color(0.45, 0.45, 0.5)
	else:
		dibujo = Piezas.icono_premio(premio.tipo, EstiloInterfaz.NEON if estado > 0 else color, 2)
	dibujo.position = donde * 2.0
	casilla.add_child(dibujo)
	if estado != 1:
		var marca := Piezas.dibujo(CHECK if estado == 2 else CANDADO)
		marca.position = Vector2(lado.x * 2.0 - 30.0, -2.0)
		casilla.add_child(marca)
	casilla.tooltip_text = "Nivel %d: %s" % [nivel, Premios.nombre(premio)]
	casilla.mouse_filter = Control.MOUSE_FILTER_PASS
	_casillas.append(casilla)
	columna.add_child(casilla)
	var numero := EstiloInterfaz.etiqueta("%d" % nivel, 16, color)
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numero.custom_minimum_size.y = ALTO_NUMERO
	columna.add_child(numero)
	return columna


## El cable entre dos casillas, encendido si ya se ha pasado por él: 9-slice
## con las vías a los lados y el centro en mosaico, a x2.
func _conector(encendido: bool) -> VBoxContainer:
	var parche := NinePatchRect.new()
	parche.texture = CONECTOR
	parche.region_rect = Rect2(24.0 if encendido else 0.0, 0.0, 24.0, 8.0)
	parche.patch_margin_left = 4
	parche.patch_margin_right = 4
	parche.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	parche.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parche.self_modulate = Piezas.CONSEGUIDO if encendido else EstiloInterfaz.TEXTO_SUAVE.darkened(0.4)
	parche.size = Vector2(12.0, 8.0)
	parche.scale = Vector2(2.0, 2.0)
	# El cable, en un Control normal: los contenedores le quitarían la escala.
	var cable := Control.new()
	cable.custom_minimum_size = Vector2(24.0, 16.0)
	cable.add_child(parche)
	var columna := VBoxContainer.new()
	columna.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columna.add_theme_constant_override("separation", 0)
	columna.add_child(cable)
	# Debajo, lo que ocupa el número: así queda a la altura de las casillas.
	var hueco := Control.new()
	hueco.custom_minimum_size.y = ALTO_NUMERO
	columna.add_child(hueco)
	return columna


func _flecha(texto: String, cuanto: float) -> Button:
	var boton := EstiloInterfaz.boton(texto, func(): create_tween().tween_property(_desplazar, "scroll_horizontal", _desplazar.scroll_horizontal + int(cuanto), 0.2), 36)
	boton.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return boton

