extends SceneTree

## Herramienta, no forma parte del juego: genera todos los efectos de sonido y
## las tres músicas sumando ondas simples (cuadrada, triángulo, sierra, seno y
## ruido), como los chips de sonido de las consolas antiguas. Así el audio es
## propio, sin licencias, y encaja con la estética de ordenador.
##
## Cada sonido es una o varias notas: una onda cuya frecuencia va de un valor a
## otro, con un volumen que sube rápido (ataque) y se apaga poco a poco. La
## música es una secuencia de notas por pasos, como un secuenciador.
##
##   Godot --headless --path . --script res://herramientas/generar_audio.gd

const RUTA := "res://medios/audio/"
const MEZCLA := 22050

const LA := 69 # Número de nota MIDI del La de 440 Hz.


func _initialize() -> void:
	# Semilla fija: el ruido sale igual cada vez y regenerar no cambia nada.
	seed(1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RUTA))
	_efectos()
	_musica_menu()
	_musica_partida()
	_musica_jefe()
	# Lo del 27/10 (sonido 2, 3 y 4 de las mejoras propuestas), después de
	# todo lo anterior: así el ruido de lo que ya había sale igual.
	_efectos_escudo()
	_efectos_ultis()
	_efectos_evoluciones()
	_musica_fase2()
	_musica_jefe_final()
	print("audio generado")
	quit()


func _efectos() -> void:
	_guardar("muerte", _mezclar([_nota(500, 120, 0.12, "cuadrada", 0.35), _nota(0, 0, 0.1, "ruido", 0.3)]))
	_guardar("gema", _nota(1300, 1900, 0.06, "seno", 0.4))
	_guardar("subir_nivel", _arpegio([72, 76, 79, 84], 0.07, "cuadrada", 0.3))
	_guardar("elegir", _arpegio([81, 88], 0.08, "triangulo", 0.5))
	_guardar("dano", _mezclar([_nota(200, 80, 0.2, "sierra", 0.4), _nota(0, 0, 0.12, "ruido", 0.3)]))
	# La victoria y la derrota acaban en un acorde que se queda sonando (unos
	# 3 s): antes se cortaban al momento y la pantalla final quedaba muda.
	var victoria := _arpegio([72, 76, 79, 84, 79, 84, 88], 0.12, "cuadrada", 0.3)
	_guardar("victoria", _seguido(victoria, _acorde([72, 76, 79, 84], 2.2, "triangulo", 0.22)))
	var derrota := _arpegio([67, 64, 60, 55, 48], 0.18, "sierra", 0.35)
	_guardar("derrota", _seguido(derrota, _acorde([36, 43, 48], 2.2, "sierra", 0.18)))
	_guardar("pausa", _nota(660, 660, 0.08, "seno", 0.4))
	_guardar("clic", _nota(1000, 900, 0.03, "cuadrada", 0.2))
	_guardar("cambio", _nota(300, 1200, 0.2, "triangulo", 0.5))
	_guardar("evolucion", _arpegio([60, 64, 67, 72, 76, 79, 84, 88], 0.06, "triangulo", 0.5))
	_guardar("explosion", _mezclar([_nota(200, 30, 0.45, "seno", 0.6), _nota(0, 0, 0.4, "ruido", 0.45)]))
	_guardar("firewall", _nota(140, 60, 0.12, "seno", 0.5))
	_guardar("ping", _nota(1600, 2400, 0.05, "seno", 0.3))
	_guardar("escaner", _mezclar([_nota(400, 1600, 0.25, "triangulo", 0.35), _nota(0, 0, 0.25, "ruido", 0.06)]))

	# Alarmas: dos tonos que se alternan, como una sirena.
	var sirena := []
	for i in 6:
		sirena.append(76 if i % 2 == 0 else 71)
	_guardar("alarma_jefe", _arpegio(sirena, 0.2, "sierra", 0.3))
	_guardar("alarma_elite", _arpegio([79, 74, 79], 0.1, "cuadrada", 0.25))


