extends RefCounted

## Lo que da una partida y la racha (de Alan, 19/11; plan_tienda.md, «Los
## números»). Aparte de cartera.gd para que ese no pase de ~200 líneas.
##
## Sin class_name: se carga con preload.

const Misiones := preload("res://globales/misiones.gd")
## La racha: bits por cada día seguido jugado, hasta un tope (decisión de
## Alan, 19/11: sin perder nada si se falla un día, solo empieza otra vez).
const RACHA_POR_DIA := 10
const RACHA_MAXIMA := 50


## Los bits y los puntos del pase de una partida. Sin estado: así se prueba
## sin nodo y el simulador la puede usar para calibrar los números.
static func de_partida(estadisticas: Dictionary) -> Dictionary:
	if estadisticas.get("trucos", false):
		return {"bits": 0, "puntos": 0}
	var tiempo: float = estadisticas.get("tiempo", 0.0)
	var victoria: bool = estadisticas.get("victoria", false)
	var minutos := int(tiempo / 60.0)
	var bits := 2.0 * minutos
	# Llegar a la fase 2 (derrotar a Kernel Panic) y ganar dan un poco más.
	if tiempo > 600.0 or victoria:
		bits += 10.0
	if victoria:
		bits += 25.0
	bits *= {"facil": 0.75, "dificil": 1.5}.get(estadisticas.get("dificultad", "media"), 1.0)
	var puntos := 10 * minutos
	# En red los puntos del pase valen el doble (decisión de Alan, 19/11).
	if estadisticas.get("en_red", false):
		puntos *= 2
	return {"bits": roundi(bits), "puntos": puntos}


## Los días seguidos jugando (0 si se ha roto: el último no es hoy ni ayer).
static func racha(fichero: ConfigFile, hoy: String) -> int:
	var ultimo: String = fichero.get_value("racha", "ultimo_dia", "")
	return fichero.get_value("racha", "dias", 0) if ultimo == hoy or ultimo == Misiones.ayer_de(hoy) else 0


## Apunta que hoy se ha jugado y devuelve los bits de la racha: solo en la
## primera partida del día.
static func contar_racha(fichero: ConfigFile, hoy: String) -> int:
	var ultimo: String = fichero.get_value("racha", "ultimo_dia", "")
	if ultimo == hoy:
		return 0
	var dias: int = fichero.get_value("racha", "dias", 0) + 1 if ultimo == Misiones.ayer_de(hoy) else 1
	fichero.set_value("racha", "ultimo_dia", hoy)
	fichero.set_value("racha", "dias", dias)
	return mini(RACHA_POR_DIA * dias, RACHA_MAXIMA)
