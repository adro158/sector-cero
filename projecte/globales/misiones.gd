extends RefCounted

## Las misiones diarias y semanales (de Alan, 19/11; documentacio/plan_tienda.md):
## la lista fija, el sorteo con la fecha como semilla y cuánto avanza cada una
## con una partida. La cartera (cartera.gd) guarda las de ahora y su progreso.
##
## El sorteo usa el día (o el lunes de la semana) como semilla: todos tienen
## las mismas misiones el mismo día, sin servidor. Cambiando la hora del
## ordenador se puede hacer trampa; se acepta, como los bits en local.
##
## Cada misión: id (no cambia nunca: va en el fichero), texto, cuenta (qué se
## mira, ver avance), objetivo, bits y puntos del pase. Con «mejor», cuenta la
## mejor partida en vez de la suma. Sin class_name: se carga con preload.

const DIARIAS := [
	{"id": "d_eliminar", "texto": "Elimina 500 malware", "cuenta": "eliminados", "objetivo": 500, "bits": 60},
	{"id": "d_aguantar", "texto": "Aguanta 8 minutos en una partida", "cuenta": "tiempo", "objetivo": 480, "mejor": true, "bits": 70},
	{"id": "d_cofres", "texto": "Abre 3 cofres", "cuenta": "cofres", "objetivo": 3, "bits": 60},
	{"id": "d_ultis", "texto": "Lanza 5 ultis", "cuenta": "ultis", "objetivo": 5, "bits": 50},
	{"id": "d_cambios", "texto": "Cambia de personaje 10 veces", "cuenta": "cambios", "objetivo": 10, "bits": 50},
	{"id": "d_red", "texto": "Juega una partida en red", "cuenta": "partidas_red", "objetivo": 1, "bits": 80},
	{"id": "d_evolucion", "texto": "Evoluciona una herramienta", "cuenta": "evoluciones", "objetivo": 1, "bits": 70},
	{"id": "d_partidas", "texto": "Juega 3 partidas", "cuenta": "partidas", "objetivo": 3, "bits": 50},
	{"id": "d_fase2", "texto": "Llega a la fase 2", "cuenta": "fase2", "objetivo": 1, "bits": 100},
]
const SEMANALES := [
	{"id": "s_kernel", "texto": "Derrota a Kernel Panic 3 veces", "cuenta": "fase2", "objetivo": 3, "bits": 300},
	{"id": "s_dificil", "texto": "Gana una partida en difícil", "cuenta": "victoria_dificil", "objetivo": 1, "bits": 350},
	{"id": "s_eliminar", "texto": "Elimina 5000 malware", "cuenta": "eliminados", "objetivo": 5000, "bits": 300},
	{"id": "s_red", "texto": "Juega 3 partidas en red", "cuenta": "partidas_red", "objetivo": 3, "bits": 300},
	{"id": "s_victorias", "texto": "Gana 2 partidas", "cuenta": "victoria", "objetivo": 2, "bits": 300},
]
## La semanal de personaje (decisión de Alan, 19/11): una por semana, con más
## puntos, para ir hacia sus skins S y S+.
const DE_PERSONAJE := [
	{"id": "p_gana_mago", "texto": "Gana una partida acabando con el Mago", "cuenta": "victoria_con", "personaje": "Mago", "objetivo": 1, "bits": 300},
	{"id": "p_gana_espadachin", "texto": "Gana una partida acabando con el Espadachín", "cuenta": "victoria_con", "personaje": "Espadachín", "objetivo": 1, "bits": 300},
	{"id": "p_gana_segador", "texto": "Gana una partida acabando con el Segador", "cuenta": "victoria_con", "personaje": "Segador", "objetivo": 1, "bits": 300},
	{"id": "p_elimina_mago", "texto": "Elimina 2000 malware con el Mago", "cuenta": "eliminados_con", "personaje": "Mago", "objetivo": 2000, "bits": 300},
	{"id": "p_elimina_espadachin", "texto": "Elimina 2000 malware con el Espadachín", "cuenta": "eliminados_con", "personaje": "Espadachín", "objetivo": 2000, "bits": 300},
	{"id": "p_elimina_segador", "texto": "Elimina 2000 malware con el Segador", "cuenta": "eliminados_con", "personaje": "Segador", "objetivo": 2000, "bits": 300},
]
const PUNTOS_DIARIA := 60
const PUNTOS_SEMANAL := 250
const PUNTOS_DE_PERSONAJE := 350
const POR_TIPO := 3


