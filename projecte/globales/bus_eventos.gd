extends Node

signal salud_jugador_cambiada(actual: float, maxima: float)
signal experiencia_ganada(cantidad: int)
signal jugador_subio_nivel(opciones: Array[DatosMejora])
signal mejora_seleccionada(mejora: DatosMejora)
signal enemigo_muerto(posicion: Vector2, tipo_enemigo: String)
signal partida_terminada(estadisticas: Dictionary)
signal juego_pausado(en_pausa: bool)
