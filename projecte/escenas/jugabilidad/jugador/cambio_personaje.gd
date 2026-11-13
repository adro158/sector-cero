extends Node

## El personaje que lleva este jugador, de los del equipo (equipo.gd). Cada uno
## lleva su propia herramienta y su propia vida, y solo dispara y recibe
## golpes el que juega: cuando el malware se hace resistente a su
## herramienta, o cuando le queda poca vida, se cambia a otro (E al
## siguiente, Q al anterior). La espera entre cambios obliga a decidir cuándo
## hacerlo. Los que esperan se curan poco a poco.
##
## El nodo Salud del jugador es siempre la vida del que lleva: al cambiar, se
## guarda la suya en el equipo y Salud pasa a tener la del que entra. Cuando
## cae, el juego se pausa, se deshace (efectos_jugador.gd) y se elige quién
## sigue entre los que quedan; la partida se pierde cuando han caído todos.
##
## Con varios jugadores (multijugador, desde el 13/11) el equipo es de todos:
## solo se cambia a uno libre y, si cae el tuyo, pasas sin pausa al libre que
## quede; si no queda, te quedas mirando (la cámara sigue a otro jugador) y
## vuelves con un personaje al empezar la fase 2.

## Han caído todos los personajes: se acaba la partida.
signal equipo_derrotado

const TeclasAntiguas := preload("res://escenas/jugabilidad/jugador/teclas_antiguas.gd")
const Equipo := preload("res://escenas/jugabilidad/jugador/equipo.gd")
const Jugadores := preload("res://escenas/jugabilidad/jugadores.gd")
## Las partes del jugador que se apagan y se esconden sin personaje.
const PARTES_ESPECTADOR := ["GestorArmas", "AuraArma", "Ultis", "BarraVida"]

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

## Con el escudo de NÚCLEO CERO puesto se cambia sin espera: cada ancla solo
## la rompe la herramienta de su personaje (escudo_jefe_final.gd lo pone y lo
## quita). Al ponerlo, la espera que quedaba se acaba.
var sin_espera := false:
	set(valor):
		sin_espera = valor
		if valor and _restante > 0.0:
			_restante = 0.0
			_avisar_cambio()

var _indice := 0
var _restante := 0.0
var _equipo: Equipo
## Si el juego está pausado esperando a que se elija quién sigue.
var _eligiendo := false
## Sin personaje (multijugador): mira la partida hasta la fase 2.
var _espectador := false

@onready var _salud: Salud = get_parent().get_node("Salud")
@onready var _sprite: Sprite2D = get_parent().get_node("Sprite")
@onready var _efectos: Node2D = get_parent().get_node("EfectosJugador")


func _ready() -> void:
	# Uno por partida, en la raíz: el primer jugador lo crea y los demás lo
	# encuentran ya hecho.
	var raiz := get_parent().get_parent()
	if not raiz.has_meta("equipo"):
		raiz.set_meta("equipo", Equipo.new(personajes))
	_equipo = raiz.get_meta("equipo")
	_equipo.miembros.append(self)
	_equipo.derrotado.connect(equipo_derrotado.emit)
	# Para contar cuántos juegan (jugadores.gd, la vida de los enemigos): a
	# diferencia de jugador, de este grupo no se sale al quedarse mirando.
	get_parent().add_to_group("en_partida")
	# Cada jugador empieza con el primero libre: el que juega solo, con el
	# primero, como siempre.
	_indice = _equipo.primero_libre()
	_equipo.llevado_por[_indice] = self
	TeclasAntiguas.configurar()
	_salud.vida_cambiada.connect(func(_actual, _maxima): _avisar_equipo())
	_salud.murio.connect(_al_caer)
	BusEventos.personaje_elegido.connect(_al_elegir_personaje)
	_salud.poner(_equipo.vidas[_indice], _equipo.maximas[_indice])
	_aplicar()


func _physics_process(delta: float) -> void:
	_restante = maxf(_restante - delta, 0.0)
	if _equipo.curar_banquillo(delta, regeneracion_banquillo):
		_avisar_equipo()
	# Sin personaje, el jugador (y su cámara) va donde el que tiene más cerca.
	if _espectador:
		var otro := Jugadores.mas_cercano(get_tree(), get_parent().global_position)
		if otro != null:
			get_parent().global_position = otro.global_position


func _unhandled_input(evento: InputEvent) -> void:
	if _espectador:
		return
	if evento.is_action_pressed("cambiar_personaje"):
		cambiar(1)
	elif evento.is_action_pressed("personaje_anterior"):
		cambiar(-1)


## Pasa al siguiente personaje vivo y libre (paso 1) o al anterior (paso -1)
## si ha terminado la espera. Devuelve si cambió.
func cambiar(paso: int = 1) -> bool:
	var otro := _equipo.disponible_desde(_indice, paso)
	if (_restante > 0.0 and not sin_espera) or otro == _indice:
		return false

	_entrar(otro)
	_restante = 0.0 if sin_espera else espera
	_aplicar()

	# Destello al cambiar, para que se note que es otro personaje.
	_sprite.modulate = Color(2.0, 2.0, 2.0)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.3)
	return true


