extends VBoxContainer

## La pestaña PASE de la ventana SKINS (de Alan, 19/11): la Temporada 1 del
## pase de batalla (pase_batalla.gd). Desde el 25/11, con el lote de la
## interfaz de skins (como su montaje_pase.png): arriba, la cabecera de la
## temporada; debajo, el nivel y la barra hacia el siguiente, y la pista con
## los 30 niveles (pista_pase.gd), centrada en el siguiente. Si se ha subido
## de nivel desde la última vez, sale el destello en la casilla nueva.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const PaseBatalla := preload("res://globales/pase_batalla.gd")
const PistaPase := preload("res://escenas/skins/pista_pase.gd")
const Piezas := preload("res://escenas/skins/piezas_cartera.gd")
const RUTA := "res://medios/sprites/cartera/pase/"
const ANCHO := 720.0

var _nivel: Label
var _puntos: Label
var _barra: TextureProgressBar
var _pista: PistaPase


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	# La cabecera (360x48, a x2), con «TEMPORADA 1» en su placa del centro.
	var cabecera := Piezas.dibujo(load(RUTA + "cabecera_temporada.png"))
	cabecera.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var temporada := EstiloInterfaz.etiqueta("TEMPORADA %d" % PaseBatalla.TEMPORADA, 22, EstiloInterfaz.TEXTO)
	temporada.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	temporada.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	temporada.position = Vector2(0.0, 46.0 - 16.0)
	temporada.size = Vector2(ANCHO, 32.0)
	cabecera.add_child(temporada)
	add_child(cabecera)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	_nivel = EstiloInterfaz.etiqueta("", 18, EstiloInterfaz.TEXTO)
	_nivel.custom_minimum_size.x = 120
	fila.add_child(_nivel)
	fila.add_child(_barra_de_nivel())
	_puntos = EstiloInterfaz.etiqueta("", 16, EstiloInterfaz.TEXTO_SUAVE)
	fila.add_child(_puntos)
	add_child(fila)
	_pista = PistaPase.new()
	add_child(_pista)
	add_child(EstiloInterfaz.etiqueta("Sube jugando (10 puntos por minuto aguantado, el doble en red) y con las misiones. Los premios se dan solos.", 13, EstiloInterfaz.TEXTO_SUAVE))


## La barra del nivel (9-slice: 6 a los lados y 4 arriba y abajo), teñida de
## neón y a x2. En un Control normal: los contenedores le quitarían la escala.
func _barra_de_nivel() -> Control:
	_barra = TextureProgressBar.new()
	_barra.texture_under = load(RUTA + "barra_marco.png")
	_barra.texture_progress = load(RUTA + "barra_relleno.png")
	_barra.nine_patch_stretch = true
	_barra.stretch_margin_left = 6
	_barra.stretch_margin_right = 6
	_barra.stretch_margin_top = 4
	_barra.stretch_margin_bottom = 4
	_barra.tint_under = EstiloInterfaz.NEON.darkened(0.3)
	_barra.tint_progress = Piezas.BITS
	_barra.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_barra.size = Vector2(220.0, 12.0)
	_barra.scale = Vector2(2.0, 2.0)
	var sitio := Control.new()
	sitio.custom_minimum_size = _barra.size * 2.0
	sitio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sitio.add_child(_barra)
	return sitio


func poner_al_dia() -> void:
	var estado: Dictionary = Cartera.actual.pase()
	_nivel.text = "NIVEL %d" % estado.nivel
	if estado.nivel == estado.maximo:
		_puntos.text = "¡COMPLETO!"
	else:
		_puntos.text = "%d / %d" % [estado.en_el_nivel, estado.necesarios]
	_barra.max_value = maxi(estado.necesarios, 1)
	_barra.value = estado.en_el_nivel if estado.necesarios > 0 else 1
	_pista.poner(estado.nivel)
	await _pista.centrar(mini(estado.nivel + 1, estado.maximo))
	# Lo subido desde la última vez que se miró: el destello, una vez.
	if estado.nivel > estado.visto:
		_pista.destello(estado.nivel)
		Cartera.actual.ver_pase(estado.nivel)
