class_name Direcciones8
extends RefCounted

## Traduce una dirección de movimiento a la fila de una hoja de sprites de ocho
## direcciones. La usan el jugador y el jefe, que tienen hojas con el mismo
## orden de filas: abajo, abajo-izquierda, izquierda, arriba-izquierda, arriba,
## arriba-derecha, derecha, abajo-derecha.

## Fila de la hoja para cada octavo de vuelta, empezando por la derecha y
## girando en el sentido de las agujas del reloj (en pantalla, la y crece hacia
## abajo).
const FILA_POR_OCTANTE := [6, 7, 0, 1, 2, 3, 4, 5]


static func fila(direccion: Vector2) -> int:
	# El ángulo se redondea al octavo de vuelta más cercano: 0 es la derecha,
	# 2 abajo, 4 la izquierda y 6 arriba. posmod lo deja entre 0 y 7 aunque el
	# ángulo sea negativo, que es lo que pasa hacia arriba.
	var octante := posmod(roundi(direccion.angle() / (TAU / 8.0)), 8)
	return FILA_POR_OCTANTE[octante]
