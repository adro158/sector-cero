extends Node2D

## Jefe de la fase 1, Kernel Panic. Está en la escena desde el principio,
## oculto e inactivo, y el director lo hace aparecer al cumplirse el tiempo de
## la partida: baja en una columna de datos y no ataca hasta que se ha cargado.
## Derrotarlo abre la fase 2 (raiz_juego.gd) cuando acaba su explosión; el
## jefe final es otro, jefe_final.gd. Su vida va en la barra de arriba del HUD.
##
## Persigue al jugador despacio y hace daño por contacto. Cada cierto tiempo se
## tiñe de rojo como aviso y embiste en línea recta hacia donde estaba el
## jugador: se puede esquivar si se reacciona al aviso. Y cada intervalo de
## invocación se para, late en morado y saca un anillo de horda a su alrededor:
## cuanta menos vida le queda, más enemigos. Cada intervalo de pisotón se para,
## avisa con un anillo rojo en el suelo y pisa: durante unos segundos queda
## una jaula alrededor que nadie puede cruzar (jaula_jefe.gd). Y cada intervalo
## de ráfaga se para, late en morado y dispara 12 proyectiles en círculo; en la
## segunda mitad de su vida, dos ráfagas seguidas (rafaga_jefe.gd).
##
## Cuanta menos vida le queda, más duro: al bajar del 66 % y del 33 % se
## enfurece. En cada furia va más rápido, pega más, sus ataques llegan antes y
## saca más horda; en la última arde (el aura de la rabia). La aparición, la
## furia y la muerte, con sus dibujos, van en su hijo Efectos
## (espectaculo_jefe.gd).
##
## Para las armas es un objetivo más, igual que los gestores de la horda: está
## en el grupo objetivos y tiene danar_en_area y mas_cercano.

signal enemigo_danado(posicion: Vector2, cantidad: float, resistencia: float)
signal derrotado

enum Estado { PERSEGUIR, AVISO, EMBESTIDA, INVOCAR, PISOTON, RAFAGA }

const FOTOGRAMAS_ANDAR := 12
const Dificultad := preload("res://globales/dificultad.gd")
const SpriteDestello := preload("res://escenas/jugabilidad/enemigos/sprite_destello.gd")
const DibujoJefeFinal := preload("res://escenas/jugabilidad/enemigos/dibujo_jefe_final.gd")

@export var velocidad: float = 90.0
@export var radio: float = 40.0
@export var dano_contacto: float = 25.0
@export var fotogramas_por_segundo: float = 7.7

@export_group("Embestida")
@export var intervalo_embestida: float = 6.0
@export var duracion_aviso: float = 0.8
@export var duracion_embestida: float = 0.7
@export var velocidad_embestida: float = 480.0
@export var dano_embestida: float = 40.0
@export var color_aviso: Color = Color(1.0, 0.3, 0.3, 1.0)

@export_group("Invocación")
@export var intervalo_invocacion: float = 15.0
## Lo que dura el aviso (late en morado y crece el anillo) antes de invocar.
@export var duracion_invocacion: float = 1.0
## Enemigos de cada anillo: los primeros con toda la vida, los últimos casi
## sin ella.
@export var invocados_minimo: int = 8
@export var invocados_maximo: int = 20
@export var radio_invocacion: float = 140.0
@export var color_invocacion: Color = Color(0.75, 0.3, 1.0, 1.0)

@export_group("Pisotón")
## El primero llega antes, para que se vea pronto.
@export var primer_pisoton: float = 8.0
@export var intervalo_pisoton: float = 20.0

@export_group("Ráfaga")
@export var primera_rafaga: float = 5.0
@export var intervalo_rafaga: float = 9.0
## Lo que late en morado antes de disparar.
@export var aviso_rafaga: float = 0.5
## Con menos de la mitad de vida dispara otra, este tiempo después.
@export var entre_rafagas: float = 0.4

## La parte de la vida por debajo de la cual pasa a la furia 1 y a la 2.
const UMBRALES_FURIA: Array[float] = [0.66, 0.33]
## Por furia (0 sin furia): cuánto más rápido va, cuánto más pega y cuánto
## antes llegan sus ataques. Los avisos duran lo mismo: se siguen pudiendo
## esquivar.
const VELOCIDAD_FURIA: Array[float] = [1.0, 1.15, 1.3]
## El daño era 1,25 y 1,5 hasta la tarde del 22/10: con el cono del
## Espadachín, el simulador ganaba 6 / 3 / 0 de 10 (objetivo 7-8 / 4-5 / 1),
## y casi todas las derrotas eran contra él o al salir de él con poca vida.
const DANO_FURIA: Array[float] = [1.0, 1.15, 1.3]
const RITMO_FURIA: Array[float] = [1.0, 1.25, 1.5]

