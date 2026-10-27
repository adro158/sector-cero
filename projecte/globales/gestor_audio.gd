extends Node

## Música y efectos de sonido. Nadie lo llama: escucha las señales del
## BusEventos y los cambios de escena, y decide qué suena. Los sonidos son
## propios, generados con herramientas/generar_audio.gd.

const RUTA := "res://medios/audio/"

## Qué música suena en cada escena. La del jefe la pone su señal.
const MUSICA_POR_ESCENA := {
	"res://escenas/menu_principal/menu_principal.tscn": "musica_menu",
	"res://escenas/juego.tscn": "musica_partida",
}

## Todos los efectos, por el nombre de su fichero en medios/audio/.
const EFECTOS := [
	"muerte", "gema", "subir_nivel", "elegir", "dano", "victoria", "derrota",
	"pausa", "clic", "cambio", "evolucion", "explosion", "firewall", "ping",
	"escaner", "alarma_jefe", "alarma_elite",
	# Del 27/10: el escudo de NÚCLEO CERO, las ultis y las evoluciones.
	"ancla_bloqueada", "ancla_rota", "escudo_roto", "ulti_rayo", "ulti_giro",
	"ulti_tormenta", "ulti_lista", "firewall_perimetral", "analisis_heuristico",
	"ping_inundacion",
]

## Cada ataque de los jefes suena con uno de los efectos que ya hay, y con
## qué tono. Los del jefe final (el rayo, el torbellino y la tormenta), como
## las ultis que roba a los personajes, más graves: así se oye que te las
## roba. El pisotón y la ráfaga son del jefe del minuto 10.
const SONIDO_ATAQUE := {
	"rayo": ["ulti_rayo", 0.8],
	"torbellino": ["ulti_giro", 0.8],
	"tormenta": ["ulti_tormenta", 0.8],
	"invocar": ["alarma_elite", 0.7],
	"hielo": ["ping", 0.6],
	"escudo": ["evolucion", 0.6],
	"pisoton": ["explosion", 0.6],
	"rafaga": ["ping", 0.8],
}

## Tiempo mínimo, en segundos, entre dos veces el mismo efecto. Con decenas de
## enemigos muriendo a la vez, sonar en cada muerte sería solo ruido.
const ESPERA_MINIMA := 0.05
## Por encima de esta frecuencia se corta la música mientras se elige (mejora,
## premio de la ruleta, quién sigue) o en pausa: suena «detrás de un cristal».
const CORTE_AMORTIGUADA := 700.0

var _reproductores := {}
var _ultima_vez := {}
var _musica: AudioStreamPlayer
var _pista_actual := ""
var _personaje_anterior: DatosPersonaje
## La herramienta que se lleva: la adaptación del malware suena si es a ella.
var _arma_activa: DatosArma
## La carga de la ulti de cada personaje la última vez: «ulti lista» suena
## solo al llenarse la del que juega.
var _cargas_ulti: Array = []
## El bus de la música y el número de su filtro de paso bajo (-1 si no hay).
var _bus_musica := -1
var _filtro := -1


