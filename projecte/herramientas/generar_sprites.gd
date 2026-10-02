extends SceneTree

## Herramienta, no forma parte del juego: genera los iconos de las mejoras a
## partir de formas simples (círculos, rectángulos y líneas). Estilo neón:
## relleno oscuro y un contorno brillante que se calcula solo, a partir de la
## silueta.
##
## Los iconos miden 16x16 para que se vean nítidos al escalarlos por números
## enteros. Para retocar uno, se cambian sus números y se vuelve a ejecutar:
##
##   Godot --headless --path . --script res://herramientas/generar_sprites.gd
##
## Hasta el 02/10/2026 también dibujaba los sprites de la horda y del élite.
## Ahora esos sprites, los del ransomware y el troyano y los iconos de las
## tres últimas mejoras están hechos aparte, con más detalle (ver
## documentacio/creditos.md), así que se quitó de aquí el código que los
## dibujaba: si siguiera, al ejecutar este script se machacarían con los
## antiguos. Los antiguos siguen en el historial de Git.

const ICONOS := "res://recursos/mejoras/iconos/"
const TRANSPARENTE := Color(0, 0, 0, 0)


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ICONOS))

	_icono_dano().save_png(ICONOS + "dano.png")
	_icono_cadencia().save_png(ICONOS + "cadencia.png")
	_icono_alcance().save_png(ICONOS + "alcance.png")
	_icono_velocidad().save_png(ICONOS + "velocidad.png")
	_icono_vida().save_png(ICONOS + "vida.png")
	_icono_escaner().save_png(ICONOS + "arma_escaner.png")
	_icono_ping().save_png(ICONOS + "arma_ping.png")
	_icono_firewall().save_png(ICONOS + "arma_firewall.png")
	print("iconos generados")
	quit()


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
