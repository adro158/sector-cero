extends Node

signal arma_disparada(indice: int)

## El golpe del Firewall, en cono hacia el enemigo más cercano.
const GolpeCono := preload("res://escenas/jugabilidad/jugador/golpe_cono.gd")

@export var armas: Array[DatosArma] = []

# Las mejoras se aplican como multiplicadores aquí y nunca modificando el .tres
# del arma: los recursos están compartidos y en caché, así que tocarlos dejaría
# los valores mejorados pegados para la siguiente partida.
var multiplicador_dano := 1.0
var multiplicador_cadencia := 1.0
var multiplicador_alcance := 1.0

var _tiempos := PackedFloat32Array()
var _jugador: Node2D
var _objetivos: Array = []
var _pool_proyectiles: Node2D
var _resistencia_malware: Node
var _salud: Salud
## El cono del último ataque en cono (null si el arma ataca en círculo): para
## que aura_arma.gd lo dibuje y saque las chispas solo de lo que ha golpeado.
var ultimo_cono: RefCounted
## Hacia dónde iría ahora un golpe en cono, de largo 1: al enemigo más cercano
## a su alcance o, si no hay ninguno, hacia donde mira el personaje. Hasta el
## 24/10 era siempre hacia donde miraba, y jugando casi nunca daba a nada
## (Adam). aura_arma.gd dibuja el contorno hacia aquí.
var apuntando := Vector2.DOWN


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud = _jugador.get_node("Salud")
	_pool_proyectiles = get_tree().get_first_node_in_group("pool_proyectiles")
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")
	_tiempos.resize(armas.size())

	# Todo lo que puede recibir daño está en el grupo objetivos: un gestor por
	# tipo de enemigo de la horda (un MultiMesh solo dibuja una malla y un
	# material) y el jefe. Todos tienen danar_en_area, así que el arma no
	# necesita saber qué es cada uno.
	_objetivos = get_tree().get_nodes_in_group("objetivos")


## Sustituye todas las armas por una: la del personaje que entra.
func cambiar_arma(arma: DatosArma) -> void:
	armas.clear()
	armas.append(arma)
	_tiempos = PackedFloat32Array([0.0])


func _physics_process(delta: float) -> void:
	for i in armas.size():
		if armas[i].angulo_cono > 0.0:
			_apuntar(armas[i].radio * multiplicador_alcance)
		_tiempos[i] -= delta
		if _tiempos[i] > 0.0:
			continue

		_tiempos[i] = armas[i].cadencia * multiplicador_cadencia
		_atacar(armas[i])
		arma_disparada.emit(i)
		BusEventos.herramienta_usada.emit(armas[i])


func _atacar(arma: DatosArma) -> void:
	var dano := arma.dano * multiplicador_dano
	var radio := arma.radio * multiplicador_alcance

	match arma.tipo:
		DatosArma.Tipo.AREA:
			var resistencia: float = _resistencia_malware.resistencia(arma)
			var dano_final := dano * (1.0 - resistencia)
			var cono: RefCounted = null
			if arma.angulo_cono > 0.0:
				cono = GolpeCono.new(_jugador.global_position, apuntando, radio, arma.angulo_cono, arma.dano_pegado, arma.dano_filo)
			ultimo_cono = cono
			var alcanzados := 0

			for objetivo in _objetivos:
				alcanzados += objetivo.danar_en_area(_jugador.global_position, radio, dano_final, resistencia, cono)

			# En golpes enteros: en el cono, cada uno cuenta según su distancia.
			var golpes: float = alcanzados if cono == null else cono.golpes
			_resistencia_malware.registrar_dano(arma, golpes * dano_final)
			if arma.robo_vida > 0.0 and golpes > 0.0:
				# El Firewall cura así, con la horda encima, como mucho 1,25 de
				# vida por segundo (0,75 por golpe, cada 0,6 s). El tope era 3
				# hasta el 22/10 y 1,5 hasta el 27/10: en las partidas largas,
				# con las mejoras de cadencia, Adam se curaba demasiado.
				var robado := minf(golpes * dano_final * arma.robo_vida, arma.robo_maximo)
				_salud.curar(robado / _salud.vida_maxima)
		DatosArma.Tipo.PROYECTIL:
			# El proyectil aplica la resistencia al impactar, no al salir: puede
			# pasar un análisis mientras vuela.
			_pool_proyectiles.lanzar(_jugador.global_position, arma, dano, radio)


## Pone en apuntando la dirección al enemigo más cercano a menos de alcance (de
## la horda, un élite, un jefe o un ancla), o hacia donde mira si no hay.
func _apuntar(alcance: float) -> void:
	var desde := _jugador.global_position
	var mejor := Vector2.INF
	for objetivo in _objetivos:
		var donde: Vector2 = objetivo.mas_cercano(desde, alcance)
		if donde != Vector2.INF and desde.distance_to(donde) < desde.distance_to(mejor):
			mejor = donde
	if mejor == Vector2.INF or mejor == desde:
		apuntando = _jugador.mirando
	else:
		apuntando = (mejor - desde).normalized()
