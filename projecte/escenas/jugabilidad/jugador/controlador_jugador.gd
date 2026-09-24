extends CharacterBody2D

@export var velocidad_maxima: float = 240.0
@export var aceleracion: float = 2400.0
@export var frenado: float = 3000.0

## Cuánto se aparta del borde, para que el jugador no quede medio fuera. Debe
## coincidir con su radio.
@export var margen_limites: float = 16.0

var _limite_minimo := Vector2.ZERO
var _limite_maximo := Vector2.ZERO
var _hay_limites := false


func _ready() -> void:
	_leer_limites_arena()


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
