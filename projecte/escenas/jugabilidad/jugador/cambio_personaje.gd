extends Node

## Cambio de personaje durante la partida. Cada personaje lleva su propia
## herramienta y solo dispara la del activo: cuando el malware se hace
## resistente a ella, cambiar de personaje es la respuesta. La espera entre
## cambios obliga a decidir cuándo hacerlo en lugar de cambiar sin parar.

@export var personajes: Array[DatosPersonaje] = []
@export var espera: float = 10.0

var _indice := 0
var _restante := 0.0


func _ready() -> void:
	_aplicar()


func _physics_process(delta: float) -> void:
	_restante = maxf(_restante - delta, 0.0)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("cambiar_personaje"):
		cambiar()


## Pasa al siguiente personaje si ha terminado la espera. Devuelve si cambió.
func cambiar() -> bool:
	if _restante > 0.0:
		return false

	_indice = (_indice + 1) % personajes.size()
	_restante = espera
	_aplicar()

	# Destello al cambiar, para que se note que es otro personaje.
	var sprite: Sprite2D = get_parent().get_node("Sprite")
	sprite.modulate = Color(2.0, 2.0, 2.0)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.3)
	return true


func actual() -> DatosPersonaje:
	return personajes[_indice]


func _aplicar() -> void:
	var personaje := personajes[_indice]
	get_parent().get_node("Sprite").texture = personaje.hoja
	get_parent().get_node("GestorArmas").cambiar_arma(personaje.arma)
	var siguiente := personajes[(_indice + 1) % personajes.size()]
	# Diferido: al empezar la partida, el HUD aún no está conectado.
	BusEventos.personaje_cambiado.emit.call_deferred(personaje, siguiente, _restante)
