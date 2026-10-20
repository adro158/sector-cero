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

## Robo de vida: la parte del daño hecho que cura al personaje (0.1 es un
## 10 %), con un tope por golpe (ROBO_MAXIMO en gestor_armas.gd). Solo en las
## armas de área: lo tiene el Firewall del Espadachín, que llega poco y pega
## poco, para que compense pegarse a la horda.
@export var robo_vida: float = 0.0

## Nombre del efecto de medios/audio/ que suena cada vez que ataca.
@export var sonido: String = "firewall"

@export_group("Solo proyectiles")
@export var velocidad_proyectil: float = 420.0

## Cuántas veces salta de un enemigo a otro antes de agotarse.
@export var rebotes: int = 3
@export var vida_util: float = 2.5
