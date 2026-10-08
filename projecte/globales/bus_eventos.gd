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
## Cómo está el equipo: al empezar, al cambiar de personaje y cuando cambia la
## vida de alguno. personajes: un diccionario por personaje con personaje
## (DatosPersonaje), arma (DatosArma), vida, maxima y caido. activo: su índice.
signal equipo_cambiado(personajes: Array, activo: int)
## Ha caído el personaje activo y quedan otros: llega con el juego pausado y se
## contesta con personaje_elegido. Mismo formato que equipo_cambiado.
signal personaje_caido(personajes: Array, caido: int)
## La interfaz avisa de quién sigue tras caer uno (su índice en el equipo).
signal personaje_elegido(indice: int)
## El jugador ha recibido un golpe que hace daño. Para el sonido: comparar la
## vida no sirve, porque también baja al cambiar a un personaje con menos.
signal jugador_danado(cantidad: float)
## La carga de la ulti de cada personaje, de 0 a 1 (llena: se lanza con R), y
## el índice del activo. Al empezar, al matar y al lanzarla.
signal ulti_cambiada(cargas: Array, activo: int)
## El personaje activo ha lanzado su ulti.
signal ulti_lanzada(personaje: DatosPersonaje)
## Una herramienta se ha convertido en su evolución.
signal arma_evolucionada(arma: DatosArma)
signal jugador_subio_nivel(opciones: Array[DatosMejora])
## Se ha recogido el cofre que suelta un élite al morir.
signal cofre_recogido
## El cofre abre la ruleta: las 8 mejoras de los sectores y la que ha tocado,
## que se sortea antes de girar. Como al subir de nivel, llega con el juego
## pausado y se contesta con mejora_seleccionada(premio).
signal ruleta_abierta(opciones: Array[DatosMejora], premio: DatosMejora)
signal mejora_seleccionada(mejora: DatosMejora)
## Una mejora dada desde el menú de desarrollador, ya aplicada: solo para que
## la interfaz la apunte.
signal mejora_regalada(mejora: DatosMejora)
signal enemigo_muerto(posicion: Vector2, tipo_enemigo: String)
## Cada vez que la herramienta del personaje ataca. Para el sonido.
signal herramienta_usada(arma: DatosArma)
signal jefe_aparecio
## El jefe acaba de sacar un anillo de horda a su alrededor.
signal jefe_invoco
## descripcion: los nombres de sus afijos, como "BLINDADO + EXPLOSIVO".
signal elite_aparecio(descripcion: String)
## Un élite explosivo ha estallado al terminar su aviso.
signal elite_exploto(posicion: Vector2)
## Al morir o al sobrevivir el tiempo de la partida. Claves de estadisticas:
## victoria (bool), tiempo (float, en segundos), nivel (int), eliminados (int).
signal partida_terminada(estadisticas: Dictionary)
signal juego_pausado(en_pausa: bool)
