extends Control

@onready var barra_vida: ProgressBar = $Margen/ContenedorBarras/BarraVida
@onready var etiqueta_nivel: Label = $Margen/ContenedorBarras/EtiquetaNivel

@onready var menu_subida_nivel: PanelContainer = $MenuSubidaNivel
@onready var tarjeta_1: Button = $MenuSubidaNivel/ContenedorVertical/ContenedorTarjetas/Tarjeta1
@onready var tarjeta_2: Button = $MenuSubidaNivel/ContenedorVertical/ContenedorTarjetas/Tarjeta2
@onready var tarjeta_3: Button = $MenuSubidaNivel/ContenedorVertical/ContenedorTarjetas/Tarjeta3

var nivel_actual: int = 1

func _ready() -> void:
	# Ocultamos el menu de subida de nivel al arrancar
	menu_subida_nivel.visible = false
	
	# Nos conectamos a las señales del autoload BusEventos
	BusEventos.salud_jugador_cambiada.connect(_on_salud_jugador_cambiada)
	BusEventos.jugador_subio_nivel.connect(_on_jugador_subio_nivel)
	
	# Conectamos las pulsaciones de las tarjetas
	tarjeta_1.pressed.connect(func(): _elegir_mejora(0))
	tarjeta_2.pressed.connect(func(): _elegir_mejora(1))
	tarjeta_3.pressed.connect(func(): _elegir_mejora(2))

func _on_salud_jugador_cambiada(actual: float, maxima: float) -> void:
	barra_vida.max_value = maxima
	barra_vida.value = actual

func _on_jugador_subio_nivel(_opciones: Array) -> void:
	nivel_actual += 1
	etiqueta_nivel.text = "NIVEL: %d" % nivel_actual
	menu_subida_nivel.visible = true

func _elegir_mejora(_indice: int) -> void:
	menu_subida_nivel.visible = false