const FOTOGRAMAS_RABIA := 4
const SEGUNDOS_POR_FOTOGRAMA_RABIA := 0.1

var _activo := false
var _estado := Estado.PERSEGUIR
var _tiempo_estado := 0.0
var _direccion := Vector2.DOWN
var _tiempo_andando := 0.0
var _hasta_invocar := 0.0
var _hasta_pisoton := 0.0
var _hasta_rafaga := 0.0
## Las ráfagas que lleva disparadas la de ahora y las que le tocan (1 o 2).
var _rafagas_hechas := 0
var _rafagas_toca := 1
## 0 sin furia; 1 y 2 al bajar de cada umbral.
var _furia := 0
var _tiempo_rabia := 0.0
var _jugador: Node2D
var _salud_jugador: Salud
var _jaula: Node2D

@onready var _sprite: SpriteDestello = $Sprite
@onready var _salud: Salud = $Salud
@onready var _rafaga: Node2D = $Rafaga
## Las llamas de la rabia, detrás del jefe: es el primer hijo, antes del Sprite.
@onready var _aura: Sprite2D = $Rabia
## La aparición, la furia y la muerte (espectaculo_jefe.gd).
@onready var _efectos: Node2D = $Efectos


func _ready() -> void:
	visible = false
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud_jugador = _jugador.get_node("Salud")
	_jaula = get_tree().get_first_node_in_group("jaula_jefe")
	_salud.murio.connect(_al_morir)
	_salud.vida_cambiada.connect(_al_cambiar_vida)
	_efectos.aparecido.connect(func(): _activo = true)
	_efectos.acabo_de_morir.connect(_al_acabar_de_morir)


func aparecer(posicion: Vector2) -> void:
	global_position = posicion
	# La vida de la escena por la de su dificultad, que va aparte de la de la
	# horda desde el 23/10.
	_salud.reiniciar(_salud.vida_maxima * Dificultad.dato("vida_jefe"))
	visible = true
	_hasta_invocar = intervalo_invocacion
	_hasta_pisoton = primer_pisoton
	_hasta_rafaga = primera_rafaga
	_furia = 0
	_aura.visible = false
	# No recibe daño ni ataca hasta que acaba de aparecer.
	_activo = false
	_cambiar_estado(Estado.PERSEGUIR)
	_efectos.aparicion()
	BusEventos.jefe_aparecio.emit()


## Misma forma que en los gestores de la horda: devuelve a cuántos alcanza.
func danar_en_area(centro: Vector2, radio_golpe: float, cantidad: float, resistencia := 0.0, cono: RefCounted = null) -> int:
	if not _activo or global_position.distance_to(centro) > radio_golpe + radio:
		return 0
	if cono != null:
		var factor: float = cono.factor(global_position, radio)
		if factor <= 0.0:
			return 0
		cantidad *= factor
		cono.golpes += factor

	_salud.recibir_dano(cantidad)
	# Avisando, invocando o antes de la ráfaga no destella: con el Ping
	# rebotando contra él, el blanco taparía el color del aviso, que es lo que
	# deja esquivar el ataque.
	if _estado != Estado.AVISO and _estado != Estado.INVOCAR and _estado != Estado.RAFAGA:
		_sprite.destellar()
	# El número sale sobre el cuerpo y un poco desplazado, para que varios
	# golpes seguidos no se pinten uno encima de otro.
	enemigo_danado.emit(global_position + Vector2(randf_range(-24.0, 24.0), -40.0), cantidad, resistencia)
	return 1


## Para la ficha que sale al pincharlo, como en la horda y los élites.
func ficha_en(punto: Vector2, radio_busqueda: float) -> Dictionary:
	var distancia := global_position.distance_to(punto)
	if not _activo or distancia > radio_busqueda + radio:
		return {}
	var resultado := ficha(0)
	resultado.distancia = distancia
	return resultado


