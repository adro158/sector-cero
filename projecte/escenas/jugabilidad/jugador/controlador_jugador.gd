extends CharacterBody2D

@export var velocidad_maxima: float = 240.0
@export var aceleracion: float = 2400.0
@export var frenado: float = 3000.0

## Cuánto se aparta del borde, para que el jugador no quede medio fuera. Debe
## coincidir con su radio.
@export var margen_limites: float = 16.0

@export_group("Respuesta al recibir daño")
@export var color_golpe: Color = Color(1.0, 0.25, 0.25, 1.0)
@export var duracion_golpe: float = 0.3
@export var sacudida_camara: float = 6.0

@export_group("Animación")
## Las hojas de los personajes están hechas para 130 ms por fotograma.
@export var fotogramas_por_segundo: float = 7.7

## La hoja del sprite tiene una fila por dirección y una columna por fotograma
## del ciclo de andar.
const FOTOGRAMAS_ANDAR := 6

var _limite_minimo := Vector2.ZERO
var _limite_maximo := Vector2.ZERO
var _hay_limites := false
var _efecto_golpe: Tween
var _fila := 0
var _tiempo_andando := 0.0


func _ready() -> void:
	_leer_limites_arena()
	$Salud.danado.connect(_al_recibir_dano)


func _al_recibir_dano(_cantidad: float) -> void:
	# El jugador se tiñe de rojo y la cámara da un tirón, y los dos vuelven a
	# su estado normal a la vez. Si llega otro golpe antes de acabar, se corta
	# el efecto anterior para que no compitan dos animaciones por lo mismo.
	if _efecto_golpe != null:
		_efecto_golpe.kill()

	$Sprite.modulate = color_golpe
	$Camara.offset = Vector2.RIGHT.rotated(randf() * TAU) * sacudida_camara

	_efecto_golpe = create_tween().set_parallel()
	_efecto_golpe.tween_property($Sprite, "modulate", Color.WHITE, duracion_golpe)
	_efecto_golpe.tween_property($Camara, "offset", Vector2.ZERO, duracion_golpe)


func _leer_limites_arena() -> void:
	# La arena declara su zona jugable con un Area2D en el grupo limites_arena.
	# El jugador se mantiene dentro por código, no con muros sólidos, para que la
	# escena de la arena no tenga que traer colisiones propias.
	var limites: Area2D = get_tree().get_first_node_in_group("limites_arena")
	if limites == null:
		return

	var forma := limites.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if forma == null or not forma.shape is RectangleShape2D:
		return

	var mitad: Vector2 = (forma.shape as RectangleShape2D).size * 0.5 - Vector2.ONE * margen_limites
	var centro := limites.global_position + forma.position

	_limite_minimo = centro - mitad
	_limite_maximo = centro + mitad
	_hay_limites = true


func _physics_process(delta: float) -> void:
	var direccion := Input.get_vector(
		"mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo"
	)

	if direccion != Vector2.ZERO:
		velocity = velocity.move_toward(direccion * velocidad_maxima, aceleracion * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, frenado * delta)

	move_and_slide()

	if _hay_limites:
		global_position = global_position.clamp(_limite_minimo, _limite_maximo)

	_animar(direccion, delta)


func _animar(direccion: Vector2, delta: float) -> void:
	if direccion == Vector2.ZERO:
		# Quieto: primer fotograma, mirando hacia donde iba.
		_tiempo_andando = 0.0
	else:
		_fila = Direcciones8.fila(direccion)
		_tiempo_andando += delta

	var columna := int(_tiempo_andando * fotogramas_por_segundo) % FOTOGRAMAS_ANDAR
	$Sprite.frame = _fila * FOTOGRAMAS_ANDAR + columna
