extends RefCounted

## Lo que hace la cartera al acabar una partida (de Alan, 19/11;
## plan_tienda.md): los bits de la partida y de la racha, las misiones
## cumplidas, los niveles nuevos del pase con sus premios y los logros. Aparte
## de cartera.gd para que ese no pase de ~200 líneas.
##
## Sin class_name: se carga con preload.

const Misiones := preload("res://globales/misiones.gd")
const PaseBatalla := preload("res://globales/pase_batalla.gd")
const Logros := preload("res://globales/logros.gd")
const Premios := preload("res://globales/premios.gd")
const Recompensa := preload("res://globales/recompensa.gd")
## Si el pase da una skin que ya se tenía (comprada), se devuelve en bits.
const BITS_POR_REPETIDA := 300


## Cobra una partida en la cartera y devuelve lo ganado, para la pantalla
## final: {bits, puntos, racha, misiones, niveles, premios, sin_recompensa}.
## partida: lo contado (contador_partida.gd) con las estadísticas del final.
static func cobrar(cartera: Node, estadisticas: Dictionary, partida: Dictionary) -> Dictionary:
	var ganancia := vacia()
	# Con el menú de desarrollador se puede hacer cualquier cosa: no cuenta.
	if estadisticas.get("trucos", false):
		ganancia.sin_recompensa = true
		return ganancia
	var fichero: ConfigFile = cartera._fichero
	var de_la_partida := Recompensa.de_partida(estadisticas)
	ganancia.racha = Recompensa.contar_racha(fichero, cartera.hoy())
	ganancia.bits = de_la_partida.bits + ganancia.racha
	ganancia.puntos = de_la_partida.puntos
	Misiones.renovar(fichero, cartera.hoy())
	for mision in Misiones.contar(fichero, partida):
		ganancia.bits += mision.bits
		ganancia.puntos += mision.puntos
		ganancia.misiones.append(mision)
		cartera.mision_completada.emit(mision)
	cartera._sumar_bits(ganancia.bits)
	# El pase: cada nivel nuevo da su premio solo.
	for nivel in PaseBatalla.sumar(fichero, ganancia.puntos):
		ganancia.niveles.append(nivel)
		dar(cartera, PaseBatalla.premio(nivel), ganancia)
	var estado := PaseBatalla.estado(fichero)
	cartera.pase_cambiado.emit(estado.nivel, estado.en_el_nivel, estado.necesarios)
	for logro in Logros.contar(fichero, partida, cartera.racha(), Premios.skins_conseguidas(fichero)):
		ganancia.premios.append({"nombre": "Logro: %s" % logro.texto})
		dar(cartera, {"tipo": "titulo", "id": logro.titulo}, ganancia)
	return ganancia


## Da un premio del pase o de un logro y lo apunta en la ganancia. Una skin
## que ya se tenía (comprada antes) se devuelve en bits.
static func dar(cartera: Node, premio: Dictionary, ganancia: Dictionary) -> void:
	if premio.tipo == "skin" and cartera.tiene_skin(premio.personaje, premio.numero):
		premio = {"tipo": "bits", "cantidad": BITS_POR_REPETIDA}
	if premio.tipo == "bits":
		cartera._sumar_bits(premio.cantidad)
	else:
		Premios.dar(cartera._fichero, premio)
	var conseguido := premio.duplicate()
	conseguido.nombre = Premios.nombre(premio)
	ganancia.premios.append(conseguido)
	cartera.premio_conseguido.emit(conseguido)


static func vacia() -> Dictionary:
	return {"bits": 0, "puntos": 0, "racha": 0, "misiones": [], "niveles": [], "premios": [], "sin_recompensa": false}
