extends SceneTree

## Herramienta de testeo, no forma parte del juego: mide el rendimiento con la
## horda llena. Mantiene una cantidad fija de enemigos persiguiendo al jugador
## (con vida infinita, para que las armas les sigan pegando sin matarlos) y
## mide durante unos segundos los fotogramas por segundo y lo que tarda la
## física en cada paso, para 100, 300, 600 y 1200 enemigos.
##
## Se ejecuta con ventana, porque en headless no se dibuja nada y los FPS no
## significan nada, y sin sincronización vertical, para ver el margen real:
##
##   Godot --path . --script res://herramientas/medir_rendimiento.gd
##
## Lee y cambia campos internos de los nodos (los que empiezan por _); en el
## código del juego eso no se hace.

const CANTIDADES := [100, 300, 600, 1200]
const SEGUNDOS_POR_MEDIDA := 5.0

var _gestores: Array = []
var _jugador: Node2D


func _initialize() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var bus := root.get_node("BusEventos")
	bus.partida_terminada.disconnect.call_deferred(root.get_node("GestorGuardado")._al_terminar_partida)
	_medir.call_deferred()


func _medir() -> void:
	var juego: Node = load("res://escenas/juego.tscn").instantiate()
	root.add_child(juego)
	await physics_frame
	await physics_frame

	var raiz := juego.get_node("RaizJuego")
	_jugador = raiz.get_node("Jugador")
	# Ni reloj ni apariciones propias: aquí los enemigos los pone la medida.
	raiz.get_node("DirectorOleadas").set_physics_process(false)
	var salud = _jugador.get_node("Salud")
	salud.vida_maxima = 1.0e9
	salud._vida = 1.0e9
	_gestores = get_nodes_in_group("gestor_enemigos")
	for gestor in _gestores:
		gestor.datos.vida = 1.0e9

	print("GPU: ", RenderingServer.get_video_adapter_name(), " · ", RenderingServer.get_video_adapter_api_version())
	for cantidad in CANTIDADES:
		_rellenar(cantidad)
		# Dos segundos para que la horda llegue al jugador y se estabilice. Además,
		# el monitor de tiempo de física se refresca por segundos y el primero
		# incluye lo que tardó en cargar la escena: no es un tirón del juego.
		await create_timer(2.0).timeout

		var fotogramas := 0
		var fisica := PackedFloat32Array()
		var inicio := Time.get_ticks_usec()
		while Time.get_ticks_usec() - inicio < SEGUNDOS_POR_MEDIDA * 1000000.0:
			await process_frame
			fotogramas += 1
			fisica.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
		var segundos := (Time.get_ticks_usec() - inicio) / 1000000.0
		# La mediana y no la media: un tirón suelto (cargar un sonido la primera
		# vez, por ejemplo) no debe deformar la medida. El máximo se da aparte.
		fisica.sort()
		print("%5d enemigos: %6.0f FPS · física %5.2f ms por paso (peor %5.2f ms; presupuesto a 60 FPS: 16,67 ms)" % [
			_vivos(), fotogramas / segundos, fisica[fisica.size() / 2], fisica[fisica.size() - 1]])
	quit()


## Reparte enemigos entre los tres tipos hasta llegar a la cantidad, en un
## anillo alrededor del jugador.
func _rellenar(cantidad: int) -> void:
	var i := 0
	# El tope de vueltas evita un bucle infinito si los gestores se llenan.
	while _vivos() < cantidad and i < cantidad * 2:
		var posicion := _jugador.global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(300.0, 650.0)
		_gestores[i % _gestores.size()].aparecer(posicion)
		i += 1


func _vivos() -> int:
	var total := 0
	for gestor in _gestores:
		total += gestor.vivos()
	return total
