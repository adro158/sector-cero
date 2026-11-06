extends RefCounted

## Una partida en una fila: la usan el ranking (panel_ranking.gd) y «tus
## últimas partidas» de la cuenta (panel_cuenta.gd), para que se vean igual.
## Es una banda de 9 trozos con, de izquierda a derecha: el puesto (medalla en
## los tres primeros) o la fecha, la victoria o la derrota como icono, el
## nombre (solo en el ranking), el tiempo, el nivel, los eliminados, el
## personaje con su mini retrato y la dificultad en un chip de su color.
##
## Sin class_name: se carga con preload.

const Dificultad := preload("res://globales/dificultad.gd")
## Normal y resaltada (la de tu cuenta), de 48x24 y márgenes 6.
const BANDA := preload("res://medios/interfaz/fila_banda.png")
const CHIP := preload("res://medios/interfaz/chip.png")
## 16x16: 0 tiempo, 1 nivel, 2 eliminados, 3 dificultad, 4 victoria, 5
## derrota, 6 récord (también los de la pantalla final).
const ICONOS := preload("res://medios/interfaz/final_iconos.png")
## Oro, plata y bronce en fila, de 16x16 (lote 9).
const MEDALLAS := preload("res://medios/interfaz/medallas_ranking.png")
## Los mini retratos de 32x32 (lote 9), por el nombre que guarda la partida.
const MINI_RETRATOS := {
	"Espadachín": preload("res://medios/interfaz/retrato_mini_espadachin.png"),
	"Mago": preload("res://medios/interfaz/retrato_mini_mago.png"),
	"Segador": preload("res://medios/interfaz/retrato_mini_segador.png"),
}
## El color de cada dificultad, para su chip.
const COLORES_DIFICULTAD := {
	"facil": EstiloInterfaz.VICTORIA,
	"media": Color(1.0, 0.8, 0.25),
	"dificil": EstiloInterfaz.DERROTA,
}
## El borde de los tres primeros, del color de su medalla.
const COLORES_PODIO := [Color(1.0, 0.8, 0.3), Color(0.8, 0.85, 0.9), Color(0.85, 0.55, 0.35)]
## El ancho de cada columna, para que las filas casen como en una tabla. Con
## «Texto grande» crecen como la letra.
const ANCHOS := {"primera": 52, "resultado": 22, "nombre": 150, "tiempo": 64,
	"nivel": 48, "eliminados": 92, "personaje": 140, "dificultad": 90}
const LETRA := 15


## Los títulos de las columnas, alineados con las filas. primera es el de la
## primera columna («#» o «FECHA»).
static func cabecera(primera: String, con_nombre: bool) -> HBoxContainer:
	var fila := _fila_vacia()
	fila.add_child(_celda(primera, "primera", EstiloInterfaz.TEXTO_SUAVE, 13))
	fila.add_child(_celda("", "resultado", EstiloInterfaz.TEXTO_SUAVE, 13))
	if con_nombre:
		fila.add_child(_celda("NOMBRE", "nombre", EstiloInterfaz.TEXTO_SUAVE, 13))
	for titulo in [["TIEMPO", "tiempo"], ["NIVEL", "nivel"], ["ELIMINADOS", "eliminados"], ["PERSONAJE", "personaje"], ["DIFICULTAD", "dificultad"]]:
		fila.add_child(_celda(titulo[0], titulo[1], EstiloInterfaz.TEXTO_SUAVE, 13))
	# El mismo margen que la banda, para que los títulos caigan encima.
	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 10)
	margen.add_child(fila)
	var caja := HBoxContainer.new()
	caja.add_child(margen)
	return caja


## Una partida. primera: el puesto (0 es el primero) para el ranking o la
## fecha («05/11») para la cuenta. resaltada: si es de tu cuenta.
static func crear(partida: Dictionary, primera: Variant, resaltada := false) -> PanelContainer:
	var victoria: bool = partida.victoria
	var color := EstiloInterfaz.VICTORIA if victoria else EstiloInterfaz.TEXTO
	var borde := EstiloInterfaz.TEXTO_SUAVE
	if resaltada:
		borde = EstiloInterfaz.NEON
	elif primera is int and primera < 3:
		borde = COLORES_PODIO[primera]

	var fila := _fila_vacia()
	fila.add_child(_puesto(primera, color))
	fila.add_child(_icono(4 if victoria else 5, EstiloInterfaz.VICTORIA if victoria else EstiloInterfaz.DERROTA, "resultado"))
	if partida.has("nombre"):
		fila.add_child(_celda(partida.nombre, "nombre", EstiloInterfaz.NEON if resaltada else color))
	var tiempo := int(partida.tiempo)
	fila.add_child(_celda("%02d:%02d" % [tiempo / 60, tiempo % 60], "tiempo", color))
	fila.add_child(_celda(str(int(partida.nivel)), "nivel", color))
	fila.add_child(_celda(str(int(partida.get("eliminados", 0))), "eliminados", color))
	fila.add_child(_personaje(partida.get("personaje", ""), color))
	fila.add_child(_chip(partida.get("dificultad", "media")))

	var banda := PanelContainer.new()
	banda.add_theme_stylebox_override("panel", estilo(BANDA, 1 if resaltada else 0, Vector2(48, 24), 6, borde))
	banda.add_child(fila)
	return banda


