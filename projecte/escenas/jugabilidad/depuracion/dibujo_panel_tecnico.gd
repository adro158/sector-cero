extends RefCounted

## Cómo se dibuja el panel técnico (panel_depuracion.gd), como una terminal:
## el marco con su barra de título, las cabeceras de sección con su icono, las
## filas, las barras de 10 casillas, el aviso y las gráficas. Las piezas van en
## grises y se tiñen con el verde del panel; los rellenos, las líneas y el
## aviso, del color que toque. Son funciones estáticas: el panel se pasa a sí
## mismo como lienzo y cada una devuelve la y donde empieza lo siguiente.
##
## Sin class_name: se carga con preload, como dibujo_ultis.gd.

const TeclasDibujadas := preload("res://escenas/interfaz/teclas_dibujadas.gd")
const COLOR := Color(0.45, 1.0, 0.65)
const MARCO := preload("res://medios/interfaz/tecnico_marco.png")
const SECCION := preload("res://medios/interfaz/tecnico_seccion.png")
const ICONOS := preload("res://medios/interfaz/tecnico_iconos.png")
const BARRA := preload("res://medios/interfaz/tecnico_barra.png")
const RELLENO := preload("res://medios/interfaz/tecnico_barra_relleno.png")
const AVISO := preload("res://medios/interfaz/tecnico_aviso.png")
const GRAFICA := preload("res://medios/interfaz/tecnico_grafica.png")
const LED := preload("res://medios/interfaz/tecnico_led.png")
## El orden de la tira de iconos.
enum Icono { SISTEMA, ANTIVIRUS, HORDA, RESISTENCIA, TIEMPO, FPS, VIDA, NIVEL, EXPERIENCIA, GOLPE, EN_PANTALLA, ELIMINADOS }
const ANCHO := 264.0
const LINEA := 18.0
const LETRA := 14
## Por dónde va cada columna de una fila: el nombre, la barra y el valor (o
## el valor, si no hay barra).
const X_NOMBRE := 32.0
const X_BARRA := 122.0
const X_VALOR_BARRA := 192.0
const X_VALOR := 150.0
## Lo que cabe del nombre antes de la barra.
const ANCHO_NOMBRE := 88.0
## Con una resistencia a partir de esta parte del máximo, el aviso.
const AVISO_DESDE := 0.8

## Los tres de 9 trozos, creados una vez al cargar el script.
static var _marco: StyleBoxTexture
static var _seccion: StyleBoxTexture
static var _grafica: StyleBoxTexture


static func _static_init() -> void:
	_marco = _estilo(MARCO, 8, 24, 8, 8)
	_seccion = _estilo(SECCION, 20, 0, 6, 0)
	_grafica = _estilo(GRAFICA, 4, 4, 4, 4)
	# La rejilla del fondo se repite a lo ancho en vez de estirarse.
	_grafica.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE


static func _estilo(textura: Texture2D, izquierda: int, arriba: int, derecha: int, abajo: int) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	estilo.texture_margin_left = izquierda
	estilo.texture_margin_top = arriba
	estilo.texture_margin_right = derecha
	estilo.texture_margin_bottom = abajo
	estilo.modulate_color = COLOR
	return estilo


## El marco, del alto dado, y su barra de título: el piloto que late, el
## nombre y la tecla.
static func marco(lienzo: Control, alto: float, segundos: float) -> float:
	lienzo.draw_style_box(_marco, Rect2(0.0, 0.0, ANCHO, alto))
	# De apagado a encendido y vuelta, a 0,15 s.
	var fotograma: int = [0, 1, 2, 3, 2, 1][int(segundos / 0.15) % 6]
	lienzo.draw_texture_rect_region(LED, Rect2(8.0, 8.0, 8.0, 8.0), Rect2(fotograma * 8.0, 0.0, 8.0, 8.0), COLOR)
	_texto(lienzo, Vector2(22.0, 17.0), "PANEL TÉCNICO", COLOR)
	lienzo.draw_texture_rect_region(TeclasDibujadas.TIRA, Rect2(ANCHO - 28.0, 2.0, 20.0, 20.0), TeclasDibujadas.region("F3"))
	return 26.0


static func cabecera(lienzo: Control, y: float, icono: Icono, nombre: String) -> float:
	y += 4.0
	lienzo.draw_style_box(_seccion, Rect2(8.0, y, ANCHO - 16.0, 18.0))
	_icono(lienzo, Vector2(9.0, y + 1.0), icono)
	_texto(lienzo, Vector2(X_NOMBRE, y + 14.0), nombre, COLOR)
	return y + LINEA + 6.0


## Una fila con su icono, el nombre y el valor.
static func fila(lienzo: Control, y: float, icono: Icono, nombre: String, valor: String) -> float:
	_icono(lienzo, Vector2(10.0, y + 1.0), icono)
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), nombre, Color(COLOR, 0.75))
	_texto(lienzo, Vector2(X_VALOR, y + 13.0), valor, Color.WHITE)
	return y + LINEA


