extends SceneTree

## Herramienta, no forma parte del juego: genera los sprites de la horda a
## partir de formas simples (círculos, rectángulos y líneas) y los guarda en
## recursos/enemigos/sprites/. Estilo neón: relleno oscuro y un contorno
## brillante que se calcula solo, a partir de la silueta.
##
## Cada sprite mide exactamente el tamano de su tipo de enemigo, así que se ve
## nítido sin escalar. Para retocar uno, se cambian sus números y se vuelve a
## ejecutar:
##
##   Godot --headless --path . --script res://herramientas/generar_sprites_enemigos.gd

const DESTINO := "res://recursos/enemigos/sprites/"
const TRANSPARENTE := Color(0, 0, 0, 0)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DESTINO))
	_bit_corrupto().save_png(DESTINO + "bit_corrupto.png")
	_paquete_perdido().save_png(DESTINO + "paquete_perdido.png")
	_proceso_colgado().save_png(DESTINO + "proceso_colgado.png")
	print("sprites generados en %s" % DESTINO)
	quit()


## Virus redondo con espinas, cara enfadada y una franja desplazada, como si
## la imagen estuviera corrupta.
func _bit_corrupto() -> Image:
	var img := _lienzo(24)
	var centro := Vector2(11.5, 11.5)
	var relleno := Color(0.35, 0.05, 0.14)

	for i in 8:
		var direccion := Vector2.RIGHT.rotated(i * TAU / 8.0)
		_linea(img, centro + direccion * 6.0, centro + direccion * 9.5, relleno)
		_disco(img, centro + direccion * 10.0, 1.3, relleno)
	_disco(img, centro, 7.0, relleno)
	_contorno(img, Color(1.0, 0.3, 0.5))

	var ojo := Color(1.0, 0.85, 0.9)
	_rect(img, Rect2i(8, 10, 2, 2), ojo)
	_rect(img, Rect2i(14, 10, 2, 2), ojo)
	_linea(img, Vector2(7, 8), Vector2(10, 9), ojo)
	_linea(img, Vector2(17, 8), Vector2(14, 9), ojo)
	_linea(img, Vector2(9, 15), Vector2(14, 15), ojo)

	_desplazar_fila(img, 13, 2)
	_desplazar_fila(img, 14, 2)
	return img


## Sobre de datos con la solapa marcada y dos ojos.
func _paquete_perdido() -> Image:
	var img := _lienzo(20)
	_rect(img, Rect2i(2, 5, 16, 11), Color(0.35, 0.18, 0.03))
	_contorno(img, Color(1.0, 0.65, 0.2))

	var brillo := Color(1.0, 0.8, 0.4)
	_linea(img, Vector2(3, 6), Vector2(9.5, 10), brillo)
	_linea(img, Vector2(16, 6), Vector2(10.5, 10), brillo)
	_rect(img, Rect2i(7, 12, 2, 2), Color.WHITE)
	_rect(img, Rect2i(11, 12, 2, 2), Color.WHITE)
	return img


## Ventana de programa que no responde: barra de título con el botón de cerrar
## en rojo, ojos en X y boca en zigzag.
func _proceso_colgado() -> Image:
	var img := _lienzo(40)
	_rect(img, Rect2i(3, 5, 34, 30), Color(0.16, 0.08, 0.26))
	_contorno(img, Color(0.75, 0.45, 1.0))

	_rect(img, Rect2i(4, 6, 32, 5), Color(0.42, 0.22, 0.62))
	_rect(img, Rect2i(23, 7, 3, 3), Color(0.75, 0.6, 0.9))
	_rect(img, Rect2i(27, 7, 3, 3), Color(0.75, 0.6, 0.9))
	_rect(img, Rect2i(31, 7, 3, 3), Color(1.0, 0.25, 0.3))

	var cara := Color(0.9, 0.8, 1.0)
	for centro in [Vector2(13, 19), Vector2(26, 19)]:
		_linea(img, centro + Vector2(-2, -2), centro + Vector2(2, 2), cara)
		_linea(img, centro + Vector2(-2, 2), centro + Vector2(2, -2), cara)

	var boca := [Vector2(12, 28), Vector2(15, 26), Vector2(18, 28), Vector2(21, 26), Vector2(24, 28), Vector2(27, 26)]
	for i in boca.size() - 1:
		_linea(img, boca[i], boca[i + 1], cara)
	return img


func _lienzo(tamano: int) -> Image:
	var img := Image.create(tamano, tamano, false, Image.FORMAT_RGBA8)
	img.fill(TRANSPARENTE)
	return img


func _disco(img: Image, centro: Vector2, radio: float, color: Color) -> void:
	for y in img.get_height():
		for x in img.get_width():
			if Vector2(x, y).distance_to(centro) <= radio:
				img.set_pixel(x, y, color)


func _rect(img: Image, zona: Rect2i, color: Color) -> void:
	img.fill_rect(zona, color)


## Línea de un píxel de grosor: se avanza en pasos de medio píxel y se pinta el
## píxel más cercano a cada punto.
func _linea(img: Image, desde: Vector2, hasta: Vector2, color: Color) -> void:
	var pasos := int(ceil(desde.distance_to(hasta) * 2.0)) + 1
	for i in pasos:
		var punto := desde.lerp(hasta, float(i) / maxi(pasos - 1, 1))
		var pixel := Vector2i(roundi(punto.x), roundi(punto.y))
		if Rect2i(Vector2i.ZERO, img.get_size()).has_point(pixel):
			img.set_pixelv(pixel, color)


## Pinta del color dado los píxeles opacos que tocan un píxel transparente: el
## borde de la silueta, que es lo que da el aspecto de neón.
func _contorno(img: Image, color: Color) -> void:
	var original := img.duplicate() as Image
	for y in img.get_height():
		for x in img.get_width():
			if original.get_pixel(x, y).a == 0.0:
				continue
			for vecino in [Vector2i(x - 1, y), Vector2i(x + 1, y), Vector2i(x, y - 1), Vector2i(x, y + 1)]:
				var fuera := not Rect2i(Vector2i.ZERO, img.get_size()).has_point(vecino)
				if fuera or original.get_pixelv(vecino).a == 0.0:
					img.set_pixel(x, y, color)
					break


## Mueve una fila entera unos píxeles a la derecha: el efecto de imagen corrupta.
func _desplazar_fila(img: Image, fila: int, cantidad: int) -> void:
	var ancho := img.get_width()
	var copia := []
	for x in ancho:
		copia.append(img.get_pixel(x, fila))
	for x in ancho:
		img.set_pixel(x, fila, copia[posmod(x - cantidad, ancho)])
