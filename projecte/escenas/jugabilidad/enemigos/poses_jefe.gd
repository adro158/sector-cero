extends RefCounted

## Qué hoja y qué fotograma lleva Kernel Panic según lo que hace (lote 10).
## Andando, la de andar (12 columnas). Avisando la embestida, invocando o
## antes de la ráfaga, la de cargar (5): se yergue cargando energía morada;
## los 3 primeros fotogramas suben y el 3 y el 4 se repiten mientras dura. En
## el pisotón, la del pisotón (6): se agacha y salta mientras la jaula avisa
## (0,5 s), y al pisar cae con polvo y se recupera (ATERRIZAJE).
##
## Las tres hojas tienen las mismas 8 filas, una por dirección, y el mismo
## tamaño de fotograma. Sin class_name: jefe.gd la carga con preload.

const ANDAR := preload("res://escenas/jugabilidad/enemigos/jefe_8_direcciones.png")
const CARGAR := preload("res://medios/sprites/jefe/jefe_cargar.png")
const PISOTON := preload("res://medios/sprites/jefe/jefe_pisoton.png")
const COLUMNAS_ANDAR := 12
const COLUMNAS_CARGAR := 5
const COLUMNAS_PISOTON := 6
const SEGUNDOS := 0.1
## Lo que se queda quieto después de pisar: los dos últimos fotogramas.
const SEGUNDOS_CAIDA := 0.12
const ATERRIZAJE := SEGUNDOS_CAIDA * 2


static func andar(sprite: Sprite2D, fila: int, columna: int) -> void:
	_poner(sprite, ANDAR, COLUMNAS_ANDAR, fila, columna)


static func cargar(sprite: Sprite2D, fila: int, tiempo: float) -> void:
	var columna := int(tiempo / SEGUNDOS)
	if columna >= 3:
		columna = 3 + (columna - 3) % 2
	_poner(sprite, CARGAR, COLUMNAS_CARGAR, fila, columna)


## En el aire, de 0 a 3 a lo largo del aviso; tras pisar (desde_que_piso de 0
## en adelante), el 4 y el 5.
static func pisoton(sprite: Sprite2D, fila: int, tiempo: float, aviso: float, desde_que_piso: float) -> void:
	var columna := mini(int(tiempo / aviso * 4.0), 3)
	if desde_que_piso >= 0.0:
		columna = 4 + mini(int(desde_que_piso / SEGUNDOS_CAIDA), 1)
	_poner(sprite, PISOTON, COLUMNAS_PISOTON, fila, columna)


## Cambia de hoja solo si hace falta. Primero el fotograma 0: con menos
## columnas, el que tenía podía no existir.
static func _poner(sprite: Sprite2D, hoja: Texture2D, columnas: int, fila: int, columna: int) -> void:
	if sprite.texture != hoja:
		sprite.frame = 0
		sprite.texture = hoja
		sprite.hframes = columnas
	sprite.frame = fila * columnas + columna
