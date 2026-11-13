extends RefCounted

## Lo que el anfitrión manda a los clientes unas 20 veces por segundo
## (partida_red.gd) y cómo lo ponen ellos: la partida es la del anfitrión, y
## los clientes la dibujan sin simularla (plan_multijugador.md, punto 5,
## segunda tanda). Si se pierde un estado no pasa nada: el siguiente trae lo
## de ahora.
##
## Las claves son cortas porque va muchas veces por segundo:
## - j: por id de la red, [posición, velocidad, personaje, vida, máxima]
## - h: por tipo de la horda (en el orden del grupo gestor_enemigos, el mismo
##   en todos los ordenadores), las posiciones de los vivos
## - g: [posiciones, valores] de los fragmentos de datos
## - t: [segundos, duración] del reloj; x: [experiencia, necesaria, nivel]
## - e: [vidas, máximas, caídos] del equipo (para el banquillo)
##
## Sin class_name: se carga con preload.


## En el anfitrión. reloj y experiencia: lo último que avisó el bus.
static func del_anfitrion(arbol: SceneTree, por_id: Dictionary, reloj: Array, experiencia: Array) -> Dictionary:
	var jugadores := {}
	var equipo: RefCounted = null
	for id in por_id:
		var jugador: CharacterBody2D = por_id[id]
		var cambio: Node = jugador.get_node("CambioPersonaje")
		var salud: Salud = jugador.get_node("Salud")
		jugadores[id] = [jugador.global_position, jugador.velocity, cambio.indice_actual(), salud.vida(), salud.vida_maxima]
		equipo = cambio._equipo
	var horda := []
	for gestor in arbol.get_nodes_in_group("gestor_enemigos"):
		horda.append(gestor.posiciones_vivos())
	var gemas: Node = arbol.get_first_node_in_group("pool_gemas")
	return {
		"j": jugadores,
		"h": horda,
		"g": [gemas.posiciones_vivas(), gemas.valores_vivos()],
		"t": reloj,
		"x": experiencia,
		"e": [equipo.vidas, equipo.maximas, equipo.caidos],
	}


## En los clientes.
static func aplicar(arbol: SceneTree, por_id: Dictionary, estado: Dictionary) -> void:
	for id in estado.j:
		var jugador: CharacterBody2D = por_id.get(id)
		if jugador == null:
			continue
		var datos: Array = estado.j[id]
		jugador.global_position = datos[0]
		# Entre un estado y el siguiente sigue andando hacia donde iba.
		jugador.direccion_red = (datos[1] / jugador.velocidad_maxima).limit_length(1.0)
		jugador.get_node("CambioPersonaje").seguir_red(datos[2])
		var salud: Salud = jugador.get_node("Salud")
		if not is_equal_approx(salud.vida(), datos[3]) or not is_equal_approx(salud.vida_maxima, datos[4]):
			salud.poner(datos[3], datos[4])
	var gestores := arbol.get_nodes_in_group("gestor_enemigos")
	for i in mini(gestores.size(), estado.h.size()):
		gestores[i].poner_desde_red(estado.h[i])
	arbol.get_first_node_in_group("pool_gemas").poner_desde_red(estado.g[0], estado.g[1])
	if estado.t.size() == 2:
		BusEventos.tiempo_partida.emit(estado.t[0], estado.t[1])
	if estado.x.size() == 3:
		BusEventos.experiencia_cambiada.emit(estado.x[0], estado.x[1], estado.x[2])
	var equipo: RefCounted = por_id.values()[0].get_node("CambioPersonaje")._equipo
	equipo.vidas.assign(estado.e[0])
	equipo.maximas.assign(estado.e[1])
	equipo.caidos.assign(estado.e[2])
