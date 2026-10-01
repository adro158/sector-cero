extends CanvasLayer

## Filtro CRT a pantalla completa, encima del juego y de la interfaz. Es un
## autoload para que esté en todas las escenas sin añadirlo a cada una. Se
## enciende y se apaga desde las opciones.


func _ready() -> void:
	# Por encima del juego, el HUD y el panel técnico; por debajo del fundido.
	layer = 110

	var filtro := ColorRect.new()
	var material := ShaderMaterial.new()
	material.shader = preload("res://medios/shaders/crt.gdshader")
	filtro.material = material
	filtro.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Que los clicks lo atraviesen hasta los botones de debajo.
	filtro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(filtro)

	visible = GestorGuardado.opcion("crt")
	GestorGuardado.opcion_cambiada.connect(_al_cambiar_opcion)


func _al_cambiar_opcion(clave: String, valor: Variant) -> void:
	if clave == "crt":
		visible = valor