func ficha(_id: int) -> Dictionary:
	if not _activo:
		return {}
	# El primer fotograma de la hoja: el jefe mirando de frente.
	var retrato := AtlasTexture.new()
	retrato.atlas = _sprite.texture
	retrato.region = Rect2(Vector2.ZERO, _sprite.texture.get_size() / Vector2(_sprite.hframes, _sprite.vframes))
	return {"id": 0, "nombre": "Kernel Panic (jefe)", "textura": retrato, "color": Color(0.75, 0.3, 1.0),
		"vida": _salud.vida(), "vida_maxima": _salud.vida_maxima, "dano": dano_contacto * DANO_FURIA[_furia],
		"velocidad": velocidad * VELOCIDAD_FURIA[_furia]}


func mas_cercano(desde: Vector2, radio_busqueda: float) -> Vector2:
	if _activo and global_position.distance_to(desde) < radio_busqueda:
		return global_position
	return Vector2.INF


func _physics_process(delta: float) -> void:
	if not _activo:
		return

	_tiempo_estado += delta
	_hasta_invocar -= delta * _ritmo()
	_hasta_pisoton -= delta * _ritmo()
	_hasta_rafaga -= delta * _ritmo()
	var hacia_jugador := (_jugador.global_position - global_position).normalized()

	match _estado:
		Estado.PERSEGUIR:
			_direccion = hacia_jugador
			global_position += _direccion * velocidad * VELOCIDAD_FURIA[_furia] * delta
			# Con la jaula puesta no invoca (lo deja para cuando se rompa) ni
			# vuelve a pisar.
			var sin_jaula: bool = not _jaula.activa()
			if _hasta_invocar <= 0.0 and sin_jaula:
				_cambiar_estado(Estado.INVOCAR)
			elif _hasta_pisoton <= 0.0 and sin_jaula:
				_jaula.empezar(global_position)
				_cambiar_estado(Estado.PISOTON)
			elif _hasta_rafaga <= 0.0:
				_rafagas_hechas = 0
				_rafagas_toca = 2 if _salud.vida() < _salud.vida_maxima / 2.0 else 1
				_cambiar_estado(Estado.RAFAGA)
			elif _tiempo_estado >= intervalo_embestida / _ritmo():
				_cambiar_estado(Estado.AVISO)
		Estado.AVISO:
			# Quieto y mirando al jugador: la embestida irá hacia donde esté
			# cuando acabe el aviso, no hacia donde vaya después.
			_direccion = hacia_jugador
			queue_redraw()
			if _tiempo_estado >= duracion_aviso:
				_cambiar_estado(Estado.EMBESTIDA)
		Estado.EMBESTIDA:
			global_position += _direccion * velocidad_embestida * delta
			if _tiempo_estado >= duracion_embestida:
				_cambiar_estado(Estado.PERSEGUIR)
		Estado.INVOCAR:
			# Quieto, latiendo en morado mientras crece el anillo.
			var latido := 0.5 + 0.5 * sin(_tiempo_estado * 20.0)
			_sprite.modulate = Color.WHITE.lerp(color_invocacion, latido)
			queue_redraw()
			if _tiempo_estado >= duracion_invocacion:
				_invocar()
				_hasta_invocar = intervalo_invocacion
				_cambiar_estado(Estado.PERSEGUIR)
		Estado.PISOTON:
			# Quieto mientras la jaula avisa; al pisar, sigue con la jaula puesta.
			if not _jaula.avisando():
				_hasta_pisoton = intervalo_pisoton
				_cambiar_estado(Estado.PERSEGUIR)
		Estado.RAFAGA:
			# Quieto, latiendo en morado: el aviso de que va a disparar.
			var latido := 0.5 + 0.5 * sin(_tiempo_estado * 20.0)
			_sprite.modulate = Color.WHITE.lerp(color_invocacion, latido)
			if _tiempo_estado >= aviso_rafaga + _rafagas_hechas * entre_rafagas:
				# La segunda, girada: tapa los huecos de la primera.
				_rafaga.disparar(global_position, _rafagas_hechas == 1, DANO_FURIA[_furia])
				_rafagas_hechas += 1
				if _rafagas_hechas == _rafagas_toca:
					_hasta_rafaga = intervalo_rafaga
					_cambiar_estado(Estado.PERSEGUIR)

	# Si está dentro de su jaula, tampoco sale él, ni embistiendo.
	global_position = _jaula.mantener(global_position, radio)

	if global_position.distance_to(_jugador.global_position) < radio + 16.0:
		var dano := dano_embestida if _estado == Estado.EMBESTIDA else dano_contacto
		_salud_jugador.recibir_dano(dano * DANO_FURIA[_furia])

	_animar(delta)


