extends Node

## El equipo de personajes. Cada uno lleva su propia herramienta y su propia
## vida, y solo dispara y recibe golpes el activo: cuando el malware se hace
## resistente a su herramienta, o cuando le queda poca vida, se cambia a otro
## (E al siguiente, Q al anterior). La espera entre cambios obliga a decidir
## cuándo hacerlo. Los que esperan se curan poco a poco.
##
## El nodo Salud del jugador es siempre la vida del activo: al cambiar, se
## guarda la suya aquí y Salud pasa a tener la del que entra. Cuando el activo
## cae, el juego se pausa y se elige quién sigue entre los que quedan; la
## partida se pierde cuando han caído todos.

## Han caído todos los personajes: se acaba la partida.
signal equipo_derrotado

@export var personajes: Array[DatosPersonaje] = []
@export var espera: float = 10.0
## La mejora Cambio en caliente acorta la espera, pero nunca por debajo de esto:
## sin espera se podría cambiar sin parar y la resistencia no obligaría a nada.
@export var espera_minima: float = 4.0
## Vida por segundo que recuperan los que no están jugando.
@export var regeneracion_banquillo: float = 1.5
## Segundos sin recibir daño del que entra tras caer el anterior: si no, la
## horda que acaba de matar al primero mataría al segundo al momento.
@export var proteccion_al_entrar: float = 2.0

var _indice := 0
var _restante := 0.0
## La herramienta actual de cada personaje. Empieza siendo la de sus datos y
## cambia al evolucionar; se guarda aquí porque el .tres está compartido y en
## caché, y modificarlo dejaría la evolución pegada para la siguiente partida.
var _armas: Array[DatosArma] = []
## La vida de cada personaje, su máximo y si ha caído. La del activo vive en
## el nodo Salud mientras juega.
var _vidas: Array[float] = []
var _maximas: Array[float] = []
var _caidos: Array[bool] = []
## Si el juego está pausado esperando a que se elija quién sigue.
var _eligiendo := false

@onready var _salud: Salud = get_parent().get_node("Salud")


func _ready() -> void:
	for personaje in personajes:
		_armas.append(personaje.arma)
		_vidas.append(personaje.vida_maxima)
		_maximas.append(personaje.vida_maxima)
		_caidos.append(false)
	_configurar_teclas_antiguas()
	_salud.vida_cambiada.connect(func(_actual, _maxima): _avisar_equipo())
	_salud.murio.connect(_al_caer)
	BusEventos.personaje_elegido.connect(_al_elegir_personaje)
	_salud.poner(_vidas[_indice], _maximas[_indice])
	_aplicar()


func _physics_process(delta: float) -> void:
	_restante = maxf(_restante - delta, 0.0)

	var cambio := false
	for i in personajes.size():
		if i == _indice or _caidos[i] or _vidas[i] >= _maximas[i]:
			continue
		var antes := int(_vidas[i])
		_vidas[i] = minf(_vidas[i] + regeneracion_banquillo * delta, _maximas[i])
		# Como Salud: solo se avisa cuando cambia el número entero.
		cambio = cambio or int(_vidas[i]) != antes
	if cambio:
		_avisar_equipo()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("cambiar_personaje"):
		cambiar(1)
	elif evento.is_action_pressed("personaje_anterior"):
		cambiar(-1)


## Pasa al siguiente personaje vivo (paso 1) o al anterior (paso -1) si ha
## terminado la espera. Devuelve si cambió.
func cambiar(paso: int = 1) -> bool:
	var otro := _vivo_desde(_indice, paso)
	if _restante > 0.0 or otro == _indice:
		return false

	_entrar(otro)
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


## Si el juego está pausado porque se está eligiendo quién sigue.
func eligiendo() -> bool:
	return _eligiendo


## La mejora Cambio en caliente: quita un porcentaje de la espera. Cuenta a
## partir del siguiente cambio, no acorta el que ya está en marcha.
func reducir_espera(fraccion: float) -> void:
	espera = maxf(espera * (1.0 - fraccion), espera_minima)


