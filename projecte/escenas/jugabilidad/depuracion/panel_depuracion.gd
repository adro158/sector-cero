extends Control

## Panel técnico, no es la interfaz del juego: datos internos para probar el
## juego y enseñarlo por dentro. F3 lo abre y lo cierra y F4 cambia de
## pestaña:
## - Malware: lo que resiste a cada herramienta y lo que está midiendo para
##   el próximo análisis (cuánto falta, a cuál se adaptará y el daño por
##   segundo de cada una). Es el elemento diferencial, visto por dentro.
## - Rendimiento: fps, física, llamadas de dibujo y nodos. Con cientos de
##   enemigos, las llamadas y los nodos apenas suben: la horda es un MultiMesh
##   por tipo, no un nodo por enemigo.
## - Horda: los vivos de cada tipo, cuánta vida tienen de más y cuándo llegan
##   el próximo élite y el jefe.
## - Antivirus: la vida, el nivel, el último golpe y lo que suman las mejoras.
##
## Desde el 05/11 va a la izquierda, junto a la columna de mejoras (abajo a la
## derecha chocaba con el panel del equipo), en pestañas y sin gráficas. Se
## alimenta del BusEventos y, para lo que no viaja por el bus, de los nodos.

const Dibujo := preload("res://escenas/jugabilidad/depuracion/dibujo_panel_tecnico.gd")
const Dificultad := preload("res://globales/dificultad.gd")
enum Pestana { MALWARE, RENDIMIENTO, HORDA, ANTIVIRUS }
const NOMBRES := ["MALWARE", "RENDIMIENTO", "HORDA", "ANTIVIRUS"]
const ICONOS := [Dibujo.Icono.RESISTENCIA, Dibujo.Icono.SISTEMA, Dibujo.Icono.HORDA, Dibujo.Icono.ANTIVIRUS]
## A la derecha de la columna de mejoras del HUD (hud.gd, en x 16 e y 104).
const POSICION := Vector2(80.0, 104.0)

var _pestana := Pestana.MALWARE
var _vida := 0.0
var _vida_maxima := 0.0
var _nivel := 1
var _ultimo_golpe := 0.0
## Para el piloto y el aviso, que laten también en pausa.
var _segundos := 0.0
## Por herramienta (DatosArma): [icono de su mejora, color de su personaje].
var _herramientas := {}
## El alto que ocupó el último dibujo: el panel mide lo que mide su contenido.
var _alto := 200.0
var _resistencia_malware: Node
var _director: Node
var _gestor_armas: Node


func _ready() -> void:
	# Sigue actualizándose con el juego pausado, para poder consultarlo mientras
	# se elige una mejora.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	theme = EstiloInterfaz.tema()
	position = POSICION
	custom_minimum_size = Vector2(Dibujo.ANCHO, _alto)

	var raiz := get_tree().get_first_node_in_group("jugador").get_parent()
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")
	_director = raiz.get_node("DirectorOleadas")
	_gestor_armas = raiz.get_node("Jugador/GestorArmas")
	_conocer_herramientas(raiz)

	BusEventos.salud_jugador_cambiada.connect(func(actual, maxima):
		_vida = actual
		_vida_maxima = maxima)
	BusEventos.experiencia_cambiada.connect(func(_actual, _necesaria, nivel): _nivel = nivel)
	# El golpe, de su señal y no restando vidas: al cambiar a un personaje con
	# menos vida, la vida baja sin que nadie haya pegado.
	BusEventos.jugador_danado.connect(func(cantidad): _ultimo_golpe = cantidad)


## El icono y el color de cada herramienta, sacados de los datos y no escritos
## a mano: el color, del personaje que la lleva; el icono, de su evolución en
## el pool de mejoras, que es el mismo para la base y para la evolucionada.
func _conocer_herramientas(raiz: Node) -> void:
	var colores := {}
	for personaje in raiz.get_node("Jugador/CambioPersonaje").personajes:
		colores[personaje.arma] = personaje.color
	for evolucion in raiz.get_node("SistemaNiveles").pool_mejoras.evoluciones:
		var datos := [evolucion.icono, colores.get(evolucion.arma_base, Dibujo.COLOR)]
		_herramientas[evolucion.arma_base] = datos
		_herramientas[evolucion.arma] = datos


func _unhandled_input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode == KEY_F3:
		visible = not visible
	elif evento.keycode == KEY_F4 and visible:
		_pestana = (_pestana + 1) % NOMBRES.size() as Pestana


func _process(delta: float) -> void:
	# En segundos reales: delta va escalado con la velocidad x4 del F1 y con el
	# frenazo del tiempo de golpe.
	_segundos += delta / Engine.time_scale
	if visible:
		custom_minimum_size = Vector2(Dibujo.ANCHO, _alto)
		queue_redraw()


