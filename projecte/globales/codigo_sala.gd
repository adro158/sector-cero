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


## Del código a la IP. Acepta minúsculas, espacios y guiones, y también la IP
## escrita tal cual («10.1.2.3»): por si el código lleva una que no es (la sala
## enseña su IP debajo del código). "" si no vale.
static func a_ip(codigo: String) -> String:
	if de_ip(codigo.strip_edges()) != "":
		return codigo.strip_edges()
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


## Redes que crea el propio ordenador y a las que no llega nadie de fuera: las
## de VirtualBox (192.168.56.x y la NAT de una máquina virtual, 10.0.2.x), la
## de KVM en Linux (192.168.122.x) y la de Docker (172.17.x).
const VIRTUALES := ["192.168.56.", "10.0.2.", "192.168.122.", "172.17."]
## Adaptadores virtuales, por su nombre en Linux (docker0, virbr0, vboxnet0,
## tun0 de una VPN...) y por el que enseña Windows. Sus IP tampoco sirven.
const NOMBRES_VIRTUALES := ["docker", "br-", "veth", "virbr", "vboxnet", "vmnet", "tun", "tap", "tailscale", "zt", "lxc", "lxd", "podman"]
const NOMBRES_WINDOWS_VIRTUALES := ["virtualbox", "vmware", "vethernet", "hyper-v", "wsl"]


## Para enseñarlo: en dos trozos, más fácil de leer y de dictar.
static func bonito(codigo: String) -> String:
	return codigo.substr(0, 3) + "-" + codigo.substr(3)


## La IP de este ordenador en la red local: la primera de casa o de clase
## (192.168.x, 10.x, 172.16-31.x), sin la de bucle (127.x) ni las de sin red
## (169.254.x). Las de redes y adaptadores virtuales, solo si no hay otra: en
## un Linux con Docker o KVM, o un PC con VirtualBox, el código llevaría a una
## red a la que nadie llega (el 17/11 en clase no se pudo entrar en la sala). "" si no hay ninguna.
static func ip_local() -> String:
	var reales := []
	var virtuales := []
	for interfaz in IP.get_local_interfaces():
		var virtual := _adaptador_virtual(interfaz.name, interfaz.friendly)
		for ip in interfaz.addresses:
			if ip.count(".") != 3 or ip.begins_with("127.") or ip.begins_with("169.254."):
				continue
			if virtual or VIRTUALES.any(func(prefijo): return ip.begins_with(prefijo)):
				virtuales.append(ip)
			else:
				reales.append(ip)
	for prefijo in ["192.168.", "10.", "172."]:
		for ip in reales:
			if ip.begins_with(prefijo):
				return ip
	if not reales.is_empty():
		return reales[0]
	return virtuales[0] if not virtuales.is_empty() else ""


static func _adaptador_virtual(nombre: String, nombre_windows: String) -> bool:
	if NOMBRES_VIRTUALES.any(func(inicio): return nombre.to_lower().begins_with(inicio)):
		return true
	return NOMBRES_WINDOWS_VIRTUALES.any(func(trozo): return nombre_windows.to_lower().contains(trozo))
