class_name DatosTipoEnemigo
extends Resource

@export var tipo: String = ""
@export var vida: float = 20.0
@export var velocidad: float = 90.0
@export var tamano: float = 24.0
@export var color: Color = Color.WHITE
@export var dano_contacto: float = 8.0
@export var experiencia: int = 1

## Segundo de partida a partir del cual este tipo empieza a aparecer.
@export var tiempo_aparicion: float = 0.0
