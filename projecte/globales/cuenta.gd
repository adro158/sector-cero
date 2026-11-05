extends Node

## Las cuentas de jugador (05/11, documentacio/plan_cuentas.md): crear una
## cuenta con usuario y contraseña, entrar, recordar la sesión y subir cada
## partida terminada a Supabase, que guarda las cuentas y las partidas. Sin
## cuenta se juega como invitado, como siempre; sin conexión, las partidas
## esperan en una cola y se suben más tarde.
##
## Habla con Supabase con peticiones HTTP normales (HTTPRequest), sin
## librerías. La contraseña nunca se guarda: solo el token de renovación que
## da Supabase al entrar.
##
## Lo crea Transicion al arrancar, como entrada.gd. Sin class_name: se carga
## con preload, y la ventana de la cuenta lo usa por Cuenta.actual. Las
## opciones del jugador las sube y las baja su hijo cuenta_opciones.gd.

## El proyecto de Supabase: su URL y la clave publicable (sb_publishable_...),
## que está hecha para ir dentro del juego; lo que protege los datos son las
## reglas por filas del SQL. Vacías, las cuentas no están activadas.
const URL := "https://ounawnkngqsgozvadufe.supabase.co"
const CLAVE := "sb_publishable_6tlMdkAvdfybL33FjGwoVw_iu0Pece4"
## Supabase pide un email: se inventa a partir del usuario. No se manda ningún
## correo, porque la confirmación está apagada en el proyecto.
const DOMINIO := "@sectorcero.app"
const RUTA := "user://cuenta.cfg"
## El mismo límite que pone el SQL a la tabla de perfiles.
const NOMBRE_VALIDO := "^[A-Za-z0-9_]{3,14}$"
const SIN_CONEXION := "Sin conexión con el servidor: puedes jugar como invitado."
const CuentaOpciones := preload("res://globales/cuenta_opciones.gd")

## Para que una petición espere a la renovación de la sesión que ya está en
## marcha (_renovar).
signal renovacion_terminada

static var actual: Node

## El nombre de la cuenta; vacío si se juega como invitado.
var nombre := ""
var _url := URL
var _clave := CLAVE
## El id de la cuenta en Supabase, el token de acceso (dura una hora), cuándo
## caduca (en segundos Unix) y el de renovación, que sirve para pedir otro.
var _usuario := ""
var _acceso := ""
var _caduca := 0.0
var _renovacion := ""
## Las partidas que faltan por subir, cada una con el id de su cuenta.
var _pendientes: Array = []
var _subiendo := false
var _renovando := false
var _fichero := ConfigFile.new()


func _ready() -> void:
	actual = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Para probar con un servidor local que imita a Supabase, sin tocar el
	# proyecto de verdad (como el de GitHub en la sesión 6). Solo desde Godot
	# (depuración): en el juego publicado no se puede mandar a otro servidor.
	for argumento in OS.get_cmdline_user_args():
		if OS.is_debug_build() and argumento.begins_with("supabase="):
			_url = argumento.trim_prefix("supabase=")
			_clave = "clave-de-prueba"
	_fichero.load(RUTA)
	nombre = _fichero.get_value("sesion", "nombre", "")
	_usuario = _fichero.get_value("sesion", "usuario", "")
	_renovacion = _fichero.get_value("sesion", "renovacion", "")
	_pendientes = _fichero.get_value("cola", "partidas", [])
	BusEventos.partida_terminada.connect(_al_terminar_partida)
	add_child(CuentaOpciones.new())
	if activada() and _renovacion != "":
		_arrancar.call_deferred()


## Con una sesión guardada: se renueva (así se sabe que sigue valiendo y se
## bajan las opciones de la cuenta) y se sube lo que quedara en la cola.
func _arrancar() -> void:
	# El simulador quita el servidor antes de que llegue aquí.
	if not activada():
		return
	if await _renovar():
		subir_pendientes()


func activada() -> bool:
	return _url != "" and _clave != ""


## El id de la cuenta en Supabase (vacío como invitado).
func usuario() -> String:
	return _usuario


## Devuelven el error para enseñarlo, o "" si ha ido bien.
func crear_cuenta(usuario: String, contrasena: String) -> String:
	var problema := _comprobar(usuario, contrasena)
	if problema != "":
		return problema
	var respuesta := await _pedir(HTTPClient.METHOD_POST, "/auth/v1/signup",
		{"email": usuario.to_lower() + DOMINIO, "password": contrasena, "data": {"nombre": usuario}})
	# El perfil lo crea un trigger del SQL: si el nombre ya existe con otras
	# mayúsculas, Supabase falla con un 500 (solo al crear la cuenta).
	if respuesta.codigo >= 500:
		return "Ese usuario ya existe o no se puede usar."
	if respuesta.codigo == 0 or respuesta.codigo >= 400:
		return _error(respuesta)
	# Con la confirmación apagada, ya viene con la sesión; si no, se entra.
	if respuesta.datos is Dictionary and respuesta.datos.has("access_token"):
		_guardar_sesion(respuesta.datos)
		return ""
	return await entrar(usuario, contrasena)


