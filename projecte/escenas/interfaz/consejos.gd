extends Label

## Consejos en las primeras partidas: una línea pequeña encima de la barra del
## equipo, una sola vez por partida cada uno, cuando pasa lo que explican
## (moverse, los fragmentos, la adaptación del malware, la ulti, el cofre, la
## jaula y el escudo). Quien no lee las reglas (el tribunal jugando un par de minutos) se
## perdía el elemento diferencial (mejoras propuestas, jugabilidad 10).
##
## Salen en las PRIMERAS_PARTIDAS primeras partidas y con la opción
## «Consejos» encendida. Solo lee el guardado: no escribe nada.
##
## Lo crea hud.gd. Sin class_name: se carga con preload.

const PRIMERAS_PARTIDAS := 3
## Lo que se ve cada consejo.
const DURA := 5.0
const APAGADO := 0.6

## Los consejos que ya han salido en esta partida.
var _dados := {}
## Los que esperan a que acabe el de ahora.
var _cola: Array[String] = []
var _tiempo := -1.0


func _ready() -> void:
	add_theme_font_size_override("font_size", EstiloInterfaz.tamano_texto(16))
	add_theme_color_override("font_color", EstiloInterfaz.NEON)
	# Con contorno: va encima de la placa base, que tiene muchas líneas.
	add_theme_constant_override("outline_size", 6)
	add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.07))
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	offset_left = -560.0
	offset_right = 560.0
	# Encima de la barra del equipo (barra_equipo.gd), que empieza a -158.
	offset_top = -186.0
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	if not GestorGuardado.opcion("consejos") or GestorGuardado.record("partidas") >= PRIMERAS_PARTIDAS:
		return

	_dar.call_deferred("moverse", "Te mueves con WASD, las flechas o el stick; tu herramienta ataca sola.")
	BusEventos.enemigo_muerto.connect(func(_posicion, _tipo): _dar("fragmentos", "El malware suelta fragmentos de datos: recógelos antes de 30 s para subir de nivel."))
	BusEventos.malware_adaptado.connect(func(_arma, _resistencia): _dar("adaptarse", "Cuanto más usas una herramienta, más la resiste el malware: cambia de personaje con E o Q."))
	BusEventos.ulti_cambiada.connect(_al_cargar_ulti)
	BusEventos.cofre_recogido.connect(func(): _dar("cofre", "El cofre de los élites gira una ruleta con una mejora de premio."))
	BusEventos.jefe_ataco.connect(_al_atacar_jefe)
	BusEventos.anclas_pendientes.connect(_al_cambiar_anclas)


func _al_cargar_ulti(cargas: Array, activo: int) -> void:
	if activo < cargas.size() and cargas[activo] >= 1.0:
		_dar("ulti", "Tu ulti está lista: lánzala con R (o B en el mando).")


func _al_cambiar_anclas(personajes: Array) -> void:
	if not personajes.is_empty():
		_dar("escudo", "Con el escudo puesto cambias de personaje sin esperar: ve a por cada ancla con el suyo.")


func _al_atacar_jefe(ataque: String) -> void:
	if ataque == "pisoton":
		_dar("jaula", "Nadie cruza la jaula hasta que se rompe: esquiva a Kernel Panic dentro.")


## Cada consejo, una vez por partida.
func _dar(clave: String, texto: String) -> void:
	if _dados.has(clave):
		return
	_dados[clave] = true
	_cola.append(texto)


func _process(delta: float) -> void:
	if _tiempo >= 0.0:
		_tiempo += delta
	if _tiempo < 0.0 or _tiempo >= DURA:
		if _cola.is_empty():
			_tiempo = -1.0
			modulate.a = 0.0
			return
		text = _cola.pop_front()
		_tiempo = 0.0
	# Aparece rápido y se apaga en el último trozo.
	modulate.a = clampf(minf(_tiempo / 0.2, (DURA - _tiempo) / APAGADO), 0.0, 1.0)
