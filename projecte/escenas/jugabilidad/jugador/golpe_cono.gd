extends RefCounted

## Un golpe en cono, el del Firewall del Espadachín: sale del personaje hacia
## el enemigo más cercano y hace más daño cuanto más pegado está. Lo crea
## gestor_armas.gd en cada ataque y se lo pasa a danar_en_area de cada
## objetivo, que le pregunta con factor() cuánto daño le toca. Sin cono (el
## Escáner, los proyectiles, las ultis), danar_en_area sigue siendo un círculo
## con el daño entero.
##
## Sin class_name: se carga con preload, como embestida_horda.gd.

var centro: Vector2
## Hacia donde va el cono, de largo 1.
var direccion: Vector2
var alcance: float
## La mitad de su ángulo, en radianes: lo que se puede apartar de direccion.
var medio_angulo: float
## El daño, como parte del del arma, pegado al personaje y en el filo del
## alcance. En medio, repartido en línea recta.
var dano_pegado: float
var dano_filo: float
## La suma de los factores de todo lo que ha recibido daño: el daño hecho,
## en golpes enteros. La lleva cada objetivo al recibirlo (un ancla con otro
## personaje no lo recibe) y la usan el robo de vida y la resistencia del
## malware.
var golpes := 0.0


func _init(desde: Vector2, hacia: Vector2, largo: float, grados: float, pegado: float, filo: float) -> void:
	centro = desde
	direccion = hacia.normalized()
	alcance = largo
	medio_angulo = deg_to_rad(grados) / 2.0
	dano_pegado = pegado
	dano_filo = filo


## Por cuánto se multiplica el daño de algo de ese radio que está en punto: 0
## si queda fuera del cono.
func factor(punto: Vector2, radio_objetivo: float) -> float:
	var hacia := punto - centro
	# Lo que separa su borde del personaje: «pegado» es tocándole.
	var distancia := maxf(hacia.length() - radio_objetivo, 0.0)
	if distancia > alcance:
		return 0.0
	# Si el cono le roza el borde, también le da: se suma el ángulo que ocupa
	# visto desde el personaje. Uno encima del personaje siempre recibe.
	if hacia.length() > radio_objetivo:
		var ancho := atan2(radio_objetivo, hacia.length())
		if absf(direccion.angle_to(hacia)) > medio_angulo + ancho:
			return 0.0
	return lerpf(dano_pegado, dano_filo, distancia / alcance)
