class_name DatosArma
extends Resource

enum Tipo {
	AREA,
	PROYECTIL,
}

@export var nombre: String = ""
@export var tipo: Tipo = Tipo.AREA
@export var dano: float = 6.0
@export var cadencia: float = 0.6

## En las armas de área es el alcance del golpe. En los proyectiles, el radio
## con el que impactan.
@export var radio: float = 90.0

@export_group("Solo proyectiles")
@export var velocidad_proyectil: float = 420.0

## Cuántas veces salta de un enemigo a otro antes de agotarse.
@export var rebotes: int = 3
@export var vida_util: float = 2.5
