class_name DatosAfijoElite
extends Resource

## Un afijo de élite: una propiedad que se combina al azar con otras al hacer
## aparecer un élite. Con cuatro afijos y combinaciones de uno o dos salen diez
## élites distintos sin diseñar ninguno a mano.

enum Efecto {
	BLINDADO,
	REPLICANTE,
	AURA_LENTA,
	EXPLOSIVO,
}

@export var nombre: String = ""
## Para la ventana de reglas.
@export_multiline var descripcion: String = ""
@export var efecto: Efecto = Efecto.BLINDADO
## Color con el que se dibuja su anillo alrededor del élite.
@export var color: Color = Color.WHITE

## Depende del efecto: la fracción del daño que ignora el blindado, cuántos
## bits corruptos suelta el replicante al morir, la fracción de velocidad que
## quita el aura y el daño de la explosión.
@export var valor: float = 0.5
