extends Node

signal arma_disparada(indice: int)

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


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
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


func anadir_arma(arma: DatosArma) -> void:
	armas.append(arma)
	_tiempos.append(0.0)


func _physics_process(delta: float) -> void:
	for i in armas.size():
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
			var alcanzados := 0

			for objetivo in _objetivos:
				alcanzados += objetivo.danar_en_area(_jugador.global_position, radio, dano_final, resistencia)

			_resistencia_malware.registrar_dano(arma, alcanzados * dano_final)
		DatosArma.Tipo.PROYECTIL:
			# El proyectil aplica la resistencia al impactar, no al salir: puede
			# pasar un análisis mientras vuela.
			_pool_proyectiles.lanzar(_jugador.global_position, arma, dano, radio)
