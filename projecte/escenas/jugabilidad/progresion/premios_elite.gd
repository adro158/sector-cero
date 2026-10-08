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
	if tipo == "elite":
		soltar(posicion)


## Suelta el corazón y el cofre. Público para el menú de desarrollador.
func soltar(posicion: Vector2) -> void:
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
	for premio in get_children():
		# Los recogidos están haciendo su animación: ni flotan ni se recogen otra vez.
		if not premio is Sprite2D or premio.has_meta("recogido"):
			continue
		var suelo: Vector2 = premio.get_meta("suelo")
		# Cada premio flota con un desfase distinto según dónde cayó.
		premio.position.y = suelo.y + sin(_tiempo * VELOCIDAD_FLOTE + suelo.x) * ALTURA_FLOTE
		if _jugador.global_position.distance_to(suelo) < RADIO_RECOGIDA:
			_recoger(premio)


func _recoger(premio: Sprite2D) -> void:
	premio.set_meta("recogido", true)
	if premio.get_meta("tipo") == "corazon":
		var antes := _salud.vida()
		_salud.curar(CURACION)
		_animar_corazon(premio, _salud.vida() - antes)
	else:
		_animar_cofre(premio)


## El corazón crece y se desvanece, y sube un "+N" verde con lo que ha curado.
func _animar_corazon(corazon: Sprite2D, curado: float) -> void:
	var efecto := create_tween().set_parallel()
	efecto.tween_property(corazon, "scale", Vector2(2.5, 2.5), 0.4)
	efecto.tween_property(corazon, "modulate:a", 0.0, 0.4)
	efecto.tween_property(corazon, "position:y", corazon.position.y - 30.0, 0.4)
	efecto.chain().tween_callback(corazon.queue_free)

	var texto := Label.new()
	texto.text = "+%d" % roundi(curado)
	texto.add_theme_font_size_override("font_size", 20)
	texto.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	texto.add_theme_color_override("font_outline_color", Color.BLACK)
	texto.add_theme_constant_override("outline_size", 4)
	texto.position = corazon.position + Vector2(-16.0, -40.0)
	add_child(texto)
	var sube := create_tween().set_parallel()
	sube.tween_property(texto, "position:y", texto.position.y - 40.0, 0.9)
	sube.tween_property(texto, "modulate:a", 0.0, 0.9).set_delay(0.3)
	sube.chain().tween_callback(texto.queue_free)


## El cofre da un salto con un destello dorado y empieza a abrirse; después
## avisa y se abre la ruleta, que sigue la animación en grande.
func _animar_cofre(cofre: Sprite2D) -> void:
	var efecto := create_tween()
	efecto.tween_property(cofre, "scale", Vector2(1.7, 1.7), 0.12)
	efecto.parallel().tween_property(cofre, "modulate", Color(2.0, 1.7, 0.8), 0.12)
	efecto.tween_callback(func(): cofre.frame = 1)
	efecto.tween_property(cofre, "scale", Vector2(1.3, 1.3), 0.12)
	efecto.tween_callback(func(): cofre.frame = 2)
	efecto.tween_interval(0.08)
	efecto.tween_callback(BusEventos.cofre_recogido.emit)
	efecto.tween_callback(cofre.queue_free)