static func _fila_vacia() -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)
	return fila


## Un texto en su columna, centrado en la altura de la fila.
static func _celda(texto: String, columna: String, color: Color, tamano := LETRA) -> Label:
	var etiqueta := EstiloInterfaz.etiqueta(texto, tamano, color)
	etiqueta.custom_minimum_size.x = _ancho(columna)
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.clip_text = true
	return etiqueta


static func _ancho(columna: String) -> float:
	return ANCHOS[columna] * EstiloInterfaz.tamano_texto(100) / 100.0


## La medalla en los tres primeros; si no, el número o la fecha.
static func _puesto(primera: Variant, color: Color) -> Control:
	if primera is int and primera < 3:
		var medalla := TextureRect.new()
		medalla.texture = trozo(MEDALLAS, primera, 16)
		medalla.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		medalla.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		medalla.custom_minimum_size = Vector2(_ancho("primera"), 20)
		return medalla
	return _celda(str(primera + 1) if primera is int else str(primera), "primera", color)


static func _icono(indice: int, color: Color, columna: String) -> TextureRect:
	var icono := TextureRect.new()
	icono.texture = trozo(ICONOS, indice, 16)
	icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icono.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icono.custom_minimum_size = Vector2(_ancho(columna), 20)
	icono.modulate = color
	return icono


## El personaje con el que acabó: su mini retrato y su nombre.
static func _personaje(nombre: String, color: Color) -> HBoxContainer:
	var caja := HBoxContainer.new()
	caja.custom_minimum_size.x = _ancho("personaje")
	caja.add_theme_constant_override("separation", 6)
	if MINI_RETRATOS.has(nombre):
		var retrato := TextureRect.new()
		retrato.texture = MINI_RETRATOS[nombre]
		retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		caja.add_child(retrato)
	var etiqueta := EstiloInterfaz.etiqueta(nombre, LETRA, color)
	etiqueta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	caja.add_child(etiqueta)
	return caja


## La dificultad: su nombre en oscuro sobre un chip de su color.
static func _chip(clave: String) -> CenterContainer:
	var chip := PanelContainer.new()
	# 3 px por arriba: con menos, se cortaba la tilde de FÁCIL y DIFÍCIL.
	chip.add_theme_stylebox_override("panel", estilo(CHIP, 0, Vector2(24, 14), 5, COLORES_DIFICULTAD.get(clave, EstiloInterfaz.TEXTO), 8, 3))
	chip.add_child(EstiloInterfaz.etiqueta(Dificultad.DIFICULTADES.get(clave, Dificultad.DIFICULTADES.media).nombre, 12, Color(0.04, 0.06, 0.09)))
	var centro := CenterContainer.new()
	centro.custom_minimum_size.x = _ancho("dificultad")
	centro.add_child(chip)
	return centro


## Un trozo cuadrado de una tira.
static func trozo(tira: Texture2D, indice: int, lado: float) -> AtlasTexture:
	var trozo := AtlasTexture.new()
	trozo.atlas = tira
	trozo.region = Rect2(indice * lado, 0.0, lado, lado)
	return trozo


## Un fotograma de una tira de 9 trozos, teñido, con su margen por dentro.
static func estilo(tira: Texture2D, fotograma: int, lado: Vector2, margen: int, color: Color, dentro_x := 10, dentro_y := 4) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = tira
	estilo.region_rect = Rect2(Vector2(fotograma * lado.x, 0.0), lado)
	estilo.set_texture_margin_all(margen)
	estilo.content_margin_left = dentro_x
	estilo.content_margin_right = dentro_x
	estilo.content_margin_top = dentro_y
	estilo.content_margin_bottom = dentro_y
	estilo.modulate_color = color
	return estilo
