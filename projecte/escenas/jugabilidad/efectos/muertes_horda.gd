extends Node2D

## La muerte de cada enemigo de la horda: un destello y el enemigo que se
## deshace en trocitos, teñido del color de su tipo y escalado a su tamaño (el
## dibujo es para uno de 24 px). Escucha enemigo_muerto; los élites y los jefes
## se quedan con su estallido de partículas (pool_particulas.gd).
##
## Un solo nodo las dibuja todas, porque pueden morir decenas a la vez; todas
## usan la misma textura, así que el motor las junta en pocas llamadas de
## dibujado. Va encima de la horda (z_index 4) y debajo de las chispas de las
## partículas.
##
## Sin class_name: es un script de una escena, no hace falta que sea global.

const MUERTE := preload("res://medios/sprites/efectos/muerte_horda.png")
const LADO := 48.0
const FOTOGRAMAS := 6
const SEGUNDOS_POR_FOTOGRAMA := 0.05
## El tamaño de enemigo para el que está hecho el dibujo.
const TAMANO_DIBUJO := 24.0
## Si mueren más a la vez, las nuevas no se dibujan: son decoración.
const MAXIMO := 300

## Por tipo de la horda: [color, escala].
var _tipos := {}
## Cada muerte: [posición, color, escala, segundos].
var _muertes: Array = []


func _ready() -> void:
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		_tipos[gestor.datos.tipo] = [gestor.datos.color, gestor.datos.tamano / TAMANO_DIBUJO]
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


func _al_morir_enemigo(posicion: Vector2, tipo: String) -> void:
	if tipo in _tipos and _muertes.size() < MAXIMO:
		_muertes.append([posicion, _tipos[tipo][0], _tipos[tipo][1], 0.0])


## Con el juego en pausa no se llama: las muertes se quedan quietas.
func _process(delta: float) -> void:
	if _muertes.is_empty():
		return
	for muerte in _muertes:
		muerte[3] += delta
	_muertes = _muertes.filter(func(muerte): return muerte[3] < FOTOGRAMAS * SEGUNDOS_POR_FOTOGRAMA)
	queue_redraw()


func _draw() -> void:
	for muerte in _muertes:
		var lado: Vector2 = Vector2(LADO, LADO) * muerte[2]
		var fotograma := int(muerte[3] / SEGUNDOS_POR_FOTOGRAMA)
		draw_texture_rect_region(MUERTE, Rect2(muerte[0] - lado / 2.0, lado), Rect2(fotograma * LADO, 0.0, LADO, LADO), muerte[1])
