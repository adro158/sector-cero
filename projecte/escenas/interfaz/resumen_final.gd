extends RefCounted

## Lo que enseña la pantalla final de la partida (pantalla_final.gd): las
## tarjetas de datos y lo que hizo cada personaje. Va aparte para que
## pantalla_final.gd se quede con el orden de la ventana, el ranking y los
## botones.
##
## Sin class_name: se carga con preload.

const Dificultad := preload("res://globales/dificultad.gd")
const FilaPartida := preload("res://escenas/interfaz/fila_partida.gd")
## Normal y la del récord, de 48x48 y márgenes 12.
const TARJETA := preload("res://medios/interfaz/final_tarjeta.png")
const ANCHO_TARJETA := 132.0


## Una tarjeta por dato: tiempo, nivel, malware eliminado y dificultad. Las
## de un récord batido (claves de GestorGuardado.records_batidos) llevan otro
## borde, la estrella y «RÉCORD», y laten.
static func tarjetas(estadisticas: Dictionary, batidos: Array) -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 12)
	var tiempo := int(estadisticas.tiempo)
	var dificultad: String = estadisticas.get("dificultad", "media")
	for dato in [
		["tiempo", 0, "%02d:%02d" % [tiempo / 60, tiempo % 60], "TIEMPO", EstiloInterfaz.NEON],
		["nivel", 1, str(estadisticas.nivel), "NIVEL", EstiloInterfaz.NEON],
		["eliminados", 2, str(estadisticas.eliminados), "ELIMINADOS", EstiloInterfaz.NEON],
		["", 3, Dificultad.DIFICULTADES[dificultad].nombre, "DIFICULTAD", FilaPartida.COLORES_DIFICULTAD[dificultad]],
	]:
		fila.add_child(_tarjeta(dato[1], dato[2], dato[3], dato[4], dato[0] in batidos))
	return fila


static func _tarjeta(icono: int, valor: String, nombre: String, color: Color, record: bool) -> PanelContainer:
	var tarjeta := PanelContainer.new()
	var estilo := FilaPartida.estilo(TARJETA, 1 if record else 0, Vector2(48, 48), 12, EstiloInterfaz.NEON if record else EstiloInterfaz.TEXTO_SUAVE, 10, 8)
	tarjeta.add_theme_stylebox_override("panel", estilo)
	tarjeta.custom_minimum_size.x = ANCHO_TARJETA * EstiloInterfaz.tamano_texto(100) / 100.0
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 2)
	# El icono del dato y, si es récord, la estrella al lado.
	var iconos := HBoxContainer.new()
	iconos.alignment = BoxContainer.ALIGNMENT_CENTER
	if record:
		iconos.add_child(_icono(6, EstiloInterfaz.NEON))
	iconos.add_child(_icono(icono, EstiloInterfaz.NEON if record else color))
	caja.add_child(iconos)
	for texto in [[valor, 22, EstiloInterfaz.TEXTO], [nombre + (" · RÉCORD" if record else ""), 12, EstiloInterfaz.NEON if record else EstiloInterfaz.TEXTO_SUAVE]]:
		var etiqueta := EstiloInterfaz.etiqueta(texto[0], texto[1], texto[2])
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(etiqueta)
	tarjeta.add_child(caja)
	if record:
		# Late, para que se vea que es una novedad.
		var latido := tarjeta.create_tween().set_loops()
		latido.tween_property(tarjeta, "modulate", Color(1.4, 1.4, 1.4), 0.5)
		latido.tween_property(tarjeta, "modulate", Color.WHITE, 0.5)
	return tarjeta


## Un icono de final_iconos.png al doble: a tamaño real se perdía al lado del
## número.
static func _icono(indice: int, color: Color) -> TextureRect:
	var dibujo := TextureRect.new()
	dibujo.texture = FilaPartida.trozo(FilaPartida.ICONOS, indice, 16)
	dibujo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	dibujo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dibujo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dibujo.custom_minimum_size = Vector2(32, 32)
	dibujo.modulate = color
	return dibujo


## Una columna por personaje: su retrato (en gris si cayó) y la parte del daño
## que hizo su herramienta, en una barra de su color. Enseña que cambiar de
## personaje sirvió.
static func equipo(personajes: Array) -> HBoxContainer:
	var total := 0.0
	for datos in personajes:
		total += datos.dano
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 28)
	for datos in personajes:
		var personaje: DatosPersonaje = datos.personaje
		var columna := VBoxContainer.new()
		columna.add_theme_constant_override("separation", 4)
		var retrato := TextureRect.new()
		retrato.texture = personaje.retrato
		retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		retrato.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		retrato.modulate = Color(0.45, 0.45, 0.45) if datos.caido else Color.WHITE
		columna.add_child(retrato)
		var parte: float = datos.dano / total if total > 0.0 else 0.0
		var nombre := EstiloInterfaz.etiqueta("%s%s" % [personaje.nombre.to_upper(), "  (caído)" if datos.caido else ""], 13, personaje.color)
		nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columna.add_child(nombre)
		var barra := ProgressBar.new()
		barra.custom_minimum_size = Vector2(150, 8)
		barra.show_percentage = false
		barra.max_value = 1.0
		barra.value = parte
		var fondo := StyleBoxFlat.new()
		fondo.bg_color = Color(0.1, 0.15, 0.2)
		var relleno := StyleBoxFlat.new()
		relleno.bg_color = personaje.color
		barra.add_theme_stylebox_override("background", fondo)
		barra.add_theme_stylebox_override("fill", relleno)
		columna.add_child(barra)
		var cifra := EstiloInterfaz.etiqueta("%d %% del daño" % roundi(parte * 100.0), 13, EstiloInterfaz.TEXTO_SUAVE)
		cifra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columna.add_child(cifra)
		fila.add_child(columna)
	return fila
