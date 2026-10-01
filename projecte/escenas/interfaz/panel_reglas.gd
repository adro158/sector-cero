class_name PanelReglas
extends Control

## Ventana de reglas del menú principal, en cuatro pestañas: cómo se juega, los
## personajes y cuándo conviene cada uno, las mejoras y evoluciones, y los
## enemigos con los afijos de los élites.
##
## Casi todo se lee de los recursos de datos (.tres): si se cambia la
## descripción de un personaje o se añade un enemigo, la ventana se actualiza
## sola, sin tocar este script.

signal cerrado

const PERSONAJES := [
	"res://recursos/personajes/datos/espadachin.tres",
	"res://recursos/personajes/datos/mago.tres",
	"res://recursos/personajes/datos/segador.tres",
]
const ENEMIGOS := [
	"res://recursos/enemigos/datos/bit_corrupto.tres",
	"res://recursos/enemigos/datos/paquete_perdido.tres",
	"res://recursos/enemigos/datos/proceso_colgado.tres",
	"res://recursos/enemigos/datos/elite.tres",
]
const MEJORAS := "res://recursos/mejoras/datos/pool_mejoras.tres"
## La configuración de las oleadas guarda la lista de afijos que se sortean.
const OLEADAS := "res://recursos/oleadas/datos/config_principal.tres"
const HOJA_JEFE := "res://escenas/jugabilidad/enemigos/jefe_8_direcciones.png"

const COMO_SE_JUEGA := [
	["OBJETIVO", "Eres un proceso antivirus. Aguanta 10 minutos contra el malware y derrota al jefe final. Si tu integridad (la barra sobre tu personaje) llega a cero, pierdes."],
	["SOLO TE MUEVES", "Tu herramienta ataca sola cada poco tiempo. Tu decisión es dónde colocarte: deja que el malware entre en tu alcance sin que te rodee."],
	["EXPERIENCIA", "El malware suelta fragmentos de datos al morir. Acércate para recogerlos. Al subir de nivel el juego se pausa y eliges una de tres mejoras."],
	["EL MALWARE SE ADAPTA", "Cada 20 s gana resistencia (hasta un 50 %) contra la herramienta que más daño le ha hecho y la pierde poco a poco contra las demás. Lo verás porque tus números de daño y el anillo de tu herramienta se vuelven rojos."],
	["CAMBIA DE PERSONAJE", "Con Q o Tab pasas al siguiente personaje, que lleva otra herramienta contra la que el malware aún no se ha protegido. Después hay que esperar 10 s para volver a cambiar."],
	["CONTROLES", "Moverse: WASD, flechas o stick · Cambiar de personaje: Q, Tab o Y · Pausa: Esc, P o Start · Mejoras: click o 1, 2, 3 · Panel técnico: F3"],
]

var _ventana: ColorRect
var _pestanas: TabContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var caja := VBoxContainer.new()
	var titulo := EstiloInterfaz.etiqueta("REGLAS DEL JUEGO", 32, EstiloInterfaz.NEON)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	_pestanas = TabContainer.new()
	_pestanas.custom_minimum_size = Vector2(920, 440)
	_pestanas.add_child(_pestana("Cómo se juega", _como_se_juega()))
	_pestanas.add_child(_pestana("Personajes", _personajes()))
	_pestanas.add_child(_pestana("Mejoras", _mejoras()))
	_pestanas.add_child(_pestana("Enemigos", _enemigos()))
	caja.add_child(_pestanas)

	var ayuda := EstiloInterfaz.etiqueta("Pestañas: click o flechas izquierda y derecha · Rueda o flechas arriba y abajo para leer", 13, EstiloInterfaz.TEXTO_SUAVE)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(ayuda)
	var volver := EstiloInterfaz.boton("VOLVER  [Esc]", cerrar)
	volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(volver)

	_ventana = EstiloInterfaz.ventana_centrada(caja)
	add_child(_ventana)
	visible = false


func abrir() -> void:
	visible = true
	_pestanas.current_tab = 0
	_pestanas.get_tab_bar().grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if not visible:
		return
	if evento.is_action_pressed("ui_cancel"):
		cerrar()
		# Que no llegue al menú de debajo, que con Esc saldría del juego.
		get_viewport().set_input_as_handled()
	elif evento.is_action_pressed("ui_right"):
		_pestanas.current_tab = (_pestanas.current_tab + 1) % _pestanas.get_tab_count()
	elif evento.is_action_pressed("ui_left"):
		_pestanas.current_tab = posmod(_pestanas.current_tab - 1, _pestanas.get_tab_count())


