class_name Salud
extends Node

signal vida_cambiada(actual: float, maxima: float)
## Solo cuando el golpe hace daño de verdad, no durante la invulnerabilidad.
signal danado(cantidad: float)
signal murio

@export var vida_maxima: float = 100.0
@export var invulnerabilidad: float = 0.5
## Vida que se recupera por segundo. Sin ella, cada roce se acumula hasta matar:
## en las partidas simuladas nadie pasaba de los 7 minutos.
@export var regeneracion: float = 0.0

var _vida: float
var _tiempo_invulnerable := 0.0


func _ready() -> void:
	_vida = vida_maxima
	# Diferido porque los hijos están listos antes que el padre: si se emitiera
	# aquí mismo, nadie se habría conectado todavía y el aviso se perdería.
	vida_cambiada.emit.call_deferred(_vida, vida_maxima)


func _physics_process(delta: float) -> void:
	_tiempo_invulnerable -= delta

	if regeneracion > 0.0 and _vida > 0.0 and _vida < vida_maxima:
		var antes := int(_vida)
		_vida = minf(_vida + regeneracion * delta, vida_maxima)
		# Solo se avisa al cambiar de número entero: la interfaz no necesita
		# enterarse sesenta veces por segundo de cada décima recuperada.
		if int(_vida) != antes:
			vida_cambiada.emit(_vida, vida_maxima)


func vida() -> float:
	return _vida


## Vuelve a llenar la vida con un máximo nuevo. Para los élites, que se
## reutilizan de una aparición a la siguiente.
func reiniciar(maxima: float) -> void:
	vida_maxima = maxima
	_vida = maxima
	vida_cambiada.emit(_vida, vida_maxima)


## Recupera una fracción de la vida máxima (0.5 es la mitad), sin pasarse.
func curar(fraccion: float) -> void:
	if _vida <= 0.0:
		return
	_vida = minf(_vida + vida_maxima * fraccion, vida_maxima)
	vida_cambiada.emit(_vida, vida_maxima)


func aumentar_vida_maxima(cantidad: float) -> void:
	vida_maxima += cantidad
	_vida += cantidad
	vida_cambiada.emit(_vida, vida_maxima)


func recibir_dano(cantidad: float) -> void:
	if _vida <= 0.0 or _tiempo_invulnerable > 0.0:
		return

	_vida = maxf(_vida - cantidad, 0.0)
	_tiempo_invulnerable = invulnerabilidad
	vida_cambiada.emit(_vida, vida_maxima)
	danado.emit(cantidad)

	if _vida <= 0.0:
		murio.emit()
