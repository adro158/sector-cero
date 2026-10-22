extends Node2D

## Los ataques del jefe final. Se los ha robado a los personajes y a la horda,
## así que las ultis se dibujan con las mismas funciones de dibujo_ultis.gd.
## Todos avisan antes de hacer daño, para que se puedan esquivar:
## - rayo (Mago): flechas hacia donde estaba el jugador y, 0,8 s después, el
##   rayo. En la amalgama, dos rayos a ±25°.
## - torbellino (Espadachín): un anillo alrededor del jefe y, después, el
##   torbellino, que hace daño mientras estés dentro.
## - tormenta (Segador): dianas alrededor del jugador y, al acabar el aviso, un
##   mini rayo en cada una.
## - invocar: portales cerca del jefe por los que sale horda y, desde el núcleo
##   armado, un rootkit explosivo si hay algún élite libre.
## - hielo (proceso colgado): cristales que caen cerca del jugador y dejan
##   zonas de hielo que ralentizan (zonas_hielo.gd).
##
## Cuál y cuándo lo decide el jefe (jefe_final.gd); aquí se llevan el tiempo,
## el dibujo y el daño de cada uno. Es top_level: dibuja en coordenadas del
## mundo y no se mueve con el jefe. Sin class_name: lo usa la escena del jefe.

const DibujoUltis := preload("res://escenas/jugabilidad/jugador/dibujo_ultis.gd")
const Dibujo := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")
const EXPLOSIVO := preload("res://recursos/enemigos/afijos/explosivo.tres")

## Lo que avisan el rayo y el torbellino antes de hacer daño.
const AVISO := 0.8
const RAYO_DURACION := 0.6
const RAYO_LARGO := 860.0
const RAYO_RADIO := 34.0
## Sale un poco por delante del jefe, como el del Mago.
const RAYO_DELANTE := 40.0
## Los dos rayos de la amalgama, a ±25° (en radianes).
const RAYO_ABIERTO := 25.0 * PI / 180.0
const TORBELLINO_RADIO := 170.0
const TORBELLINO_DURACION := 1.5
const TORBELLINO_VUELTAS := 1.7
## Una entrada por forma.
const DIANAS: Array[int] = [3, 5, 8]
const PORTALES: Array[int] = [2, 3, 3]
const CRISTALES: Array[int] = [0, 2, 4]
const DIANAS_AVISO := 0.6
const DIANAS_ALREDEDOR := 170.0
## Lo que mide la diana del aviso: el mini rayo pega donde se ve.
const MINI_RADIO := 32.0
## Los mini rayos caen uno detrás de otro. Tiene que valer lo mismo que el
## 0,08 de dibujo_ultis.tormenta(), que los dibuja.
const MINI_CADA := 0.08
const PORTAL_DURACION := 2.6
const PORTAL_DISTANCIA := 150.0
## Cada portal saca un enemigo cada tanto mientras está abierto.
const PORTAL_SALIDA := 0.3
## Lo que tarda en invocar: después el jefe sigue y los portales se quedan.
const INVOCAR_DURACION := 0.6
const CRISTAL_VUELO := 0.45
const CRISTALES_ALREDEDOR := 110.0

## Lo que se suma a cada ataque por el tamaño del jugador: pega si le roza,
## no solo si le da en el centro.
const RADIO_JUGADOR := 12.0

## Daño al jugador, antes de la dificultad (la aplica su salud).
const DANO_RAYO := 30.0
const DANO_TORBELLINO := 12.0
const DANO_MINI := 25.0

## El ataque en curso, o "" si no hay ninguno.
var _ataque := ""
var _tiempo := 0.0
## Dónde estaba el jefe al empezar: el jefe se queda quieto mientras ataca.
var _origen := Vector2.ZERO
var _direcciones: Array[Vector2] = []
var _dianas: Array[Vector2] = []
## Mini rayos de la tormenta que ya han caído.
var _caidos := 0
## El rayo pega una sola vez aunque el jugador se quede dentro.
var _rayo_pego := false
var _cristales: Array[Vector2] = []
## Cada portal: [posición, segundos abierto, segundos hasta el siguiente].
var _portales: Array = []
var _gestores: Array = []
var _jugador: Node2D
var _salud_jugador: Salud


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	# Como el primer jefe: solo los tipos sin límite de vivos.
	_gestores = get_tree().get_nodes_in_group("gestor_enemigos").filter(func(gestor): return gestor.datos.maximo_vivos == 0)


