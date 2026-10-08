extends Node2D

const MAXIMO_GEMAS := 800

## Sprite del fragmento de datos, en grises: cada gema lo tiñe según lo que vale.
@export var textura: Texture2D
@export var tamano: float = 12.0
@export var radio_iman: float = 100.0
@export var radio_recogida: float = 18.0
@export var velocidad_iman: float = 420.0
## En un mapa sin fin, las gemas que se quedan muy atrás no se van a recoger y
## llenarían el pool: a partir de esta distancia se descartan.
@export var distancia_olvido: float = 1200.0
## Segundos que dura una gema sin recoger. Con el mapa infinito se quedaban
## cientos por el camino; así nunca se acumulan y además hay que ir a por ellas.
@export var duracion: float = 30.0
## En los últimos segundos parpadea para avisar de que se va a perder.
@export var aviso: float = 3.0

@export_group("Colores por valor")
## Hasta valor_medio - 1 de experiencia, color_bajo; hasta valor_alto - 1,
## color_medio; desde valor_alto, color_alto. Colores cálidos: el cian y el
## verde son los de las pistas de la placa base y las gemas se camuflaban.
@export var color_bajo := Color(1.0, 0.92, 0.3)
@export var valor_medio := 3
@export var color_medio := Color(1.0, 0.55, 0.2)
@export var valor_alto := 10
@export var color_alto := Color(1.0, 0.35, 0.85)

var _posiciones := PackedVector2Array()
var _valores := PackedInt32Array()
## Segundos que le quedan a cada gema antes de desaparecer.
var _restantes := PackedFloat32Array()
var _vivas := 0
var _experiencia_por_tipo := {}
var _jugador: Node2D

@onready var _gemas: MultiMeshInstance2D = $Gemas


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_posiciones.resize(MAXIMO_GEMAS)
	_valores.resize(MAXIMO_GEMAS)
	_restantes.resize(MAXIMO_GEMAS)
	_preparar_multimesh()

	# Cada gestor de la horda y cada élite trae sus datos, con la experiencia
	# que vale su tipo. El jefe no tiene: al derrotarlo se acaba la partida.
	for objetivo in get_tree().get_nodes_in_group("objetivos"):
		if "datos" in objetivo:
			_experiencia_por_tipo[objetivo.datos.tipo] = objetivo.datos.experiencia
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


func _preparar_multimesh() -> void:
	var malla := QuadMesh.new()
	malla.size = Vector2(tamano, tamano)

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	# Un color por gema, según lo que vale. Hay que activarlo antes de fijar el
	# número de instancias.
	multimesh.use_colors = true
	multimesh.mesh = malla
	multimesh.instance_count = MAXIMO_GEMAS
	multimesh.visible_instance_count = 0

	_gemas.multimesh = multimesh
	_gemas.texture = textura
	_gemas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	if _vivas >= MAXIMO_GEMAS:
		return

	_posiciones[_vivas] = posicion
	_valores[_vivas] = _experiencia_por_tipo.get(tipo, 1)
	_restantes[_vivas] = duracion
	_vivas += 1


func _physics_process(delta: float) -> void:
	var objetivo := _jugador.global_position

	# Hacia atrás porque al recoger una gema se trae la última a su hueco.
	var i := _vivas - 1

	while i >= 0:
		var distancia := _posiciones[i].distance_to(objetivo)
		_restantes[i] -= delta

		if distancia < radio_recogida:
			BusEventos.experiencia_ganada.emit(_valores[i])
			_eliminar(i)
		elif distancia < radio_iman:
			# Si ya vuela hacia el jugador no caduca: perderla en el último
			# momento parecería un fallo.
			_posiciones[i] = _posiciones[i].move_toward(objetivo, velocidad_iman * delta)
		elif distancia > distancia_olvido or _restantes[i] <= 0.0:
			_eliminar(i)

		i -= 1

	_volcar_al_multimesh()


func _eliminar(indice: int) -> void:
	_vivas -= 1
	_posiciones[indice] = _posiciones[_vivas]
	_valores[indice] = _valores[_vivas]
	_restantes[indice] = _restantes[_vivas]


func _volcar_al_multimesh() -> void:
	var multimesh := _gemas.multimesh

	# Escala vertical -1: el QuadMesh tiene la textura invertida respecto al 2D.
	# El color se pone cada fotograma, junto a la posición: al recoger una gema
	# la última pasa a su hueco y cambia de índice.
	for i in _vivas:
		multimesh.set_instance_transform_2d(i, Transform2D(0.0, Vector2(1.0, -1.0), 0.0, _posiciones[i]))
		var color := _color(_valores[i])
		# Parpadeo de aviso: cinco veces por segundo, medio tiempo casi
		# transparente.
		if _restantes[i] < aviso and fmod(_restantes[i], 0.2) < 0.1:
			color.a = 0.2
		multimesh.set_instance_color(i, color)

	multimesh.visible_instance_count = _vivas


func _color(valor: int) -> Color:
	if valor >= valor_alto:
		return color_alto
	if valor >= valor_medio:
		return color_medio
	return color_bajo
