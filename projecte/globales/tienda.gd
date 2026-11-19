extends RefCounted

## La tienda y los paquetes cifrados (de Alan, 19/11; plan_tienda.md): qué
## skin se vende y por cuánto, y el sorteo de un paquete. La cartera
## (cartera.gd) cobra los bits y guarda lo conseguido.
##
## En la tienda, las C, B y A (decisión de Adam, 19/11); las S y S+ solo salen
## en el pase. Un paquete da una skin C, B o A al azar, con las probabilidades
## a la vista; una repetida se devuelve en bits. Sin dinero real.
##
## Sin class_name: se carga con preload.

const PaseBatalla := preload("res://globales/pase_batalla.gd")
const PRECIOS := {"C": 300, "B": 600, "A": 1200}
const PRECIO_PAQUETE := 250
## La probabilidad de cada categoría en un paquete, en %.
const PROBABILIDADES := {"C": 60, "B": 30, "A": 10}
## Lo que se devuelve por una skin repetida de un paquete.
const DEVUELTOS := {"C": 60, "B": 150, "A": 400}
## Los personajes por su nombre, ya cargados: un paquete los recorre todos.
const DATOS := {
	"Mago": preload("res://recursos/personajes/datos/mago.tres"),
	"Espadachín": preload("res://recursos/personajes/datos/espadachin.tres"),
	"Segador": preload("res://recursos/personajes/datos/segador.tres"),
}


## Lo que cuesta esa skin en la tienda, o 0 si no se vende (la original, las
## del pase o una que no existe).
static func precio(personaje: String, numero: int) -> int:
	var skin := _skin(personaje, numero)
	if skin == null or PaseBatalla.es_del_pase(personaje, numero):
		return 0
	return PRECIOS.get(skin.categoria, 0)


## Dónde se consigue una skin, para el armario («En la tienda: 600 bits»...).
static func donde(personaje: String, numero: int) -> String:
	if precio(personaje, numero) > 0:
		return "En la tienda: %d bits, o en un paquete cifrado." % precio(personaje, numero)
	for nivel in range(1, PaseBatalla.NIVELES + 1):
		var premio := PaseBatalla.premio(nivel)
		if premio.tipo == "skin" and premio.personaje == personaje and premio.numero == numero:
			return "En el pase de batalla: nivel %d." % nivel
	return ""


## El sorteo de un paquete: una skin {personaje, numero, categoria}. azar: el
## de la cartera (nunca el global, que fija el simulador).
static func sortear(azar: RandomNumberGenerator) -> Dictionary:
	var tirada := azar.randi_range(1, 100)
	var categoria := "C" if tirada <= PROBABILIDADES.C else ("B" if tirada <= PROBABILIDADES.C + PROBABILIDADES.B else "A")
	var posibles := []
	for personaje in DATOS:
		for skin in DATOS[personaje].skins:
			if skin.categoria == categoria:
				posibles.append({"personaje": personaje, "numero": skin.numero, "categoria": categoria})
	return posibles[azar.randi_range(0, posibles.size() - 1)]


static func _skin(personaje: String, numero: int) -> Resource:
	var datos: DatosPersonaje = DATOS.get(personaje)
	var skin: Resource = datos.skin(numero) if datos != null else null
	return skin if skin != datos else null
