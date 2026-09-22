class_name RejillaEspacial
extends RefCounted

var _tamano_celda: float
var _celdas: Dictionary = {}


func _init(tamano_celda: float) -> void:
	_tamano_celda = tamano_celda


func limpiar() -> void:
	_celdas.clear()


func insertar(indice: int, posicion: Vector2) -> void:
	var clave := _clave(posicion)

	if _celdas.has(clave):
		_celdas[clave].append(indice)
	else:
		_celdas[clave] = [indice]


func indices_cerca(posicion: Vector2) -> Array:
	# Con celdas del tamaño del radio de búsqueda, mirar la celda propia y las 8
	# de alrededor basta para no dejarse ningún vecino dentro del radio.
	var resultado: Array = []
	var centro := _clave(posicion)

	for desplazamiento_y in range(-1, 2):
		for desplazamiento_x in range(-1, 2):
			var clave := centro + Vector2i(desplazamiento_x, desplazamiento_y)
			if _celdas.has(clave):
				resultado.append_array(_celdas[clave])

	return resultado


func _clave(posicion: Vector2) -> Vector2i:
	return Vector2i(
		floori(posicion.x / _tamano_celda),
		floori(posicion.y / _tamano_celda)
	)
