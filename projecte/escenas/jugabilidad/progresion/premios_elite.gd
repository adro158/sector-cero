extends Node2D

## El premio de los élites: al morir uno, suelta en el suelo un corazón y un
## cofre. El corazón cura la mitad de la vida máxima al pasar por encima; el
## cofre abre la ruleta de mejoras (avisa por el bus y el sistema de niveles
## hace el resto). Hay que ir a por ellos, y no caducan.
##
## El élite no sabe nada de esto: aquí se escucha su muerte en el bus. Como no
## hay más de tres élites, los premios son Sprite2D normales, sin pool.

const CURACION := 0.5
## Distancia al jugador a la que se recogen.
const RADIO_RECOGIDA := 24.0
## Separación entre el corazón y el cofre al caer, para que no se tapen.
const SEPARACION := 22.0
## Flotan arriba y abajo para que se vean entre la horda.
const ALTURA_FLOTE := 3.0
const VELOCIDAD_FLOTE := 4.0

var _corazon := preload("res://medios/sprites/corazon.png")
var _cofre := preload("res://medios/sprites/cofre.png")
var _jugador: Node2D
var _salud: Salud
var _tiempo := 0.0


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador")
	_salud = _jugador.get_node("Salud")
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	if tipo != "elite":
		return
	_soltar("corazon", _corazon, posicion + Vector2(-SEPARACION, 0.0))
	var cofre := _soltar("cofre", _cofre, posicion + Vector2(SEPARACION, 0.0))
	# La hoja del cofre tiene 4 fotogramas; en el suelo se ve cerrado.
	cofre.hframes = 4
	cofre.frame = 0


func _soltar(tipo: String, textura: Texture2D, posicion: Vector2) -> Sprite2D:
	var premio := Sprite2D.new()
	premio.texture = textura
	premio.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	premio.position = posicion
	premio.set_meta("tipo", tipo)
	# Dónde cayó, para flotar alrededor de ese punto.
	premio.set_meta("suelo", posicion)
	add_child(premio)
	return premio


func _physics_process(delta: float) -> void:
	_tiempo += delta
	for premio: Sprite2D in get_children():
		var suelo: Vector2 = premio.get_meta("suelo")
		# Cada premio flota con un desfase distinto según dónde cayó.
		premio.position.y = suelo.y + sin(_tiempo * VELOCIDAD_FLOTE + suelo.x) * ALTURA_FLOTE
		if _jugador.global_position.distance_to(suelo) < RADIO_RECOGIDA:
			_recoger(premio)


func _recoger(premio: Sprite2D) -> void:
	if premio.get_meta("tipo") == "corazon":
		_salud.curar(CURACION)
	else:
		BusEventos.cofre_recogido.emit()
	# free y no queue_free: si en un fotograma hay dos pasos de física, con
	# queue_free el premio seguiría ahí en el segundo y se recogería dos veces.
	premio.free()
