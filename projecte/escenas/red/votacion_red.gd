extends PanelContainer

## En la partida en red: la votación para parar la partida (petición de Adam,
## 17/11). Cuando uno pulsa Esc, los demás ven «Alan quiere parar la partida»
## con SÍ y NO y, debajo, el voto de cada uno (pendiente, sí o no; el
## anfitrión, con su corona). Solo lo enseña: la lógica es de pausa_red.gd,
## que le pasa los votos y escucha `votado`.
##
## Sin class_name: lo crea interfaz_red.gd con preload.

signal votado(si: bool)

enum Voto { PENDIENTE, SI, NO }

## 3 de 12x12, en el orden de Voto.
const VOTOS := preload("res://medios/interfaz/red_voto.png")
## 8 de 12x12: 0 en uso, 1 jugador, 2 anfitrión, 3 conexión, 4 espera, 5 sí,
## 6 no y 7 pausa.
const ICONOS := preload("res://medios/interfaz/red_iconos.png")
const ICONO_ANFITRION := 2
const ICONO_PAUSA := 7
const COLORES_VOTO := [EstiloInterfaz.TEXTO_SUAVE, EstiloInterfaz.VICTORIA, EstiloInterfaz.DERROTA]
const COLOR_ANFITRION := Color(1.0, 0.8, 0.2)
## Si alguien dice que no, el aviso se queda este rato y se va.
const SEGUNDOS_RECHAZO := 2.5
## Lo que baja desde el borde de arriba: por debajo del reloj.
const ARRIBA := 120.0

var _titulo: Label
var _lista: HBoxContainer
var _botones: HBoxContainer
var _si: Button


func _ready() -> void:
	add_theme_stylebox_override("panel", EstiloInterfaz.banda(EstiloInterfaz.NEON, 30.0, 12.0))
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 10)
	add_child(columna)
	var cabecera := HBoxContainer.new()
	cabecera.alignment = BoxContainer.ALIGNMENT_CENTER
	cabecera.add_theme_constant_override("separation", 12)
	cabecera.add_child(_icono(ICONOS, ICONO_PAUSA, EstiloInterfaz.NEON))
	_titulo = EstiloInterfaz.etiqueta("", 22, EstiloInterfaz.NEON)
	cabecera.add_child(_titulo)
	columna.add_child(cabecera)
	_lista = HBoxContainer.new()
	_lista.alignment = BoxContainer.ALIGNMENT_CENTER
	_lista.add_theme_constant_override("separation", 22)
	columna.add_child(_lista)
	_botones = HBoxContainer.new()
	_botones.alignment = BoxContainer.ALIGNMENT_CENTER
	_botones.add_theme_constant_override("separation", 16)
	_si = EstiloInterfaz.boton("SÍ", _votar.bind(true), 120.0)
	_botones.add_child(_si)
	_botones.add_child(EstiloInterfaz.boton("NO", _votar.bind(false), 120.0))
	columna.add_child(_botones)
	visible = false


## titulo: lo de arriba; votos: cada uno {nombre, voto: Voto, anfitrion};
## puedo_votar: si se enseñan SÍ y NO (no al que la ha pedido ni a quien ya
## ha votado); rechazada: alguien ha dicho que no y se va sola.
func mostrar(titulo: String, votos: Array, puedo_votar: bool, rechazada := false) -> void:
	_titulo.text = titulo
	for hijo in _lista.get_children():
		hijo.queue_free()
	for datos in votos:
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 6)
		fila.add_child(_icono(VOTOS, datos.voto, COLORES_VOTO[datos.voto]))
		if datos.anfitrion:
			fila.add_child(_icono(ICONOS, ICONO_ANFITRION, COLOR_ANFITRION))
		fila.add_child(EstiloInterfaz.etiqueta(datos.nombre, 16))
		_lista.add_child(fila)
	var ya_visible := visible and _botones.visible
	_botones.visible = puedo_votar
	visible = true
	# El foco al SÍ al aparecer los botones, para votar también con el mando.
	if puedo_votar and not ya_visible:
		_si.grab_focus()
	if rechazada:
		get_tree().create_timer(SEGUNDOS_RECHAZO, true).timeout.connect(hide)
	_centrar.call_deferred()


## Centrada arriba, debajo del reloj. A mano y en diferido: lo que mide cambia
## con los nombres y los votos, y se sabe en el fotograma siguiente.
func _centrar() -> void:
	reset_size()
	position = Vector2((get_viewport_rect().size.x - size.x) / 2.0, ARRIBA)


func _votar(si: bool) -> void:
	_botones.visible = false
	votado.emit(si)


## Un icono de 12x12 de una tira, al doble y teñido.
func _icono(tira: Texture2D, indice: int, color: Color) -> TextureRect:
	var trozo := AtlasTexture.new()
	trozo.atlas = tira
	trozo.region = Rect2(indice * 12.0, 0.0, 12.0, 12.0)
	var icono := TextureRect.new()
	icono.texture = trozo
	icono.custom_minimum_size = Vector2(24.0, 24.0)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icono.modulate = color
	return icono
