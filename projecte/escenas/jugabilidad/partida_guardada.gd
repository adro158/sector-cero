extends RefCounted

## Dejar una partida a medias y seguirla otro día (Adam, 24/11). Se guarda lo
## que hace falta para seguir con lo mismo, no la foto exacta de la pantalla:
## - el minuto, la fase y la dificultad
## - el nivel, la experiencia y cuántas veces se ha cogido cada mejora
## - cada personaje con su vida, su máximo, si ha caído y la carga de su ulti,
##   y el que se llevaba
## - la resistencia del malware, los eliminados y si se usó el F1
##
## Al continuar, la partida empieza en ese minuto (como el F1, saltar_a) y se
## le vuelven a dar las mejoras (las evoluciones, también). La horda vuelve a
## salir sola, como a ese minuto; con un jefe en juego, su combate empieza de
## nuevo: NÚCLEO CERO cambia de forma según su vida y ponérsela a mano podría
## saltarse alguna. Guardar la horda, los proyectiles y los ataques a medias
## tocaría casi todos los scripts de la partida.
##
## Se guarda en este ordenador (user://) y, con cuenta, también en Supabase
## (la tabla partida_guardada, plan_cuentas.md): así se puede empezar en clase
## y seguir en casa. Al continuar se borra de los dos sitios. Solo con un
## jugador. Sin class_name: se carga con preload.

const Dificultad := preload("res://globales/dificultad.gd")
const Cuenta := preload("res://globales/cuenta.gd")
const RUTA := "user://partida_guardada.json"
## La partida a continuar, apuntada en la raíz del árbol para la escena nueva
## (como el salto del F1, panel_trucos.gd).
const CONTINUAR := "partida_a_continuar"


## Lo que se guarda de la partida que se está jugando. raiz: RaizJuego.
static func datos(raiz: Node) -> Dictionary:
	var director: Node = raiz.get_node("DirectorOleadas")
	var niveles: Node = raiz.get_node("SistemaNiveles")
	var cambio: Node = raiz.get_node("Jugador/CambioPersonaje")
	var equipo: RefCounted = cambio._equipo
	var mejoras := {}
	var veces: Dictionary = niveles.veces_por_mejora()
	for mejora in veces:
		mejoras[mejora.resource_path] = veces[mejora]
	# Con un jefe en juego, el reloj está parado en su minuto: al continuar
	# desde ahí, el director lo vuelve a sacar.
	return {
		"fecha": Time.get_unix_time_from_system(),
		"dificultad": Dificultad.actual(),
		"segundos": director.tiempo(),
		"fase": director.fase(),
		"nivel": niveles.nivel(),
		"experiencia": niveles.experiencia(),
		"mejoras": mejoras,
		"vidas": equipo.vidas.duplicate(),
		"maximas": equipo.maximas.duplicate(),
		"caidos": equipo.caidos.duplicate(),
		"cargas": equipo.cargas.duplicate(),
		"activo": cambio.indice_actual(),
		"vida_activo": cambio.salud().vida(),
		"resistencias": raiz.get_node("ResistenciaMalware").datos_red(),
		"eliminados": raiz.eliminados(),
		"trucos": raiz.con_trucos(),
	}


## Al empezar la partida, con lo guardado. Se llama un fotograma después de su
## _ready, cuando ya está todo (raiz_juego.gd).
static func continuar(raiz: Node, guardada: Dictionary) -> void:
	if guardada.trucos:
		raiz.usar_trucos()
	raiz.get_node("DirectorOleadas").saltar_a(guardada.segundos, int(guardada.fase))
	var niveles: Node = raiz.get_node("SistemaNiveles")
	niveles.poner_nivel(int(guardada.nivel), int(guardada.experiencia))
	# Las mejoras, otra vez (sus efectos se suman, así que el orden no
	# importa). La vida máxima la cambian algunas: el equipo va después.
	for ruta in guardada.mejoras:
		var mejora: DatosMejora = load(ruta)
		for vez in int(guardada.mejoras[ruta]):
			niveles.regalar(mejora)
	# Primero el personaje que se llevaba: al cambiar, tomar() apunta la vida
	# del que deja, y pisaría la guardada si fuera después.
	var cambio: Node = raiz.get_node("Jugador/CambioPersonaje")
	cambio.tomar(int(guardada.activo))
	var equipo: RefCounted = cambio._equipo
	equipo.maximas.assign(guardada.maximas)
	equipo.vidas.assign(guardada.vidas)
	equipo.caidos.assign(guardada.caidos)
	cambio.salud().poner(guardada.vida_activo, equipo.maximas[int(guardada.activo)])
	raiz.get_node("Jugador/Ultis").poner_cargas(guardada.cargas)
	raiz.get_node("ResistenciaMalware").poner_desde_red(guardada.resistencias)
	raiz.poner_eliminados(int(guardada.eliminados))


## «minuto 7:32 · nivel 9 · MEDIA», para el botón CONTINUAR.
static func resumen(guardada: Dictionary) -> String:
	var segundos := int(guardada.segundos)
	var dificultad: Dictionary = Dificultad.DIFICULTADES.get(guardada.dificultad, Dificultad.DIFICULTADES.media)
	return "minuto %d:%02d · nivel %d · %s" % [segundos / 60, segundos % 60, int(guardada.nivel), dificultad.nombre]


## Guarda aquí y, con cuenta, en Supabase. La subida va sola: no hace falta
## esperarla para volver al menú (la hace la cuenta, que no se borra).
static func guardar(guardada: Dictionary) -> void:
	var fichero := FileAccess.open(RUTA, FileAccess.WRITE)
	if fichero != null:
		fichero.store_string(JSON.stringify(guardada))
	if _con_cuenta():
		Cuenta.actual.pedir(HTTPClient.METHOD_POST, "/rest/v1/partida_guardada?on_conflict=usuario",
			{"usuario": Cuenta.actual.usuario(), "datos": guardada}, "resolution=merge-duplicates,return=minimal")


## La guardada más nueva: la de este ordenador o, con cuenta, la de Supabase
## (empezada en otro ordenador). Vacío si no hay ninguna.
static func cargar() -> Dictionary:
	var aqui := _de_este_ordenador()
	if not _con_cuenta():
		return aqui
	var respuesta: Dictionary = await Cuenta.actual.pedir(HTTPClient.METHOD_GET,
		"/rest/v1/partida_guardada?usuario=eq.%s" % Cuenta.actual.usuario(), null)
	if respuesta.codigo != 200 or not respuesta.datos is Array or respuesta.datos.is_empty():
		return aqui
	var en_la_cuenta: Dictionary = respuesta.datos[0].datos
	return en_la_cuenta if aqui.is_empty() or float(en_la_cuenta.fecha) > float(aqui.fecha) else aqui


## La de este ordenador, sin esperar a la cuenta.
static func _de_este_ordenador() -> Dictionary:
	if not FileAccess.file_exists(RUTA):
		return {}
	var leido: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	return leido if leido is Dictionary and leido.has("segundos") else {}


## Al continuar: fuera de los dos sitios, para no seguir la misma dos veces.
static func borrar() -> void:
	if FileAccess.file_exists(RUTA):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA))
	if _con_cuenta():
		Cuenta.actual.pedir(HTTPClient.METHOD_DELETE, "/rest/v1/partida_guardada?usuario=eq.%s" % Cuenta.actual.usuario(), null)


static func _con_cuenta() -> bool:
	return Cuenta.actual != null and Cuenta.actual.activada() and Cuenta.actual.nombre != ""