## El personaje que lleva el jugador ahora. Para el ranking.
func personaje_actual() -> DatosPersonaje:
	return personajes[_indice]


## Su puesto en el equipo (0, 1 o 2). Para la ulti, que lleva una carga por
## personaje.
func indice_actual() -> int:
	return _indice


## La salud de este jugador: la del personaje que lleva. Para equipo.gd.
func salud() -> Salud:
	return _salud


## Cómo está cada personaje (lo mismo que trae equipo_cambiado). Para el
## resumen de la pantalla final.
func estado() -> Array:
	return _equipo.estado()


## Si el juego está pausado porque se está eligiendo quién sigue.
func eligiendo() -> bool:
	return _eligiendo


## Si este jugador se ha quedado sin personaje y está mirando.
func espectador() -> bool:
	return _espectador


## Para el menú de desarrollador: todos vuelven con la vida llena.
func revivir_todos() -> void:
	for i in personajes.size():
		_equipo.caidos[i] = false
		_equipo.vidas[i] = _equipo.maximas[i]
	for quien in _jugadores_del_equipo():
		quien.salud().poner(_equipo.maximas[quien.indice_actual()], _equipo.maximas[quien.indice_actual()])
	_volver_espectadores()


## Al pasar a la fase 2 (raiz_juego.gd): el sector se reinicia y los que han
## caído contra el jefe vuelven con esa parte de su vida. Sin esto se llegaba a
## la fase 2 con uno o dos personajes y casi siempre se perdía al empezarla.
func revivir_caidos(fraccion: float) -> void:
	for i in personajes.size():
		if _equipo.caidos[i]:
			_equipo.caidos[i] = false
			_equipo.vidas[i] = _equipo.maximas[i] * fraccion
	_volver_espectadores()
	_avisar_equipo()


## Los que se habían quedado sin personaje vuelven con uno libre (con varios
## jugadores, al empezar la fase 2). Con uno solo nunca hay espectadores.
func _volver_espectadores() -> void:
	for miembro in _equipo.miembros:
		var libre := _equipo.primero_libre()
		if miembro.espectador() and libre != -1:
			miembro.volver(libre)


## Deja de mirar y entra con ese personaje, protegido un momento.
func volver(indice: int) -> void:
	_poner_espectador(false)
	_indice = indice
	_equipo.llevado_por[_indice] = self
	_salud.poner(_equipo.vidas[_indice], _equipo.maximas[_indice])
	_salud.proteger(proteccion_al_entrar)
	_efectos.escudo(personajes[_indice].color, proteccion_al_entrar)
	_aplicar()


## Sin personaje no se mueve, ni dispara, ni lanza la ulti, ni se ve, y sale
## del grupo jugador: la horda y los jefes dejan de verle.
func _poner_espectador(si: bool) -> void:
	_espectador = si
	var jugador := get_parent()
	jugador.set_physics_process(not si)
	for parte in PARTES_ESPECTADOR:
		var nodo = jugador.get_node(parte)
		nodo.process_mode = Node.PROCESS_MODE_DISABLED if si else Node.PROCESS_MODE_INHERIT
		if nodo is CanvasItem:
			nodo.visible = not si
	jugador.get_node("FormaColision").set_deferred("disabled", si)
	_sprite.visible = not si
	if si:
		jugador.remove_from_group("jugador")
	else:
		jugador.add_to_group("jugador")


## Para el menú de desarrollador: cambiar de personaje sin esperar.
func quitar_espera() -> void:
	espera = 0.0
	espera_minima = 0.0
	_restante = 0.0


## La mejora Cambio en caliente: quita un porcentaje de la espera. Cuenta a
## partir del siguiente cambio, no acorta el que ya está en marcha.
func reducir_espera(fraccion: float) -> void:
	espera = maxf(espera * (1.0 - fraccion), espera_minima)


## La mejora Memoria redundante: más vida máxima para todo el equipo.
func aumentar_vida_maxima(cantidad: float) -> void:
	for i in personajes.size():
		_equipo.maximas[i] += cantidad
		if not _equipo.caidos[i]:
			_equipo.vidas[i] += cantidad
	for quien in _jugadores_del_equipo():
		quien.salud().aumentar_vida_maxima(cantidad)


## Si esa herramienta la lleva alguien que no ha caído: la evolución de un
## caído no sirve de nada y no se ofrece.
func puede_evolucionar(base: DatosArma) -> bool:
	var cual := _equipo.armas.find(base)
	return cual != -1 and not _equipo.caidos[cual]


