extends RefCounted

## Los logros (de Alan, 19/11; plan_tienda.md): retos que no caducan, cada
## uno con su título (premios.gd). Se cuentan al acabar cada partida, con lo
## mismo que las misiones (contador_partida.gd), y algunos con lo que guarda
## la cartera (la racha y las skins conseguidas).
##
## Cada logro: id (no cambia nunca), texto, cuenta (como en misiones.gd, o
## "racha", "skins" o "trio"), objetivo y titulo. Sin class_name.

const Misiones := preload("res://globales/misiones.gd")

const LISTA := [
	{"id": "l_eliminar", "texto": "Elimina 10 000 malware", "cuenta": "eliminados", "objetivo": 10000, "titulo": "t_cazador"},
	{"id": "l_kernel", "texto": "Derrota a Kernel Panic 10 veces", "cuenta": "fase2", "objetivo": 10, "titulo": "t_kernel"},
	{"id": "l_exorcista", "texto": "Derrota a NÚCLEO CERO en difícil", "cuenta": "victoria_dificil", "objetivo": 1, "titulo": "t_exorcista"},
	{"id": "l_trio", "texto": "Gana acabando con cada uno de los tres personajes", "cuenta": "trio", "objetivo": 3, "titulo": "t_trio"},
	{"id": "l_red", "texto": "Juega 10 partidas en red", "cuenta": "partidas_red", "objetivo": 10, "titulo": "t_companero"},
	{"id": "l_racha", "texto": "Juega 7 días seguidos", "cuenta": "racha", "objetivo": 7, "titulo": "t_constante"},
	{"id": "l_skins", "texto": "Consigue 10 skins", "cuenta": "skins", "objetivo": 10, "titulo": "t_coleccionista"},
]


## Para enseñarlos: [{id, texto, titulo, progreso, objetivo, hecho}].
static func lista(fichero: ConfigFile) -> Array:
	var progreso: Dictionary = fichero.get_value("logros", "progreso", {})
	var hechos: Array = fichero.get_value("logros", "hechos", [])
	return LISTA.map(func(logro): return {"id": logro.id, "texto": logro.texto, "titulo": logro.titulo,
		"progreso": mini(_valor(progreso.get(logro.id, 0)), logro.objetivo), "objetivo": logro.objetivo,
		"hecho": logro.id in hechos})


## Suma una partida. racha y skins: lo que tiene la cartera ahora. Devuelve
## los logros que se acaban de conseguir (la cartera da su título).
static func contar(fichero: ConfigFile, partida: Dictionary, racha: int, skins: int) -> Array:
	var progreso: Dictionary = fichero.get_value("logros", "progreso", {})
	var hechos: Array = fichero.get_value("logros", "hechos", [])
	var conseguidos := []
	for logro in LISTA:
		if logro.id in hechos:
			continue
		match logro.cuenta:
			"racha":
				progreso[logro.id] = maxi(progreso.get(logro.id, 0), racha)
			"skins":
				progreso[logro.id] = skins
			"trio":
				# Los personajes con los que ya se ha ganado, sin repetir.
				var con: Array = progreso.get(logro.id, [])
				if partida.get("victoria", 0) == 1 and partida.personaje != "" and not partida.personaje in con:
					con.append(partida.personaje)
				progreso[logro.id] = con
			_:
				progreso[logro.id] = progreso.get(logro.id, 0) + Misiones.avance(logro, partida)
		if _valor(progreso[logro.id]) >= logro.objetivo:
			hechos.append(logro.id)
			conseguidos.append(logro)
	fichero.set_value("logros", "progreso", progreso)
	fichero.set_value("logros", "hechos", hechos)
	return conseguidos


## El del trío es la lista de personajes; los demás, un número.
static func _valor(progreso: Variant) -> int:
	return progreso.size() if progreso is Array else int(progreso)
