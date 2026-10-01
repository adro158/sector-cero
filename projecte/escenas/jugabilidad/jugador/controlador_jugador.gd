extends CharacterBody2D

@export var velocidad_maxima: float = 240.0
@export var aceleracion: float = 2400.0
@export var frenado: float = 3000.0

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

var _efecto_golpe: Tween
var _fila := 0
var _tiempo_andando := 0.0
var _lentitud := 0.0
var _tiempo_lento := 0.0


func _ready() -> void:
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


## Lo llama el aura de un élite en cada fotograma que el jugador está dentro:
## la velocidad baja esa fracción mientras siga dentro.
func ralentizar(fraccion: float) -> void:
	_lentitud = fraccion
	# Un poco más que un fotograma: al salir del aura, el efecto se acaba solo.
	_tiempo_lento = 0.1


func _physics_process(delta: float) -> void:
	var direccion := Input.get_vector(
		"mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo"
	)

	var maxima := velocidad_maxima
	if _tiempo_lento > 0.0:
		_tiempo_lento -= delta
		maxima *= 1.0 - _lentitud

	if direccion != Vector2.ZERO:
		velocity = velocity.move_toward(direccion * maxima, aceleracion * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, frenado * delta)

	move_and_slide()
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
