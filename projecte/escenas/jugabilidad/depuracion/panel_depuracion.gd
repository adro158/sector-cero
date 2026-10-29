extends Control

## Panel técnico, no es la interfaz del juego: datos internos para probar y
## enseñar el sistema, sobre todo la resistencia del malware. Se muestra y se
## oculta con F3. Se alimenta de las señales del BusEventos y, para lo que no
## viaja por el bus (enemigos en pantalla, resistencias), de los grupos.
##
## Desde el 29/10 se dibuja con sprites, como una terminal (el dibujo va en
## dibujo_panel_tecnico.gd), y tiene dos gráficas: los fps del último minuto y
## la resistencia a cada herramienta en los dos últimos. Aquí se guardan sus
## muestras.

const Dibujo := preload("res://escenas/jugabilidad/depuracion/dibujo_panel_tecnico.gd")
## Cada gráfica guarda sus últimas 60 muestras: los fps, una por segundo, y
## cada resistencia, una cada 2 s. Así, en dos minutos se ven los escalones de
## cada análisis del malware (cada 20 s).
const MUESTRAS := 60
const CADA_FPS := 1.0
const CADA_RESISTENCIA := 2.0

var _vida := 0.0
var _vida_maxima := 0.0
var _experiencia := 0
var _nivel := 1
var _muertos := 0
var _tiempo := 0.0
var _ultimo_golpe := 0.0
var _fps := PackedFloat32Array()
## Por herramienta (DatosArma), sus últimas resistencias.
var _historia := {}
var _desde_fps := 0.0
var _desde_resistencia := 0.0
## Para el piloto y el aviso, que laten también en pausa.
var _segundos := 0.0
## Por herramienta (DatosArma): [icono de su mejora, color de su personaje].
var _herramientas := {}
## El máximo de la gráfica de los fps: el refresco de la pantalla, que es lo
## más que se dibuja (240 en la de Adam, 60 en una normal).
var _fps_maximo := 60.0
## El alto que ocupó el último dibujo: el panel mide lo que mide su contenido.
var _alto := 400.0
var _resistencia_malware: Node


func _ready() -> void:
	# Sigue actualizándose con el juego pausado, para poder consultarlo mientras
	# se elige una mejora.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	theme = EstiloInterfaz.tema()
	# Abajo a la derecha: la izquierda es del HUD y arriba a la derecha sale la
	# ficha del enemigo pinchado. Los bordes en el mismo punto y creciendo hacia
	# la izquierda y hacia arriba: el panel ocupa solo lo que mide su contenido.
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	offset_left = -16.0
	offset_right = -16.0
	offset_top = -16.0
	offset_bottom = -16.0
	custom_minimum_size = Vector2(Dibujo.ANCHO, _alto)

	_fps.resize(MUESTRAS)
	_fps_maximo = maxf(roundf(DisplayServer.screen_get_refresh_rate()), 60.0)
	_resistencia_malware = get_tree().get_first_node_in_group("resistencia_malware")
	_conocer_herramientas()

	BusEventos.salud_jugador_cambiada.connect(_al_cambiar_vida)
	BusEventos.experiencia_ganada.connect(func(cantidad): _experiencia += cantidad)
	BusEventos.experiencia_cambiada.connect(func(_actual, _necesaria, nivel): _nivel = nivel)
	BusEventos.enemigo_muerto.connect(func(_posicion, _tipo): _muertos += 1)
	# El reloj de la partida, el mismo que el del HUD: se para con el jefe.
	BusEventos.tiempo_partida.connect(func(segundos, _duracion): _tiempo = segundos)


## El icono y el color de cada herramienta, sacados de los datos y no escritos
## a mano: el color, del personaje que la lleva; el icono, de su evolución en
## el pool de mejoras, que es el mismo para la base y para la evolucionada.
func _conocer_herramientas() -> void:
	var raiz := get_tree().get_first_node_in_group("jugador").get_parent()
	var colores := {}
	for personaje in raiz.get_node("Jugador/CambioPersonaje").personajes:
		colores[personaje.arma] = personaje.color
	for evolucion in raiz.get_node("SistemaNiveles").pool_mejoras.evoluciones:
		var datos := [evolucion.icono, colores.get(evolucion.arma_base, Dibujo.COLOR)]
		_herramientas[evolucion.arma_base] = datos
		_herramientas[evolucion.arma] = datos


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and evento.keycode == KEY_F3:
		visible = not visible