func ocupado() -> bool:
	return _ataque != ""


## Al transformarse o al romperle el escudo. Los portales abiertos siguen
## hasta cerrarse.
func cortar() -> void:
	_ataque = ""
	queue_redraw()


## Al morir el jefe: también se cierran los portales, para que no salga más
## horda mientras se rompe.
func quitar() -> void:
	_portales.clear()
	cortar()


func lanzar(ataque: String, forma: int) -> void:
	_ataque = ataque
	_tiempo = 0.0
	_origen = get_parent().global_position
	var jugador := _jugador.global_position
	match ataque:
		"rayo":
			var hacia := (jugador - _origen).normalized()
			_rayo_pego = false
			_direcciones.clear()
			if forma < 2:
				_direcciones.append(hacia)
			else:
				_direcciones.append(hacia.rotated(RAYO_ABIERTO))
				_direcciones.append(hacia.rotated(-RAYO_ABIERTO))
		"tormenta":
			# Una justo donde está y las demás alrededor.
			_dianas.clear()
			_dianas.append(jugador)
			for i in DIANAS[forma] - 1:
				_dianas.append(jugador + Vector2.from_angle(randf() * TAU) * randf_range(50.0, DIANAS_ALREDEDOR))
			_caidos = 0
		"invocar":
			# Repartidos por igual alrededor del jefe, con todo el reparto girado
			# al azar.
			var giro := randf() * TAU
			for i in PORTALES[forma]:
				var angulo := giro + TAU * i / PORTALES[forma]
				_portales.append([_origen + Vector2.from_angle(angulo) * PORTAL_DISTANCIA, 0.0, PORTAL_SALIDA])
			if forma >= 1:
				_invocar_explosivo(_portales.back()[0])
		"hielo":
			_cristales.clear()
			for i in CRISTALES[forma]:
				_cristales.append(jugador + Vector2.from_angle(randf() * TAU) * randf() * CRISTALES_ALREDEDOR)
	BusEventos.jefe_final_ataco.emit(ataque)


func _physics_process(delta: float) -> void:
	_avanzar_portales(delta)
	if _ataque == "":
		return
	_tiempo += delta
	match _ataque:
		"rayo":
			_rayo()
		"torbellino":
			_torbellino()
		"tormenta":
			_tormenta()
		"invocar":
			if _tiempo >= INVOCAR_DURACION:
				_ataque = ""
		"hielo":
			if _tiempo >= CRISTAL_VUELO:
				for cristal in _cristales:
					get_tree().get_first_node_in_group("zonas_hielo").crear(cristal)
				_ataque = ""
	queue_redraw()


func _rayo() -> void:
	if _tiempo >= AVISO + RAYO_DURACION:
		_ataque = ""
	elif _tiempo >= AVISO and not _rayo_pego:
		for direccion in _direcciones:
			var desde := _origen + direccion * RAYO_DELANTE
			var cercano := Geometry2D.get_closest_point_to_segment(_jugador.global_position, desde, desde + direccion * RAYO_LARGO)
			if cercano.distance_to(_jugador.global_position) < RAYO_RADIO + RADIO_JUGADOR:
				var antes := _salud_jugador.vida()
				_salud_jugador.recibir_dano(DANO_RAYO)
				# Solo cuenta si le ha quitado vida. Si acababa de recibir otro
				# golpe (la horda le toca a menudo), su salud está protegida medio
				# segundo y no le hace nada: lo sigue intentando mientras se vea
				# el rayo. Hasta el 22/10 contaba igual y el rayo no hacía daño.
				if _salud_jugador.vida() < antes:
					_rayo_pego = true
					return


