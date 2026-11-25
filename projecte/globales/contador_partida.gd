extends Node

## Lo que se cuenta durante una partida para las misiones y los logros (de
## Alan, 19/11): cofres, ultis, cambios de personaje, evoluciones, si se ha
## derrotado a Kernel Panic y lo eliminado con cada personaje. Lo demás (el
## tiempo, la victoria, la dificultad...) llega al final en partida_terminada.
## Escucha el bus: no toca ningún fichero de la partida.
##
## Empieza de cero cada vez que entra en el árbol una partida (un nodo
## RaizJuego), así lo de una partida abandonada no pasa a la siguiente.
##
## Hijo de cartera.gd. Sin class_name: se carga con preload.

var _cofres := 0
var _ultis := 0
var _cambios := 0
var _evoluciones := 0
var _kernel := false
## El personaje que lleva el jugador de este ordenador ahora (su nombre).
var _personaje := ""
## Lo eliminado mientras llevaba cada personaje: {"Mago": 120}.
var _eliminados_con := {}
## El primer personaje_cambiado de cada partida es el de empezar, no un cambio.
var _primer_aviso := true


func _ready() -> void:
	get_tree().node_added.connect(_al_entrar_nodo)
	BusEventos.cofre_recogido.connect(_al_recoger_cofre)
	BusEventos.ulti_lanzada.connect(_al_lanzar_ulti)
	BusEventos.arma_evolucionada.connect(_al_evolucionar)
	BusEventos.personaje_cambiado.connect(_al_cambiar_personaje)
	BusEventos.fase_cambiada.connect(_al_cambiar_fase)
	BusEventos.enemigo_muerto.connect(_al_morir_enemigo)


func empezar() -> void:
	_cofres = 0
	_ultis = 0
	_cambios = 0
	_evoluciones = 0
	_kernel = false
	_personaje = ""
	_eliminados_con = {}
	_primer_aviso = true


## La partida entera, para misiones.gd y logros.gd: lo contado aquí y lo que
## trae partida_terminada. El personaje es el de este ordenador (en red, las
## estadísticas son las del anfitrión).
func resumen(estadisticas: Dictionary) -> Dictionary:
	var victoria: bool = estadisticas.get("victoria", false)
	var en_red: bool = estadisticas.get("en_red", false)
	var dificil: bool = estadisticas.get("dificultad", "") == "dificil"
	return {
		"tiempo": int(estadisticas.get("tiempo", 0.0)),
		"victoria": 1 if victoria else 0,
		"victoria_dificil": 1 if victoria and dificil else 0,
		"eliminados": int(estadisticas.get("eliminados", 0)),
		"personaje": _personaje if _personaje != "" else str(estadisticas.get("personaje", "")),
		"partidas": 1,
		"partidas_red": 1 if en_red else 0,
		"en_red": en_red,
		"fase2": 1 if _kernel or victoria else 0,
		"cofres": _cofres,
		"ultis": _ultis,
		"cambios": _cambios,
		"evoluciones": _evoluciones,
		"eliminados_con": _eliminados_con.duplicate(),
	}


func _al_entrar_nodo(nodo: Node) -> void:
	if nodo.name == "RaizJuego":
		empezar()


func _al_recoger_cofre() -> void:
	_cofres += 1


## Solo las del personaje que lleva este jugador: en red llegan también las de
## los compañeros.
func _al_lanzar_ulti(personaje: DatosPersonaje) -> void:
	if personaje.nombre == _personaje:
		_ultis += 1


func _al_evolucionar(_arma: DatosArma) -> void:
	_evoluciones += 1


func _al_cambiar_personaje(actual: DatosPersonaje, _arma: DatosArma, _siguiente: DatosPersonaje, _espera: float) -> void:
	if not _primer_aviso and actual.nombre != _personaje:
		_cambios += 1
	_primer_aviso = false
	_personaje = actual.nombre


## La fase 2 empieza al derrotar a Kernel Panic.
func _al_cambiar_fase(fase: int) -> void:
	if fase == 2:
		_kernel = true


func _al_morir_enemigo(_posicion: Vector2, tipo: String) -> void:
	if tipo != "jefe" and _personaje != "":
		_eliminados_con[_personaje] = _eliminados_con.get(_personaje, 0) + 1
