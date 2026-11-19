extends RefCounted

## El pase de batalla, Temporada 1 (de Alan, 19/11; plan_tienda.md): 30
## niveles de 300 puntos, un solo carril y gratis, sin fecha de caducidad. Los
## puntos salen de jugar (10 por minuto, el doble en red) y de las misiones.
## Al subir de nivel su premio se da solo (cartera.gd).
##
## Las skins S y S+ de los tres personajes solo se consiguen aquí (decisión de
## Adam, 19/11); entre medias, bits, paquetes cifrados, títulos, marcos,
## estelas y temas (premios.gd).
##
## Sin class_name: se carga con preload.

const TEMPORADA := 1
const NIVELES := 30
const PUNTOS_POR_NIVEL := 300
## El premio de cada nivel (el índice 0 es el nivel 1).
const PREMIOS := [
	{"tipo": "bits", "cantidad": 100},
	{"tipo": "titulo", "id": "t_novato"},
	{"tipo": "paquete"},
	{"tipo": "bits", "cantidad": 150},
	{"tipo": "skin", "personaje": "Mago", "numero": 10},
	{"tipo": "estela", "id": "e_datos"},
	{"tipo": "bits", "cantidad": 150},
	{"tipo": "skin", "personaje": "Espadachín", "numero": 10},
	{"tipo": "marco", "id": "m_verde"},
	{"tipo": "tema", "id": "te_verde"},
	{"tipo": "skin", "personaje": "Segador", "numero": 10},
	{"tipo": "bits", "cantidad": 200},
	{"tipo": "paquete"},
	{"tipo": "skin", "personaje": "Mago", "numero": 11},
	{"tipo": "marco", "id": "m_rosa"},
	{"tipo": "bits", "cantidad": 200},
	{"tipo": "skin", "personaje": "Espadachín", "numero": 11},
	{"tipo": "estela", "id": "e_vacio"},
	{"tipo": "tema", "id": "te_ambar"},
	{"tipo": "skin", "personaje": "Segador", "numero": 11},
	{"tipo": "bits", "cantidad": 250},
	{"tipo": "marco", "id": "m_rojo"},
	{"tipo": "paquete"},
	{"tipo": "skin", "personaje": "Mago", "numero": 12},
	{"tipo": "estela", "id": "e_fuego"},
	{"tipo": "tema", "id": "te_rosa"},
	{"tipo": "skin", "personaje": "Espadachín", "numero": 12},
	{"tipo": "marco", "id": "m_oro"},
	{"tipo": "titulo", "id": "t_veterano"},
	{"tipo": "skin", "personaje": "Segador", "numero": 12},
]


## El nivel que da ese total de puntos (0 sin ninguno; como mucho, NIVELES).
static func nivel(puntos: int) -> int:
	return mini(puntos / PUNTOS_POR_NIVEL, NIVELES)


static func premio(de_nivel: int) -> Dictionary:
	return PREMIOS[de_nivel - 1]


## Si esa skin sale en el pase (las S y S+): no se vende en la tienda.
static func es_del_pase(personaje: String, numero: int) -> bool:
	for uno in PREMIOS:
		if uno.tipo == "skin" and uno.personaje == personaje and uno.numero == numero:
			return true
	return false


## Cómo va, para la pestaña: {nivel, puntos, en_el_nivel, necesarios, maximo}.
## en_el_nivel: los puntos que lleva hacia el siguiente.
static func estado(fichero: ConfigFile) -> Dictionary:
	var puntos: int = fichero.get_value("pase", "puntos", 0)
	var actual := nivel(puntos)
	return {"nivel": actual, "puntos": puntos, "maximo": NIVELES,
		"en_el_nivel": 0 if actual == NIVELES else puntos % PUNTOS_POR_NIVEL,
		"necesarios": 0 if actual == NIVELES else PUNTOS_POR_NIVEL}


## Suma puntos y devuelve los niveles nuevos cuyo premio aún no se ha dado
## (los da la cartera). Si la temporada cambia, los puntos vuelven a cero.
static func sumar(fichero: ConfigFile, puntos: int) -> Array:
	if fichero.get_value("pase", "temporada", TEMPORADA) != TEMPORADA:
		fichero.set_value("pase", "puntos", 0)
		fichero.set_value("pase", "nivel_dado", 0)
	fichero.set_value("pase", "temporada", TEMPORADA)
	fichero.set_value("pase", "puntos", fichero.get_value("pase", "puntos", 0) + puntos)
	var dado: int = fichero.get_value("pase", "nivel_dado", 0)
	var nuevo := nivel(fichero.get_value("pase", "puntos"))
	fichero.set_value("pase", "nivel_dado", maxi(dado, nuevo))
	return range(dado + 1, nuevo + 1)
