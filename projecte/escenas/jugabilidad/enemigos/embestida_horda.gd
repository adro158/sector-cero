extends RefCounted

## Embestida de los enemigos de horda que la tienen (el troyano). Es la misma
## idea que la del jefe: persigue, al acercarse se queda quieto avisando y
## después sale disparado en línea recta hacia donde estaba el jugador.
##
## Un enemigo de horda no es un nodo (ver gestor_enemigos.gd), así que su
## estado no puede ir en variables sueltas como en el jefe: va en arrays de
## tamaño fijo, con el mismo índice que su posición y su vida en el gestor.
## Solo crean uno de estos los gestores de los tipos que embisten.
##
## Sin class_name a propósito: el gestor lo carga con preload. Una clase global
## nueva no llegaría con la actualización (.pck) a quien ya tiene instalada la
## v0.2, y tendría que bajarse el juego entero.

enum Estado { PERSEGUIR, AVISO, EMBESTIDA }

var _datos: DatosTipoEnemigo
var _estados := PackedInt32Array()
## Segundos que le quedan al estado actual. Persiguiendo, lo que le falta para
## poder volver a embestir.
var _tiempos := PackedFloat32Array()
var _direcciones := PackedVector2Array()


func _init(datos: DatosTipoEnemigo, maximo: int) -> void:
	_datos = datos
	_estados.resize(maximo)
	_tiempos.resize(maximo)
	_direcciones.resize(maximo)


## Un enemigo nuevo persigue y puede embestir en cuanto se acerque.
func reiniciar(indice: int) -> void:
	_estados[indice] = Estado.PERSEGUIR
	_tiempos[indice] = 0.0


## Lo usa el gestor al eliminar un enemigo, cuando trae el último vivo a su
## hueco: el estado tiene que viajar con él.
func copiar(desde: int, hasta: int) -> void:
	_estados[hasta] = _estados[desde]
	_tiempos[hasta] = _tiempos[desde]
	_direcciones[hasta] = _direcciones[desde]


func actualizar(indice: int, posicion: Vector2, destino: Vector2, delta: float) -> void:
	_tiempos[indice] -= delta

	match _estados[indice]:
		Estado.PERSEGUIR:
			if _tiempos[indice] <= 0.0 and posicion.distance_to(destino) < _datos.distancia_embestida:
				_cambiar(indice, Estado.AVISO, _datos.duracion_aviso)
		Estado.AVISO:
			# Mira al jugador hasta el final del aviso: embiste hacia donde
			# estaba entonces, no hacia donde vaya después.
			_direcciones[indice] = (destino - posicion).normalized()
			if _tiempos[indice] <= 0.0:
				_cambiar(indice, Estado.EMBESTIDA, _datos.duracion_embestida)
		Estado.EMBESTIDA:
			if _tiempos[indice] <= 0.0:
				_cambiar(indice, Estado.PERSEGUIR, _datos.espera_embestida)


## Si persigue como los demás. Si no, lo mueve avance().
func persigue(indice: int) -> bool:
	return _estados[indice] == Estado.PERSEGUIR


## Quieto mientras avisa; en línea recta y más rápido mientras embiste.
func avance(indice: int, delta: float) -> Vector2:
	if _estados[indice] != Estado.EMBESTIDA:
		return Vector2.ZERO
	return _direcciones[indice] * _datos.velocidad * _datos.multiplicador_embestida * delta


## 1 mientras avisa y 0 si no. Lo recibe el shader de la horda para hacerlo
## parpadear.
func avisando(indice: int) -> float:
	return 1.0 if _estados[indice] == Estado.AVISO else 0.0


func _cambiar(indice: int, estado: Estado, duracion: float) -> void:
	_estados[indice] = estado
	_tiempos[indice] = duracion
