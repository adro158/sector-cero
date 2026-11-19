extends RefCounted

## Lo que se puede conseguir además de bits y skins (de Alan, 19/11;
## documentacio/plan_tienda.md): títulos, marcos de la placa del nombre,
## estelas y temas de color del filtro CRT. Aquí solo están sus nombres y sus
## colores; cuáles se tienen lo guarda la cartera (sección [premios]) y cuál se
## lleva puesto, la opción "perfil" de GestorGuardado.
##
## Un premio es {tipo, ...}: {"tipo": "bits", "cantidad": 100},
## {"tipo": "skin", "personaje": "Mago", "numero": 10}, {"tipo": "paquete"} o
## {"tipo": "titulo"|"marco"|"estela"|"tema", "id": "..."}.
##
## Sin class_name: se carga con preload.

const TITULOS := {
	"t_novato": "Antivirus novato",
	"t_cazador": "Cazador de malware",
	"t_kernel": "Superviviente del Kernel",
	"t_exorcista": "Exorcista del NÚCLEO",
	"t_trio": "Trío perfecto",
	"t_companero": "Compañero fiel",
	"t_constante": "Constante",
	"t_coleccionista": "Coleccionista",
	"t_veterano": "Veterano de la Temporada 1",
}
## Los marcos tiñen la placa del nombre en red; las estelas y los temas, su
## color. Los demás datos (sus nombres), para la interfaz.
const MARCOS := {
	"m_verde": {"nombre": "Marco verde", "color": Color("#4DFF99")},
	"m_rosa": {"nombre": "Marco rosa", "color": Color("#FF4DD2")},
	"m_rojo": {"nombre": "Marco rojo", "color": Color("#FF4D66")},
	"m_oro": {"nombre": "Marco dorado", "color": Color("#FFC23D")},
}
const ESTELAS := {
	"e_datos": {"nombre": "Estela de datos", "color": Color("#00E5FF")},
	"e_vacio": {"nombre": "Estela del vacío", "color": Color("#BF73FF")},
	"e_fuego": {"nombre": "Estela de fuego", "color": Color("#FF8A3D")},
}
const TEMAS := {
	"te_verde": {"nombre": "CRT verde fósforo", "color": Color("#33FF66")},
	"te_ambar": {"nombre": "CRT ámbar", "color": Color("#FFB000")},
	"te_rosa": {"nombre": "CRT rosa neón", "color": Color("#FF4DD2")},
}
## La lista de cada tipo, para recorrerlas sin saber cuál es.
const LISTAS := {"titulo": TITULOS, "marco": MARCOS, "estela": ESTELAS, "tema": TEMAS}


## El nombre de un premio, para los avisos ("Skin Hacker del Mago", "Título
## «Constante»"...).
static func nombre(premio: Dictionary) -> String:
	match premio.tipo:
		"bits":
			return "%d bits" % premio.cantidad
		"paquete":
			return "Un paquete cifrado"
		"skin":
			var personaje: DatosPersonaje = load("res://recursos/personajes/datos/%s.tres" % _fichero_de(premio.personaje))
			var skin: Resource = personaje.skin(premio.numero)
			return "Skin %s del %s" % [skin.nombre, premio.personaje]
		"titulo":
			return "Título «%s»" % TITULOS.get(premio.id, premio.id)
		_:
			return LISTAS.get(premio.tipo, {}).get(premio.id, {}).get("nombre", premio.id)


## El nombre del .tres de un personaje («Espadachín» → espadachin).
static func _fichero_de(personaje: String) -> String:
	return personaje.to_lower().replace("í", "i")


# --- Lo conseguido, en el fichero de la cartera ---


## Guarda un premio conseguido (todos menos los bits, que suma la cartera).
static func dar(fichero: ConfigFile, premio: Dictionary) -> void:
	match premio.tipo:
		"skin":
			var tengo: Dictionary = fichero.get_value("skins", "tengo", {})
			var suyas: Array = tengo.get(premio.personaje, [])
			if not premio.numero in suyas:
				suyas.append(premio.numero)
			tengo[premio.personaje] = suyas
			fichero.set_value("skins", "tengo", tengo)
		"paquete":
			fichero.set_value("premios", "paquetes", fichero.get_value("premios", "paquetes", 0) + 1)
		"titulo", "marco", "estela", "tema":
			var seccion: String = premio.tipo + "s"
			var lista: Array = fichero.get_value("premios", seccion, [])
			if not premio.id in lista:
				lista.append(premio.id)
			fichero.set_value("premios", seccion, lista)


## Los de un tipo que se tienen ("titulo", "marco", "estela" o "tema"): sus ids.
static func conseguidos(fichero: ConfigFile, tipo: String) -> Array:
	return fichero.get_value("premios", tipo + "s", [])


## Cuántas skins se han conseguido (sin contar las originales).
static func skins_conseguidas(fichero: ConfigFile) -> int:
	var total := 0
	for suyas in fichero.get_value("skins", "tengo", {}).values():
		total += suyas.size()
	return total


# --- Lo que se lleva puesto (la opción "perfil" de GestorGuardado) ---


## Los tipos que se pueden llevar, en el orden de la pestaña PERFIL.
const DE_PERFIL := ["titulo", "marco", "estela", "icono", "tema"]


## Lo que lleva puesto el jugador de este ordenador, solo si lo tiene:
## {titulo, marco, estela, icono, tema} (vacío lo que no lleva). El icono es
## «Personaje:número», el retrato mini de una skin que se tiene (o la original).
static func perfil(cartera: Node) -> Dictionary:
	var puesto: Dictionary = GestorGuardado.opcion("perfil")
	var valido := {}
	for tipo in DE_PERFIL:
		var id: String = str(puesto.get(tipo, ""))
		valido[tipo] = id if id != "" and _lo_tiene(cartera, tipo, id) else ""
	return valido


static func _lo_tiene(cartera: Node, tipo: String, id: String) -> bool:
	if cartera == null:
		return false
	if tipo == "icono":
		var partes := id.split(":")
		return partes.size() == 2 and cartera.tiene_skin(partes[0], int(partes[1]))
	return id in cartera.conseguidos(tipo)


## El retrato mini de un icono («Mago:10»), o null si no vale.
static func textura_icono(id: String) -> Texture2D:
	var partes := id.split(":")
	if partes.size() != 2:
		return null
	var ruta := "res://recursos/personajes/datos/%s.tres" % _fichero_de(partes[0])
	if not ResourceLoader.exists(ruta):
		return null
	var personaje: DatosPersonaje = load(ruta)
	var aspecto: Resource = personaje.skin(int(partes[1]))
	if aspecto == personaje:
		return load("res://medios/interfaz/retrato_mini_%s.png" % _fichero_de(partes[0]))
	return aspecto.retrato_mini


## El color de un marco, una estela o un tema (o el que se pasa si no hay;
## los títulos son solo texto, sin color).
static func color(tipo: String, id: String, si_no: Color) -> Color:
	var datos: Variant = LISTAS.get(tipo, {}).get(id, {})
	return datos.get("color", si_no) if datos is Dictionary else si_no


## El perfil que llega en el saludo de la sala (red.gd), con solo lo que tiene
## sentido: los tipos de perfil, con un id de texto. Lo que no se conoce se
## dibuja como nada (color() y textura_icono() tienen su «si no»).
static func perfil_de_red(valor: Variant) -> Dictionary:
	var limpio := {}
	if valor is Dictionary:
		for tipo in DE_PERFIL:
			if valor.get(tipo, "") is String:
				limpio[tipo] = valor.get(tipo, "")
	return limpio
