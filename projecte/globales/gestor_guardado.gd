extends Node

## Persistencia: los récords de partida y las opciones del jugador. Se guardan
## en un ConfigFile, el formato de Godot para pares clave-valor por secciones:
## se lee y se escribe con una llamada y el fichero es texto legible.
##
## Vive en user://, la carpeta de datos del usuario que Godot reserva para cada
## juego (en Windows, %APPDATA%/Godot/app_userdata/Sector Cero). Dentro del
## ejecutable exportado res:// es de solo lectura.

signal opcion_cambiada(clave: String, valor: Variant)

const RUTA := "user://sector_cero.cfg"

const OPCIONES_POR_DEFECTO := {
	"volumen_musica": 0.6,
	"volumen_efectos": 0.8,
	"pantalla_completa": false,
	"crt": true,
}

## Los récords que se comparan al terminar cada partida. Son las mismas claves
## que trae el diccionario de partida_terminada.
const RECORDS := ["tiempo", "nivel", "eliminados"]

## Los récords que ha batido la última partida, para que la pantalla final los
## anuncie. Vacío en la primera partida: cualquier resultado sería un récord.
var records_batidos: Array[String] = []

var _fichero := ConfigFile.new()


func _ready() -> void:
	# La primera vez el fichero no existe y load devuelve un error: no pasa
	# nada, se usan los valores por defecto hasta que se guarde algo.
	_fichero.load(RUTA)
	for clave in OPCIONES_POR_DEFECTO:
		_aplicar(clave, opcion(clave))
	BusEventos.partida_terminada.connect(_al_terminar_partida)


func opcion(clave: String) -> Variant:
	return _fichero.get_value("opciones", clave, OPCIONES_POR_DEFECTO[clave])


func cambiar_opcion(clave: String, valor: Variant) -> void:
	_fichero.set_value("opciones", clave, valor)
	_fichero.save(RUTA)
	_aplicar(clave, valor)
	opcion_cambiada.emit(clave, valor)


## Récords: tiempo, nivel y eliminados de la mejor partida en cada cosa, y los
## contadores partidas y victorias. Cero si todavía no hay ninguno.
func record(clave: String) -> float:
	return _fichero.get_value("records", clave, 0)


func _al_terminar_partida(estadisticas: Dictionary) -> void:
	var habia_partidas := record("partidas") > 0
	records_batidos.clear()

	for clave in RECORDS:
		if estadisticas[clave] > record(clave):
			_fichero.set_value("records", clave, estadisticas[clave])
			if habia_partidas:
				records_batidos.append(clave)

	_fichero.set_value("records", "partidas", record("partidas") + 1)
	if estadisticas.victoria:
		_fichero.set_value("records", "victorias", record("victorias") + 1)
	_fichero.save(RUTA)


func _aplicar(clave: String, valor: Variant) -> void:
	match clave:
		"volumen_musica":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Musica"), valor)
		"volumen_efectos":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Efectos"), valor)
		"pantalla_completa":
			get_window().mode = Window.MODE_FULLSCREEN if valor else Window.MODE_WINDOWED
		# El filtro CRT lo aplica su propia capa al recibir opcion_cambiada.
