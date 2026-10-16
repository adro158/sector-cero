extends RefCounted

## Para el menú de desarrollador: al saltar a un minuto, deja al jugador con el
## nivel y las mejoras que tendría si hubiera jugado hasta ahí. Así, saltando
## al minuto 10, el jefe se prueba como llega de verdad.
##
## Las cifras salen del simulador de partidas (herramientas/simular_partidas.gd):
## la media de sus 10 partidas al llegar a cada minuto, medida el 16/10/2026
## con el bot que ya recoge fragmentos. Del 0 al 10, en media; del 11 al 15
## (la fase 2), en fácil, porque en media casi ninguna partida llega. Si cambia
## el balance, hay que volver a medirlas. Cada nivel ganado da una mejora y
## cada cofre de élite otra, por eso las dos tablas van por separado.
##
## El minuto 10 es el de la llegada del jefe. Como el reloj se para mientras
## está, lo que se gana peleando con él no sale en ningún minuto: va aparte, en
## lo que se tiene al empezar la fase 2 (la línea «FASE 2» del simulador, en
## media). En la fase 2 nunca se tiene menos que eso.

## Nivel al llegar a cada minuto, del 0 al 15.
const NIVEL: Array[int] = [1, 2, 6, 8, 9, 10, 11, 11, 12, 12, 13, 15, 15, 16, 16, 16]
## Mejoras aplicadas al llegar a cada minuto, del 0 al 15.
const MEJORAS: Array[int] = [0, 1, 6, 7, 9, 10, 11, 11, 13, 13, 14, 21, 22, 23, 24, 24]
## Al empezar la fase 2, tras ganar al jefe.
const NIVEL_FASE_2 := 15
const MEJORAS_FASE_2 := 20
## Las mejoras se eligen como las elige el bot del simulador, el que da las
## cifras: la evolución si sale y, si no, una de ataque.
const DE_ATAQUE := [DatosMejora.Efecto.DANO_ARMAS, DatosMejora.Efecto.CADENCIA_ARMAS, DatosMejora.Efecto.ALCANCE_ARMAS]


## Sube el nivel y da las mejoras de ese minuto y esa fase. Se llama con la
## partida recién empezada: el menú recarga la escena antes de saltar.
static func ponerse_al_dia(niveles: Node, segundos: float, fase := 1) -> void:
	var nivel := _en(NIVEL, segundos)
	var mejoras := _en(MEJORAS, segundos)
	if fase == 2:
		nivel = maxi(nivel, NIVEL_FASE_2)
		mejoras = maxi(mejoras, MEJORAS_FASE_2)
	if nivel > niveles.nivel():
		niveles.poner_nivel(nivel)
	while niveles.mejoras_aplicadas() < mejoras:
		niveles.regalar(_elegir(niveles.opciones_de_nivel()))


## El valor de la tabla en ese segundo, a medio camino entre un minuto y el
## siguiente: a las 7:30, la mitad entre lo del minuto 7 y lo del 8.
static func _en(tabla: Array[int], segundos: float) -> int:
	var minuto := clampf(segundos / 60.0, 0.0, tabla.size() - 1.0)
	var antes := floori(minuto)
	var despues := mini(antes + 1, tabla.size() - 1)
	return roundi(lerpf(tabla[antes], tabla[despues], minuto - antes))


## Las opciones ya vienen barajadas: la primera de ataque es una al azar.
static func _elegir(opciones: Array[DatosMejora]) -> DatosMejora:
	if opciones[0].efecto == DatosMejora.Efecto.EVOLUCIONAR_ARMA:
		return opciones[0]
	for mejora in opciones:
		if mejora.efecto in DE_ATAQUE:
			return mejora
	return opciones[0]
