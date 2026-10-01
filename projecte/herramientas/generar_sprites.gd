extends SceneTree

## Herramienta, no forma parte del juego: genera los sprites de la horda y los
## iconos de las mejoras a partir de formas simples (círculos, rectángulos y
## líneas). Estilo neón: relleno oscuro y un contorno brillante que se calcula
## solo, a partir de la silueta.
##
## Cada sprite de enemigo mide exactamente el tamano de su tipo, y los iconos
## 16x16, para que se vean nítidos al escalarlos por números enteros. Para
## retocar uno, se cambian sus números y se vuelve a ejecutar:
##
##   Godot --headless --path . --script res://herramientas/generar_sprites.gd

const ENEMIGOS := "res://recursos/enemigos/sprites/"
const ICONOS := "res://recursos/mejoras/iconos/"
const TRANSPARENTE := Color(0, 0, 0, 0)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ENEMIGOS))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ICONOS))

	_bit_corrupto().save_png(ENEMIGOS + "bit_corrupto.png")
	_paquete_perdido().save_png(ENEMIGOS + "paquete_perdido.png")
	_proceso_colgado().save_png(ENEMIGOS + "proceso_colgado.png")
	_rootkit().save_png(ENEMIGOS + "rootkit.png")

	_icono_dano().save_png(ICONOS + "dano.png")
	_icono_cadencia().save_png(ICONOS + "cadencia.png")
	_icono_alcance().save_png(ICONOS + "alcance.png")
	_icono_velocidad().save_png(ICONOS + "velocidad.png")
	_icono_vida().save_png(ICONOS + "vida.png")
	_icono_escaner().save_png(ICONOS + "arma_escaner.png")
	_icono_ping().save_png(ICONOS + "arma_ping.png")
	_icono_firewall().save_png(ICONOS + "arma_firewall.png")
	print("sprites e iconos generados")
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


## Rootkit, el élite: un rombo dorado con ojos rojos y el símbolo # de la
## consola de administrador, que es lo que busca un rootkit. Una franja
## desplazada, como el bit corrupto.
func _rootkit() -> Image:
	var img := _lienzo(48)
	for y in 48:
		var media := 21.0 - absf(y - 23.5)
		if media > 0.0:
			_linea(img, Vector2(23.5 - media, y), Vector2(23.5 + media, y), Color(0.3, 0.2, 0.03))
	_contorno(img, Color(1.0, 0.85, 0.3))

	var ojo := Color(1.0, 0.3, 0.2)
	_rect(img, Rect2i(14, 17, 6, 3), ojo)
	_rect(img, Rect2i(28, 17, 6, 3), ojo)

	var simbolo := Color(1.0, 0.9, 0.6)
	_linea(img, Vector2(20, 24), Vector2(19, 34), simbolo)
	_linea(img, Vector2(27, 24), Vector2(26, 34), simbolo)
	_linea(img, Vector2(16, 27), Vector2(31, 27), simbolo)
	_linea(img, Vector2(16, 31), Vector2(31, 31), simbolo)

	_desplazar_fila(img, 21, 3)
	_desplazar_fila(img, 22, 3)
	return img


# --- Iconos de mejora (16x16) ---


## Heurística agresiva (+daño): una espada.
func _icono_dano() -> Image:
	var img := _lienzo(16)
	var hoja := Color(1.0, 0.45, 0.35)
	_linea(img, Vector2(3, 12), Vector2(12, 3), hoja)
	_linea(img, Vector2(4, 12), Vector2(12, 4), hoja)
	_linea(img, Vector2(2, 9), Vector2(6, 13), Color(0.8, 0.8, 0.9))
	_linea(img, Vector2(2, 13), Vector2(3, 14), Color(0.8, 0.8, 0.9))
	return img