## La vida, con su barra de rojo a verde, como la de encima del personaje.
static func fila_vida(lienzo: Control, y: float, vida: float, maxima: float) -> float:
	var parte := vida / maxf(maxima, 1.0)
	_icono(lienzo, Vector2(10.0, y + 1.0), Icono.VIDA)
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), "vida", Color(COLOR, 0.75))
	_barra(lienzo, Vector2(X_BARRA, y + 5.0), parte, Color(1.0, 0.25, 0.3).lerp(Color(0.3, 1.0, 0.5), parte))
	_texto(lienzo, Vector2(X_VALOR_BARRA, y + 13.0), "%.0f" % vida, Color.WHITE)
	return y + LINEA


## La resistencia a una herramienta: el icono de su mejora, su nombre, la
## barra del color de su personaje (llena es el máximo) y, cerca del máximo,
## el aviso que parpadea: toca cambiar de personaje. herramienta es
## [icono, color].
static func fila_resistencia(lienzo: Control, y: float, herramienta: Array, nombre: String, valor: float, maximo: float, segundos: float) -> float:
	if herramienta[0] != null:
		lienzo.draw_texture(herramienta[0], Vector2(10.0, y + 1.0))
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), nombre, COLOR, ANCHO_NOMBRE)
	_barra(lienzo, Vector2(X_BARRA, y + 5.0), valor / maximo, herramienta[1])
	_texto(lienzo, Vector2(X_VALOR_BARRA, y + 13.0), "%2d%%" % roundi(valor * 100.0), Color.WHITE)
	if valor >= maximo * AVISO_DESDE:
		var encendido := int(segundos / 0.25) % 2
		lienzo.draw_texture_rect_region(AVISO, Rect2(ANCHO - 26.0, y + 3.0, 12.0, 12.0), Rect2(encendido * 12.0, 0.0, 12.0, 12.0), EstiloInterfaz.DERROTA)
	return y + LINEA


static func ninguna(lienzo: Control, y: float) -> float:
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), "ninguna todavía", Color(COLOR, 0.6))
	return y + LINEA


## Gráfica de 40 px de alto: el fondo con la rejilla y una línea por serie
## ([muestras, color]), de la más vieja a la izquierda a la de ahora a la
## derecha. El máximo da la escala y su rótulo va arriba a la derecha.
static func grafica(lienzo: Control, y: float, series: Array, maximo: float, rotulo: String) -> float:
	var caja := Rect2(8.0, y + 2.0, ANCHO - 16.0, 40.0)
	lienzo.draw_style_box(_grafica, caja)
	# La zona de las líneas: 4 px dentro del borde, y el cero 35 px por debajo.
	var izquierda := caja.position.x + 4.0
	var ancho := caja.size.x - 9.0
	var abajo := caja.position.y + 35.0
	for serie in series:
		var muestras: PackedFloat32Array = serie[0]
		var puntos := PackedVector2Array()
		for i in muestras.size():
			var alto := clampf(muestras[i] / maximo, 0.0, 1.0) * 31.0
			puntos.append(Vector2(izquierda + ancho * i / (muestras.size() - 1), abajo - alto))
		lienzo.draw_polyline(puntos, serie[1], 1.0)
	lienzo.draw_string(lienzo.get_theme_default_font(), Vector2(caja.end.x - 34.0, caja.position.y + 13.0), rotulo, HORIZONTAL_ALIGNMENT_RIGHT, 28.0, 10, Color(COLOR, 0.6))
	return y + 46.0


static func _icono(lienzo: Control, posicion: Vector2, icono: Icono) -> void:
	lienzo.draw_texture_rect_region(ICONOS, Rect2(posicion, Vector2(16.0, 16.0)), Rect2(icono * 16.0, 0.0, 16.0, 16.0), COLOR)


## Un texto; con ancho, si no cabe a su tamaño se escribe más pequeño (los
## nombres de las evoluciones son largos).
static func _texto(lienzo: Control, posicion: Vector2, texto: String, color: Color, ancho := -1.0) -> void:
	var fuente := lienzo.get_theme_default_font()
	var tamano := LETRA
	while ancho > 0.0 and tamano > 9 and fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x > ancho:
		tamano -= 1
	lienzo.draw_string(fuente, posicion, texto, HORIZONTAL_ALIGNMENT_LEFT, ancho, tamano, color)


## Barra de 10 casillas: el marco y una casilla encendida por cada décima.
static func _barra(lienzo: Control, posicion: Vector2, parte: float, color: Color) -> void:
	lienzo.draw_texture(BARRA, posicion, COLOR)
	var casillas := roundi(clampf(parte, 0.0, 1.0) * 10.0)
	if casillas > 0:
		# Cada casilla mide 5 px y entre una y otra hay 1.
		var ancho := casillas * 6.0 - 1.0
		lienzo.draw_texture_rect_region(RELLENO, Rect2(posicion + Vector2(2.0, 2.0), Vector2(ancho, 4.0)), Rect2(0.0, 0.0, ancho, 4.0), color)
