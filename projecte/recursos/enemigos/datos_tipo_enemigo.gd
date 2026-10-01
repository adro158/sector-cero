class_name DatosTipoEnemigo
extends Resource

## Identificador interno, el que viaja en la señal enemigo_muerto.
@export var tipo: String = ""
## Nombre y descripción para la ventana de reglas.
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var vida: float = 20.0
@export var velocidad: float = 90.0
@export var tamano: float = 24.0
## Sprite de este tipo. Todos los enemigos de un tipo lo comparten, porque se
## dibujan con un único MultiMesh. Sin sprite, se dibuja un cuadrado del color.
@export var textura: Texture2D
@export var color: Color = Color.WHITE
@export var dano_contacto: float = 8.0
@export var experiencia: int = 1

## Segundo de partida a partir del cual este tipo empieza a aparecer.
@export var tiempo_aparicion: float = 0.0
