class_name DatosTipoEnemigo
extends Resource

## Identificador interno, el que viaja en la señal enemigo_muerto.
@export var tipo: String = ""
## Nombre y descripción para la ventana de reglas.
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var vida: float = 20.0
## Vida de más por cada nivel del jugador, sobre la de nivel 1: con 0.04, al
## nivel 10 tiene un 36 % más. Sin esto, al subir de nivel los enemigos
## morían de un golpe. Con 0.08 el bot no ganaba ninguna partida.
@export var vida_extra_por_nivel: float = 0.04
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
## Cuántos de este tipo puede haber vivos a la vez; 0 es sin límite. Es para
## los tanques como el ransomware: lentos y con mucha vida, sin límite se
## acumulan detrás del jugador.
@export var maximo_vivos: int = 0
## Barra de vida sobre cada uno. Solo para tipos de los que hay pocos a la vez
## (el ransomware): con cientos sería ruido.
@export var mostrar_vida: bool = false

@export_group("Embestida")
## Si es true, además de perseguir embiste como el jefe (ver embestida_horda.gd).
## Los valores de abajo solo cuentan para los tipos que embisten.
@export var embiste: bool = false
## A qué distancia del jugador empieza el aviso.
@export var distancia_embestida: float = 220.0
## Segundos quieto y parpadeando antes de salir disparado.
@export var duracion_aviso: float = 0.4
@export var duracion_embestida: float = 0.6
## Cuántas veces su velocidad normal lleva mientras embiste.
@export var multiplicador_embestida: float = 3.0
## Segundos que tiene que pasar persiguiendo antes de poder embestir otra vez.
@export var espera_embestida: float = 2.5


## La vida con la que aparece si el jugador va por ese nivel.
func vida_para_nivel(nivel: int) -> float:
	return vida * (1.0 + vida_extra_por_nivel * (nivel - 1))
