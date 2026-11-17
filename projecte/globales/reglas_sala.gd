extends RefCounted

## Las reglas de la sala del multijugador, en el anfitrión (red.gd): quién
## puede entrar y qué personaje lleva cada uno. Un jugador es {id, nombre,
## personaje}. Aparte de red.gd para que ese no pase de ~200 líneas.
##
## Sin class_name: se carga con preload.

const MAXIMO_JUGADORES := 3
const PERSONAJES := 3


## Por qué no puede entrar uno con esa versión, o "" si puede: tiene que tener
## la misma versión y quedar sitio.
static func motivo_rechazo(jugadores: Array, version: String) -> String:
	if version != Version.ACTUAL:
		return "La sala es de la versión %s y tú tienes la %s." % [Version.ACTUAL, version]
	if jugadores.size() >= MAXIMO_JUGADORES or primer_personaje_libre(jugadores) == -1:
		return "La sala está llena."
	return ""


static func primer_personaje_libre(jugadores: Array) -> int:
	for indice in PERSONAJES:
		if not jugadores.any(func(jugador): return jugador.personaje == indice):
			return indice
	return -1


## Si está libre (y existe), ese jugador pasa a llevarlo. Devuelve si ha
## cambiado algo.
static func poner_personaje(jugadores: Array, id: int, indice: int) -> bool:
	if indice < 0 or indice >= PERSONAJES:
		return false
	for jugador in jugadores:
		if jugador.personaje == indice and jugador.id != id:
			return false
	for jugador in jugadores:
		if jugador.id == id:
			jugador.personaje = indice
	return true
