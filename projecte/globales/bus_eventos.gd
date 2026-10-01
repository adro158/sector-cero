extends Node

signal salud_jugador_cambiada(actual: float, maxima: float)
signal experiencia_ganada(cantidad: int)
## Para la barra de experiencia: cuánta hay, cuánta hace falta para subir y el
## nivel actual. Llega al empezar y cada vez que cambia.
signal experiencia_cambiada(actual: int, necesaria: int, nivel: int)
## Una vez por segundo de partida. duracion es cuándo llega el jefe.
signal tiempo_partida(segundos: float, duracion: float)
## Al empezar, en cada cambio de personaje y cuando evoluciona la herramienta
## del activo. arma: la que lleva ahora. espera: segundos hasta poder volver a
## cambiar.
signal personaje_cambiado(actual: DatosPersonaje, arma: DatosArma, siguiente: DatosPersonaje, espera: float)
## Una herramienta se ha convertido en su evolución.
signal arma_evolucionada(arma: DatosArma)
signal jugador_subio_nivel(opciones: Array[DatosMejora])
signal mejora_seleccionada(mejora: DatosMejora)
signal enemigo_muerto(posicion: Vector2, tipo_enemigo: String)
## Cada vez que la herramienta del personaje ataca. Para el sonido.
signal herramienta_usada(arma: DatosArma)
signal jefe_aparecio
## descripcion: los nombres de sus afijos, como "BLINDADO + EXPLOSIVO".
signal elite_aparecio(descripcion: String)
## Un élite explosivo ha estallado al terminar su aviso.
signal elite_exploto(posicion: Vector2)
## Al morir o al sobrevivir el tiempo de la partida. Claves de estadisticas:
## victoria (bool), tiempo (float, en segundos), nivel (int), eliminados (int).
signal partida_terminada(estadisticas: Dictionary)
signal juego_pausado(en_pausa: bool)
