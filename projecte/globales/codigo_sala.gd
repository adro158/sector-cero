extends RefCounted

## El código de una sala del multijugador: la IP del anfitrión en la red
## local, escrita con letras (plan_multijugador.md, «el código de sala»). El
## que crea la sala lo enseña y los demás lo escriben: nadie escribe una IP, y
## no hace falta que la red deje anunciar partidas (broadcast), que en el
## instituto puede estar cortado.
##
## Una IPv4 son 4 números de 0 a 255, 32 bits: en base 32 caben en 7 letras.
## Sin 0, O, 1 ni I, que se confunden al copiarlas. Ejemplo: 192.168.1.37 →
## «52CJ2B7» (se enseña como «52C-J2B7»).
##
## Sin class_name: se carga con preload.

const LETRAS := "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
const LARGO := 7


## De la IP («192.168.1.37») al código. "" si no es una IPv4.
static func de_ip(ip: String) -> String:
	var partes := ip.split(".")
	if partes.size() != 4:
		return ""
	var numero := 0
	for parte in partes:
		if not parte.is_valid_int() or int(parte) < 0 or int(parte) > 255:
			return ""
		numero = numero * 256 + int(parte)
	var codigo := ""
	for i in LARGO:
		codigo = LETRAS[numero % 32] + codigo
		numero /= 32
	return codigo


## Del código a la IP. Acepta minúsculas, espacios y guiones. "" si no vale.
static func a_ip(codigo: String) -> String:
	var limpio := codigo.to_upper().replace("-", "").replace(" ", "")
	if limpio.length() != LARGO:
		return ""
	var numero := 0
	for letra in limpio:
		var valor := LETRAS.find(letra)
		if valor == -1:
			return ""
		numero = numero * 32 + valor
	if numero > 0xFFFFFFFF:
		return ""
	return "%d.%d.%d.%d" % [(numero >> 24) & 255, (numero >> 16) & 255, (numero >> 8) & 255, numero & 255]


## Para enseñarlo: en dos trozos, más fácil de leer y de dictar.
static func bonito(codigo: String) -> String:
	return codigo.substr(0, 3) + "-" + codigo.substr(3)


## La IP de este ordenador en la red local: la primera de casa o de clase
## (192.168.x, 10.x, 172.16-31.x), sin la de bucle (127.x) ni las de sin red
## (169.254.x). "" si no hay ninguna.
static func ip_local() -> String:
	var candidatas := []
	for ip in IP.get_local_addresses():
		if ip.count(".") == 3 and not ip.begins_with("127.") and not ip.begins_with("169.254."):
			candidatas.append(ip)
	for prefijo in ["192.168.", "10.", "172."]:
		for ip in candidatas:
			if ip.begins_with(prefijo):
				return ip
	return candidatas[0] if not candidatas.is_empty() else ""
