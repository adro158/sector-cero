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
	"res://recursos/enemigos/datos/troyano.tres",
	"res://recursos/enemigos/datos/ransomware.tres",
	"res://recursos/enemigos/datos/elite.tres",
]
const MEJORAS := "res://recursos/mejoras/datos/pool_mejoras.tres"
## La configuración de las oleadas guarda la lista de afijos que se sortean.
const OLEADAS := "res://recursos/oleadas/datos/config_principal.tres"
const HOJA_JEFE := "res://escenas/jugabilidad/enemigos/jefe_8_direcciones.png"
const HOJA_JEFE_FINAL := "res://medios/sprites/jefe_final/jefe_final.png"

const COMO_SE_JUEGA := [
	["OBJETIVO", "Eres un proceso antivirus. Aguanta 10 minutos contra el malware y derrota al jefe: el sector queda dañado y empieza la fase 2. A los 15 minutos llega NÚCLEO CERO, el jefe final; derrótalo para ganar. Si la integridad de tu personaje (la barra sobre él) llega a cero, cae y eliges quién sigue; pierdes cuando caen los tres."],
	["DIFICULTAD", "Se elige en el menú principal, antes de jugar. En FÁCIL el malware tiene menos vida, hace menos daño y huye cuando llega el jefe. En MEDIA, la partida como la hemos equilibrado. En DIFÍCIL tiene más vida y hace más daño. Cuando llega el jefe, en MEDIA huye la mitad de la horda y en DIFÍCIL se queda toda."],
	["SOLO TE MUEVES", "Tu herramienta ataca sola cada poco tiempo. Tu decisión es dónde colocarte: deja que el malware entre en tu alcance sin que te rodee."],
	["EXPERIENCIA", "El malware suelta fragmentos de datos al morir: amarillos, naranjas o magentas según lo que valen. Acércate para recogerlos; a los 30 s parpadean y se pierden. Al subir de nivel el juego se pausa y eliges una de tres mejoras. Los enemigos ganan vida con cada nivel que subes y, desde el minuto 3, con cada minuto que pasa."],
	["EL MALWARE SE ADAPTA", "Cada 20 s gana resistencia (hasta un 50 %) contra la herramienta que más daño le ha hecho y la pierde poco a poco contra las demás. Lo verás porque tus números de daño y el anillo de tu herramienta se vuelven rojos."],
	["CAMBIA DE PERSONAJE", "Con E (o Tab) pasas al siguiente personaje y con Q vuelves al anterior. Cada uno lleva otra herramienta, contra la que el malware aún no se ha protegido, y su propia vida: los que esperan se curan poco a poco. Después hay que esperar 10 s para volver a cambiar. Con C ves cómo está cada uno."],
	["ULTI", "Cada personaje carga su ulti matando mientras juega: la barra amarilla bajo su vida. Llena, parpadea un rayo a su lado: pulsa R (B con mando) y la lanza. El Mago dispara un rayo morado enorme (apunta con el ratón y lanza con click), el Espadachín gira con sus hojas y al Segador le cae una tormenta de rayos."],
	["PREMIO DE LOS ÉLITES", "Al morir, un élite deja en el suelo un corazón, que cura la mitad de la vida, y un cofre. Al recoger el cofre gira una ruleta con las mejoras y te llevas la que toque."],
	["FICHA DEL ENEMIGO", "Haz click en un enemigo para ver arriba a la derecha su vida, el daño que hace y cuánto resiste a tu herramienta. Click derecho para cerrarla."],
	["CONTROLES", "Moverse: WASD, flechas, stick o cruceta · Personaje siguiente: E, Tab, Y o RB · Anterior: Q o LB · Ulti: R o B · Equipo: C o Select · Pausa: Esc, P o Start · Mejoras: click, 1, 2, 3 o A · Panel técnico: F3 · Menú de desarrollador: F1 (la partida deja de contar para el ranking)"],
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
		var titulo := "%s · %s · %d de vida" % [personaje.nombre.to_upper(), personaje.arma.nombre, personaje.vida_maxima]
		var texto := "%s\nULTI (R), %s: %s" % [personaje.descripcion, personaje.nombre_ulti, personaje.descripcion_ulti]
		lista.add_child(_fila(icono, titulo, personaje.color, texto))
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

	# Los jefes no tienen recurso de datos: son únicos y su texto va aquí. Una
	# fila por ataque, con el dibujo de ese ataque: hasta el 24/10 eran dos
	# párrafos de 800 y 900 letras (mejoras propuestas, interfaz 13).
	lista.add_child(_fila(_primer_fotograma(load(HOJA_JEFE), 12, 8), "KERNEL PANIC (jefe)", EstiloInterfaz.DERROTA,
		"Llega a los 10 minutos y ya no sale más horda: la que queda sigue (en fácil huye toda y en media, la mitad). Mientras está, el reloj se para. El Ping y el Escáner le pegan sin acercarse."))
	for ataque in [
		["jefe_final/jefe_final_aviso_linea.png", 4, 0, "EMBESTIDA", "Cada 6 s marca una franja roja con flechas y embiste en línea recta hacia donde estabas: apártate, que embistiendo pega mucho."],
		["efectos/invocacion_kernel_panic.png", 8, 6, "ANILLO DE MALWARE", "Cada 15 s se para, late en morado y dibuja un círculo de runas en el suelo; al cerrarse, saca un anillo de malware a su alrededor, más grande cuanto menos vida le queda."],
		["jefe/jefe_rafaga.png", 4, 0, "RÁFAGA DE DATOS", "Cada 9 s late en morado y dispara datos en círculo: pasa por los huecos. Con menos de la mitad de vida, dispara dos."],
		["jefe/jefe_jaula.png", 4, 0, "PISOTÓN Y JAULA", "Cada 20 s marca un anillo rojo en el suelo y pisa: durante 4 s nadie cruza la jaula, y si estabas dentro te quedas encerrado con él."],
		["jefe/jefe_furia.png", 8, 3, "FURIAS", "Al bajarle al 66 % y al 33 % de vida se enfurece: va más rápido, pega más, ataca más seguido y saca más malware. En la última furia, arde."],
		["jefe/jefe_muerte.png", 12, 5, "AL DERROTARLO", "Empieza la fase 2, y los personajes que habían caído vuelven con la mitad de su vida."],
	]:
		lista.add_child(_ataque(ataque))
	lista.add_child(_fila(_primer_fotograma(load(HOJA_JEFE_FINAL), 6, 3), "NÚCLEO CERO (jefe final)", EstiloInterfaz.DERROTA,
		"Llega a los 15 minutos, al acabar la fase 2: derrótalo para ganar. Tiene tres formas: al bajarle al 66 % y al 33 % de vida se transforma y cuesta más matarlo (recibe menos daño y ataca más deprisa)."))
	for ataque in [
		["jefe_final/jefe_final_aviso_diana.png", 4, 0, "TUS ATAQUES", "Usa los ataques de tus personajes: el rayo, el torbellino y la tormenta. Avisan antes de caer."],
		["jefe_final/jefe_final_portal.png", 8, 3, "PORTALES", "Abre portales de los que sale malware."],
		["jefe_final/jefe_final_hielo.png", 8, 4, "HIELO", "Deja zonas de hielo que te ralentizan mientras estás dentro."],
		["jefe_final/jefe_final_escudo.png", 4, 0, "ESCUDO", "Al cambiar de forma se encierra en un escudo que no deja pasar el daño. Rompe las cuatro anclas y se quedará aturdido, recibiendo más daño. En su última forma vuelve a encerrarse cada 35 s."],
		["jefe_final/jefe_final_ancla_mago.png", 5, 0, "ANCLAS", "Cada ancla es de un personaje (su color y su nombre, abajo) y solo la rompe su herramienta: ve cambiando, que con el escudo puesto se cambia sin espera. Si pasan 30 s sin que rompas ninguna, las rotas se vuelven a cerrar."],
	]:
		lista.add_child(_ataque(ataque))

	lista.add_child(EstiloInterfaz.etiqueta("AFIJOS DE LOS ÉLITES", 20, Color(1.0, 0.85, 0.3)))
	var oleadas: DatosConfigOleada = load(OLEADAS)
	for afijo in oleadas.afijos_elite:
		lista.add_child(_fila(afijo.icono, afijo.nombre, afijo.color, afijo.descripcion))
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


## Un ataque de un jefe, debajo de su fila y un poco metido: [dibujo dentro de
## medios/sprites/ (o "" para el cuadrado de color), fotogramas de su tira, el
## que se enseña (en algunos el primero casi no se ve), título, explicación].
func _ataque(ataque: Array) -> HBoxContainer:
	var icono: AtlasTexture = null
	if ataque[0] != "":
		icono = _primer_fotograma(load("res://medios/sprites/" + ataque[0]), ataque[1], 1)
		icono.region.position.x = ataque[2] * icono.region.size.x
	var fila := _fila(icono, ataque[3], Color(EstiloInterfaz.DERROTA, 0.8), ataque[4])
	# Metida a la altura del texto del jefe.
	var sangria := Control.new()
	sangria.custom_minimum_size.x = 48.0
	fila.add_child(sangria)
	fila.move_child(sangria, 0)
	return fila


## El primer fotograma de una hoja de sprites: el personaje mirando de frente.
func _primer_fotograma(hoja: Texture2D, columnas: int, filas: int) -> AtlasTexture:
	var fotograma := AtlasTexture.new()
	fotograma.atlas = hoja
	fotograma.region = Rect2(Vector2.ZERO, hoja.get_size() / Vector2(columnas, filas))
	return fotograma
