class_name DatosPoolMejoras
extends Resource

## Lista de todas las mejoras que pueden salir al subir de nivel. Vive en un
## recurso propio, y no dentro de una escena, para que se pueda balancear sin
## tocar ninguna escena.
@export var mejoras: Array[DatosMejora] = []
