extends CharacterBody2D

@export var velocidad_maxima: float = 240.0
@export var aceleracion: float = 2400.0
@export var frenado: float = 3000.0

@export_group("Respuesta al recibir daño")
@export var color_golpe: Color = Color(1.0, 0.25, 0.25, 1.0)
@export var duracion_golpe: float = 0.3

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
## de andar cada vez que el arma ataca (arma_disparada), si está quieto.
## Andando sale la de atacar corriendo, que tiene las 6 columnas de andar.
const FOTOGRAMAS_ATAQUE := 4
const FOTOGRAMAS_REPOSO := 4
const SEGUNDOS_REPOSO := 0.15
## La sacudida de la cámara: los píxeles que se mueve como mucho y lo que se
## apaga por segundo. Un golpe de fuerza 6 mueve la cámara 6 px y dura 0,25 s.
const SACUDIDA_MAXIMA := 16.0
const APAGADO_SACUDIDA := 1.5

## Hacia donde mira, de largo 1: hacia donde se mueve o, quieto, hacia donde
## iba. Hacia aquí ataca el Espadachín si no tiene a nadie a su alcance
## (gestor_armas.gd).
var mirando := Vector2.DOWN

var _efecto_golpe: Tween
## Las hojas del personaje que se lleva (las pone cambio_personaje.gd).
var _hoja_andar: Texture2D
var _hoja_ataque: Texture2D
var _hoja_correr_ataque: Texture2D
var _hoja_reposo: Texture2D
## Lo que lleva quieto, para el reposo.
var _tiempo_quieto := 0.0
var _segundos_ataque := 0.05
## Segundos desde que empezó el ataque que se está dibujando (-1: ninguno).
var _tiempo_ataque := -1.0
var _fila := 0
## La fila (la dirección) del ataque que se está dibujando: la del tajo del
## Espadachín, que va al enemigo más cercano, o hacia donde se mueve.
var _fila_ataque := 0
var _tiempo_andando := 0.0
var _lentitud := 0.0
var _tiempo_lento := 0.0
## Cuánto tiembla la cámara, de 0 a 1: sube con cada golpe y se apaga sola.
var _trauma := 0.0
## Un azar propio para el temblor, con semilla fija: el de la partida decide la
## horda y los premios, y si el temblor lo gastara, el simulador ya no
## repetiría las mismas partidas.
var _azar_camara := RandomNumberGenerator.new()


func _ready() -> void:
	_azar_camara.seed = 7
	$Salud.danado.connect(_al_recibir_dano)
	$GestorArmas.arma_disparada.connect(_al_atacar)
	# Otros momentos fuertes que también mueven la cámara.
	BusEventos.ulti_lanzada.connect(func(_personaje): sacudir(5.0))
	BusEventos.elite_exploto.connect(func(_posicion): sacudir(8.0))
	BusEventos.jefe_final_aparecio.connect(func(): sacudir(10.0))


## Las hojas de andar, de atacar y de atacar corriendo del personaje que entra.
func poner_hojas(andar: Texture2D, ataque: Texture2D, correr_ataque: Texture2D, reposo: Texture2D, segundos: float) -> void:
	_hoja_andar = andar
	_hoja_ataque = ataque
	_hoja_correr_ataque = correr_ataque
	_hoja_reposo = reposo
	_segundos_ataque = segundos
	_tiempo_ataque = -1.0
	_poner_hoja(andar, FOTOGRAMAS_ANDAR)


func _al_atacar(indice: int) -> void:
	_tiempo_ataque = 0.0
	_fila_ataque = _fila
	if $GestorArmas.armas[indice].angulo_cono > 0.0:
		_fila_ataque = Direcciones8.fila($GestorArmas.ultimo_cono.direccion)


func _al_recibir_dano(cantidad: float) -> void:
	# El jugador se tiñe de rojo y vuelve a su color. Si llega otro golpe antes
	# de acabar, se corta el efecto anterior para que no compitan dos tweens.
	if _efecto_golpe != null:
		_efecto_golpe.kill()
	$Sprite.modulate = color_golpe
	_efecto_golpe = create_tween()
	_efecto_golpe.tween_property($Sprite, "modulate", Color.WHITE, duracion_golpe)
	# La cámara, según lo fuerte que sea el golpe.
	sacudir(clampf(cantidad / 5.0, 3.0, 12.0))


