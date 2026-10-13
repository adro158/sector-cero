extends RefCounted

## Para el menú de desarrollador: al saltar a un minuto, deja al jugador con el
## nivel y las mejoras que tendría si hubiera jugado hasta ahí. Así, saltando
## al minuto 10, el jefe se prueba como llega de verdad.
##
## Las cifras salen del simulador de partidas (herramientas/simular_partidas.gd):
## la media de sus 10 partidas al llegar a cada minuto, medida el 13/10/2026.
## Si cambia el balance, hay que volver a medirlas. Cada nivel ganado da una
## mejora y cada cofre de élite otra, por eso las dos tablas van por separado.

## Nivel al llegar a cada minuto, del 0 al 10.
const NIVEL: Array[int] = [1, 2, 6, 7, 9, 9, 9, 10, 11, 11, 12]
## Mejoras aplicadas al llegar a cada minuto, del 0 al 10.
const MEJORAS: Array[int] = [0, 1, 5, 6, 8, 8, 9, 10, 10, 11, 12]
## Las mejoras se eligen como las elige el bot del simulador, el que da las
## cifras: la evolución si sale y, si no, una de ataque.
const DE_ATAQUE := [DatosMejora.Efecto.DANO_ARMAS, DatosMejora.Efecto.CADENCIA_ARMAS, DatosMejora.Efecto.ALCANCE_ARMAS]


## Sube el nivel y da las mejoras que falten. Si ya se tiene más (por ejemplo,
## al volver atrás en el tiempo), no se quita nada.
static func ponerse_al_dia(niveles: Node, segundos: float) -> void:
	var nivel := _en(NIVEL, segundos)
	if nivel > niveles.nivel():
		niveles.poner_nivel(nivel)
	while niveles.mejoras_aplicadas() < _en(MEJORAS, segundos):
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
