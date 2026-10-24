extends Control

## HUD de la partida: nivel y experiencia arriba a la izquierda
## (panel_experiencia.gd), reloj y cuenta atrás hasta el jefe (o el jefe
## final, en la fase 2) arriba en el centro, y la columna de mejoras elegidas a
## la izquierda. La vida va en una barra sobre el propio personaje; el equipo
## (abajo y con C) lo lleva panel_equipo.gd, y el negro entre fases,
## pantalla_fase.gd.
##
## Solo escucha señales del BusEventos. Los niveles de cada mejora los anotan
## el panel de mejoras y la ruleta al elegir, en un diccionario que comparten.

const FichaEnemigo := preload("res://escenas/interfaz/ficha_enemigo.gd")
const PanelRuleta := preload("res://escenas/interfaz/panel_ruleta.gd")
const PanelEquipo := preload("res://escenas/interfaz/panel_equipo.gd")
const PanelCaida := preload("res://escenas/interfaz/panel_caida.gd")
const PanelExperiencia := preload("res://escenas/interfaz/panel_experiencia.gd")
const PantallaFase := preload("res://escenas/interfaz/pantalla_fase.gd")
const BarraJefe := preload("res://escenas/interfaz/barra_jefe.gd")
const AvisosHud := preload("res://escenas/interfaz/avisos_hud.gd")

var niveles_mejora := {}

var _etiqueta_tiempo: Label
var _etiqueta_jefe: Label
## De quién es la cuenta atrás: del jefe (1) o del jefe final (2).
var _fase := 1
var _columna: VBoxContainer
var _iconos := {}
## Cuántas evoluciones hay en la columna: van las primeras, por orden.
var _evoluciones := 0
## La herramienta del personaje que se lleva: el aviso de la adaptación del
## malware solo sale si es contra ella.
var _arma_activa: DatosArma
var _avisos: Label


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Los paneles de la escena (mejoras, pausa, pantalla final) van encima de lo
	# que se crea aquí: si no, el nivel, el reloj y la columna de mejoras salían
	# sin oscurecer encima de la pausa y de la subida de nivel.
	var de_la_escena := get_child_count()
	add_child(PanelExperiencia.new())
	_crear_reloj()
	_crear_barras_jefe()

	_columna = VBoxContainer.new()
	_columna.position = Vector2(16, 104)
	_columna.add_theme_constant_override("separation", 6)
	add_child(_columna)

	# Los avisos grandes de arriba, en cola (avisos_hud.gd).
	_avisos = AvisosHud.new()
	add_child(_avisos)
	for i in get_child_count() - de_la_escena:
		move_child(get_child(de_la_escena + i), i)

	# Los primeros hijos: así quedan por debajo de la pausa y las mejoras.
	for panel in [PanelEquipo.new(), FichaEnemigo.new()]:
		add_child(panel)
		move_child(panel, 0)
	$PanelMejoras.niveles = niveles_mejora
	# Justo encima del panel de mejoras: por debajo de la pausa y de la
	# pantalla final, como él.
	var ruleta := PanelRuleta.new()
	ruleta.niveles = niveles_mejora
	add_child(ruleta)
	move_child(ruleta, $PanelMejoras.get_index() + 1)
	var caida := PanelCaida.new()
	add_child(caida)
	move_child(caida, ruleta.get_index() + 1)
	BusEventos.elite_aparecio.connect(func(descripcion): _avisar("ÉLITE: " + descripcion, Color(1.0, 0.85, 0.3)))
	BusEventos.jefe_aparecio.connect(func(): _avisar("¡JEFE: KERNEL PANIC!", EstiloInterfaz.DERROTA, true))
	BusEventos.jefe_furia_cambiada.connect(func(furia): _avisar(["", "¡KERNEL PANIC SE ENFURECE!", "¡KERNEL PANIC ARDE DE FURIA!"][furia], EstiloInterfaz.DERROTA, true))
	BusEventos.fase_cambiada.connect(_al_cambiar_fase)
	BusEventos.jefe_final_aparecio.connect(func(): _avisar("¡NÚCLEO CERO!", EstiloInterfaz.DERROTA, true))
	BusEventos.jefe_final_forma_cambiada.connect(func(forma): _avisar(["", "¡NÚCLEO ARMADO!", "¡AMALGAMA!"][forma], EstiloInterfaz.DERROTA, true))
	BusEventos.jefe_final_ataco.connect(_al_atacar_jefe_final)
	BusEventos.arma_evolucionada.connect(func(arma): _avisar("EVOLUCIÓN: " + arma.nombre.to_upper(), EstiloInterfaz.VICTORIA))
	BusEventos.personaje_cambiado.connect(func(_actual, arma, _siguiente, _espera): _arma_activa = arma)
	BusEventos.malware_adaptado.connect(_al_adaptarse_malware)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.tiempo_partida.connect(_al_pasar_tiempo)
	BusEventos.mejora_seleccionada.connect(_al_elegir_mejora)
	BusEventos.mejora_regalada.connect(_al_regalar_mejora)
	# El último: el negro de la transición tapa todo lo demás.
	add_child(PantallaFase.new())