## Las 3 diarias de ese día ("2026-11-19").
static func sortear_diarias(dia: String) -> Array:
	return _elegir(DIARIAS, POR_TIPO, "diarias " + dia)


## Las 3 semanales de esa semana (su lunes): 2 normales y 1 de personaje.
static func sortear_semanales(lunes: String) -> Array:
	return _elegir(SEMANALES, POR_TIPO - 1, "semanales " + lunes) + _elegir(DE_PERSONAJE, 1, "personaje " + lunes)


## Otra diaria para cambiar por una de ahora (que no esté ya), o "" si no hay.
static func otra_diaria(dia: String, ahora: Array) -> String:
	var libres := DIARIAS.filter(func(mision): return not mision.id in ahora)
	if libres.is_empty():
		return ""
	return _elegir(libres, 1, "cambio " + dia)[0]


## n ids distintos de la lista, siempre los mismos para la misma semilla. Con
## su propio RandomNumberGenerator: el azar de la partida no se toca.
static func _elegir(lista: Array, n: int, semilla: String) -> Array:
	var azar := RandomNumberGenerator.new()
	azar.seed = hash(semilla)
	var quedan := lista.map(func(mision): return mision.id)
	var elegidas := []
	while elegidas.size() < n and not quedan.is_empty():
		elegidas.append(quedan.pop_at(azar.randi_range(0, quedan.size() - 1)))
	return elegidas


## La misión con ese id, o {} si ya no existe (de una versión anterior).
static func por_id(id: String) -> Dictionary:
	for mision in DIARIAS + SEMANALES + DE_PERSONAJE:
		if mision.id == id:
			return mision
	return {}


static func tipo(id: String) -> String:
	return "diaria" if id.begins_with("d_") else "semanal"


static func puntos(id: String) -> int:
	if id.begins_with("p_"):
		return PUNTOS_DE_PERSONAJE
	return PUNTOS_DIARIA if id.begins_with("d_") else PUNTOS_SEMANAL


## Cuánto suma una partida a esa misión. partida: lo contado por
## contador_partida.gd con las estadísticas del final.
static func avance(mision: Dictionary, partida: Dictionary) -> int:
	match mision.cuenta:
		"eliminados_con":
			return partida.eliminados_con.get(mision.personaje, 0)
		"victoria_con":
			return 1 if partida.victoria and partida.personaje == mision.personaje else 0
		_:
			return partida.get(mision.cuenta, 0)


# --- Las de ahora, en el fichero de la cartera (sección [misiones]) ---


## Si ha cambiado el día o la semana, sortea las nuevas y empiezan de cero.
## Devuelve si ha cambiado algo (para guardar).
static func renovar(fichero: ConfigFile, dia: String) -> bool:
	var semana := lunes_de(dia)
	var cambia := false
	if fichero.get_value("misiones", "dia", "") != dia:
		fichero.set_value("misiones", "dia", dia)
		fichero.set_value("misiones", "diarias", sortear_diarias(dia))
		_olvidar(fichero, "diaria")
		cambia = true
	if fichero.get_value("misiones", "semana", "") != semana:
		fichero.set_value("misiones", "semana", semana)
		fichero.set_value("misiones", "semanales", sortear_semanales(semana))
		_olvidar(fichero, "semanal")
		cambia = true
	return cambia