## Sustituye la herramienta base por su evolución en el personaje que la lleva.
## Si lo lleva un jugador, la nueva empieza a disparar ya.
func evolucionar(base: DatosArma, nueva: DatosArma) -> void:
	var cual := _equipo.armas.find(base)
	if cual == -1:
		return
	_equipo.armas[cual] = nueva
	BusEventos.arma_evolucionada.emit(nueva)
	# El efecto, solo si alguien lo lleva: el del banquillo no está en pantalla
	# (ya avisan el HUD y las partículas).
	var quien = _equipo.llevado_por[cual]
	if quien != null:
		quien.al_evolucionar()


## El efecto y la herramienta nueva del que lleva este jugador. Lo llama el
## evolucionar() de cualquier jugador del equipo.
func al_evolucionar() -> void:
	_efectos.evolucion(personajes[_indice].color)
	_aplicar()


func _al_caer() -> void:
	_equipo.vidas[_indice] = 0.0
	_equipo.caidos[_indice] = true
	_avisar_equipo()
	var ultimo := _equipo.todos_caidos()
	if not ultimo and get_tree().get_nodes_in_group("jugador").size() > 1:
		_caer_en_red()
		return
	# La pausa la pone la jugabilidad, como al subir de nivel, y es suya hasta
	# que se elige quién sigue o se acaba la partida: el menú de pausa no la
	# quita (raiz_juego.gd mira eligiendo()).
	_eligiendo = true
	get_tree().paused = true
	# Con el juego parado, el personaje se deshace (el efecto se anima en
	# pausa) y al acabar se avisa. El temporizador corre en pausa.
	_sprite.visible = false
	await get_tree().create_timer(_efectos.caer(personajes[_indice].color, ultimo)).timeout
	if ultimo:
		_equipo.derrotado.emit()
		return
	# La interfaz enseña quién queda y avisa del elegido con personaje_elegido.
	BusEventos.personaje_caido.emit(_estado(), _indice)


## Con varios jugadores no se pausa: si queda uno libre y vivo, se pasa a él
## (decisión de Adam, 06/11); si no, el jugador se queda mirando hasta la
## fase 2.
func _caer_en_red() -> void:
	_sprite.visible = false
	await get_tree().create_timer(_efectos.caer(personajes[_indice].color, false)).timeout
	var libre := _equipo.primero_libre()
	if libre == -1:
		_equipo.llevado_por[_indice] = null
		_poner_espectador(true)
		_avisar_equipo()
		return
	_entrar(libre)
	_sprite.visible = true
	_salud.proteger(proteccion_al_entrar)
	_efectos.escudo(personajes[libre].color, proteccion_al_entrar)
	_aplicar()


func _al_elegir_personaje(indice: int) -> void:
	if not _eligiendo or _equipo.caidos[indice]:
		return
	_eligiendo = false
	_entrar(indice)
	_sprite.visible = true
	_salud.proteger(proteccion_al_entrar)
	_efectos.escudo(personajes[indice].color, proteccion_al_entrar)
	_aplicar()
	get_tree().paused = false


## Guarda la vida del que sale, lo deja libre y pone en Salud la del que entra.
func _entrar(indice: int) -> void:
	if not _equipo.caidos[_indice]:
		_equipo.vidas[_indice] = _salud.vida()
		_equipo.maximas[_indice] = _salud.vida_maxima
	_equipo.llevado_por[_indice] = null
	_indice = indice
	_equipo.llevado_por[_indice] = self
	_salud.poner(_equipo.vidas[_indice], _equipo.maximas[_indice])


## Los cambio_personaje.gd de los jugadores que llevan a alguien.
func _jugadores_del_equipo() -> Array:
	return _equipo.llevado_por.filter(func(quien): return quien != null)


func _aplicar() -> void:
	var personaje := personajes[_indice]
	# Con la herramienta evolucionada, la hoja con el arma nueva. Vale también
	# para el que evolucionó en el banquillo: sale con ella al entrar.
	var evolucionada := _equipo.armas[_indice] != personaje.arma and personaje.hoja_evolucion != null
	if evolucionada:
		get_parent().poner_hojas(personaje.hoja_evolucion, personaje.hoja_ataque_evolucion, personaje.hoja_correr_ataque_evolucion, personaje.hoja_reposo_evolucion, personaje.segundos_ataque)
	else:
		get_parent().poner_hojas(personaje.hoja, personaje.hoja_ataque, personaje.hoja_correr_ataque, personaje.hoja_reposo, personaje.segundos_ataque)
	get_parent().get_node("GestorArmas").cambiar_arma(_equipo.armas[_indice])
	_avisar_cambio()
	_avisar_equipo.call_deferred()


func _avisar_cambio() -> void:
	var siguiente := personajes[_equipo.disponible_desde(_indice, 1)]
	# Diferido: al empezar la partida, el HUD aún no está conectado.
	BusEventos.personaje_cambiado.emit.call_deferred(personajes[_indice], _equipo.armas[_indice], siguiente, _restante)


func _avisar_equipo() -> void:
	BusEventos.equipo_cambiado.emit(_estado(), _indice)


func _estado() -> Array:
	return _equipo.estado()
