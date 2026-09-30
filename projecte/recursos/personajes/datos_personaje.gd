class_name DatosPersonaje
extends Resource

## Un personaje jugable: su aspecto y la herramienta que usa. Solo dispara el
## arma del personaje activo, así que cambiar de personaje es la forma de
## esquivar la resistencia que el malware va ganando contra esa arma.

@export var nombre: String = ""

## Hoja de sprites de 6 columnas (pasos) por 8 filas (direcciones), como la del
## personaje original.
@export var hoja: Texture2D
@export var arma: DatosArma

## Color que lo identifica en la interfaz.
@export var color: Color = Color.WHITE
