extends RefCounted

## Los jugadores de la partida. Hoy hay uno; con el multijugador
## (`documentacio/plan_multijugador.md`, punto 1 de Adam) habrá uno por
## persona, todos en el grupo «jugador». Lo que antes buscaba «el» jugador
## (la horda, los élites, los jefes...) busca aquí al más cercano. Con uno
## solo da siempre ese, así que la partida de un jugador no cambia.
##
## Sin class_name: se carga con preload, como dificultad.gd.


## Las posiciones de todos. La horda las pide una vez por fotograma y después
## elige la más cercana de cada enemigo sin volver a preguntar al árbol.
static func posiciones(arbol: SceneTree) -> PackedVector2Array:
	var lista := PackedVector2Array()
	for jugador: Node2D in arbol.get_nodes_in_group("jugador"):
		lista.append(jugador.global_position)
	return lista


## La más cercana a desde de una lista que no puede estar vacía.
static func mas_cercana(lista: PackedVector2Array, desde: Vector2) -> Vector2:
	var mejor := lista[0]
	for posicion in lista:
		if posicion.distance_squared_to(desde) < mejor.distance_squared_to(desde):
			mejor = posicion
	return mejor


## El jugador más cercano a desde, o null si no hay ninguno.
static func mas_cercano(arbol: SceneTree, desde: Vector2) -> Node2D:
	var mejor: Node2D = null
	for jugador: Node2D in arbol.get_nodes_in_group("jugador"):
		if mejor == null or jugador.global_position.distance_squared_to(desde) < mejor.global_position.distance_squared_to(desde):
			mejor = jugador
	return mejor