# --- Contenido de cada pestaña ---


func _como_se_juega() -> VBoxContainer:
	var lista := _lista()
	for apartado in COMO_SE_JUEGA:
		lista.add_child(_fila(null, apartado[0], EstiloInterfaz.NEON, apartado[1]))
	return lista


func _personajes() -> VBoxContainer:
	var lista := _lista()
	for ruta in PERSONAJES:
		var personaje: DatosPersonaje = load(ruta)
		# Las hojas tienen 6 columnas (pasos) y 8 filas (direcciones).
		var icono := _primer_fotograma(personaje.hoja, 6, 8)
		var titulo := "%s · %s" % [personaje.nombre.to_upper(), personaje.arma.nombre]
		lista.add_child(_fila(icono, titulo, personaje.color, personaje.descripcion))
	return lista


func _mejoras() -> VBoxContainer:
	var lista := _lista()
	var pool: DatosPoolMejoras = load(MEJORAS)
	for mejora in pool.mejoras:
		lista.add_child(_fila(mejora.icono, mejora.nombre, EstiloInterfaz.NEON, mejora.descripcion + ". Se puede elegir varias veces y se acumula."))

	lista.add_child(EstiloInterfaz.etiqueta("EVOLUCIONES", 20, EstiloInterfaz.VICTORIA))
	for evolucion in pool.evoluciones:
		var requisito := "Aparece al elegir %s %d veces." % [evolucion.requisito.nombre, evolucion.nivel_requisito]
		lista.add_child(_fila(evolucion.icono, evolucion.nombre, EstiloInterfaz.VICTORIA, evolucion.descripcion + " " + requisito))
	return lista


func _enemigos() -> VBoxContainer:
	var lista := _lista()
	for ruta in ENEMIGOS:
		var tipo: DatosTipoEnemigo = load(ruta)
		lista.add_child(_fila(tipo.textura, tipo.nombre, tipo.color, tipo.descripcion))

	# El jefe no tiene recurso de datos: es único y su texto va aquí.
	lista.add_child(_fila(_primer_fotograma(load(HOJA_JEFE), 12, 8), "Jefe final", EstiloInterfaz.DERROTA,
		"Llega a los 10 minutos y desde entonces ya no sale horda. Persigue despacio y cada 7 s se pone rojo y embiste en línea recta hacia donde estabas: apártate de su camino. Derrótalo para ganar. El Ping y el Escáner le pegan sin acercarse."))

	lista.add_child(EstiloInterfaz.etiqueta("AFIJOS DE LOS ÉLITES", 20, Color(1.0, 0.85, 0.3)))
	var oleadas: DatosConfigOleada = load(OLEADAS)
	for afijo in oleadas.afijos_elite:
		lista.add_child(_fila(null, afijo.nombre, afijo.color, afijo.descripcion))
	return lista


# --- Piezas ---


## Cada pestaña es un contenedor con barra de desplazamiento vertical. El
## TabContainer usa el nombre del nodo como título de la pestaña.
func _pestana(titulo: String, contenido: Control) -> ScrollContainer:
	var desplazable := ScrollContainer.new()
	desplazable.name = titulo
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	contenido.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desplazable.add_child(contenido)
	return desplazable


func _lista() -> VBoxContainer:
	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 14)
	return lista


## Una fila: icono a la izquierda (o un cuadrado del color si no hay) y, a la
## derecha, el título en color y la explicación debajo.
func _fila(icono: Texture2D, titulo: String, color: Color, texto: String) -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)

	if icono != null:
		var imagen := TextureRect.new()
		imagen.texture = icono
		imagen.custom_minimum_size = Vector2(48, 48)
		imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fila.add_child(imagen)
	else:
		var marca := ColorRect.new()
		marca.color = color
		marca.custom_minimum_size = Vector2(10, 10)
		marca.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		fila.add_child(marca)

	var textos := VBoxContainer.new()
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textos.add_child(EstiloInterfaz.etiqueta(titulo, 18, color))
	var explicacion := EstiloInterfaz.etiqueta(texto, 14)
	explicacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	textos.add_child(explicacion)
	fila.add_child(textos)
	return fila


## El primer fotograma de una hoja de sprites: el personaje mirando de frente.
func _primer_fotograma(hoja: Texture2D, columnas: int, filas: int) -> AtlasTexture:
	var fotograma := AtlasTexture.new()
	fotograma.atlas = hoja
	fotograma.region = Rect2(Vector2.ZERO, hoja.get_size() / Vector2(columnas, filas))
	return fotograma
