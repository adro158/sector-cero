class_name DatosConfigOleada
extends Resource

## Segundos entre apariciones al empezar la partida y al llegar a la dificultad
## máxima. El director interpola entre ambos según avanza el tiempo.
@export var intervalo_inicial: float = 0.5
@export var intervalo_final: float = 0.08
@export var tiempo_hasta_dificultad_maxima: float = 600.0

## A qué distancia del jugador aparecen, para que lo hagan fuera de cámara.
@export var distancia_aparicion: float = 700.0

## Segundos que hay que sobrevivir para que llegue el jefe.
@export var duracion_partida: float = 600.0
## Segundos de la fase 2: empieza al derrotar al jefe, con el reloj otra vez
## en duracion_partida, y al acabar llega el jefe final.
@export var duracion_fase_2: float = 300.0
## La horda de la fase 2 entra poco a poco: en sus primeros entrada_fase_2
## segundos, el intervalo va de intervalo_inicio_fase_2 al de siempre (el
## final). Desde el 22/10: entraba toda de golpe y en media y difícil casi
## todas las partidas se perdían en sus dos primeros minutos.
@export var entrada_fase_2: float = 60.0
@export var intervalo_inicio_fase_2: float = 0.3

@export_group("Élites")
## Segundo en que llega el primer élite y cada cuánto llega otro.
@export var primer_elite: float = 90.0
@export var intervalo_elites: float = 60.0
## A partir de este segundo los élites traen dos afijos en vez de uno.
@export var tiempo_dos_afijos: float = 300.0
## Los afijos que se sortean.
@export var afijos_elite: Array[DatosAfijoElite] = []
