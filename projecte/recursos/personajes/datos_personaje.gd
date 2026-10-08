class_name DatosPersonaje
extends Resource

## Un personaje jugable: su aspecto y la herramienta que usa. Solo dispara el
## arma del personaje activo, así que cambiar de personaje es la forma de
## esquivar la resistencia que el malware va ganando contra esa arma.

@export var nombre: String = ""
## Para la ventana de reglas: qué hace su herramienta y cuándo conviene.
@export_multiline var descripcion: String = ""

## Hoja de sprites de 6 columnas (pasos) por 8 filas (direcciones), como la del
## personaje original.
@export var hoja: Texture2D
@export var arma: DatosArma
## Cada personaje tiene su propia vida: el que pega de cerca aguanta más.
@export var vida_maxima: float = 100.0

## Su ulti, que se lanza con R cuando se ha cargado matando: "rayo", "giro" o
## "tormenta" (ultis.gd). El nombre y la descripción son para la interfaz.
@export var ulti: String = ""
@export var nombre_ulti: String = ""
@export_multiline var descripcion_ulti: String = ""

## Color que lo identifica en la interfaz.
@export var color: Color = Color.WHITE