func _torbellino() -> void:
	if _tiempo >= AVISO + TORBELLINO_DURACION:
		_ataque = ""
	elif _tiempo >= AVISO and _origen.distance_to(_jugador.global_position) < TORBELLINO_RADIO + RADIO_JUGADOR:
		# Su salud se protege medio segundo tras cada golpe: no pega cada fotograma.
		_salud_jugador.recibir_dano(DANO_TORBELLINO)


## Cada mini rayo hace daño en el momento en que cae en su diana.
func _tormenta() -> void:
	while _caidos < _dianas.size() and _tiempo >= DIANAS_AVISO + _caidos * MINI_CADA:
		if _dianas[_caidos].distance_to(_jugador.global_position) < MINI_RADIO + RADIO_JUGADOR:
			_salud_jugador.recibir_dano(DANO_MINI)
		_caidos += 1
	if _tiempo >= DIANAS_AVISO + _dianas.size() * MINI_CADA + 0.25:
		_ataque = ""


func _avanzar_portales(delta: float) -> void:
	if _portales.is_empty():
		return
	for portal in _portales:
		portal[1] += delta
		portal[2] -= delta
		# Saca horda mientras está abierto, no al cerrarse (su último trozo).
		if portal[2] <= 0.0 and portal[1] < PORTAL_DURACION - Dibujo.CIERRE_PORTAL:
			portal[2] = PORTAL_SALIDA
			_gestores.pick_random().aparecer(portal[0])
	_portales = _portales.filter(func(portal): return portal[1] < PORTAL_DURACION)
	queue_redraw()


## Un rootkit explosivo por el portal, si hay algún élite libre.
func _invocar_explosivo(donde: Vector2) -> void:
	for elite in get_tree().get_nodes_in_group("elites"):
		if not elite.activo():
			var afijos: Array[DatosAfijoElite] = [EXPLOSIVO]
			elite.aparecer(donde, afijos)
			return


func _draw() -> void:
	for portal in _portales:
		Dibujo.portal(self, to_local(portal[0]), portal[1], PORTAL_DURACION)
	var origen := to_local(_origen)
	match _ataque:
		"rayo":
			for direccion in _direcciones:
				var desde := origen + direccion * RAYO_DELANTE
				if _tiempo < AVISO:
					Dibujo.aviso_linea(self, desde, direccion, RAYO_LARGO, (RAYO_RADIO + RADIO_JUGADOR) * 2.0, _tiempo)
				else:
					DibujoUltis.rayo(self, desde, direccion, RAYO_LARGO, _tiempo - AVISO, RAYO_DURACION)
		"torbellino":
			# El torbellino se dibuja centrado en el lienzo: se lleva al jefe.
			draw_set_transform(origen)
			if _tiempo < AVISO:
				Dibujo.fotograma(self, Dibujo.AVISO_ZONA, int(_tiempo / 0.1) % 4, 352.0, Vector2.ZERO)
			else:
				DibujoUltis.torbellino(self, _tiempo - AVISO, TORBELLINO_DURACION, TORBELLINO_VUELTAS)
			draw_set_transform(Vector2.ZERO)
		"tormenta":
			var puntos: Array[Vector2] = []
			for diana in _dianas:
				puntos.append(to_local(diana))
			# Cada diana se queda hasta que cae su mini rayo: avisa siempre antes.
			for i in puntos.size():
				if _tiempo < DIANAS_AVISO + i * MINI_CADA:
					Dibujo.fotograma(self, Dibujo.AVISO_DIANA, mini(int(_tiempo / 0.15), 3), 64.0, puntos[i])
			if _tiempo >= DIANAS_AVISO:
				DibujoUltis.tormenta(self, origen, puntos, _tiempo - DIANAS_AVISO, false)
		"hielo":
			for cristal in _cristales:
				var donde := origen.lerp(to_local(cristal), _tiempo / CRISTAL_VUELO)
				Dibujo.fotograma(self, Dibujo.PROYECTIL_HIELO, int(_tiempo / 0.06) % 4, 24.0, donde)
