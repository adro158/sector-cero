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
var _tiempo := 0.0
## Quién recogió el último cofre: el premio de la ruleta es suyo (lo lee el
## sistema de niveles al oír cofre_recogido).
var ultimo_cofre_de: Node2D
## Multijugador: en los clientes no se recogen; están como diga el anfitrión
## (poner_desde_red).
var solo_dibujar := false


func _ready() -> void:
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	# En los clientes los premios llegan del anfitrión (poner_desde_red).
	if tipo == "elite" and not solo_dibujar:
		soltar(posicion)


## Suelta el corazón y el cofre. Público para el menú de desarrollador.
func soltar(posicion: Vector2) -> void:
	_soltar("corazon", posicion + Vector2(-SEPARACION, 0.0))
	_soltar("cofre", posicion + Vector2(SEPARACION, 0.0))


func _soltar(tipo: String, posicion: Vector2) -> void:
	var premio := Sprite2D.new()
	premio.texture = _corazon if tipo == "corazon" else _cofre
	if tipo == "cofre":
		# La hoja del cofre tiene 4 fotogramas; en el suelo se ve cerrado.
		premio.hframes = 4
		premio.frame = 0
	premio.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	premio.position = posicion
	premio.set_meta("tipo", tipo)
	# Dónde cayó, para flotar alrededor de ese punto.
	premio.set_meta("suelo", posicion)
	add_child(premio)


func _physics_process(delta: float) -> void:
	_tiempo += delta
	for premio in get_children():
		# Los recogidos están haciendo su animación: ni flotan ni se recogen otra vez.
		if not premio is Sprite2D or premio.has_meta("recogido"):
			continue
		var suelo: Vector2 = premio.get_meta("suelo")
		# Cada premio flota con un desfase distinto según dónde cayó.
		premio.position.y = suelo.y + sin(_tiempo * VELOCIDAD_FLOTE + suelo.x) * ALTURA_FLOTE
		if solo_dibujar:
			continue
		# Lo recoge el primero que pase por encima (multijugador).
		for jugador: Node2D in get_tree().get_nodes_in_group("jugador"):
			if jugador.global_position.distance_to(suelo) < RADIO_RECOGIDA:
				_recoger(premio, jugador)
				break


## El corazón cura a quien lo recoge; el cofre abre su ruleta.
func _recoger(premio: Sprite2D, jugador: Node2D) -> void:
	premio.set_meta("recogido", true)
	if premio.get_meta("tipo") == "corazon":
		var salud: Salud = jugador.get_node("Salud")
		var antes := salud.vida()
		salud.curar(CURACION)
		_animar_corazon(premio, salud.vida() - antes)
		jugador.get_node("EfectosJugador").curar()
	else:
		_animar_cofre(premio, jugador)


## Multijugador: lo que manda el anfitrión (estado_red.gd), los premios que
## siguen en el suelo: [tipo, dónde cayó]...
func datos_red() -> Array:
	var premios := []
	for premio in get_children():
		if premio is Sprite2D and not premio.has_meta("recogido"):
			premios.append([premio.get_meta("tipo"), premio.get_meta("suelo")])
	return premios


## ... y cómo lo pone un cliente. Los que ya no están los ha recogido alguien:
## se animan igual, pero sin curar ni abrir nada (eso es del anfitrión).
func poner_desde_red(premios: Array) -> void:
	var llegan := premios.map(func(premio): return premio[1])
	var aqui := []
	for premio in get_children():
		if not premio is Sprite2D:
			continue
		aqui.append(premio.get_meta("suelo"))
		if not premio.has_meta("recogido") and not premio.get_meta("suelo") in llegan:
			premio.set_meta("recogido", true)
			if premio.get_meta("tipo") == "corazon":
				_animar_corazon(premio, -1.0)
			else:
				_animar_cofre(premio, null)
	for premio in premios:
		if not premio[1] in aqui:
			_soltar(premio[0], premio[1])


## El corazón crece y se desvanece, y sube un "+N" verde con lo que ha curado
## (en los clientes, sin el número: curado es -1).
func _animar_corazon(corazon: Sprite2D, curado: float) -> void:
	var efecto := create_tween().set_parallel()
	efecto.tween_property(corazon, "scale", Vector2(2.5, 2.5), 0.4)
	efecto.tween_property(corazon, "modulate:a", 0.0, 0.4)
	efecto.tween_property(corazon, "position:y", corazon.position.y - 30.0, 0.4)
	efecto.chain().tween_callback(corazon.queue_free)
	if curado < 0.0:
		return

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
## avisa y se abre la ruleta, que sigue la animación en grande. En los
## clientes (jugador null) no avisa: la ruleta llega del anfitrión.
func _animar_cofre(cofre: Sprite2D, jugador: Node2D) -> void:
	var efecto := create_tween()
	efecto.tween_property(cofre, "scale", Vector2(1.7, 1.7), 0.12)
	efecto.parallel().tween_property(cofre, "modulate", Color(2.0, 1.7, 0.8), 0.12)
	efecto.tween_callback(func(): cofre.frame = 1)
	efecto.tween_property(cofre, "scale", Vector2(1.3, 1.3), 0.12)
	efecto.tween_callback(func(): cofre.frame = 2)
	efecto.tween_interval(0.08)
	if jugador != null:
		efecto.tween_callback(func():
			ultimo_cofre_de = jugador
			BusEventos.cofre_recogido.emit())
	efecto.tween_callback(cofre.queue_free)
