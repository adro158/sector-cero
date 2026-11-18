extends PanelContainer

## En la partida en red: la votación para parar la partida (petición de Adam,
## 17/11). Cuando uno pulsa Esc, los demás ven «Alan quiere parar la partida»
## con SÍ y NO y, debajo, el voto de cada uno. Solo lo enseña: la lógica es de
## pausa_red.gd, que le pasa los votos y escucha `votado`.
##
## Sin class_name: lo crea interfaz_red.gd con preload.

signal votado(si: bool)

enum Voto { PENDIENTE, SI, NO }

## La banda de los avisos del HUD, con los márgenes de avisos_hud.gd.
const BANDA := preload("res://medios/interfaz/aviso_banda.png")
const TEXTOS_VOTO := ["...", "SÍ", "NO"]
const COLORES_VOTO := [EstiloInterfaz.TEXTO_SUAVE, EstiloInterfaz.VICTORIA, EstiloInterfaz.DERROTA]
## Si alguien dice que no, el aviso se queda este rato y se va.
const SEGUNDOS_RECHAZO := 2.5
## Lo que baja desde el borde de arriba: por debajo del reloj.
const ARRIBA := 120.0

var _titulo: Label
var _lista: HBoxContainer
var _botones: HBoxContainer
var _si: Button


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	add_theme_stylebox_override("panel", _banda(EstiloInterfaz.NEON))
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 10)
	add_child(columna)
	_titulo = EstiloInterfaz.etiqueta("", 22, EstiloInterfaz.NEON)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_titulo)
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
		var corona := " (anfitrión)" if datos.anfitrion else ""
		var etiqueta := EstiloInterfaz.etiqueta("%s %s%s" % [TEXTOS_VOTO[datos.voto], datos.nombre, corona], 16, COLORES_VOTO[datos.voto])
		_lista.add_child(etiqueta)
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


func _banda(color: Color) -> StyleBoxTexture:
	var banda := StyleBoxTexture.new()
	banda.texture = BANDA
	banda.texture_margin_left = 16.0
	banda.texture_margin_right = 16.0
	banda.texture_margin_top = 8.0
	banda.texture_margin_bottom = 8.0
	banda.content_margin_left = 30.0
	banda.content_margin_right = 30.0
	banda.content_margin_top = 12.0
	banda.content_margin_bottom = 12.0
	banda.modulate_color = color
	return banda
