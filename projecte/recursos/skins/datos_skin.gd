extends Resource

## Una skin de un personaje: otro aspecto con las mismas animaciones. Las hojas
## se llaman igual que en DatosPersonaje (hoja, hoja_ataque...), así que el
## código que pone las hojas del personaje sirve tal cual para las de su skin.
## Cada personaje lista las suyas en DatosPersonaje.skins y las da con skin().
## Es de Alan (equipo/reparto.md); los PNG, en medios/sprites/skins/.
##
## Sin class_name a propósito: una clase global nueva no llega con el .pck de
## actualización y obligaría a subir EJECUTABLE_MINIMO (CLAUDE.md). Se carga
## con preload("res://recursos/skins/datos_skin.gd").

## El personaje al que pertenece, como DatosPersonaje.nombre ("Mago"...).
@export var personaje: String = ""
## Su número: 1 es el aspecto original y las skins van del 2 en adelante,
## ordenadas de la categoría más baja a la más alta.
@export var numero: int = 2
@export var nombre: String = ""
## "C", "B", "A", "S" o "S+": cuanto más alta, más trabajada y más difícil de
## conseguir.
@export var categoria: String = "C"
@export_multiline var descripcion: String = ""

@export var hoja: Texture2D
@export var hoja_evolucion: Texture2D
@export var hoja_ataque: Texture2D
@export var hoja_ataque_evolucion: Texture2D
@export var hoja_correr_ataque: Texture2D
@export var hoja_correr_ataque_evolucion: Texture2D
@export var hoja_reposo: Texture2D
@export var hoja_reposo_evolucion: Texture2D

## 64x64 (panel del equipo, ventana de caída, resumen) y 32x32 (ranking y
## fichas del equipo).
@export var retrato: Texture2D
@export var retrato_mini: Texture2D


## El número de la skin que ha elegido el jugador de este ordenador para ese
## personaje (opción "skins" de GestorGuardado, {"Mago": 12}; sin elegir, la
## 1). Con int(): las opciones que bajan de la cuenta llegan del JSON como 12.0.
## Desde la tienda (19/11) solo vale una skin que se tenga (cartera.gd): si no,
## la original. load() y no preload(): así una skin no arrastra la cartera (y
## todos sus scripts) al cargarse.
static func numero_elegido(personaje: DatosPersonaje) -> int:
	var numero := int(GestorGuardado.opcion("skins").get(personaje.nombre, 1))
	var cartera: Node = load("res://globales/cartera.gd").actual
	if cartera != null and not cartera.tiene_skin(personaje.nombre, numero):
		return 1
	return numero


## Lo que lleva puesto ese personaje en este ordenador: su skin elegida o el
## propio personaje. Para la partida de un jugador y la interfaz.
static func elegida(personaje: DatosPersonaje) -> Resource:
	return personaje.skin(numero_elegido(personaje))
