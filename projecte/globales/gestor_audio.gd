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
]

## Cada ataque del jefe final suena con uno de los efectos que ya hay, y con
## qué tono: el rayo, el torbellino y la tormenta, como las armas o las ultis
## de las que salen.
const SONIDO_ATAQUE := {
	"rayo": ["escaner", 0.6],
	"torbellino": ["firewall", 0.7],
	"tormenta": ["explosion", 1.2],
	"invocar": ["alarma_elite", 0.7],
	"hielo": ["ping", 0.6],
	"escudo": ["evolucion", 0.6],
}

## Tiempo mínimo, en segundos, entre dos veces el mismo efecto. Con decenas de
## enemigos muriendo a la vez, sonar en cada muerte sería solo ruido.
const ESPERA_MINIMA := 0.05

var _reproductores := {}
var _ultima_vez := {}
var _musica: AudioStreamPlayer
var _pista_actual := ""
var _personaje_anterior: DatosPersonaje


func _ready() -> void:
	# La interfaz suena también con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_musica = AudioStreamPlayer.new()
	_musica.bus = "Musica"
	add_child(_musica)

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
	BusEventos.elite_exploto.connect(func(_posicion): sonar("explosion"))
	BusEventos.transicion_fase.connect(_al_empezar_transicion)
	# La fase 2 suena con la música de la partida, pero más grave.
	BusEventos.fase_cambiada.connect(func(_fase): _poner_musica("musica_partida", 0.85))
	BusEventos.jefe_final_aparecio.connect(_al_aparecer_jefe_final)
	BusEventos.jefe_final_forma_cambiada.connect(_al_cambiar_forma_jefe_final)
	BusEventos.jefe_final_ataco.connect(func(ataque): sonar(SONIDO_ATAQUE[ataque][0], SONIDO_ATAQUE[ataque][1]))
	BusEventos.arma_evolucionada.connect(func(_arma): sonar("evolucion"))
	BusEventos.ulti_lanzada.connect(_al_lanzar_ulti)
	BusEventos.juego_pausado.connect(_al_pausar)
	BusEventos.partida_terminada.connect(_al_terminar)
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


func _al_cambiar_escena() -> void:
	_personaje_anterior = null
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


func _al_cambiar_personaje(actual: DatosPersonaje, _arma: DatosArma, _siguiente: DatosPersonaje, _espera: float) -> void:
	# La señal llega también al empezar la partida y al evolucionar la
	# herramienta: solo suena si de verdad cambia el personaje.
	if _personaje_anterior != null and actual != _personaje_anterior:
		sonar("cambio")
	_personaje_anterior = actual


func _al_lanzar_ulti(_personaje: DatosPersonaje) -> void:
	sonar("evolucion")
	sonar("explosion", 0.8)


func _al_aparecer_jefe() -> void:
	sonar("alarma_jefe")
	_poner_musica("musica_jefe")


## La música del jefe, algo más rápida.
func _al_aparecer_jefe_final() -> void:
	sonar("alarma_jefe")
	_poner_musica("musica_jefe", 1.1)


func _al_cambiar_forma_jefe_final(_forma: int) -> void:
	sonar("alarma_jefe", 0.8)
	sonar("explosion", 0.7)


## Con el negro, la música se apaga poco a poco y suena una alarma grave. La
## nueva entra con fase_cambiada.
func _al_empezar_transicion(segundos: float) -> void:
	sonar("alarma_jefe", 0.6)
	create_tween().tween_property(_musica, "volume_db", -40.0, segundos * 0.4)


func _al_pausar(en_pausa: bool) -> void:
	sonar("pausa")
	# La música baja mientras dura la pausa.
	_musica.volume_db = -12.0 if en_pausa else 0.0


func _al_terminar(estadisticas: Dictionary) -> void:
	_musica.stop()
	_pista_actual = ""
	sonar("victoria" if estadisticas.victoria else "derrota")


func _al_cambiar_opcion(clave: String, _valor: Variant) -> void:
	# Al mover el volumen de los efectos se oye uno, para saber cómo queda.
	if clave == "volumen_efectos":
		sonar("gema")
