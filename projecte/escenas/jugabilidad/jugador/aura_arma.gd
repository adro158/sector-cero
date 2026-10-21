extends Node2D

## Dibuja el alcance de cada arma de área con su anillo en grises, teñido de
## cian a rojo según la resistencia que el malware ha desarrollado contra ella,
## y en cada ataque su efecto en su color: el golpe del Firewall o el pulso de
## radar del Escáner. Las evoluciones traen su propio dibujo. Todo sale del
## DatosArma del arma activa.
##
## Los dibujos están hechos al radio base de cada herramienta: con la mejora de
## alcance se escalan (radio de verdad / radio del dibujo).
##
## Va detrás del jugador (show_behind_parent): debajo de él y de la horda,
## encima del suelo.

@export var color: Color = Color(0.35, 0.8, 1.0, 1.0)
@export var color_resistido: Color = Color(1.0, 0.0, 0.15, 1.0)
@export var duracion_destello: float = 0.12

var _gestor_armas: Node
var _resistencia_malware: Node
## Por arma: lo que le queda al destello del anillo y los segundos desde su
## último ataque, para saber qué fotograma del efecto toca.
var _destellos := PackedFloat32Array()
var _desde_ataque := PackedFloat32Array()


func _ready() -> void:
	_gestor_armas = get_parent().get_node("GestorArmas")
	_gestor_armas.arma_disparada.connect(_al_disparar)
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")


func _al_disparar(indice: int) -> void:
	while _destellos.size() <= indice:
		_destellos.append(0.0)
		# Grande: sin efecto hasta el primer ataque.
		_desde_ataque.append(99.0)
	_destellos[indice] = duracion_destello
	_desde_ataque[indice] = 0.0


## Con el juego en pausa no se llama: el efecto se queda en su fotograma.
func _process(delta: float) -> void:
	for i in _destellos.size():
		_destellos[i] = maxf(_destellos[i] - delta, 0.0)
		_desde_ataque[i] += delta
	queue_redraw()


func _draw() -> void:
	var armas: Array = _gestor_armas.armas
	for i in armas.size():
		var arma: DatosArma = armas[i]
		if arma.tipo != DatosArma.Tipo.AREA or arma.anillo == null:
			continue

		var escala: float = arma.radio * _gestor_armas.multiplicador_alcance / arma.radio_dibujo
		var encendido := i < _destellos.size() and _destellos[i] > 0.0
		var tinte := color.lerp(color_resistido, _resistencia_malware.resistencia(arma))
		# El anillo, más transparente cuando no ataca.
		_fotograma(arma.anillo, 1, 0, escala, Color(tinte, 0.9 if encendido else 0.35))
		# El efecto, una sola vez por ataque y sin teñir.
		if i < _desde_ataque.size() and arma.efecto != null:
			var fotograma := int(_desde_ataque[i] / arma.segundos_por_fotograma)
			if fotograma < arma.fotogramas_efecto:
				_fotograma(arma.efecto, arma.fotogramas_efecto, fotograma, escala, Color.WHITE)


## Un fotograma de una tira horizontal, centrado en el jugador y escalado.
func _fotograma(hoja: Texture2D, fotogramas: int, fotograma: int, escala: float, modulado: Color) -> void:
	var lado := Vector2(hoja.get_width() / float(fotogramas), hoja.get_height())
	draw_texture_rect_region(hoja, Rect2(-lado * escala / 2.0, lado * escala), Rect2(Vector2(fotograma * lado.x, 0.0), lado), modulado)