func _ready() -> void:
	# La interfaz suena también con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_musica = AudioStreamPlayer.new()
	_musica.bus = "Musica"
	add_child(_musica)
	_preparar_filtro()

	# Un reproductor por efecto, todos cargados al arrancar el juego: cargar un
	# sonido la primera vez que suena daría un tirón en mitad de la partida.
	for nombre in EFECTOS:
		var reproductor := AudioStreamPlayer.new()
		reproductor.stream = load(RUTA + nombre + ".wav")
		reproductor.bus = "Efectos"
		# Hasta cuatro copias del mismo efecto a la vez; si no, cada una
		# cortaría a la anterior.
		reproductor.max_polyphony = 4
		add_child(reproductor)
		_reproductores[nombre] = reproductor

	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)
	BusEventos.experiencia_ganada.connect(func(_cantidad): sonar("gema"))
	BusEventos.jugador_subio_nivel.connect(func(_opciones): sonar("subir_nivel"))
	BusEventos.ruleta_abierta.connect(func(_opciones, _premio): sonar("subir_nivel"))
	BusEventos.mejora_seleccionada.connect(func(_mejora): sonar("elegir"))
	BusEventos.herramienta_usada.connect(func(arma: DatosArma): sonar(arma.sonido))
	BusEventos.jugador_danado.connect(func(_cantidad): sonar("dano"))
	BusEventos.personaje_cambiado.connect(_al_cambiar_personaje)
	BusEventos.personaje_caido.connect(func(_personajes, _caido): sonar("explosion"))
	BusEventos.jefe_aparecio.connect(_al_aparecer_jefe)
	BusEventos.elite_aparecio.connect(func(_descripcion): sonar("alarma_elite"))
	BusEventos.jefe_invoco.connect(func(): sonar("alarma_elite", 0.7))
	BusEventos.jefe_furia_cambiada.connect(_al_endurecerse_jefe)
	# Una alarma grave, como un aviso del sistema.
	BusEventos.malware_adaptado.connect(func(arma, _resistencia): if arma == _arma_activa: sonar("alarma_elite", 0.55))
	BusEventos.jefe_ataco.connect(func(ataque): sonar(SONIDO_ATAQUE[ataque][0], SONIDO_ATAQUE[ataque][1]))
	BusEventos.elite_exploto.connect(func(_posicion): sonar("explosion"))
	BusEventos.transicion_fase.connect(_al_empezar_transicion)
	# La fase 2 tiene su música desde el 27/10 (antes, la de la partida más grave).
	BusEventos.fase_cambiada.connect(func(_fase): _poner_musica("musica_fase2"))
	BusEventos.jefe_final_aparecio.connect(_al_aparecer_jefe_final)
	BusEventos.jefe_final_forma_cambiada.connect(_al_endurecerse_jefe)
	BusEventos.jefe_final_ataco.connect(func(ataque): sonar(SONIDO_ATAQUE[ataque][0], SONIDO_ATAQUE[ataque][1]))
	BusEventos.arma_evolucionada.connect(func(_arma): sonar("evolucion"))
	BusEventos.ulti_lanzada.connect(_al_lanzar_ulti)
	BusEventos.ulti_cambiada.connect(_al_cargar_ulti)
	BusEventos.escudo_final.connect(func(suceso): sonar({"bloqueado": "ancla_bloqueada", "ancla_rota": "ancla_rota", "roto": "escudo_roto"}[suceso]))
	BusEventos.juego_pausado.connect(_al_pausar)
	BusEventos.partida_terminada.connect(_al_terminar)
	# La música, amortiguada mientras se elige. Si hay varias subidas de nivel
	# seguidas, se quita y se vuelve a poner en el mismo fotograma: no se nota.
	BusEventos.jugador_subio_nivel.connect(func(_opciones): _amortiguar(true))
	BusEventos.ruleta_abierta.connect(func(_opciones, _premio): _amortiguar(true))
	BusEventos.personaje_caido.connect(func(_personajes, _caido): _amortiguar(true))
	BusEventos.mejora_seleccionada.connect(func(_mejora): _amortiguar(false))
	BusEventos.personaje_elegido.connect(func(_indice): _amortiguar(false))
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)
	get_tree().scene_changed.connect(_al_cambiar_escena)
	# Cada botón que aparezca, en cualquier pantalla, hará clic al pulsarlo.
	get_tree().node_added.connect(_al_anadir_nodo)
	# La primera escena no avisa con scene_changed: se mira cuando ya está.
	_al_cambiar_escena.call_deferred()


## Reproduce un efecto por el nombre de su fichero. tono cambia la altura: 1 es
## la original.
func sonar(nombre: String, tono := 1.0) -> void:
	var ahora := Time.get_ticks_msec() / 1000.0
	if ahora - _ultima_vez.get(nombre, -1.0) < ESPERA_MINIMA:
		return
	_ultima_vez[nombre] = ahora
	_reproductores[nombre].pitch_scale = tono
	_reproductores[nombre].play()


## tono cambia la velocidad y la altura a la vez: 0.85 es más lenta y grave.
func _poner_musica(pista: String, tono := 1.0) -> void:
	if pista == _pista_actual and is_equal_approx(_musica.pitch_scale, tono):
		return
	_pista_actual = pista
	_musica.stream = load(RUTA + pista + ".wav")
	_musica.pitch_scale = tono
	# Entra con un fundido en lugar de golpe.
	_musica.volume_db = -30.0
	_musica.play()
	create_tween().tween_property(_musica, "volume_db", 0.0, 1.0)


