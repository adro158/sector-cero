extends "res://escenas/interfaz/panel_ruleta.gd"

## En la partida en red: la ruleta del cofre que ha cogido un compañero, solo
## para mirar. Es la misma ruleta en grande (panel_ruleta.gd), con el mismo
## tiempo, y arriba «ALAN ESTÁ ABRIENDO UN COFRE». No contesta nada: se queda
## con el premio hasta que el compañero lo acepta y se va.
##
## Hasta el 18/11 era una ruleta pequeña que giraba sin la animación del
## cofre: acababa antes que la del que lo abría y le chafaba la sorpresa
## (Adam, 18/11).
##
## Sin class_name: lo crea interfaz_red.gd con preload.

## Lo que se queda el premio a la vista después de que el compañero lo acepte,
## si lo acepta antes de que aquí acabe de girar (llega con algo de retraso).
const SEGUNDOS_PREMIO := 1.0

var _titulo: Label
## De quién es el cofre (id de la red) y su premio, para saber cuándo cerrar.
var _id := -1
var _premio_companero: DatosMejora
var _girando := false
## El compañero ya ha aceptado el premio.
var _aceptada := false


func _ready() -> void:
	super()
	# La ruleta de este jugador ya la enseña la del HUD: esta solo se abre con
	# mostrar().
	BusEventos.ruleta_abierta.disconnect(_al_abrir)
	BusEventos.jugador_desconectado.connect(func(id): if id == _id: cerrar())
	add_to_group("cofre_companero")
	_titulo = EstiloInterfaz.etiqueta("", 26)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.set_anchors_preset(Control.PRESET_CENTER)
	_titulo.offset_left = -400.0
	_titulo.offset_right = 400.0
	_titulo.offset_top = -240.0
	_fondo.add_child(_titulo)


## niveles_companero: sus mejoras (mejora → veces), para el texto del nivel.
func mostrar(id: int, nombre: String, color: Color, opciones: Array, premio: DatosMejora, niveles_companero: Dictionary) -> void:
	_id = id
	_premio_companero = premio
	_girando = true
	_aceptada = false
	niveles = niveles_companero
	_titulo.text = "%s ESTÁ ABRIENDO UN COFRE" % nombre.to_upper()
	_titulo.add_theme_color_override("font_color", color)
	_al_abrir(opciones, premio)


func abierta() -> bool:
	return _fondo.visible


## Una mejora aplicada a un jugador (sucesos_red.gd): si es el premio de este
## cofre, el compañero lo ha aceptado.
func al_aplicar(id: int, mejora: DatosMejora) -> void:
	if not abierta() or id != _id or mejora != _premio_companero:
		return
	_aceptada = true
	if not _girando:
		cerrar()


func cerrar() -> void:
	_id = -1
	_fondo.visible = false
	if _latido != null:
		_latido.kill()


func _al_parar(sector: int) -> void:
	super(sector)
	# Como la del HUD, pero sin aceptar: el premio es del compañero.
	_parada = false
	_ayuda.visible = false
	_girando = false
	if _aceptada:
		# Si mientras tanto se abre otro cofre, _aceptada vuelve a ser false.
		get_tree().create_timer(SEGUNDOS_PREMIO, true).timeout.connect(func(): if _aceptada: cerrar())
