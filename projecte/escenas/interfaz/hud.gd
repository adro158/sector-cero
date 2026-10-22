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

var niveles_mejora := {}

var _etiqueta_tiempo: Label
var _etiqueta_jefe: Label
## De quién es la cuenta atrás: del jefe (1) o del jefe final (2).
var _fase := 1
var _columna: VBoxContainer
var _iconos := {}
var _aviso: Label
var _efecto_aviso: Tween


func _ready() -> void:
	theme = EstiloInterfaz.tema()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(PanelExperiencia.new())
	_crear_reloj()
	_crear_barras_jefe()

	_columna = VBoxContainer.new()
	_columna.position = Vector2(16, 104)
	_columna.add_theme_constant_override("separation", 6)
	add_child(_columna)

	_aviso = EstiloInterfaz.etiqueta("", 26)
	_aviso.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_aviso.offset_left = -400.0
	_aviso.offset_right = 400.0
	# Debajo de las barras de los jefes, que van de 62 a 102.
	_aviso.offset_top = 108.0
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.modulate.a = 0.0
	add_child(_aviso)

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
	BusEventos.jefe_aparecio.connect(func(): _avisar("¡JEFE: KERNEL PANIC!", EstiloInterfaz.DERROTA))
	BusEventos.jefe_furia_cambiada.connect(func(furia): _avisar(["", "¡KERNEL PANIC SE ENFURECE!", "¡KERNEL PANIC ARDE DE FURIA!"][furia], EstiloInterfaz.DERROTA))
	BusEventos.fase_cambiada.connect(_al_cambiar_fase)
	BusEventos.jefe_final_aparecio.connect(func(): _avisar("¡NÚCLEO CERO!", EstiloInterfaz.DERROTA))
	BusEventos.jefe_final_forma_cambiada.connect(func(forma): _avisar(["", "¡NÚCLEO ARMADO!", "¡AMALGAMA!"][forma], EstiloInterfaz.DERROTA))
	BusEventos.arma_evolucionada.connect(func(arma): _avisar("EVOLUCIÓN: " + arma.nombre.to_upper(), EstiloInterfaz.VICTORIA))
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
	BusEventos.transicion_fase.connect(func(_segundos): barra.hide())
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
	_avisar("¡FASE 2! EL SECTOR ESTÁ DAÑADO", EstiloInterfaz.DERROTA)


func _al_elegir_mejora(mejora: DatosMejora) -> void:
	if not _iconos.has(mejora):
		var icono := IconoMejora.new()
		icono.mejora = mejora
		_columna.add_child(icono)
		_iconos[mejora] = icono
	_iconos[mejora].poner_nivel(niveles_mejora.get(mejora, 1))


## Las mejoras del menú de desarrollador no pasan por los paneles: se apunta
## aquí su nivel.
func _al_regalar_mejora(mejora: DatosMejora) -> void:
	niveles_mejora[mejora] = niveles_mejora.get(mejora, 0) + 1
	_al_elegir_mejora(mejora)


## Matar un élite deja en el suelo un corazón y un cofre: se avisa para que se
## sepa que hay que ir a por ellos.
func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo == "elite":
		_avisar("ÉLITE ELIMINADO: RECOGE EL CORAZÓN Y EL COFRE", EstiloInterfaz.VICTORIA)


## Mensaje grande arriba en el centro que se desvanece a los pocos segundos.
func _avisar(texto: String, color: Color) -> void:
	_aviso.text = texto
	_aviso.add_theme_color_override("font_color", color)
	# Un aviso nuevo sustituye al anterior aunque no se haya apagado.
	if _efecto_aviso != null:
		_efecto_aviso.kill()
	_aviso.modulate.a = 1.0
	_efecto_aviso = create_tween()
	_efecto_aviso.tween_interval(2.0)
	_efecto_aviso.tween_property(_aviso, "modulate:a", 0.0, 1.0)


static func _formato(segundos: float) -> String:
	return "%02d:%02d" % [int(segundos) / 60, int(segundos) % 60]