## Olvida el progreso de todas las misiones de ese tipo y si estaban hechas.
## Todas, no solo las que se van: una diaria que vuelve a salir al día
## siguiente empieza de cero (hasta el 27/11 se quedaba con lo de ayer, ya
## hecha, y parecía que las misiones no se renovaban).
static func _olvidar(fichero: ConfigFile, de_tipo: String) -> void:
	var progreso: Dictionary = fichero.get_value("misiones", "progreso", {})
	for id in progreso.keys():
		if tipo(id) == de_tipo:
			progreso.erase(id)
	fichero.set_value("misiones", "progreso", progreso)
	var hechas: Array = fichero.get_value("misiones", "hechas", [])
	fichero.set_value("misiones", "hechas", hechas.filter(func(id): return tipo(id) != de_tipo))


static func de_ahora(fichero: ConfigFile) -> Array:
	return fichero.get_value("misiones", "diarias", []) + fichero.get_value("misiones", "semanales", [])


## Las de ahora para enseñarlas: [{id, texto, tipo, progreso, objetivo, bits, puntos, hecha}].
static func lista(fichero: ConfigFile) -> Array:
	var progreso: Dictionary = fichero.get_value("misiones", "progreso", {})
	var hechas: Array = fichero.get_value("misiones", "hechas", [])
	var resultado := []
	for id in de_ahora(fichero):
		var mision := por_id(id)
		if not mision.is_empty():
			resultado.append({"id": id, "texto": mision.texto, "tipo": tipo(id),
				"progreso": mini(progreso.get(id, 0), mision.objetivo), "objetivo": mision.objetivo,
				"bits": mision.bits, "puntos": puntos(id), "hecha": id in hechas})
	return resultado


## Cambia esa diaria (sin completar) por otra, si hoy no se ha cambiado ya.
static func cambiar(fichero: ConfigFile, id: String, dia: String) -> bool:
	var diarias: Array = fichero.get_value("misiones", "diarias", [])
	if fichero.get_value("misiones", "cambio_usado", "") == dia or not id in diarias \
			or id in fichero.get_value("misiones", "hechas", []):
		return false
	var otra := otra_diaria(dia, diarias)
	if otra == "":
		return false
	diarias[diarias.find(id)] = otra
	fichero.set_value("misiones", "diarias", diarias)
	fichero.set_value("misiones", "cambio_usado", dia)
	return true


## Suma una partida a las de ahora. Devuelve las que se acaban de completar:
## [{id, texto, tipo, bits, puntos}] (las cobra la cartera).
static func contar(fichero: ConfigFile, partida: Dictionary) -> Array:
	var progreso: Dictionary = fichero.get_value("misiones", "progreso", {})
	var hechas: Array = fichero.get_value("misiones", "hechas", [])
	var completadas := []
	for id in de_ahora(fichero):
		var mision := por_id(id)
		if mision.is_empty() or id in hechas:
			continue
		var suma := avance(mision, partida)
		progreso[id] = maxi(progreso.get(id, 0), suma) if mision.get("mejor", false) else progreso.get(id, 0) + suma
		if progreso[id] >= mision.objetivo:
			hechas.append(id)
			completadas.append({"id": id, "texto": mision.texto, "tipo": tipo(id), "bits": mision.bits, "puntos": puntos(id)})
	fichero.set_value("misiones", "progreso", progreso)
	fichero.set_value("misiones", "hechas", hechas)
	return completadas


## El lunes de la semana de ese día ("2026-11-19" → "2026-11-16").
static func lunes_de(dia: String) -> String:
	var unix := Time.get_unix_time_from_datetime_string(dia)
	# weekday: 0 es domingo; del lunes a ese día van (weekday + 6) % 7 días.
	var semana := int(Time.get_date_dict_from_unix_time(unix).weekday)
	return Time.get_date_string_from_unix_time(unix - ((semana + 6) % 7) * 86400)


static func ayer_de(dia: String) -> String:
	return Time.get_date_string_from_unix_time(Time.get_unix_time_from_datetime_string(dia) - 86400)
