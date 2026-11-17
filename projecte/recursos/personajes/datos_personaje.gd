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

## Color que lo identifica en la interfaz. No cambia con la skin: es lo que
## lo reconoce en el HUD, las ultis y los efectos.
@export var color: Color = Color.WHITE

## Sus skins (recursos/skins/<personaje>/, con datos_skin.gd), de la categoría
## más baja a la más alta. El aspecto original es la número 1 y no está aquí.
@export var skins: Array[Resource] = []


## La skin con ese número, o el propio personaje si es la 1 (la original) o no
## la tiene. Las dos tienen las hojas y el retrato con los mismos nombres, así
## que quien dibuja no necesita saber cuál es. El número lo da quien llama: la
## opción guardada (datos_skin.gd, elegida) o, en red, el de cada jugador.
## Aquí no se lee la opción: con --script (el simulador) esta clase se compila
## antes de que existan los autoloads y GestorGuardado no se encontraría.
func skin(numero: int) -> Resource:
	for una in skins:
		if una.numero == numero:
			return una
	return self
