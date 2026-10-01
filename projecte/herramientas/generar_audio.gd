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
	print("audio generado")
	quit()


func _efectos() -> void:
	_guardar("muerte", _mezclar([_nota(500, 120, 0.12, "cuadrada", 0.35), _nota(0, 0, 0.1, "ruido", 0.3)]))
	_guardar("gema", _nota(1300, 1900, 0.06, "seno", 0.4))
	_guardar("subir_nivel", _arpegio([72, 76, 79, 84], 0.07, "cuadrada", 0.3))
	_guardar("elegir", _arpegio([81, 88], 0.08, "triangulo", 0.5))
	_guardar("dano", _mezclar([_nota(200, 80, 0.2, "sierra", 0.4), _nota(0, 0, 0.12, "ruido", 0.3)]))
	_guardar("victoria", _arpegio([72, 76, 79, 84, 79, 84, 88], 0.12, "cuadrada", 0.3))
	_guardar("derrota", _arpegio([67, 64, 60, 55, 48], 0.18, "sierra", 0.35))
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


## Dm, Bb, C y A a 150 pulsaciones: más rápida y con el bajo en sierra. 13 s.
func _musica_jefe() -> void:
	var acordes := [[62, 65, 69], [58, 62, 65], [60, 64, 67], [57, 61, 64]]
	var paso := 60.0 / 150.0 / 2.0
	var bajo := []
	var arpegio := []
	for acorde in acordes:
		for compas in 2:
			for i in 8:
				bajo.append(acorde[0] - 24 + (12 if i % 2 == 1 else 0))
				arpegio.append(acorde[[0, 1, 2, 1][i % 4]] + 24)
	var pistas := [
		_secuencia(bajo, paso, "sierra", 0.25, 0.9),
		_secuencia(arpegio, paso, "cuadrada", 0.12, 0.5),
	]
	pistas.append_array(_bateria(bajo.size(), paso))
	_guardar("musica_jefe", _mezclar(pistas), true)


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
