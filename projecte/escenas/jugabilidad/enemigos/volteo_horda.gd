extends RefCounted

## Hacia dónde mira cada enemigo de horda de los tipos que se voltean (el
## troyano, un caballo de ajedrez dibujado mirando a la izquierda): se da la
## vuelta para mirar al jugador. Se hace con la escala x de su transformación
## en el MultiMesh, así que no hace falta otro dibujo.
##
## Como la embestida (embestida_horda.gd), va en un array de tamaño fijo con el
## mismo índice que la posición y la vida en el gestor, y solo lo crean los
## gestores de los tipos que se voltean.
##
## Sin class_name a propósito: el gestor lo carga con preload (ver
## embestida_horda.gd).

## El jugador tiene que estar claramente a un lado (más de estos píxeles) para
## que se dé la vuelta: así no parpadea cuando lo tiene justo encima.
const MARGEN := 8.0

## 1 si mira a la derecha (volteado) y 0 si a la izquierda, como en el dibujo.
var _a_la_derecha := PackedByteArray()


func _init(maximo: int) -> void:
	_a_la_derecha.resize(maximo)


## Uno nuevo mira como en el dibujo.
func reiniciar(indice: int) -> void:
	_a_la_derecha[indice] = 0


## Lo usa el gestor al eliminar un enemigo, cuando trae el último vivo a su
## hueco: hacia dónde mira tiene que viajar con él.
func copiar(desde: int, hasta: int) -> void:
	_a_la_derecha[hasta] = _a_la_derecha[desde]


## La escala x de su dibujo: -1 le da la vuelta para mirar a la derecha. Solo
## cambia de lado si el jugador está claramente al otro; si no, sigue como iba.
func escala_x(indice: int, posicion: Vector2, jugador: Vector2) -> float:
	var hacia_jugador := jugador.x - posicion.x
	if hacia_jugador > MARGEN:
		_a_la_derecha[indice] = 1
	elif hacia_jugador < -MARGEN:
		_a_la_derecha[indice] = 0
	return -1.0 if _a_la_derecha[indice] == 1 else 1.0
