extends VBoxContainer

## La pestaña PASE de la ventana SKINS (de Alan, 19/11): la Temporada 1 del
## pase de batalla (pase_batalla.gd). Arriba, el nivel y la barra hacia el
## siguiente; debajo, los 30 niveles con su premio: los conseguidos, en verde;
## el siguiente, resaltado; los demás, apagados. Las skins, con su retrato.
##
## Sin class_name: la crea ventana_skins.gd con preload.

const Cartera := preload("res://globales/cartera.gd")
const PaseBatalla := preload("res://globales/pase_batalla.gd")
const Premios := preload("res://globales/premios.gd")
const ANCHO := 720.0
const BITS := Color("#00E5FF")
const HECHO := Color("#4DFF99")
const ICONO_GRANDE := preload("res://medios/sprites/bits/bits_icono_grande.png")

var _nivel: Label
var _barra: ProgressBar
var _lista: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	_nivel = EstiloInterfaz.etiqueta("", 18, EstiloInterfaz.NEON)
	add_child(_nivel)
	_barra = ProgressBar.new()
	_barra.show_percentage = false
	_barra.custom_minimum_size = Vector2(ANCHO, 10)
	_barra.add_theme_stylebox_override("background", _plana(Color(1.0, 1.0, 1.0, 0.08)))
	_barra.add_theme_stylebox_override("fill", _plana(BITS))
	add_child(_barra)
	add_child(EstiloInterfaz.etiqueta("Sube jugando (10 puntos por minuto aguantado, el doble en red) y con las misiones. Los premios se dan solos.", 13, EstiloInterfaz.TEXTO_SUAVE))
	var desplazar := ScrollContainer.new()
	desplazar.custom_minimum_size = Vector2(ANCHO, 330)
	desplazar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 4)
	desplazar.add_child(_lista)
	add_child(desplazar)


func poner_al_dia() -> void:
	var estado: Dictionary = Cartera.actual.pase()
	if estado.nivel == estado.maximo:
		_nivel.text = "TEMPORADA %d · NIVEL %d / %d · ¡COMPLETO!" % [PaseBatalla.TEMPORADA, estado.nivel, estado.maximo]
	else:
		_nivel.text = "TEMPORADA %d · NIVEL %d / %d · %d / %d puntos para el %d" % [PaseBatalla.TEMPORADA,
			estado.nivel, estado.maximo, estado.en_el_nivel, estado.necesarios, estado.nivel + 1]
	_barra.max_value = maxi(estado.necesarios, 1)
	_barra.value = estado.en_el_nivel if estado.necesarios > 0 else 1
	for hijo in _lista.get_children():
		hijo.queue_free()
	for nivel in range(1, PaseBatalla.NIVELES + 1):
		_lista.add_child(_fila(nivel, estado.nivel))


## Un nivel: su número, el retrato si es una skin, el premio y si ya se tiene.
func _fila(nivel: int, actual: int) -> PanelContainer:
	var premio := PaseBatalla.premio(nivel)
	var conseguido := nivel <= actual
	var color := HECHO if conseguido else (EstiloInterfaz.NEON if nivel == actual + 1 else EstiloInterfaz.TEXTO_SUAVE.darkened(0.3))
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloInterfaz.caja(color, 6))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	var numero := EstiloInterfaz.etiqueta("%2d" % nivel, 18, color)
	numero.custom_minimum_size.x = 40
	fila.add_child(numero)
	if premio.tipo == "skin" or premio.tipo == "bits":
		var retrato := TextureRect.new()
		retrato.texture = ICONO_GRANDE if premio.tipo == "bits" else _personaje(premio.personaje).skin(premio.numero).retrato_mini
		retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fila.add_child(retrato)
	var texto := EstiloInterfaz.etiqueta(Premios.nombre(premio), 15, EstiloInterfaz.TEXTO if conseguido or nivel == actual + 1 else EstiloInterfaz.TEXTO_SUAVE)
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(texto)
	fila.add_child(EstiloInterfaz.etiqueta("CONSEGUIDO" if conseguido else "nivel %d" % nivel, 13, color))
	panel.add_child(fila)
	return panel


static func _personaje(nombre: String) -> DatosPersonaje:
	return load("res://recursos/personajes/datos/%s.tres" % nombre.to_lower().replace("í", "i"))


static func _plana(color: Color) -> StyleBoxFlat:
	var caja := StyleBoxFlat.new()
	caja.bg_color = color
	return caja
