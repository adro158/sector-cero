extends Control

@onready var barra_vida: ProgressBar = $Margen/ContenedorBarras/BarraVida
@onready var etiqueta_nivel: Label = $Margen/ContenedorBarras/EtiquetaNivel

@onready var menu_subida_nivel: PanelContainer = $MenuSubidaNivel
@onready var tarjeta_1: Button = $MenuSubidaNivel/ContenedorVertical/ContenedorTarjetas/Tarjeta1
@onready var tarjeta_2: Button = $MenuSubidaNivel/ContenedorVertical/ContenedorTarjetas/Tarjeta2
@onready var tarjeta_3: Button = $MenuSubidaNivel/ContenedorVertical/ContenedorTarjetas/Tarjeta3

var nivel_actual: int = 1
var _opciones: Array = []

func _ready() -> void:
	# Permite que la UI siga recibiendo clics aunque el juego este pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	menu_subida_nivel.visible = false
	
	# Conexión a eventos globales
	BusEventos.salud_jugador_cambiada.connect(_on_salud_jugador_cambiada)
	BusEventos.jugador_subio_nivel.connect(_on_jugador_subio_nivel)
	
	# Conexión a los botones de mejora
	tarjeta_1.pressed.connect(func(): _elegir_mejora(0))
	tarjeta_2.pressed.connect(func(): _elegir_mejora(1))
	tarjeta_3.pressed.connect(func(): _elegir_mejora(2))

func _on_salud_jugador_cambiada(actual: float, maxima: float) -> void:
	barra_vida.max_value = maxima
	barra_vida.value = actual

func _on_jugador_subio_nivel(opciones: Array) -> void:
	_opciones = opciones
	nivel_actual += 1
	etiqueta_nivel.text = "NIVEL: %d" % nivel_actual
	
	var tarjetas := [tarjeta_1, tarjeta_2, tarjeta_3]
	for i in tarjetas.size():
		tarjetas[i].visible = i < opciones.size()
		if i < opciones.size():
			tarjetas[i].text = "%s\n\n%s" % [opciones[i].nombre, opciones[i].descripcion]
	
	menu_subida_nivel.visible = true
	get_tree().paused = true

func _elegir_mejora(indice: int) -> void:
	menu_subida_nivel.visible = false
	get_tree().paused = false
	if indice < _opciones.size():
		BusEventos.mejora_seleccionada.emit(_opciones[indice])