## Las gráficas se llenan aunque el panel esté cerrado: al abrirlo ya se ve
## lo que ha pasado. En pausa no avanzan.
func _process(delta: float) -> void:
	_segundos += delta
	if not get_tree().paused:
		_desde_fps += delta
		if _desde_fps >= CADA_FPS:
			_desde_fps -= CADA_FPS
			_meter(_fps, Engine.get_frames_per_second())
		_desde_resistencia += delta
		if _desde_resistencia >= CADA_RESISTENCIA:
			_desde_resistencia -= CADA_RESISTENCIA
			_muestrear_resistencias()
	if visible:
		custom_minimum_size = Vector2(Dibujo.ANCHO, _alto)
		queue_redraw()


## Una muestra nueva al final y la más vieja fuera.
func _meter(muestras: PackedFloat32Array, valor: float) -> void:
	muestras.remove_at(0)
	muestras.append(valor)


## Una muestra por herramienta. La que aparece empieza con todas a cero, para
## que su línea salga desde abajo; la que ya no tiene resistencia, a cero.
func _muestrear_resistencias() -> void:
	var actuales: Dictionary = _resistencia_malware.resistencias()
	for arma in actuales:
		if not _historia.has(arma):
			var nueva := PackedFloat32Array()
			nueva.resize(MUESTRAS)
			_historia[arma] = nueva
	for arma in _historia:
		_meter(_historia[arma], actuales.get(arma, 0.0))


func _draw() -> void:
	var y := Dibujo.marco(self, size.y, _segundos)
	y = Dibujo.cabecera(self, y, Dibujo.Icono.SISTEMA, "SISTEMA")
	y = Dibujo.fila(self, y, Dibujo.Icono.TIEMPO, "tiempo", "%02d:%02d" % [int(_tiempo) / 60, int(_tiempo) % 60])
	y = Dibujo.fila(self, y, Dibujo.Icono.FPS, "fps", str(Engine.get_frames_per_second()))
	y = Dibujo.grafica(self, y, [[_fps, Dibujo.COLOR]], _fps_maximo, str(int(_fps_maximo)))

	y = Dibujo.cabecera(self, y, Dibujo.Icono.ANTIVIRUS, "ANTIVIRUS")
	y = Dibujo.fila_vida(self, y, _vida, _vida_maxima)
	y = Dibujo.fila(self, y, Dibujo.Icono.NIVEL, "nivel", str(_nivel))
	y = Dibujo.fila(self, y, Dibujo.Icono.EXPERIENCIA, "experiencia", str(_experiencia))
	y = Dibujo.fila(self, y, Dibujo.Icono.GOLPE, "último golpe", "-%.0f" % _ultimo_golpe)

	y = Dibujo.cabecera(self, y, Dibujo.Icono.HORDA, "HORDA")
	y = Dibujo.fila(self, y, Dibujo.Icono.EN_PANTALLA, "en pantalla", str(_enemigos_vivos()))
	y = Dibujo.fila(self, y, Dibujo.Icono.ELIMINADOS, "eliminados", str(_muertos))

	# Llena, la barra y la gráfica son el máximo que puede llegar a resistir.
	y = Dibujo.cabecera(self, y, Dibujo.Icono.RESISTENCIA, "RESISTENCIA MALWARE")
	var maximo: float = _resistencia_malware.maximo
	var resistencias: Dictionary = _resistencia_malware.resistencias()
	if resistencias.is_empty():
		y = Dibujo.ninguna(self, y)
	for arma in resistencias:
		y = Dibujo.fila_resistencia(self, y, _herramienta(arma), arma.nombre, resistencias[arma], maximo, _segundos)
	var series := []
	for arma in _historia:
		series.append([_historia[arma], _herramienta(arma)[1]])
	y = Dibujo.grafica(self, y, series, maximo, "%d%%" % roundi(maximo * 100.0))
	_alto = y + 6.0


func _herramienta(arma: DatosArma) -> Array:
	return _herramientas.get(arma, [null, Dibujo.COLOR])


func _enemigos_vivos() -> int:
	var total := 0
	for gestor in get_tree().get_nodes_in_group("gestor_enemigos"):
		total += gestor.vivos()
	return total


func _al_cambiar_vida(actual: float, maxima: float) -> void:
	if _vida_maxima > 0.0 and actual < _vida:
		_ultimo_golpe = _vida - actual
	_vida = actual
	_vida_maxima = maxima