## La mejora Memoria redundante: más vida máxima para todo el equipo.
func aumentar_vida_maxima(cantidad: float) -> void:
	for i in personajes.size():
		_maximas[i] += cantidad
		if not _caidos[i]:
			_vidas[i] += cantidad
	_salud.aumentar_vida_maxima(cantidad)


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


func _al_caer() -> void:
	_vidas[_indice] = 0.0
	_caidos[_indice] = true
	_avisar_equipo()
	if not _caidos.has(false):
		equipo_derrotado.emit()
		return
	# La pausa la pone la jugabilidad, como al subir de nivel: la interfaz solo
	# enseña quién queda y avisa del elegido con personaje_elegido.
	_eligiendo = true
	get_tree().paused = true
	BusEventos.personaje_caido.emit(_estado(), _indice)


func _al_elegir_personaje(indice: int) -> void:
	if not _eligiendo or _caidos[indice]:
		return
	_eligiendo = false
	_entrar(indice)
	_salud.proteger(proteccion_al_entrar)
	_aplicar()
	get_tree().paused = false


## Guarda la vida del que sale y pone en Salud la del que entra.
func _entrar(indice: int) -> void:
	if not _caidos[_indice]:
		_vidas[_indice] = _salud.vida()
		_maximas[_indice] = _salud.vida_maxima
	_indice = indice
	_salud.poner(_vidas[_indice], _maximas[_indice])


## El primer personaje vivo a partir de desde, avanzando de paso en paso. Si
## no hay ningún otro vivo, devuelve el mismo desde.
func _vivo_desde(desde: int, paso: int) -> int:
	for salto in range(1, personajes.size()):
		var otro := posmod(desde + paso * salto, personajes.size())
		if not _caidos[otro]:
			return otro
	return desde


func _aplicar() -> void:
	var personaje := personajes[_indice]
	get_parent().get_node("Sprite").texture = personaje.hoja
	get_parent().get_node("GestorArmas").cambiar_arma(_armas[_indice])
	var siguiente := personajes[_vivo_desde(_indice, 1)]
	# Diferido: al empezar la partida, el HUD aún no está conectado.
	BusEventos.personaje_cambiado.emit.call_deferred(personaje, _armas[_indice], siguiente, _restante)
	_avisar_equipo.call_deferred()


func _avisar_equipo() -> void:
	BusEventos.equipo_cambiado.emit(_estado(), _indice)


## Cómo está cada personaje, para la interfaz: un diccionario por personaje
## con personaje, arma, vida, maxima y caido. La vida del activo es la de Salud.
func _estado() -> Array:
	var estado := []
	for i in personajes.size():
		var activo := i == _indice and not _caidos[i]
		estado.append({
			"personaje": personajes[i],
			"arma": _armas[i],
			"vida": _salud.vida() if activo else _vidas[i],
			"maxima": _salud.vida_maxima if activo else _maximas[i],
			"caido": _caidos[i],
		})
	return estado


## E pasa al siguiente y Q vuelve al anterior. Están en project.godot desde la
## v0.7, pero los ejecutables anteriores traen el project.godot viejo (Q para
## pasar al siguiente) y las actualizaciones pequeñas no lo cambian: allí se
## arreglan aquí, al empezar la partida.
static func _configurar_teclas_antiguas() -> void:
	if InputMap.has_action("personaje_anterior"):
		return
	InputMap.add_action("personaje_anterior")
	for evento in InputMap.action_get_events("cambiar_personaje"):
		if evento is InputEventKey and evento.physical_keycode == KEY_Q:
			InputMap.action_erase_event("cambiar_personaje", evento)
	var q := InputEventKey.new()
	q.physical_keycode = KEY_Q
	InputMap.action_add_event("personaje_anterior", q)
	var e := InputEventKey.new()
	e.physical_keycode = KEY_E
	InputMap.action_add_event("cambiar_personaje", e)