## La única forma de mover la cámara, para que dos temblores no se peleen por
## ella: lo usan el golpe al jugador, Kernel Panic (espectaculo_jefe.gd),
## NÚCLEO CERO, las ultis y la explosión de los élites. La fuerza son los
## píxeles que se mueve al empezar. Con mando, además, vibra. Las dos cosas se
## pueden quitar en Opciones.
func sacudir(fuerza: float) -> void:
	if GestorGuardado.opcion("sacudir_camara"):
		_trauma = minf(_trauma + fuerza / SACUDIDA_MAXIMA, 1.0)
	if GestorGuardado.opcion("vibracion"):
		var parte := clampf(fuerza / 12.0, 0.0, 1.0)
		for mando in Input.get_connected_joypads():
			Input.start_joy_vibration(mando, 0.3 * parte, 0.7 * parte, 0.1 + 0.2 * parte)


## Con el juego en pausa no se llama: el temblor se queda donde esté.
func _process(delta: float) -> void:
	if _trauma <= 0.0:
		return
	_trauma = maxf(_trauma - APAGADO_SACUDIDA * delta, 0.0)
	var salto := Vector2(_azar_camara.randf_range(-1.0, 1.0), _azar_camara.randf_range(-1.0, 1.0))
	$Camara.offset = salto * _trauma * SACUDIDA_MAXIMA


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
		_tiempo_quieto += delta
	else:
		_tiempo_quieto = 0.0
		_fila = Direcciones8.fila(direccion)
		# Con la mejora de velocidad el cuerpo va más deprisa, y en el aura
		# lenta o contra una pared, más despacio: si las piernas fueran siempre
		# al mismo ritmo, los pies patinarían.
		_tiempo_andando += delta * velocity.length() / velocidad_animacion

	# La columna de las piernas: cuenta siempre, también atacando, para que al
	# acabar el ataque no salten.
	var columna := int(_tiempo_andando * fotogramas_por_segundo) % FOTOGRAMAS_ANDAR

	# Atacando, mientras le queden fotogramas al ataque (4 de _segundos_ataque).
	if _tiempo_ataque >= 0.0 and _hoja_ataque != null:
		var fotograma := int(_tiempo_ataque / _segundos_ataque)
		_tiempo_ataque += delta
		if fotograma < FOTOGRAMAS_ATAQUE:
			if direccion != Vector2.ZERO and _hoja_correr_ataque != null:
				# Andando: la de atacar corriendo, en la columna de las piernas y
				# en la fila hacia donde corre, para que el cuerpo no gire a mitad
				# de paso. El tajo del Espadachín (aura_arma.gd) sigue yendo al
				# enemigo más cercano. Su hoja es cuatro veces más ancha que la de
				# andar: un juego de 6 pasos por fotograma del tajo (27/10; con una
				# sola pose, la espada saltaba al final del golpe sin verse).
				var fases: int = _hoja_correr_ataque.get_width() / _hoja_andar.get_width()
				var fase := fotograma if fases == FOTOGRAMAS_ATAQUE else 0
				_poner_hoja(_hoja_correr_ataque, FOTOGRAMAS_ANDAR * fases)
				$Sprite.frame = (_fila * fases + fase) * FOTOGRAMAS_ANDAR + columna
			else:
				# Quieto: la de atacar, hacia donde va el ataque.
				_poner_hoja(_hoja_ataque, FOTOGRAMAS_ATAQUE)
				$Sprite.frame = _fila_ataque * FOTOGRAMAS_ATAQUE + fotograma
			return
		_tiempo_ataque = -1.0
	# Quieto: el reposo, que empieza por el fotograma 0 de andar.
	if direccion == Vector2.ZERO and _hoja_reposo != null:
		_poner_hoja(_hoja_reposo, FOTOGRAMAS_REPOSO)
		$Sprite.frame = _fila * FOTOGRAMAS_REPOSO + int(_tiempo_quieto / SEGUNDOS_REPOSO) % FOTOGRAMAS_REPOSO
		return
	if _hoja_andar != null:
		_poner_hoja(_hoja_andar, FOTOGRAMAS_ANDAR)
	$Sprite.frame = _fila * FOTOGRAMAS_ANDAR + columna


## Cambia de hoja solo si hace falta. Primero el fotograma 0: con menos
## columnas, el que tenía podía no existir.
func _poner_hoja(hoja: Texture2D, columnas: int) -> void:
	if $Sprite.texture == hoja:
		return
	$Sprite.frame = 0
	$Sprite.texture = hoja
	$Sprite.hframes = columnas
