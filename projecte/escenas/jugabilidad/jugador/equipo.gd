extends RefCounted

## El equipo de la partida: los personajes con su herramienta, su vida y si
## han caído, y qué jugador lleva a cada uno. Es uno por partida y lo
## comparten los jugadores (multijugador, plan_multijugador.md, punto 2): el
## que juega solo lleva uno y los demás esperan en el banquillo, como
## siempre; con dos jugadores, el tercero queda libre y cualquiera puede
## cambiar a él.
##
## Lo crea el primer cambio_personaje.gd que lo pide y se guarda en la raíz
## de la partida (set_meta): así no hay que tocar la escena. Hasta el 13/11
## todo esto estaba dentro de cambio_personaje.gd. Sin class_name.

## Han caído todos: se acaba la partida.
signal derrotado

var personajes: Array[DatosPersonaje] = []
## La herramienta actual de cada personaje. Empieza siendo la de sus datos y
## cambia al evolucionar; se guarda aquí porque el .tres está compartido y en
## caché, y modificarlo dejaría la evolución pegada para la siguiente partida.
var armas: Array[DatosArma] = []
## La vida de cada personaje, su máximo y si ha caído. La del que lleva un
## jugador vive en el nodo Salud de ese jugador mientras juega.
var vidas: Array[float] = []
var maximas: Array[float] = []
var caidos: Array[bool] = []
## La carga de la ulti de cada personaje (ultis.gd la sube y la gasta). Es del
## personaje y no del jugador: en red, todos ven la misma y, si uno deja un
## personaje con la ulti cargada, el que lo coja la tiene (18/11).
var cargas: Array[float] = []
## Quién lleva a cada uno: el cambio_personaje.gd de su jugador, o null si
## está libre (en el banquillo).
var llevado_por: Array = []
## El último jugador que llevó a cada uno (aunque ahora esté libre o caído): su
## skin es la que sale en sus retratos y en el resumen del final (18/11).
var ultimo_en_llevarlo: Array = []
## Los cambio_personaje.gd de todos los jugadores, también los que se han
## quedado sin personaje (para que vuelvan en la fase 2).
var miembros: Array = []
## El cambio_personaje.gd del jugador de este ordenador (el de la escena): la
## interfaz enseña su personaje.
var local: Node = null
## Para curar el banquillo una sola vez por fotograma, aunque lo pidan todos
## los jugadores.
var _ultimo_fotograma := -1


func _init(lista: Array[DatosPersonaje]) -> void:
	personajes = lista
	for personaje in personajes:
		armas.append(personaje.arma)
		vidas.append(personaje.vida_maxima)
		maximas.append(personaje.vida_maxima)
		caidos.append(false)
		cargas.append(0.0)
		llevado_por.append(null)
		ultimo_en_llevarlo.append(null)


## El primer personaje vivo y libre a partir de desde, avanzando de paso en
## paso. Si no hay ninguno, devuelve el mismo desde.
func disponible_desde(desde: int, paso: int) -> int:
	for salto in range(1, personajes.size()):
		var otro := posmod(desde + paso * salto, personajes.size())
		if not caidos[otro] and llevado_por[otro] == null:
			return otro
	return desde


## El primero vivo y libre, o -1 si no queda ninguno.
func primero_libre() -> int:
	for i in personajes.size():
		if not caidos[i] and llevado_por[i] == null:
			return i
	return -1


func todos_caidos() -> bool:
	return not caidos.has(false)


## Los del banquillo se curan poco a poco. Devuelve si ha cambiado algún
## número entero (para avisar a la interfaz, como Salud).
func curar_banquillo(delta: float, por_segundo: float) -> bool:
	if Engine.get_physics_frames() == _ultimo_fotograma:
		return false
	_ultimo_fotograma = Engine.get_physics_frames()
	var cambio := false
	for i in personajes.size():
		if llevado_por[i] != null or caidos[i] or vidas[i] >= maximas[i]:
			continue
		var antes := int(vidas[i])
		vidas[i] = minf(vidas[i] + por_segundo * delta, maximas[i])
		cambio = cambio or int(vidas[i]) != antes
	return cambio


## Cómo está cada personaje, para la interfaz: un diccionario por personaje
## con personaje, arma, vida, maxima, caido, llevado_por (en red, el nombre
## del otro jugador que lo lleva; vacío si está libre o lo lleva el de este
## ordenador) y aspecto (su skin). La vida del que lleva un jugador es la de
## su Salud.
func estado() -> Array:
	var lista := []
	for i in personajes.size():
		var quien = llevado_por[i]
		var activo: bool = quien != null and not caidos[i]
		lista.append({
			"personaje": personajes[i],
			"arma": armas[i],
			"vida": quien.salud().vida() if activo else vidas[i],
			"maxima": quien.salud().vida_maxima if activo else maximas[i],
			"caido": caidos[i],
			"llevado_por": quien.nombre_red if quien != null and quien != local else "",
			# Su aspecto (la skin de quien lo lleva o, libre, la de este
			# ordenador): para los retratos de la barra, el panel y la caída.
			"aspecto": _aspecto(i, quien),
		})
	return lista


## La skin con la que se ve ese personaje: la de quien lo lleva, la del último
## que lo llevó (si está libre o ha caído) o, si nadie lo ha llevado, la de este
## ordenador (cambio_personaje.gd, aspecto_de).
func _aspecto(indice: int, quien) -> Resource:
	var mira = quien
	if mira == null:
		mira = ultimo_en_llevarlo[indice] if is_instance_valid(ultimo_en_llevarlo[indice]) else local
	return mira.aspecto_de(personajes[indice]) if mira != null else personajes[indice]
