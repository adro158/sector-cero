extends Node2D

## Dibuja el alcance de cada arma de área con su anillo en grises, teñido de
## cian a rojo según la resistencia que el malware ha desarrollado contra ella,
## y en cada ataque su efecto en su color: el golpe del Firewall o el pulso de
## radar del Escáner. Las evoluciones traen su propio dibujo. Todo sale del
## DatosArma del arma activa. Con el robo de vida del Firewall, además, salen
## chispas verdes de los enemigos alcanzados que vuelven al personaje.
##
## Los dibujos están hechos al radio base de cada herramienta: con la mejora de
## alcance se escalan (radio de verdad / radio del dibujo). El Firewall ataca
## en un cono hacia donde mira el personaje; hasta que estén sus dibujos, el
## cono se pinta aquí con polígonos (_cono).
##
## Va detrás del jugador (show_behind_parent): debajo de él y de la horda,
## encima del suelo. Las chispas se dibujan en el hijo Chispas, con z_index 4,
## encima de la horda.

@export var color: Color = Color(0.35, 0.8, 1.0, 1.0)
@export var color_resistido: Color = Color(1.0, 0.0, 0.15, 1.0)
@export var duracion_destello: float = 0.12

## Lo opaco que empieza el efecto de cada ataque: se va apagando hasta
## desaparecer. Con el efecto entero, el Firewall (que golpea cada 0,6 s)
## tapaba la pantalla media partida.
const OPACIDAD_EFECTO := 0.55

const CHISPA := preload("res://medios/sprites/herramientas/robo_vida_chispa.png")
const LADO_CHISPA := 8.0
const FOTOGRAMAS_CHISPA := 4
const SEGUNDOS_POR_FOTOGRAMA_CHISPA := 0.06
## Lo que tarda una chispa en llegar al personaje.
const VIAJE_CHISPA := 0.35
const CHISPAS_POR_GOLPE := 5
## A dónde llegan: el pecho del personaje, no sus pies.
const PECHO := Vector2(0.0, -20.0)
## El verde del golpe del Firewall.
const VERDE_CONO := Color(0.4, 1.0, 0.5)
## Los lados de la curva del cono: con 16 ya no se ven las esquinas.
const LADOS_CONO := 16

var _gestor_armas: Node
var _resistencia_malware: Node
## Por arma: lo que le queda al destello del anillo y los segundos desde su
## último ataque, para saber qué fotograma del efecto toca.
var _destellos := PackedFloat32Array()
var _desde_ataque := PackedFloat32Array()
var _objetivos: Array = []
## Cada chispa: [de dónde sale, en el mundo, segundos de viaje].
var _chispas: Array = []

@onready var _lienzo_chispas: Node2D = $Chispas


func _ready() -> void:
	_gestor_armas = get_parent().get_node("GestorArmas")
	_gestor_armas.arma_disparada.connect(_al_disparar)
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")
	_objetivos = get_tree().get_nodes_in_group("objetivos")
	# Chispas no tiene script propio: se dibuja desde aquí con su señal draw.
	_lienzo_chispas.draw.connect(_dibujar_chispas)


func _al_disparar(indice: int) -> void:
	while _destellos.size() <= indice:
		_destellos.append(0.0)
		# Grande: sin efecto hasta el primer ataque.
		_desde_ataque.append(99.0)
	_destellos[indice] = duracion_destello
	_desde_ataque[indice] = 0.0
	var arma: DatosArma = _gestor_armas.armas[indice]
	if arma.robo_vida > 0.0:
		_sacar_chispas(arma.radio * _gestor_armas.multiplicador_alcance)


## Una chispa por objetivo alcanzado (cada tipo de horda, élite o jefe), desde
## su enemigo más cercano: danar_en_area solo dice a cuántos alcanza, pero
## mas_cercano da dónde está uno. Así salen de enemigos de verdad sin tocar las
## armas.
func _sacar_chispas(radio: float) -> void:
	for objetivo in _objetivos:
		if _chispas.size() >= CHISPAS_POR_GOLPE:
			return
		var donde: Vector2 = objetivo.mas_cercano(global_position, radio)
		# En el cono, solo de lo que ha golpeado: no de lo que tiene detrás.
		var cono: RefCounted = _gestor_armas.ultimo_cono
		if cono != null and donde != Vector2.INF and cono.factor(donde, 0.0) <= 0.0:
			continue
		if donde != Vector2.INF:
			_chispas.append([donde, 0.0])


## Con el juego en pausa no se llama: el efecto se queda en su fotograma.
func _process(delta: float) -> void:
	for i in _destellos.size():
		_destellos[i] = maxf(_destellos[i] - delta, 0.0)
		_desde_ataque[i] += delta
	for chispa in _chispas:
		chispa[1] += delta
	_chispas = _chispas.filter(func(chispa): return chispa[1] < VIAJE_CHISPA)
	queue_redraw()
	_lienzo_chispas.queue_redraw()


