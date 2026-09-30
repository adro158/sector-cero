extends Node

signal salud_jugador_cambiada(actual: float, maxima: float)
signal experiencia_ganada(cantidad: int)
## Para la barra de experiencia: cuánta hay, cuánta hace falta para subir y el
## nivel actual. Llega al empezar y cada vez que cambia.
signal experiencia_cambiada(actual: int, necesaria: int, nivel: int)
## Una vez por segundo de partida. duracion es cuándo llega el jefe.
signal tiempo_partida(segundos: float, duracion: float)
signal jugador_subio_nivel(opciones: Array[DatosMejora])
signal mejora_seleccionada(mejora: DatosMejora)
signal enemigo_muerto(posicion: Vector2, tipo_enemigo: String)
## Al morir o al sobrevivir el tiempo de la partida. Claves de estadisticas:
## victoria (bool), tiempo (float, en segundos), nivel (int), eliminados (int).
signal partida_terminada(estadisticas: Dictionary)
signal juego_pausado(en_pausa: bool)
