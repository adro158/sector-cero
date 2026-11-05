extends RefCounted

## Cómo se dibuja el panel técnico (panel_depuracion.gd), como una terminal:
## el marco con su barra de título, las pestañas, la cabecera de la sección,
## las filas, las barras de 10 casillas y el aviso. Las piezas van en grises y
## se tiñen con el verde del panel; los rellenos y el aviso, del color que
## toque. Son funciones estáticas: el panel se pasa a sí mismo como lienzo y
## cada una devuelve la y donde empieza lo siguiente.
##
## Desde el 05/11 va en pestañas y sin gráficas (ocupaban mucho), con una
## segunda tira de iconos para las filas nuevas.
##
## Sin class_name: se carga con preload, como dibujo_ultis.gd.

const TeclasDibujadas := preload("res://escenas/interfaz/teclas_dibujadas.gd")
const COLOR := Color(0.45, 1.0, 0.65)
const MARCO := preload("res://medios/interfaz/tecnico_marco.png")
const SECCION := preload("res://medios/interfaz/tecnico_seccion.png")
const ICONOS := preload("res://medios/interfaz/tecnico_iconos.png")
## La segunda tira (05/11), para las filas de las pestañas nuevas.
const ICONOS_2 := preload("res://medios/interfaz/tecnico_iconos2.png")
## Dos de 24x16: la pestaña abierta y la cerrada.
const PESTANAS := preload("res://medios/interfaz/tecnico_pestanas.png")
const BARRA := preload("res://medios/interfaz/tecnico_barra.png")
const RELLENO := preload("res://medios/interfaz/tecnico_barra_relleno.png")
const AVISO := preload("res://medios/interfaz/tecnico_aviso.png")
const LED := preload("res://medios/interfaz/tecnico_led.png")
## El orden de cada tira de iconos.
enum Icono { SISTEMA, ANTIVIRUS, HORDA, RESISTENCIA, TIEMPO, FPS, VIDA, NIVEL, EXPERIENCIA, GOLPE, EN_PANTALLA, ELIMINADOS }
enum Icono2 { DIBUJO, NODOS, FISICA, ANALISIS, OBJETIVO, DPS, ESCALA, ELITE, JEFE, DANO, CADENCIA }
const ANCHO := 272.0
const LINEA := 18.0
const LETRA := 14
## Por dónde va cada columna de una fila: el nombre, y la barra y su valor en
## las que la llevan. El valor de las demás va pegado a la derecha.
const X_NOMBRE := 32.0
const X_BARRA := 140.0
const X_VALOR_BARRA := 210.0
## Lo que cabe del nombre antes de la barra: los nombres de las evoluciones
## («Análisis heurístico», «Firewall perimetral») miden 105 px a 10 px.
const ANCHO_NOMBRE := 106.0
## Con una resistencia a partir de esta parte del máximo, el aviso.
const AVISO_DESDE := 0.8
## Ancho de cada pestaña.
const ANCHO_PESTANA := 34.0

## Los de 9 trozos, creados una vez al cargar el script.
static var _marco: StyleBoxTexture
static var _seccion: StyleBoxTexture
static var _pestana_abierta: StyleBoxTexture
static var _pestana_cerrada: StyleBoxTexture


static func _static_init() -> void:
	_marco = _estilo(MARCO, Rect2(0, 0, 48, 48), 8, 24, 8, 8)
	_seccion = _estilo(SECCION, Rect2(0, 0, 64, 18), 20, 0, 6, 0)
	_pestana_abierta = _estilo(PESTANAS, Rect2(0, 0, 24, 16), 4, 4, 4, 0)
	_pestana_cerrada = _estilo(PESTANAS, Rect2(24, 0, 24, 16), 4, 4, 4, 0)


static func _estilo(textura: Texture2D, region: Rect2, izquierda: int, arriba: int, derecha: int, abajo: int) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	estilo.region_rect = region
	estilo.texture_margin_left = izquierda
	estilo.texture_margin_top = arriba
	estilo.texture_margin_right = derecha
	estilo.texture_margin_bottom = abajo
	estilo.modulate_color = COLOR
	return estilo


## Un icono de una de las dos tiras, como textura: así las filas aceptan
## también los iconos de las mejoras y los dibujos de los enemigos.
static func icono(tira: Texture2D, indice: int) -> AtlasTexture:
	var trozo := AtlasTexture.new()
	trozo.atlas = tira
	trozo.region = Rect2(indice * 16.0, 0.0, 16.0, 16.0)
	return trozo


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


