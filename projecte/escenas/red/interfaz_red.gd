extends CanvasLayer

## La interfaz propia de la partida en red, encima del HUD: la ficha de un
## compañero, la mini ruleta de su cofre y la votación para parar. También
## en pausa (la votación se ve con la partida parada). Lo crea partida_red.gd.
##
## Sin class_name: lo crea partida_red.gd con preload.

const FichaCompanero := preload("res://escenas/red/ficha_companero.gd")
const RuletaCompanero := preload("res://escenas/red/ruleta_companero.gd")
const VotacionRed := preload("res://escenas/red/votacion_red.gd")

var ficha: Control
var ruleta: Control
var votacion: Control
var _partida: Node


func _init(partida: Node) -> void:
	_partida = partida


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	ficha = FichaCompanero.new(_partida)
	ruleta = RuletaCompanero.new()
	votacion = VotacionRed.new()
	for parte in [ficha, ruleta, votacion]:
		parte.theme = EstiloInterfaz.tema()
		add_child(parte)
