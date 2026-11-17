extends RefCounted

## Lo que el anfitrión manda a los clientes unas 20 veces por segundo
## (partida_red.gd) y cómo lo ponen ellos: la partida es la del anfitrión, y
## los clientes la dibujan sin simularla (plan_multijugador.md, punto 5,
## segunda tanda). Si se pierde un estado no pasa nada: el siguiente trae lo
## de ahora.
##
## Las claves son cortas porque va muchas veces por segundo:
## - j: por id de la red, [posición, velocidad, personaje, vida, máxima, si
##   está mirando sin personaje, la carga de las ultis de sus personajes,
##   hacia dónde apunta su golpe en cono]
## - h: por tipo de la horda (en el orden del grupo gestor_enemigos, el mismo
##   en todos los ordenadores), lo de gestor_enemigos.gd datos_red()
## - g: [posiciones, valores] de los fragmentos de datos
## - t: [segundos, duración] del reloj; x: [experiencia, necesaria, nivel]
## - e: [vidas, máximas, caídos] del equipo (para el banquillo)
## - l: los élites (en el orden del grupo elites, el mismo en todos), cada uno
##   con lo de enemigo_elite.gd datos_red()
## - a: los jefes, sus ataques y los premios de los élites (los de RAIZ, en
##   ese orden), cada uno con lo de su datos_red()
## - m: las muertes desde el anterior, [posición, tipo]; d: los golpes,
##   [posición, cantidad, resistencia]. Para los efectos y los números de
##   daño: en los clientes nadie muere ni recibe golpes.
##
## Sin class_name: se carga con preload.

## Los nodos de RaizJuego que se mandan y se ponen igual, con datos_red() y
## poner_desde_red(): Kernel Panic, NÚCLEO CERO y sus ataques, y los premios
## de los élites.
const RAIZ := ["Jefe", "JefeFinal", "JaulaJefe", "Jefe/Rafaga", "JefeFinal/Ataques",
	"JefeFinal/Ataques2", "JefeFinal/Escudo", "ZonasHielo", "PremiosElite"]


## En el anfitrión. reloj y experiencia: lo último que avisó el bus; muertes
## y golpes: los apuntados desde el estado anterior (partida_red.gd).
static func del_anfitrion(arbol: SceneTree, por_id: Dictionary, reloj: Array, experiencia: Array, muertes: Array, golpes: Array) -> Dictionary:
	var jugadores := {}
	var equipo: RefCounted = null
	for id in por_id:
		var jugador: CharacterBody2D = por_id[id]
		var cambio: Node = jugador.get_node("CambioPersonaje")
		var salud: Salud = jugador.get_node("Salud")
		jugadores[id] = [jugador.global_position, jugador.velocity, cambio.indice_actual(), salud.vida(),
			salud.vida_maxima, cambio.espectador(), jugador.get_node("Ultis").cargas(),
			jugador.get_node("GestorArmas").apuntando]
		equipo = cambio._equipo
	var horda := []
	for gestor in arbol.get_nodes_in_group("gestor_enemigos"):
		horda.append(gestor.datos_red())
	var gemas: Node = arbol.get_first_node_in_group("pool_gemas")
	var raiz := arbol.current_scene.get_node("RaizJuego")
	return {
		"j": jugadores,
		"h": horda,
		"g": [gemas.posiciones_vivas(), gemas.valores_vivos()],
		"t": reloj,
		"x": experiencia,
		"e": [equipo.vidas, equipo.maximas, equipo.caidos],
		"l": arbol.get_nodes_in_group("elites").map(func(elite): return elite.datos_red()),
		"a": RAIZ.map(func(ruta): return raiz.get_node(ruta).datos_red()),
		"m": muertes,
		"d": golpes,
	}