## El filtro de paso bajo, en el bus de la música y apagado. Se pone por código
## y no en default_bus_layout.tres para que llegue con el .pck.
func _preparar_filtro() -> void:
	_bus_musica = AudioServer.get_bus_index("Musica")
	if _bus_musica == -1:
		return
	var filtro := AudioEffectLowPassFilter.new()
	filtro.cutoff_hz = CORTE_AMORTIGUADA
	AudioServer.add_bus_effect(_bus_musica, filtro)
	_filtro = AudioServer.get_bus_effect_count(_bus_musica) - 1
	AudioServer.set_bus_effect_enabled(_bus_musica, _filtro, false)


func _amortiguar(encendido: bool) -> void:
	if _filtro != -1:
		AudioServer.set_bus_effect_enabled(_bus_musica, _filtro, encendido)


func _al_cambiar_escena() -> void:
	_personaje_anterior = null
	_cargas_ulti = []
	_amortiguar(false)
	var escena := get_tree().current_scene
	if escena != null and MUSICA_POR_ESCENA.has(escena.scene_file_path):
		_poner_musica(MUSICA_POR_ESCENA[escena.scene_file_path])


func _al_anadir_nodo(nodo: Node) -> void:
	if nodo is BaseButton:
		nodo.pressed.connect(sonar.bind("clic"))


func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo == "jefe" or tipo == "elite":
		sonar("explosion")
	else:
		# Un poco más agudo o más grave cada vez, para que no canse.
		sonar("muerte", randf_range(0.85, 1.15))


func _al_cambiar_personaje(actual: DatosPersonaje, arma: DatosArma, _siguiente: DatosPersonaje, _espera: float) -> void:
	# La señal llega también al empezar la partida y al evolucionar la
	# herramienta: solo suena si de verdad cambia el personaje.
	if _personaje_anterior != null and actual != _personaje_anterior:
		sonar("cambio")
	_personaje_anterior = actual
	_arma_activa = arma


## Cada ulti con su sonido (rayo, giro o tormenta), hecho a su medida.
func _al_lanzar_ulti(personaje: DatosPersonaje) -> void:
	sonar("ulti_" + personaje.ulti)


func _al_cargar_ulti(cargas: Array, activo: int) -> void:
	var antes: float = _cargas_ulti[activo] if activo < _cargas_ulti.size() else 1.0
	if antes < 1.0 and cargas[activo] >= 1.0:
		sonar("ulti_lista")
	_cargas_ulti = cargas.duplicate()


func _al_aparecer_jefe() -> void:
	sonar("alarma_jefe")
	_poner_musica("musica_jefe")


## La suya desde el 27/10 (antes, la del jefe algo más rápida).
func _al_aparecer_jefe_final() -> void:
	sonar("alarma_jefe")
	_poner_musica("musica_jefe_final")


## Lo mismo cuando el jefe final cambia de forma y cuando el del minuto 10
## se enfurece: los dos se vuelven más duros.
func _al_endurecerse_jefe(_paso: int) -> void:
	sonar("alarma_jefe", 0.8)
	sonar("explosion", 0.7)


## Con el negro, la música se apaga poco a poco y suena una alarma grave. La
## nueva entra con fase_cambiada.
func _al_empezar_transicion(segundos: float) -> void:
	sonar("alarma_jefe", 0.6)
	create_tween().tween_property(_musica, "volume_db", -40.0, segundos * 0.4)


func _al_pausar(en_pausa: bool) -> void:
	sonar("pausa")
	# La música baja y se amortigua mientras dura la pausa.
	_musica.volume_db = -12.0 if en_pausa else 0.0
	_amortiguar(en_pausa)


func _al_terminar(estadisticas: Dictionary) -> void:
	_musica.stop()
	_pista_actual = ""
	sonar("victoria" if estadisticas.victoria else "derrota")


func _al_cambiar_opcion(clave: String, _valor: Variant) -> void:
	# Al mover el volumen de los efectos se oye uno, para saber cómo queda.
	if clave == "volumen_efectos":
		sonar("gema")