## Saca un anillo de horda alrededor del jefe con los tipos que no tienen
## límite de vivos (el ransomware sí lo tiene). Los crean sus gestores, como
## hace el élite replicante.
func _invocar() -> void:
	var herido := 1.0 - _salud.vida() / _salud.vida_maxima
	var cantidad := roundi(lerpf(invocados_minimo, invocados_maximo, herido))
	var gestores := get_tree().get_nodes_in_group("gestor_enemigos").filter(func(gestor): return gestor.datos.maximo_vivos == 0)
	for i in cantidad:
		var angulo := TAU * i / cantidad
		gestores.pick_random().aparecer(global_position + Vector2.from_angle(angulo) * radio_invocacion)
	BusEventos.jefe_invoco.emit()


## Lo que tardan en llegar sus ataques se divide entre esto.
func _ritmo() -> float:
	return RITMO_FURIA[_furia]


## Avisa a la barra del HUD (también al reiniciar la vida en aparecer()) y
## mira si ha bajado de algún umbral de furia.
func _al_cambiar_vida(actual: float, maxima: float) -> void:
	BusEventos.jefe_vida_cambiada.emit(actual, maxima)
	if not _activo:
		return
	var furia := 0
	for umbral in UMBRALES_FURIA:
		if actual < maxima * umbral:
			furia += 1
	if furia > _furia:
		_enfurecer(furia)


func _enfurecer(furia: int) -> void:
	_furia = furia
	# En la última, arde.
	_aura.visible = _furia == UMBRALES_FURIA.size()
	_sprite.destellar()
	_efectos.furia()
	BusEventos.jefe_furia_cambiada.emit(_furia)


func _cambiar_estado(nuevo: Estado) -> void:
	_estado = nuevo
	_tiempo_estado = 0.0
	_sprite.modulate = color_aviso if nuevo == Estado.AVISO else Color.WHITE
	# Para borrar el anillo de la invocación al terminarla.
	queue_redraw()


func _animar(delta: float) -> void:
	# Las piernas van al ritmo al que se mueve: embistiendo, tantas veces más
	# deprisa como lo es la embestida, y quieto (avisando o invocando), nada.
	if _estado == Estado.PERSEGUIR:
		_tiempo_andando += delta * VELOCIDAD_FURIA[_furia]
	elif _estado == Estado.EMBESTIDA:
		_tiempo_andando += delta * velocidad_embestida / velocidad
	var columna := int(_tiempo_andando * fotogramas_por_segundo) % FOTOGRAMAS_ANDAR
	_sprite.frame = Direcciones8.fila(_direccion) * FOTOGRAMAS_ANDAR + columna
	if _aura.visible:
		_tiempo_rabia += delta
		_aura.frame = int(_tiempo_rabia / SEGUNDOS_POR_FOTOGRAMA_RABIA) % FOTOGRAMAS_RABIA


func _draw() -> void:
	if not _activo:
		return

	# Avisando de la embestida, la franja con flechas del rayo de NÚCLEO CERO:
	# hacia dónde y hasta dónde va a ir, del ancho de lo que pega.
	if _estado == Estado.AVISO:
		DibujoJefeFinal.aviso_linea(self, Vector2.ZERO, _direccion, velocidad_embestida * duracion_embestida,
			(radio + 16.0) * 2.0, _tiempo_estado)
	# El anillo de la invocación crece hasta donde saldrán los enemigos.
	if _estado == Estado.INVOCAR:
		var avance := _tiempo_estado / duracion_invocacion
		draw_arc(Vector2.ZERO, radio_invocacion * avance, 0.0, TAU, 48, Color(color_invocacion, 0.8), 4.0)


func _al_morir() -> void:
	_activo = false
	_jaula.terminar()
	_rafaga.vaciar()
	_aura.visible = false
	BusEventos.enemigo_muerto.emit(global_position, "jefe")
	_efectos.muerte()


## Cuando acaba su explosión empieza la fase 2.
func _al_acabar_de_morir() -> void:
	visible = false
	derrotado.emit()
