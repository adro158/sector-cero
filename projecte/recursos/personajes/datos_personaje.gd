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
## La misma hoja con el arma evolucionada: se pone al evolucionar su herramienta.
@export var hoja_evolucion: Texture2D
## Al atacar, un momento: 4 columnas por las mismas 8 filas, con la columna 0
## igual que la 0 de andar. Una con el arma de siempre y otra con la
## evolucionada.
@export var hoja_ataque: Texture2D
@export var hoja_ataque_evolucion: Texture2D
## Al atacar andando: 6 columnas por las mismas 8 filas, y la columna c es la
## c de andar con los brazos y el arma del golpe. Así las piernas siguen
## corriendo mientras ataca (la de atacar está dibujada de pie).
@export var hoja_correr_ataque: Texture2D
@export var hoja_correr_ataque_evolucion: Texture2D
## Quieto (lote 10): 4 columnas por las mismas 8 filas, en bucle. La columna 0
## es la 0 de andar; en las otras respira, la capa ondea, los ojos brillan y
## el arma late.
@export var hoja_reposo: Texture2D
@export var hoja_reposo_evolucion: Texture2D
## Lo que dura cada fotograma del ataque.
@export var segundos_ataque: float = 0.05
## Retrato de 64x64 para el panel del equipo y la ventana de caída. Se enseña a
## tamaño real: escalado se deforma.
@export var retrato: Texture2D
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
