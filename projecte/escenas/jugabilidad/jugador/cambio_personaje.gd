extends Node

## Cambio de personaje durante la partida. Cada personaje lleva su propia
## herramienta y solo dispara la del activo: cuando el malware se hace
## resistente a ella, cambiar de personaje es la respuesta. La espera entre
## cambios obliga a decidir cuándo hacerlo en lugar de cambiar sin parar.

@export var personajes: Array[DatosPersonaje] = []
@export var espera: float = 10.0
## La mejora Cambio en caliente acorta la espera, pero nunca por debajo de esto:
## sin espera se podría cambiar sin parar y la resistencia no obligaría a nada.
@export var espera_minima: float = 4.0

var _indice := 0
var _restante := 0.0
## La herramienta actual de cada personaje. Empieza siendo la de sus datos y
## cambia al evolucionar; se guarda aquí porque el .tres está compartido y en
## caché, y modificarlo dejaría la evolución pegada para la siguiente partida.
var _armas: Array[DatosArma] = []


func _ready() -> void:
	for personaje in personajes:
		_armas.append(personaje.arma)
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


## El personaje que lleva el jugador ahora. Para el ranking.
func personaje_actual() -> DatosPersonaje:
	return personajes[_indice]


## La mejora Cambio en caliente: quita un porcentaje de la espera. Cuenta a
## partir del siguiente cambio, no acorta el que ya está en marcha.
func reducir_espera(fraccion: float) -> void:
	espera = maxf(espera * (1.0 - fraccion), espera_minima)


## Sustituye la herramienta base por su evolución en el personaje que la lleva.
## Si es el activo, la nueva empieza a disparar ya.
func evolucionar(base: DatosArma, nueva: DatosArma) -> void:
	var cual := _armas.find(base)
	if cual == -1:
		return
	_armas[cual] = nueva
	BusEventos.arma_evolucionada.emit(nueva)
	if cual == _indice:
		_aplicar()


func _aplicar() -> void:
	var personaje := personajes[_indice]
	get_parent().get_node("Sprite").texture = personaje.hoja
	get_parent().get_node("GestorArmas").cambiar_arma(_armas[_indice])
	var siguiente := personajes[(_indice + 1) % personajes.size()]
	# Diferido: al empezar la partida, el HUD aún no está conectado.
	BusEventos.personaje_cambiado.emit.call_deferred(personaje, _armas[_indice], siguiente, _restante)