## En los clientes.
static func aplicar(arbol: SceneTree, por_id: Dictionary, estado: Dictionary) -> void:
	# Los caídos, antes que los jugadores: así seguir_red sabe si el que lleva
	# cada uno acaba de caer (y lo anima). Las vidas, al final: al cambiar de
	# personaje, cambio_personaje.gd guarda la que tenía aquí.
	var equipo: RefCounted = por_id.values()[0].get_node("CambioPersonaje")._equipo
	equipo.caidos.assign(estado.e[2])
	for id in estado.j:
		var jugador: CharacterBody2D = por_id.get(id)
		if jugador == null:
			continue
		var datos: Array = estado.j[id]
		jugador.global_position = datos[0]
		# Entre un estado y el siguiente sigue andando hacia donde iba.
		jugador.direccion_red = (datos[1] / jugador.velocidad_maxima).limit_length(1.0)
		var cambio: Node = jugador.get_node("CambioPersonaje")
		var salud: Salud = jugador.get_node("Salud")
		var indice_antes: int = cambio.indice_actual()
		var vida_antes := salud.vida()
		cambio.seguir_red(datos[2], datos[5])
		if not is_equal_approx(salud.vida(), datos[3]) or not is_equal_approx(salud.vida_maxima, datos[4]):
			salud.poner(datos[3], datos[4])
		# Un golpe (el mismo personaje con menos vida): poner() no avisa, y sin
		# esto no saldrían su destello, su temblor ni su sonido.
		if cambio.indice_actual() == indice_antes and vida_antes - datos[3] >= 1.0:
			salud.danado.emit(vida_antes - datos[3])
		jugador.get_node("Ultis").poner_cargas(datos[6])
		jugador.get_node("GestorArmas").apuntando = datos[7]
	var gestores := arbol.get_nodes_in_group("gestor_enemigos")
	for i in mini(gestores.size(), estado.h.size()):
		gestores[i].poner_desde_red(estado.h[i])
	arbol.get_first_node_in_group("pool_gemas").poner_desde_red(estado.g[0], estado.g[1])
	var elites := arbol.get_nodes_in_group("elites")
	for i in mini(elites.size(), estado.l.size()):
		elites[i].poner_desde_red(estado.l[i])
	var raiz := arbol.current_scene.get_node("RaizJuego")
	for i in RAIZ.size():
		raiz.get_node(RAIZ[i]).poner_desde_red(estado.a[i])
	# Las muertes, por el bus como en el anfitrión: su dibujo, sus partículas
	# y los avisos. Los fragmentos, los premios y la carga de las ultis no
	# salen de aquí (pool_gemas.gd, premios_elite.gd y ultis.gd): llegan en el
	# estado.
	for muerte in estado.m:
		BusEventos.enemigo_muerto.emit(muerte[0], muerte[1])
	for golpe in estado.d:
		raiz.get_node("PoolNumeros").mostrar(golpe[0], golpe[1], golpe[2])
	if estado.t.size() == 2:
		BusEventos.tiempo_partida.emit(estado.t[0], estado.t[1])
	if estado.x.size() == 3:
		BusEventos.experiencia_cambiada.emit(estado.x[0], estado.x[1], estado.x[2])
	equipo.vidas.assign(estado.e[0])
	equipo.maximas.assign(estado.e[1])


## Las estadísticas del final (partida_terminada), para mandarlas: los
## personajes del equipo van por su ruta (un recurso no viaja por la red)...
static func fin_para_red(estadisticas: Dictionary) -> Dictionary:
	var datos := estadisticas.duplicate(true)
	datos.equipo = estadisticas.equipo.map(func(personaje): return {
		"personaje": personaje.personaje.resource_path, "caido": personaje.caido, "dano": personaje.dano})
	return datos


## ... y como las espera la pantalla final, en los clientes.
static func fin_desde_red(datos: Dictionary) -> Dictionary:
	datos.equipo = datos.equipo.map(func(personaje): return {
		"personaje": load(personaje.personaje), "caido": personaje.caido, "dano": personaje.dano})
	return datos
