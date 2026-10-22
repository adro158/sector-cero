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
## La velocidad para la que se ajustaron esos fotogramas, sin mejoras ni auras:
## a ella los pies no patinan. Las piernas van en proporción a la de verdad.
@export var velocidad_animacion: float = 240.0

## La hoja del sprite tiene una fila por dirección y una columna por fotograma
## del ciclo de andar.
const FOTOGRAMAS_ANDAR := 6
## La de atacar, las mismas filas y 4 columnas. Sale un momento encima de la
## de andar cada vez que el arma ataca (arma_disparada).
const FOTOGRAMAS_ATAQUE := 4

## Hacia donde mira, de largo 1: hacia donde se mueve o, quieto, hacia donde
## iba. Es hacia donde ataca el Espadachín (gestor_armas.gd).
var mirando := Vector2.DOWN

var _efecto_golpe: Tween
## Las hojas del personaje que se lleva (las pone cambio_personaje.gd).
var _hoja_andar: Texture2D
var _hoja_ataque: Texture2D
var _segundos_ataque := 0.05
## Segundos desde que empezó el ataque que se está dibujando (-1: ninguno).
var _tiempo_ataque := -1.0
var _fila := 0
var _tiempo_andando := 0.0
var _lentitud := 0.0
var _tiempo_lento := 0.0


func _ready() -> void:
	$Salud.danado.connect(_al_recibir_dano)
	$GestorArmas.arma_disparada.connect(func(_indice): _tiempo_ataque = 0.0)


## Las hojas de andar y de atacar del personaje que entra.
func poner_hojas(andar: Texture2D, ataque: Texture2D, segundos: float) -> void:
	_hoja_andar = andar
	_hoja_ataque = ataque
	_segundos_ataque = segundos
	_tiempo_ataque = -1.0
	_poner_hoja(andar, FOTOGRAMAS_ANDAR)


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


## Un tirón de cámara sin teñir al jugador, para los golpes fuertes del jefe
## (espectaculo_jefe.gd). Usa el mismo tween que el golpe para no pelearse
## con él por la cámara. Hacia abajo siempre: randf() gastaría números del
## azar de la partida y el simulador ya no repetiría las mismas partidas.
func sacudir(fuerza: float) -> void:
	if _efecto_golpe != null:
		_efecto_golpe.kill()
	$Sprite.modulate = Color.WHITE
	$Camara.offset = Vector2.DOWN * fuerza
	_efecto_golpe = create_tween()
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
		mirando = direccion.normalized()
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
		# Con la mejora de velocidad el cuerpo va más deprisa, y en el aura
		# lenta o contra una pared, más despacio: si las piernas fueran siempre
		# al mismo ritmo, los pies patinarían.
		_tiempo_andando += delta * velocity.length() / velocidad_animacion

	# Atacando, la hoja de ataque mientras le queden fotogramas; las piernas
	# siguen contando, para que al volver a andar no salten.
	if _tiempo_ataque >= 0.0 and _hoja_ataque != null:
		var fotograma := int(_tiempo_ataque / _segundos_ataque)
		_tiempo_ataque += delta
		if fotograma < FOTOGRAMAS_ATAQUE:
			_poner_hoja(_hoja_ataque, FOTOGRAMAS_ATAQUE)
			$Sprite.frame = _fila * FOTOGRAMAS_ATAQUE + fotograma
			return
		_tiempo_ataque = -1.0
	if _hoja_andar != null:
		_poner_hoja(_hoja_andar, FOTOGRAMAS_ANDAR)
	var columna := int(_tiempo_andando * fotogramas_por_segundo) % FOTOGRAMAS_ANDAR
	$Sprite.frame = _fila * FOTOGRAMAS_ANDAR + columna


## Cambia de hoja solo si hace falta. Primero el fotograma 0: con menos
## columnas, el que tenía podía no existir.
func _poner_hoja(hoja: Texture2D, columnas: int) -> void:
	if $Sprite.texture == hoja:
		return
	$Sprite.frame = 0
	$Sprite.texture = hoja
	$Sprite.hframes = columnas