func entrar(usuario: String, contrasena: String) -> String:
	var problema := _comprobar(usuario, contrasena)
	if problema != "":
		return problema
	var respuesta := await _pedir(HTTPClient.METHOD_POST, "/auth/v1/token?grant_type=password",
		{"email": usuario.to_lower() + DOMINIO, "password": contrasena})
	if respuesta.codigo == 0 or respuesta.codigo >= 400:
		return _error(respuesta)
	_guardar_sesion(respuesta.datos)
	return ""


## Las partidas que esperan en la cola no se pierden: se suben cuando vuelva a
## entrar la misma cuenta.
func salir() -> void:
	nombre = ""
	_usuario = ""
	_acceso = ""
	_renovacion = ""
	_guardar()
	BusEventos.sesion_cambiada.emit("")


## Las últimas partidas de la cuenta, de la más nueva a la más vieja. Vacío
## sin cuenta o sin conexión.
func mis_partidas() -> Array:
	if nombre == "" or not activada():
		return []
	var respuesta := await pedir(HTTPClient.METHOD_GET,
		"/rest/v1/partidas?usuario=eq.%s&order=jugada.desc&limit=8" % _usuario, null)
	return respuesta.datos if respuesta.codigo == 200 and respuesta.datos is Array else []


## Los récords y las estadísticas de la cuenta, que calcula el servidor con
## sus partidas (la vista estadisticas del SQL). Vacío si no hay.
func mis_estadisticas() -> Dictionary:
	if nombre == "" or not activada():
		return {}
	var respuesta := await pedir(HTTPClient.METHOD_GET, "/rest/v1/estadisticas?usuario=eq.%s" % _usuario, null)
	if respuesta.codigo == 200 and respuesta.datos is Array and not respuesta.datos.is_empty():
		return respuesta.datos[0]
	return {}


## Las partidas con trucos (F1) no cuentan, como en los récords.
func _al_terminar_partida(estadisticas: Dictionary) -> void:
	if nombre == "" or estadisticas.get("trucos", false):
		return
	_pendientes.append({
		"usuario": _usuario,
		"jugada": _ahora(),
		"victoria": estadisticas.victoria,
		"tiempo": estadisticas.tiempo,
		"nivel": estadisticas.nivel,
		"eliminados": estadisticas.eliminados,
		"personaje": estadisticas.personaje,
		"dificultad": estadisticas.dificultad,
		"donde": estadisticas.get("donde", ""),
		"version": Version.ACTUAL,
	})
	_guardar()
	subir_pendientes()


## Sube las de esta cuenta, de una en una, también las que lleguen mientras
## sube. Si una falla (sin conexión), para y se vuelve a intentar al arrancar,
## al entrar o al acabar otra partida.
func subir_pendientes() -> void:
	if _subiendo or nombre == "" or not activada():
		return
	_subiendo = true
	var partida := _siguiente_pendiente()
	while not partida.is_empty():
		var respuesta := await pedir(HTTPClient.METHOD_POST, "/rest/v1/partidas", partida)
		# 409: ya estaba (se subió pero se perdió la respuesta; el SQL no deja
		# guardar dos veces la misma partida).
		if respuesta.codigo != 201 and respuesta.codigo != 409:
			break
		_pendientes.erase(partida)
		_guardar()
		partida = _siguiente_pendiente()
	_subiendo = false


## La fecha y hora de ahora (UTC) con la fracción de segundo, en el formato de
## Postgres (el reloj de Windows da milisegundos). Con ella el SQL reconoce una
## partida repetida (unique (usuario, jugada)): con solo segundos, dos
## partidas acabadas en el mismo segundo se tomarían por la misma.
func _ahora() -> String:
	var ahora := Time.get_unix_time_from_system()
	var microsegundos := int(fmod(ahora, 1.0) * 1000000.0)
	return "%s.%06dZ" % [Time.get_datetime_string_from_unix_time(int(ahora)), microsegundos]


## La primera partida de la cola que es de esta cuenta (vacía si no hay).
func _siguiente_pendiente() -> Dictionary:
	for partida in _pendientes:
		if partida.usuario == _usuario:
			return partida
	return {}