func _draw() -> void:
	var y := Dibujo.marco(self, size.y, _segundos)
	y = Dibujo.pestanas(self, y, ICONOS, _pestana)
	y = Dibujo.cabecera(self, y, ICONOS[_pestana], NOMBRES[_pestana])
	match _pestana:
		Pestana.MALWARE:
			y = _malware(y)
		Pestana.RENDIMIENTO:
			y = _rendimiento(y)
		Pestana.HORDA:
			y = _horda(y)
		Pestana.ANTIVIRUS:
			y = _antivirus(y)
	_alto = y + 6.0


## Llena, la barra es el máximo que puede llegar a resistir.
func _malware(y: float) -> float:
	var malware := _resistencia_malware
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.ANALISIS), "próximo análisis", "%d s" % ceili(malware.falta_analisis()))
	var objetivo: DatosArma = malware.mas_usada()
	var nombre := objetivo.nombre if objetivo != null else "ninguna"
	var color: Color = _herramienta(objetivo)[1] if objetivo != null else Color.WHITE
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.OBJETIVO), "se adaptará a", nombre, Dibujo.COLOR, color)
	var resistencias: Dictionary = malware.resistencias()
	if resistencias.is_empty():
		y = Dibujo.ninguna(self, y)
	for arma in resistencias:
		y = Dibujo.fila_resistencia(self, y, _herramienta(arma), arma.nombre, resistencias[arma], malware.maximo, _segundos)
	# El daño por segundo, el de este ciclo: lo que el malware está midiendo.
	y = Dibujo.subtitulo(self, y, "daño por segundo")
	var segundos := maxf(malware.tiempo_ciclo(), 1.0)
	var dano: Dictionary = malware.dano_ciclo()
	for arma in dano:
		y = Dibujo.fila(self, y, _herramienta(arma)[0], arma.nombre, "%d" % roundi(dano[arma] / segundos), Color.WHITE)
	return y


func _rendimiento(y: float) -> float:
	y = Dibujo.fila(self, y, _icono(Dibujo.Icono.FPS), "fps", "%d" % Engine.get_frames_per_second())
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.FISICA), "física", "%.1f ms" % (Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0))
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.DIBUJO), "llamadas de dibujo", "%d" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.NODOS), "nodos", "%d" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var vivos := 0
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		vivos += gestor.vivos()
	return Dibujo.fila(self, y, _icono(Dibujo.Icono.EN_PANTALLA), "enemigos vivos", str(vivos))


func _horda(y: float) -> float:
	var gestores := get_tree().get_nodes_in_group("gestor_enemigos")
	for gestor in gestores:
		y = Dibujo.fila(self, y, gestor.datos.textura, gestor.datos.nombre, str(gestor.vivos()), Color.WHITE)
	# La vida de más de la horda: por el nivel del jugador, por el minuto y por
	# la dificultad (la misma cuenta para todos los tipos).
	var datos: DatosTipoEnemigo = gestores[0].datos
	var escala: float = datos.vida_para(_nivel, _director.tiempo()) / datos.vida * Dificultad.dato("vida")
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.ESCALA), "vida de la horda", "x%.2f" % escala)
	var elite: float = _director.falta_elite()
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.ELITE), "próximo élite", "en %d s" % ceili(elite) if elite >= 0.0 else "-")
	var jefe: float = _director.duracion() - _director.tiempo()
	var quien := "jefe" if _director.fase() == 1 else "jefe final"
	return Dibujo.fila(self, y, _icono2(Dibujo.Icono2.JEFE), quien, "en %s" % _reloj(jefe) if jefe > 0.0 else "en juego")


func _antivirus(y: float) -> float:
	y = Dibujo.fila_vida(self, y, _vida, _vida_maxima)
	y = Dibujo.fila(self, y, _icono(Dibujo.Icono.NIVEL), "nivel", str(_nivel))
	y = Dibujo.fila(self, y, _icono(Dibujo.Icono.GOLPE), "último golpe", "-%.0f" % _ultimo_golpe if _ultimo_golpe > 0.0 else "-")
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.DANO), "daño", "x%.2f" % _gestor_armas.multiplicador_dano)
	# multiplicador_cadencia multiplica la espera entre ataques: 0,8 es atacar
	# un 25 % más a menudo. Se enseña al revés, como velocidad.
	y = Dibujo.fila(self, y, _icono2(Dibujo.Icono2.CADENCIA), "cadencia", "x%.2f" % (1.0 / _gestor_armas.multiplicador_cadencia))
	return Dibujo.fila(self, y, _icono(Dibujo.Icono.EN_PANTALLA), "alcance", "x%.2f" % _gestor_armas.multiplicador_alcance)


func _icono(cual: Dibujo.Icono) -> AtlasTexture:
	return Dibujo.icono(Dibujo.ICONOS, cual)


func _icono2(cual: Dibujo.Icono2) -> AtlasTexture:
	return Dibujo.icono(Dibujo.ICONOS_2, cual)


func _herramienta(arma: DatosArma) -> Array:
	return _herramientas.get(arma, [null, Dibujo.COLOR])


func _reloj(segundos: float) -> String:
	var enteros := ceili(segundos)
	return "%d:%02d" % [enteros / 60, enteros % 60]
