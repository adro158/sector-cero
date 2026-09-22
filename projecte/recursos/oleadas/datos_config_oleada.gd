class_name DatosConfigOleada
extends Resource

## Segundos entre apariciones al empezar la partida y al llegar a la dificultad
## máxima. El director interpola entre ambos según avanza el tiempo.
@export var intervalo_inicial: float = 0.5
@export var intervalo_final: float = 0.08
@export var tiempo_hasta_dificultad_maxima: float = 600.0

## A qué distancia del jugador aparecen, para que lo hagan fuera de cámara.
@export var distancia_aparicion: float = 700.0