func _draw() -> void:
	var armas: Array = _gestor_armas.armas
	for i in armas.size():
		var arma: DatosArma = armas[i]
		if arma.tipo != DatosArma.Tipo.AREA or arma.anillo == null:
			continue

		var escala: float = arma.radio * _gestor_armas.multiplicador_alcance / arma.radio_dibujo
		var encendido := i < _destellos.size() and _destellos[i] > 0.0
		var tinte := color.lerp(color_resistido, _resistencia_malware.resistencia(arma))
		if arma.angulo_cono > 0.0:
			_dibujar_cono(arma, i, encendido, tinte)
			continue
		# El anillo, más transparente cuando no ataca.
		_fotograma(arma.anillo, 1, 0, escala, Color(tinte, 0.9 if encendido else 0.35))
		if i < _desde_ataque.size() and arma.efecto != null:
			_efecto(arma, _desde_ataque[i], escala)


## El efecto de un ataque, una sola vez y sin teñir. Para que salga suave y no
## a saltos, cada fotograma se funde con el siguiente: es como tener muchos más
## fotogramas sin dibujarlos.
func _efecto(arma: DatosArma, segundos: float, escala: float) -> void:
	var avance := segundos / arma.segundos_por_fotograma
	if avance >= arma.fotogramas_efecto:
		return
	var fotograma := int(avance)
	var mezcla := avance - fotograma
	var opacidad := OPACIDAD_EFECTO * (1.0 - avance / arma.fotogramas_efecto)
	_fotograma(arma.efecto, arma.fotogramas_efecto, fotograma, escala, Color(1.0, 1.0, 1.0, opacidad * (1.0 - mezcla)))
	if fotograma + 1 < arma.fotogramas_efecto:
		_fotograma(arma.efecto, arma.fotogramas_efecto, fotograma + 1, escala, Color(1.0, 1.0, 1.0, opacidad * mezcla))


## El cono del Firewall: su contorno hacia donde mira el personaje, teñido
## como el anillo, y en cada ataque el golpe en verde, hacia donde atacó y
## apagándose. Más fuerte cerca si pega más cerca (dano_pegado y dano_filo).
func _dibujar_cono(arma: DatosArma, indice: int, encendido: bool, tinte: Color) -> void:
	var alcance: float = arma.radio * _gestor_armas.multiplicador_alcance
	var mirando: Vector2 = get_parent().mirando
	_cono(mirando, alcance, arma.angulo_cono, Color(tinte, 0.0), Color(tinte, 0.0), Color(tinte, 0.9 if encendido else 0.35))
	var cono: RefCounted = _gestor_armas.ultimo_cono
	if cono == null or indice >= _desde_ataque.size():
		return
	var duracion := arma.fotogramas_efecto * arma.segundos_por_fotograma
	if _desde_ataque[indice] >= duracion:
		return
	var opacidad := OPACIDAD_EFECTO * (1.0 - _desde_ataque[indice] / duracion)
	var mas := maxf(arma.dano_pegado, arma.dano_filo)
	_cono(cono.direccion, alcance, arma.angulo_cono, Color(VERDE_CONO, opacidad * arma.dano_pegado / mas),
		Color(VERDE_CONO, opacidad * arma.dano_filo / mas), Color(VERDE_CONO, opacidad))


## Un cono desde el personaje: relleno del color de cerca al de lejos (un
## abanico de triángulos con el vértice en el centro) y su contorno.
func _cono(direccion: Vector2, alcance: float, grados: float, cerca: Color, lejos: Color, borde: Color) -> void:
	var medio := deg_to_rad(grados) / 2.0
	var puntos := PackedVector2Array([Vector2.ZERO])
	var colores := PackedColorArray([cerca])
	for i in LADOS_CONO + 1:
		var angulo := direccion.angle() - medio + medio * 2.0 * i / LADOS_CONO
		puntos.append(Vector2.from_angle(angulo) * alcance)
		colores.append(lejos)
	if cerca.a > 0.0 or lejos.a > 0.0:
		draw_polygon(puntos, colores)
	puntos.append(Vector2.ZERO)
	draw_polyline(puntos, borde, 2.0)


func _dibujar_chispas() -> void:
	# Cada vez más deprisa hacia el personaje, que puede haberse movido.
	var lado := Vector2(LADO_CHISPA, LADO_CHISPA)
	for chispa in _chispas:
		var avance: float = chispa[1] / VIAJE_CHISPA
		var donde: Vector2 = _lienzo_chispas.to_local(chispa[0]).lerp(PECHO, avance * avance)
		var fotograma := int(chispa[1] / SEGUNDOS_POR_FOTOGRAMA_CHISPA) % FOTOGRAMAS_CHISPA
		_lienzo_chispas.draw_texture_rect_region(CHISPA, Rect2(donde - lado / 2.0, lado), Rect2(Vector2(fotograma * LADO_CHISPA, 0.0), lado))


## Un fotograma de una tira horizontal, centrado en el jugador y escalado.
func _fotograma(hoja: Texture2D, fotogramas: int, fotograma: int, escala: float, modulado: Color) -> void:
	var lado := Vector2(hoja.get_width() / float(fotogramas), hoja.get_height())
	draw_texture_rect_region(hoja, Rect2(-lado * escala / 2.0, lado * escala), Rect2(Vector2(fotograma * lado.x, 0.0), lado), modulado)