## Multihilo (-tiempo entre ataques): tres hilos que acaban en flecha.
func _icono_cadencia() -> Image:
	var img := _lienzo(16)
	var hilo := Color(1.0, 0.85, 0.3)
	for fila in [4, 8, 12]:
		_linea(img, Vector2(2, fila), Vector2(11, fila), hilo)
		_linea(img, Vector2(11, fila - 2), Vector2(13, fila), hilo)
		_linea(img, Vector2(11, fila + 2), Vector2(13, fila), hilo)
	return img


## Ampliar subred (+alcance): ondas concéntricas.
func _icono_alcance() -> Image:
	var img := _lienzo(16)
	var onda := Color(0.3, 0.9, 1.0)
	_anillo(img, Vector2(7.5, 7.5), 6.5, onda)
	_anillo(img, Vector2(7.5, 7.5), 3.5, onda)
	_rect(img, Rect2i(7, 7, 2, 2), Color.WHITE)
	return img


## Overclock (+velocidad): doble flecha hacia la derecha.
func _icono_velocidad() -> Image:
	var img := _lienzo(16)
	var flecha := Color(0.4, 1.0, 0.5)
	for x in [3, 8]:
		_linea(img, Vector2(x, 3), Vector2(x + 4, 7.5), flecha)
		_linea(img, Vector2(x, 12), Vector2(x + 4, 7.5), flecha)
		_linea(img, Vector2(x + 1, 3), Vector2(x + 5, 7.5), flecha)
		_linea(img, Vector2(x + 1, 12), Vector2(x + 5, 7.5), flecha)
	return img


## Memoria redundante (+vida máxima): un corazón.
func _icono_vida() -> Image:
	var img := _lienzo(16)
	var relleno := Color(0.45, 0.06, 0.2)
	_disco(img, Vector2(5, 6), 3.2, relleno)
	_disco(img, Vector2(10, 6), 3.2, relleno)
	for fila in range(6, 14):
		var media := (13 - fila) * 0.9
		_linea(img, Vector2(7.5 - media, fila), Vector2(7.5 + media, fila), relleno)
	_contorno(img, Color(1.0, 0.35, 0.6))
	return img


## Escáner (arma): un radar con su barrido.
func _icono_escaner() -> Image:
	var img := _lienzo(16)
	var radar := Color(0.3, 1.0, 0.7)
	_anillo(img, Vector2(7.5, 7.5), 6.5, radar)
	_linea(img, Vector2(7.5, 7.5), Vector2(12, 3), Color.WHITE)
	_rect(img, Rect2i(4, 9, 2, 2), radar)
	return img


## Firewall (arma): un muro de ladrillos.
func _icono_firewall() -> Image:
	var img := _lienzo(16)
	var ladrillo := Color(1.0, 0.45, 0.2)
	for fila in 4:
		var y := 2 + fila * 3
		_linea(img, Vector2(1, y), Vector2(14, y), ladrillo)
		# Las juntas verticales se alternan, como en una pared de verdad.
		for x in ([1, 7, 13] if fila % 2 == 0 else [4, 10]):
			_linea(img, Vector2(x, y), Vector2(x, y + 3), ladrillo)
	_linea(img, Vector2(1, 14), Vector2(14, 14), ladrillo)
	return img


## Ping (arma): un punto que emite ondas.
func _icono_ping() -> Image:
	var img := _lienzo(16)
	var senal := Color(0.5, 1.0, 0.9)
	_disco(img, Vector2(4, 11), 1.6, Color.WHITE)
	for radio in [5.0, 9.0]:
		for i in 12:
			var angulo := -PI / 2.0 + i * (PI / 2.0) / 11.0
			var punto: Vector2 = Vector2(4, 11) + Vector2(cos(angulo), sin(angulo)) * radio
			_rect(img, Rect2i(roundi(punto.x), roundi(punto.y), 1, 1), senal)
	return img


# --- Herramientas de dibujo ---


func _anillo(img: Image, centro: Vector2, radio: float, color: Color) -> void:
	for y in img.get_height():
		for x in img.get_width():
			if absf(Vector2(x, y).distance_to(centro) - radio) < 0.6:
				img.set_pixel(x, y, color)


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