## Am, F, C y G a 80 pulsaciones: arpegios lentos y un bajo suave. 24 s.
func _musica_menu() -> void:
	var acordes := [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
	var paso := 60.0 / 80.0 / 2.0
	var arpegio := []
	var bajo := []
	for acorde in acordes:
		for compas in 2:
			for i in 8:
				arpegio.append(acorde[[0, 1, 2, 1][i % 4]] + 12)
				bajo.append(acorde[0] - 12 if i == 0 else -1)
	_guardar("musica_menu", _mezclar([
		_secuencia(arpegio, paso, "triangulo", 0.3, 0.9),
		_secuencia(bajo, paso, "seno", 0.4, 7.5),
	]), true)


## Em, C, D y B a 132 pulsaciones con batería. La segunda mitad añade una
## melodía encima. 29 s.
func _musica_partida() -> void:
	var acordes := [[64, 67, 71], [60, 64, 67], [62, 66, 69], [59, 63, 66]]
	var paso := 60.0 / 132.0 / 2.0
	var bajo := []
	var arpegio := []
	var melodia := []
	# La melodía dice qué nota del acorde toca en cada corchea (3 es la
	# fundamental una octava arriba; -1, silencio), así siempre encaja.
	var temas := [[2, -1, 1, 2, 3, -1, 2, -1], [1, -1, 0, -1, 1, 2, 1, -1]]
	for vuelta in 2:
		for acorde in acordes:
			var notas: Array = acorde + [acorde[0] + 12]
			for compas in 2:
				for i in 8:
					# Bajo: la fundamental con saltos de octava, en corcheas.
					bajo.append(acorde[0] - 24 + (12 if i in [2, 6] else 0))
					arpegio.append(acorde[[0, 1, 2, 1][i % 4]] + 12)
					var tema: int = temas[compas][i]
					melodia.append(notas[tema] + 12 if vuelta == 1 and tema >= 0 else -1)
	var pistas := [
		_secuencia(bajo, paso, "cuadrada", 0.22, 0.8),
		_secuencia(arpegio, paso, "triangulo", 0.18, 0.6),
		_secuencia(melodia, paso, "cuadrada", 0.12, 1.6),
	]
	pistas.append_array(_bateria(bajo.size(), paso))
	_guardar("musica_partida", _mezclar(pistas), true)


## Dm, Bb, C y A a 150 pulsaciones: más rápida y con el bajo en sierra. Desde
## el 27/10, con una segunda parte (Gm, Eb, F y A, con el arpegio subiendo):
## con 13 s, el bucle cansaba en un combate de varios minutos. 26 s.
func _musica_jefe() -> void:
	var partes := [
		[[62, 65, 69], [58, 62, 65], [60, 64, 67], [57, 61, 64]],
		[[55, 58, 62], [51, 55, 58], [53, 57, 60], [57, 61, 64]],
	]
	var paso := 60.0 / 150.0 / 2.0
	var bajo := []
	var arpegio := []
	for parte in partes.size():
		for acorde in partes[parte]:
			for compas in 2:
				for i in 8:
					bajo.append(acorde[0] - 24 + (12 if i % 2 == 1 else 0))
					# En la segunda parte, el arpegio sube en vez de ir y volver.
					var orden: Array = [0, 1, 2, 1] if parte == 0 else [0, 1, 2, 3]
					var notas: Array = acorde + [acorde[0] + 12]
					arpegio.append(notas[orden[i % 4]] + 24)
	var pistas := [
		_secuencia(bajo, paso, "sierra", 0.25, 0.9),
		_secuencia(arpegio, paso, "cuadrada", 0.12, 0.5),
	]
	pistas.append_array(_bateria(bajo.size(), paso))
	_guardar("musica_jefe", _mezclar(pistas), true)


## Los tres sonidos del escudo de NÚCLEO CERO: el golpe que no entra (con la
## herramienta de otro personaje), el ancla que se rompe y el escudo entero.
func _efectos_escudo() -> void:
	_guardar("ancla_bloqueada", _mezclar([_nota(120, 90, 0.08, "cuadrada", 0.35), _nota(0, 0, 0.03, "ruido", 0.12)]))
	_guardar("ancla_rota", _mezclar([_nota(0, 0, 0.18, "ruido", 0.4), _nota(600, 150, 0.22, "triangulo", 0.45)]))
	var cristal := _arpegio([96, 91, 88, 84, 79, 76], 0.06, "triangulo", 0.35)
	_guardar("escudo_roto", _mezclar([_nota(0, 0, 0.5, "ruido", 0.35), _nota(220, 55, 0.5, "seno", 0.5), cristal]))


## Una ulti por personaje, ajustada a sus tiempos (las constantes de
## ultis.gd), y un aviso corto de que está lista.
func _efectos_ultis() -> void:
	# El rayo: una sierra que sube y zumba 0,6 s, con sus tres golpes (RAYO_GOLPES).
	var rayo := _mezclar([_nota(200, 900, 0.6, "sierra", 0.3), _nota(110, 110, 0.6, "seno", 0.35)])
	for segundo in [0.0, 0.15, 0.3]:
		_sumar(rayo, _nota(0, 0, 0.06, "ruido", 0.35), roundi(segundo * MEZCLA))
	_guardar("ulti_rayo", rayo)
	# El giro: un barrido cada GIRO_CADA (0,2 s) durante GIRO_DURACION (1,5 s).
	var giro := PackedFloat32Array()
	giro.resize(roundi(1.6 * MEZCLA))
	for i in 8:
		_sumar(giro, _nota(300, 900, 0.18, "triangulo", 0.35), roundi(i * 0.2 * MEZCLA))
	_guardar("ulti_giro", giro)
	# La tormenta: un trueno y los 10 chasquidos de los mini rayos, que caen a
	# 0,3 + i·0,08 s.
	var tormenta := _mezclar([_nota(0, 0, 0.9, "ruido", 0.4), _nota(80, 35, 0.9, "seno", 0.6)])
	for i in 10:
		var chasquido := _mezclar([_nota(0, 0, 0.04, "ruido", 0.3), _nota(1800, 600, 0.04, "cuadrada", 0.15)])
		_sumar(tormenta, chasquido, roundi((0.3 + i * 0.08) * MEZCLA))
	_guardar("ulti_tormenta", tormenta)
	_guardar("ulti_lista", _arpegio([84, 91, 96], 0.05, "cuadrada", 0.22))


## Las herramientas evolucionadas, con su propio sonido: la base con algo más.
func _efectos_evoluciones() -> void:
	_guardar("firewall_perimetral", _mezclar([_nota(170, 50, 0.16, "seno", 0.5), _nota(0, 0, 0.1, "ruido", 0.15)]))
	_guardar("analisis_heuristico", _mezclar([_nota(500, 2000, 0.25, "triangulo", 0.3), _nota(1000, 3000, 0.25, "seno", 0.12)]))
	var inundacion := _nota(1400, 2600, 0.05, "seno", 0.3)
	var doble := PackedFloat32Array()
	doble.resize(roundi(0.1 * MEZCLA))
	_sumar(doble, inundacion, 0)
	_sumar(doble, _nota(1800, 2900, 0.05, "seno", 0.22), roundi(0.04 * MEZCLA))
	_guardar("ping_inundacion", doble)


## La fase 2, con el sector dañado: Cm, Ab, Fm y G a 120 pulsaciones, el bajo
## en sierra y, de vez en cuando, un paso que repite el anterior, como un
## disco rayado (con la semilla fija, siempre los mismos). 32 s.
func _musica_fase2() -> void:
	var acordes := [[60, 63, 67], [56, 60, 63], [53, 56, 60], [55, 59, 62]]
	var paso := 60.0 / 120.0 / 2.0
	var bajo := []
	var arpegio := []
	for vuelta in 2:
		for acorde in acordes:
			for compas in 2:
				for i in 8:
					bajo.append(acorde[0] - 24 + (7 if i == 6 else 0))
					var nota: int = acorde[[0, 2, 1, 2][i % 4]] + 12
					if not arpegio.is_empty() and randf() < 0.12:
						nota = arpegio[-1]
					# En la segunda vuelta, alguna nota se cae del todo.
					arpegio.append(-1 if vuelta == 1 and randf() < 0.1 else nota)
	var pistas := [
		_secuencia(bajo, paso, "sierra", 0.24, 0.95),
		_secuencia(arpegio, paso, "cuadrada", 0.13, 0.55),
	]
	pistas.append_array(_bateria(bajo.size(), paso))
	_guardar("musica_fase2", _mezclar(pistas), true)


## NÚCLEO CERO: Am, F, G y E a 160 pulsaciones en dos partes (la B, Dm, Bb, E
## y E), cada una dos veces, la segunda con una melodía encima. 48 s.
func _musica_jefe_final() -> void:
	var partes := [
		[[57, 60, 64], [53, 57, 60], [55, 59, 62], [52, 56, 59]],
		[[50, 53, 57], [46, 50, 53], [52, 56, 59], [52, 56, 59]],
	]
	var temas := [[3, -1, 2, 1, 2, -1, 0, -1], [2, 2, -1, 3, -1, 2, 1, -1]]
	var paso := 60.0 / 160.0 / 2.0
	var bajo := []
	var arpegio := []
	var melodia := []
	for parte in partes:
		for vuelta in 2:
			for acorde in parte:
				var notas: Array = acorde + [acorde[0] + 12]
				for compas in 2:
					for i in 8:
						bajo.append(acorde[0] - 24 + (12 if i % 2 == 1 else 0))
						arpegio.append(notas[[0, 1, 2, 3][i % 4]] + 12)
						var tema: int = temas[compas][i]
						melodia.append(notas[tema] + 24 if vuelta == 1 and tema >= 0 else -1)
	var pistas := [
		_secuencia(bajo, paso, "sierra", 0.26, 0.9),
		_secuencia(arpegio, paso, "cuadrada", 0.11, 0.5),
		_secuencia(melodia, paso, "triangulo", 0.2, 1.8),
	]
	pistas.append_array(_bateria(bajo.size(), paso))
	_guardar("musica_jefe_final", _mezclar(pistas), true)


## Bombo en los tiempos 1 y 3, caja en el 2 y el 4, y charles en cada corchea.
func _bateria(pasos: int, paso: float) -> Array:
	var largo := roundi(pasos * paso * MEZCLA)
	var bombo := PackedFloat32Array()
	var caja := PackedFloat32Array()
	var charles := PackedFloat32Array()
	bombo.resize(largo)
	caja.resize(largo)
	charles.resize(largo)
	for i in pasos:
		var inicio := roundi(i * paso * MEZCLA)
		if i % 4 == 0:
			_sumar(bombo, _nota(150, 45, 0.15, "seno", 0.7), inicio)
		if i % 4 == 2:
			_sumar(caja, _nota(0, 0, 0.1, "ruido", 0.3), inicio)
		_sumar(charles, _nota(0, 0, 0.03, "ruido", 0.12), inicio)
	return [bombo, caja, charles]


# --- Síntesis ---


## Una nota: la frecuencia pasa de inicio a fin a lo largo de la duración. El
## volumen sube en 5 ms (sin ese ataque se oye un chasquido) y cae hasta cero.
func _nota(inicio: float, fin: float, duracion: float, onda: String, volumen: float) -> PackedFloat32Array:
	var muestras := PackedFloat32Array()
	muestras.resize(roundi(duracion * MEZCLA))
	var fase := 0.0
	var ataque := 0.005 * MEZCLA
	for i in muestras.size():
		var progreso := float(i) / muestras.size()
		fase += lerpf(inicio, fin, progreso) / MEZCLA
		var envolvente := minf(i / ataque, 1.0) * pow(1.0 - progreso, 2.0)
		muestras[i] = _onda(onda, fase) * envolvente * volumen
	return muestras


## Valor de la onda en una fase dada, que cuenta vueltas: 0,5 es media vuelta.
func _onda(tipo: String, fase: float) -> float:
	var t := fposmod(fase, 1.0)
	match tipo:
		"cuadrada":
			return 1.0 if t < 0.5 else -1.0
		"triangulo":
			return 4.0 * absf(t - 0.5) - 1.0
		"sierra":
			return 2.0 * t - 1.0
		"ruido":
			return randf_range(-1.0, 1.0)
	return sin(fase * TAU)


func _frecuencia(nota: int) -> float:
	return 440.0 * pow(2.0, (nota - LA) / 12.0)


## Notas seguidas de la misma duración, sin cambio de tono dentro de cada una.
func _arpegio(notas: Array, duracion: float, onda: String, volumen: float) -> PackedFloat32Array:
	return _secuencia(notas, duracion, onda, volumen, 1.0)


## Una nota por paso; -1 es silencio. largo es cuánto dura cada nota respecto
## al paso: menos de 1 las separa, más de 1 las alarga sobre las siguientes.
func _secuencia(notas: Array, paso: float, onda: String, volumen: float, largo: float) -> PackedFloat32Array:
	var muestras := PackedFloat32Array()
	muestras.resize(roundi(notas.size() * paso * MEZCLA))
	for i in notas.size():
		if notas[i] < 0:
			continue
		var frecuencia := _frecuencia(notas[i])
		_sumar(muestras, _nota(frecuencia, frecuencia, paso * largo, onda, volumen), roundi(i * paso * MEZCLA))
	return muestras


## Varias notas a la vez que se quedan sonando: un acorde.
func _acorde(notas: Array, duracion: float, onda: String, volumen: float) -> PackedFloat32Array:
	var pistas := []
	for nota in notas:
		var frecuencia := _frecuencia(nota)
		pistas.append(_nota(frecuencia, frecuencia, duracion, onda, volumen))
	return _mezclar(pistas)


## Una pista detrás de la otra.
func _seguido(primera: PackedFloat32Array, segunda: PackedFloat32Array) -> PackedFloat32Array:
	var resultado := primera.duplicate()
	resultado.append_array(segunda)
	return resultado


## Suma una pista dentro de otra a partir de una muestra, sin pasarse del final.
func _sumar(destino: PackedFloat32Array, fuente: PackedFloat32Array, desde: int) -> void:
	for i in mini(fuente.size(), destino.size() - desde):
		destino[desde + i] += fuente[i]


## Suma varias pistas en una tan larga como la más larga.
func _mezclar(pistas: Array) -> PackedFloat32Array:
	var resultado := PackedFloat32Array()
	for pista in pistas:
		resultado.resize(maxi(resultado.size(), pista.size()))
	for pista in pistas:
		_sumar(resultado, pista, 0)
	return resultado


## Guarda un WAV de 16 bits. La música, que suma muchas pistas, se normaliza
## para que su pico quede en 0,9. Los efectos no: conservan el volumen que se
## les ha dado, que es lo que los equilibra entre sí.
##
## Que la música se repita no va en el WAV: se marca en la importación de cada
## fichero (edit/loop_mode=2 en su .import), que regenerarlo no toca.
func _guardar(nombre: String, muestras: PackedFloat32Array, es_musica := false) -> void:
	var escala := 1.0
	if es_musica:
		var pico := 0.001
		for valor in muestras:
			pico = maxf(pico, absf(valor))
		escala = 0.9 / pico

	var datos := PackedByteArray()
	datos.resize(muestras.size() * 2)
	for i in muestras.size():
		datos.encode_s16(i * 2, roundi(clampf(muestras[i] * escala, -1.0, 1.0) * 32767.0))

	var sonido := AudioStreamWAV.new()
	sonido.format = AudioStreamWAV.FORMAT_16_BITS
	sonido.mix_rate = MEZCLA
	sonido.data = datos
	sonido.save_to_wav(RUTA + nombre + ".wav")