## Un token de acceso nuevo con el de renovación. Si Supabase lo rechaza (400
## o 401), la sesión se cierra. Con cualquier otro fallo (sin conexión, un 429
## o un 503 de un mantenimiento) se sigue con la cuenta y se reintenta más
## tarde: no se echa a nadie por un fallo pasajero.
## Solo una a la vez: cada token de renovación vale una vez, y si dos
## peticiones lo gastaran juntas Supabase podría cerrar la sesión. La
## segunda espera a la primera.
func _renovar() -> bool:
	if _renovando:
		await renovacion_terminada
		return Time.get_unix_time_from_system() < _caduca
	_renovando = true
	var token := _renovacion
	var respuesta := await _pedir(HTTPClient.METHOD_POST, "/auth/v1/token?grant_type=refresh_token",
		{"refresh_token": token})
	var bien: bool = respuesta.codigo > 0 and respuesta.codigo < 400
	# Si mientras esperaba se ha salido o se ha entrado con otra cuenta, esta
	# respuesta ya no vale: no tiene que volver a meter la sesión vieja.
	if _renovacion != token:
		bien = false
	elif bien:
		_guardar_sesion(respuesta.datos)
	elif respuesta.codigo == 400 or respuesta.codigo == 401:
		salir()
	_renovando = false
	renovacion_terminada.emit()
	return bien


func _guardar_sesion(datos: Dictionary) -> void:
	_acceso = datos.access_token
	_renovacion = datos.refresh_token
	_caduca = Time.get_unix_time_from_system() + float(datos.expires_in)
	_usuario = datos.user.id
	# El nombre como se escribió al crear la cuenta, con sus mayúsculas.
	nombre = datos.user.user_metadata.get("nombre", "")
	_guardar()
	BusEventos.sesion_cambiada.emit(nombre)
	subir_pendientes.call_deferred()


func _guardar() -> void:
	_fichero.set_value("sesion", "nombre", nombre)
	_fichero.set_value("sesion", "usuario", _usuario)
	_fichero.set_value("sesion", "renovacion", _renovacion)
	_fichero.set_value("cola", "partidas", _pendientes)
	_fichero.save(RUTA)


## Una petición a Supabase. Devuelve el código HTTP (0 si no hay conexión) y
## la respuesta ya leída del JSON. Las de datos (/rest/) van con el token de
## la cuenta; como dura una hora, si va a caducar antes se pide otro.
## preferencia: la cabecera Prefer de Supabase (return=minimal: que no
## devuelva lo que se ha guardado; resolution=merge-duplicates: guardar
## encima si ya existe).
func pedir(metodo: HTTPClient.Method, ruta: String, cuerpo: Variant, preferencia := "return=minimal") -> Dictionary:
	if ruta.begins_with("/rest/") and Time.get_unix_time_from_system() > _caduca - 60.0 and not await _renovar():
		return {"codigo": 0, "datos": null}
	return await _pedir(metodo, ruta, cuerpo, preferencia)


func _pedir(metodo: HTTPClient.Method, ruta: String, cuerpo: Variant, preferencia := "return=minimal") -> Dictionary:
	var cabeceras := PackedStringArray(["apikey: " + _clave, "Content-Type: application/json"])
	if ruta.begins_with("/rest/"):
		cabeceras.append("Authorization: Bearer " + _acceso)
		cabeceras.append("Prefer: " + preferencia)
	var peticion := HTTPRequest.new()
	peticion.timeout = 10.0
	add_child(peticion)
	var texto := "" if cuerpo == null else JSON.stringify(cuerpo)
	if peticion.request(_url + ruta, cabeceras, metodo, texto) != OK:
		peticion.queue_free()
		return {"codigo": 0, "datos": null}
	# [resultado, código, cabeceras, cuerpo]
	var respuesta: Array = await peticion.request_completed
	peticion.queue_free()
	if respuesta[0] != HTTPRequest.RESULT_SUCCESS:
		return {"codigo": 0, "datos": null}
	var cuerpo_respuesta: String = respuesta[3].get_string_from_utf8()
	return {"codigo": respuesta[1], "datos": JSON.parse_string(cuerpo_respuesta) if cuerpo_respuesta != "" else null}


func _comprobar(usuario: String, contrasena: String) -> String:
	if not activada():
		return "Las cuentas todavía no están activadas en este juego."
	if RegEx.create_from_string(NOMBRE_VALIDO).search(usuario) == null:
		return "El usuario tiene que tener de 3 a 14 letras, números o _ (sin tildes ni espacios)."
	if contrasena.length() < 6:
		return "La contraseña tiene que tener al menos 6 caracteres."
	return ""


## Los errores de Supabase, en castellano.
func _error(respuesta: Dictionary) -> String:
	if respuesta.codigo == 0:
		return SIN_CONEXION
	var codigo: String = respuesta.datos.get("error_code", "") if respuesta.datos is Dictionary else ""
	match codigo:
		"user_already_exists":
			return "Ese usuario ya existe."
		"invalid_credentials":
			return "Usuario o contraseña incorrectos."
		"weak_password":
			return "La contraseña es demasiado débil."
		"over_request_rate_limit":
			return "Demasiados intentos seguidos: espera un poco."
	if respuesta.codigo >= 500:
		return "El servidor no responde bien: prueba más tarde o juega sin cuenta."
	return "No se ha podido (error %d)." % respuesta.codigo
