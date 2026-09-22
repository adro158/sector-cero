class_name Salud
extends Node

signal vida_cambiada(actual: float, maxima: float)
signal murio

@export var vida_maxima: float = 100.0
@export var invulnerabilidad: float = 0.5

var _vida: float
var _tiempo_invulnerable := 0.0


func _ready() -> void:
	_vida = vida_maxima
	# Diferido porque los hijos están listos antes que el padre: si se emitiera
	# aquí mismo, nadie se habría conectado todavía y el aviso se perdería.
	vida_cambiada.emit.call_deferred(_vida, vida_maxima)


func _physics_process(delta: float) -> void:
	_tiempo_invulnerable -= delta


func recibir_dano(cantidad: float) -> void:
	if _vida <= 0.0 or _tiempo_invulnerable > 0.0:
		return

	_vida = maxf(_vida - cantidad, 0.0)
	_tiempo_invulnerable = invulnerabilidad
	vida_cambiada.emit(_vida, vida_maxima)

	if _vida <= 0.0:
		murio.emit()