## Las pestañas, con el icono de cada una, y a la derecha la tecla que las
## cambia (F4).
static func pestanas(lienzo: Control, y: float, iconos: Array, abierta: int) -> float:
	y += 4.0
	for i in iconos.size():
		var caja := Rect2(8.0 + i * (ANCHO_PESTANA + 2.0), y, ANCHO_PESTANA, 20.0)
		lienzo.draw_style_box(_pestana_abierta if i == abierta else _pestana_cerrada, caja)
		var tinte := COLOR if i == abierta else Color(COLOR, 0.5)
		lienzo.draw_texture_rect_region(ICONOS, Rect2(caja.position + Vector2(9.0, 3.0), Vector2(16.0, 16.0)), Rect2(iconos[i] * 16.0, 0.0, 16.0, 16.0), tinte)
	lienzo.draw_texture_rect_region(TeclasDibujadas.TIRA, Rect2(ANCHO - 28.0, y, 20.0, 20.0), TeclasDibujadas.region("F4"))
	return y + 20.0


static func cabecera(lienzo: Control, y: float, icono_seccion: Icono, nombre: String) -> float:
	y += 4.0
	lienzo.draw_style_box(_seccion, Rect2(8.0, y, ANCHO - 16.0, 18.0))
	lienzo.draw_texture_rect_region(ICONOS, Rect2(Vector2(9.0, y + 1.0), Vector2(16.0, 16.0)), Rect2(icono_seccion * 16.0, 0.0, 16.0, 16.0), COLOR)
	_texto(lienzo, Vector2(X_NOMBRE, y + 14.0), nombre, COLOR)
	return y + LINEA + 6.0


## Un rótulo pequeño dentro de una sección («daño por segundo»).
static func subtitulo(lienzo: Control, y: float, texto: String) -> float:
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), texto, Color(COLOR, 0.6), -1.0, 11)
	return y + LINEA - 2.0


## Una fila con su icono, el nombre y el valor, pegado a la derecha. Los
## iconos de las tiras se tiñen de verde; los de las mejoras y los enemigos
## llevan su color (tinte blanco). Si el valor no cabe al lado del nombre (el
## de una evolución), se escribe más pequeño.
static func fila(lienzo: Control, y: float, textura: Texture2D, nombre: String, valor: String, tinte := COLOR, color_valor := Color.WHITE) -> float:
	if textura != null:
		lienzo.draw_texture_rect(textura, Rect2(10.0, y + 1.0, 16.0, 16.0), false, tinte)
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), nombre, Color(COLOR, 0.75))
	var derecha := ANCHO - 12.0
	var hueco := derecha - X_NOMBRE - lienzo.get_theme_default_font().get_string_size(nombre, HORIZONTAL_ALIGNMENT_LEFT, -1, LETRA).x - 8.0
	var fuente := lienzo.get_theme_default_font()
	var tamano := LETRA
	while tamano > 9 and fuente.get_string_size(valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x > hueco:
		tamano -= 1
	var ancho := fuente.get_string_size(valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x
	lienzo.draw_string(fuente, Vector2(derecha - ancho, y + 13.0), valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color_valor)
	return y + LINEA


## La vida, con su barra de rojo a verde, como la de encima del personaje.
static func fila_vida(lienzo: Control, y: float, vida: float, maxima: float) -> float:
	var parte := vida / maxf(maxima, 1.0)
	lienzo.draw_texture_rect_region(ICONOS, Rect2(10.0, y + 1.0, 16.0, 16.0), Rect2(Icono.VIDA * 16.0, 0.0, 16.0, 16.0), COLOR)
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
	# Con el número redondeado, el mismo que se lee: sumando y restando décimas
	# se llega a 0,39999... y comparado tal cual el aviso no saldría con un 40 %.
	if roundi(valor * 100.0) >= roundi(maximo * AVISO_DESDE * 100.0):
		var encendido := int(segundos / 0.25) % 2
		lienzo.draw_texture_rect_region(AVISO, Rect2(ANCHO - 26.0, y + 3.0, 12.0, 12.0), Rect2(encendido * 12.0, 0.0, 12.0, 12.0), EstiloInterfaz.DERROTA)
	return y + LINEA


static func ninguna(lienzo: Control, y: float) -> float:
	_texto(lienzo, Vector2(X_NOMBRE, y + 13.0), "ninguna todavía", Color(COLOR, 0.6))
	return y + LINEA


## Un texto; con ancho, si no cabe a su tamaño se escribe más pequeño (los
## nombres de las evoluciones son largos).
static func _texto(lienzo: Control, posicion: Vector2, texto: String, color: Color, ancho := -1.0, tamano := LETRA) -> void:
	var fuente := lienzo.get_theme_default_font()
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
