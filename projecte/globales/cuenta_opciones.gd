extends Node

## Las opciones del jugador en su cuenta (05/11): volumen, CRT, texto grande,
## destellos, dificultad... iguales en cualquier ordenador donde entre. Al
## entrar se bajan las de la cuenta; si la cuenta aún no tiene, se suben las
## de este ordenador. Después, cada cambio se sube (los de un rato, juntos).
##
## Hijo de cuenta.gd, que es quien habla con Supabase. Sin class_name: se
## carga con preload.

## Las que dependen del ordenador y no del jugador: un monitor de 240 Hz o
## pantalla completa en uno no tienen por qué valer en otro.
const DE_ESTE_ORDENADOR := ["pantalla_completa", "limite_fps", "avisar_versiones"]
## Lo que se espera tras un cambio antes de subir: mover un deslizador de
## volumen da muchos cambios seguidos y se suben juntos.
const ESPERA_SUBIR := 2.0

var _cuenta: Node
## Mientras se aplican las bajadas de la cuenta, sus cambios no se suben.
var _aplicando := false
var _subida_pedida := false
## Si ya se han bajado las de la cuenta en esta sesión. Hasta entonces no se
## sube nada: se pisarían las de la cuenta con las de este ordenador.
var _bajadas := false
var _bajando := false


func _ready() -> void:
	_cuenta = get_parent()
	BusEventos.sesion_cambiada.connect(_al_entrar)
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)


func _al_entrar(nombre: String) -> void:
	if nombre == "":
		_bajadas = false
		return
	# sesion_cambiada llega también al renovar la sesión cada hora: solo se
	# bajan una vez, al entrar. Si falla (sin conexión), se reintenta en la
	# siguiente renovación.
	if _bajadas or _bajando or _cuenta.nombre != nombre:
		return
	_bajando = true
	var respuesta: Dictionary = await _cuenta.pedir(HTTPClient.METHOD_GET,
		"/rest/v1/opciones?usuario=eq.%s" % _cuenta.usuario(), null)
	_bajando = false
	if respuesta.codigo != 200 or not respuesta.datos is Array:
		return
	_bajadas = true
	if respuesta.datos.is_empty():
		_subir()
	else:
		_aplicar(respuesta.datos[0].datos)


func _aplicar(datos: Dictionary) -> void:
	_aplicando = true
	for clave in datos:
		if clave in GestorGuardado.OPCIONES_POR_DEFECTO and not clave in DE_ESTE_ORDENADOR and GestorGuardado.opcion(clave) != datos[clave]:
			GestorGuardado.cambiar_opcion(clave, datos[clave])
	_aplicando = false


func _al_cambiar_opcion(clave: String, _valor: Variant) -> void:
	if _aplicando or _subida_pedida or not _bajadas or _cuenta.nombre == "" or clave in DE_ESTE_ORDENADOR:
		return
	_subida_pedida = true
	# El cuarto argumento: cuenta también en pausa (se cambian desde la pausa).
	await get_tree().create_timer(ESPERA_SUBIR, true, false, true).timeout
	_subida_pedida = false
	_subir()


## Guarda las opciones de ahora en la cuenta: crea la fila o la cambia.
func _subir() -> void:
	if _cuenta.nombre == "":
		return
	var datos := {}
	for clave in GestorGuardado.OPCIONES_POR_DEFECTO:
		if not clave in DE_ESTE_ORDENADOR:
			datos[clave] = GestorGuardado.opcion(clave)
	await _cuenta.pedir(HTTPClient.METHOD_POST, "/rest/v1/opciones?on_conflict=usuario",
		{"usuario": _cuenta.usuario(), "datos": datos}, "resolution=merge-duplicates,return=minimal")
