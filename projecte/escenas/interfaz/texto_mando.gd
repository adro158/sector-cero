extends Node

## Hijo de un Label o un Button: le pone el texto de teclado o el de mando,
## según con qué se juegue (globales/entrada.gd), y lo cambia en cuanto se
## toca el otro. Así «VOLVER  [Esc]» pasa a «VOLVER  [B]» al coger el mando.
## Se pone con EstiloInterfaz.segun_mando.
##
## Un nodo y no una función suelta conectada al bus: al borrarse la pantalla
## se borra con ella, y Godot quita su conexión solo.
##
## Sin class_name: se carga con preload.

const Entrada := preload("res://globales/entrada.gd")

var teclado := ""
var mando := ""


func _ready() -> void:
	BusEventos.dispositivo_cambiado.connect(_poner)
	_poner(Entrada.con_mando)


func _poner(con_mando: bool) -> void:
	get_parent().text = mando if con_mando else teclado