func _crear_reloj() -> void:
	var caja := VBoxContainer.new()
	# Anclado al centro de arriba: los offsets son relativos a ese punto.
	caja.set_anchors_preset(Control.PRESET_CENTER_TOP)
	caja.offset_left = -100.0
	caja.offset_right = 100.0
	caja.offset_top = 12.0
	add_child(caja)

	_etiqueta_tiempo = EstiloInterfaz.etiqueta("00:00", 30, EstiloInterfaz.TEXTO)
	_etiqueta_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_etiqueta_tiempo)
	_etiqueta_jefe = EstiloInterfaz.etiqueta("", 14, EstiloInterfaz.TEXTO_SUAVE)
	_etiqueta_jefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_etiqueta_jefe)


## Las dos se ven al llegar su jefe. La de Kernel Panic se quita con el negro
## de la fase 2: para entonces ya ha acabado su explosión.
func _crear_barras_jefe() -> void:
	var barra := BarraJefe.new(preload("res://medios/sprites/jefe/jefe_barra.png"), preload("res://medios/sprites/jefe/jefe_barra_relleno.png"))
	add_child(barra)
	BusEventos.jefe_aparecio.connect(barra.show)
	BusEventos.jefe_vida_cambiada.connect(barra.poner)
	# Con unbind y no con una función anónima: esta no usa el HUD, y Godot no
	# la desconectaría al salir de la partida (en la siguiente, al pasar a la
	# fase 2, intentaba esconder la barra vieja).
	BusEventos.transicion_fase.connect(barra.hide.unbind(1))
	var barra_final := BarraJefe.new(preload("res://medios/sprites/jefe_final/jefe_final_barra.png"), preload("res://medios/sprites/jefe_final/jefe_final_barra_relleno.png"))
	add_child(barra_final)
	BusEventos.jefe_final_aparecio.connect(barra_final.show)
	BusEventos.jefe_final_vida_cambiada.connect(barra_final.poner)


func _al_pasar_tiempo(segundos: float, duracion: float) -> void:
	_etiqueta_tiempo.text = _formato(segundos)
	var jefe := "KERNEL PANIC" if _fase == 1 else "NÚCLEO CERO"
	if segundos < duracion:
		# Hacia arriba: el reloj trunca los segundos, así que la cuenta atrás los
		# redondea al revés y entre los dos siempre suman la duración.
		_etiqueta_jefe.text = "%s EN %s" % [jefe, _formato(ceilf(duracion - segundos))]
	else:
		_etiqueta_jefe.text = "¡%s!" % jefe
		_etiqueta_jefe.add_theme_color_override("font_color", EstiloInterfaz.DERROTA)


## Llega detrás del negro: cuando vuelve la imagen ya está el aviso.
func _al_cambiar_fase(fase: int) -> void:
	_fase = fase
	_etiqueta_jefe.remove_theme_color_override("font_color")
	_avisar("¡FASE 2! EL SECTOR ESTÁ DAÑADO", EstiloInterfaz.DERROTA, true)


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	if not _iconos.has(mejora):
		var icono := IconoMejora.new()
		icono.mejora = mejora
		_columna.add_child(icono)
		_iconos[mejora] = icono
		# Las de un personaje (las evoluciones), arriba del todo.
		if mejora.efecto == DatosMejora.Efecto.EVOLUCIONAR_ARMA:
			_columna.move_child(icono, _evoluciones)
			_evoluciones += 1
	_iconos[mejora].poner_nivel(niveles_mejora.get(mejora, 1))


## Las mejoras del menú de desarrollador no pasan por los paneles: se apunta
## aquí su nivel.
func _al_regalar_mejora(mejora: DatosMejora) -> void:
	niveles_mejora[mejora] = niveles_mejora.get(mejora, 0) + 1
	_al_elegir_mejora(mejora)


## El elemento diferencial, a la vista: cuando el malware se hace más
## resistente a la herramienta que llevas, se avisa de que conviene cambiar.
func _al_adaptarse_malware(arma: DatosArma, resistencia: float) -> void:
	if arma == _arma_activa:
		_avisar("EL MALWARE SE ADAPTA A TU %s: %d %% · CAMBIA DE PERSONAJE" % [arma.nombre.to_upper(), roundi(resistencia * 100.0)], EstiloInterfaz.DERROTA)


## Al levantarse (o volver a cerrarse) el escudo de NÚCLEO CERO, qué hay que
## hacer: es lo que más cuesta entender. A quién cambiar lo dice la línea de
## abajo (panel_equipo.gd).
func _al_atacar_jefe_final(ataque: String) -> void:
	if ataque == "escudo":
		_avisar("ESCUDO: ROMPE CADA ANCLA CON SU PERSONAJE", EstiloInterfaz.NEON, true)


## Matar un élite deja en el suelo un corazón y un cofre: se avisa para que se
## sepa que hay que ir a por ellos.
func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo == "elite":
		_avisar("ÉLITE ELIMINADO: RECOGE EL CORAZÓN Y EL COFRE", EstiloInterfaz.VICTORIA)


## Mensaje grande arriba en el centro, en la cola de avisos_hud.gd. Los urgentes
## (jefes, furias, fase 2) pasan delante.
func _avisar(texto: String, color: Color, urgente := false) -> void:
	_avisos.avisar(texto, color, urgente)


static func _formato(segundos: float) -> String:
	return "%02d:%02d" % [int(segundos) / 60, int(segundos) % 60]
