extends RefCounted

## Las tres dificultades. La media es el juego tal como estaba equilibrado en
## la v0.9, salvo que ahora la horda se queda cuando llega el jefe (decisión de
## Adam, bitácora, sesión 11). La elegida se guarda en las opciones
## (GestorGuardado) y la partida la lee al empezar.
##
## - vida: multiplica la vida de la horda y los élites.
## - vida_jefe: la de Kernel Panic, el jefe del minuto 10. Hasta el 23/10 era
##   la de la horda; en difícil (×1) se perdía contra él casi la mitad de las
##   partidas.
## - vida_jefe_final: multiplica la de NÚCLEO CERO, que va aparte (sesión 18).
## - vida_anclas: la de las anclas de su escudo. En difícil, la de la media:
##   con la de la horda (300) se tardaba demasiado en romperlas (Adam,
##   22/10). En fácil y en media no cambia.
## - dano: multiplica el daño que recibe el jugador.
## - huye: la parte de la horda que se va al llegar el jefe (1 toda, 0 nadie).
##
## Medido con el simulador el 13/10/2026, 10 partidas en cada una: fácil, 10
## victorias; media, 1 (4 si la horda huyera, como en la v0.9: quedarse la
## horda es lo que la endurece); difícil, ninguna, y en la mitad no llega al
## jefe. Con la fase 2 y el jefe final (16/10/2026): fácil, 5; media y
## difícil, ninguna.
##
## Equilibrado el 22/10/2026 (sesión 18) al objetivo de Adam: de cada 10
## partidas, 7-8 victorias en fácil, 4-5 en media y 1 en difícil. Con 20
## partidas por dificultad: 15, 9 y 2. La vida de NÚCLEO CERO va aparte
## porque contra él se pierde por falta de daño (se acaba el tiempo con el
## personaje entero), no de vida: con un solo multiplicador, bajarla para él
## ablandaba también la horda.
##
## 29/10 (sesión 19): NÚCLEO CERO con un 50 % más de vida y los jefes más
## duros. Con 20 partidas (en el instituto) quedó en 11 / 7 / 1: fácil y
## media perdían sobre todo por tiempo contra la amalgama. Su vida en fácil
## pasó de 0,42 a 0,32 y en media de 0,5 a 0,45, sin volver a medir (Adam no
## quiso más simulaciones): falta comprobarlo.
##
## Vuelto a equilibrar el 23/10 (en la nube), tras el cono del Espadachín, las
## furias de Kernel Panic y los caídos que vuelven en la fase 2: con 20
## partidas salía 18 / 6 / 0. Se subió la vida de NÚCLEO CERO en fácil (0,4 a
## 0,5), se bajó en media (0,75 a 0,65) y Kernel Panic pasó a tener la suya
## (en difícil, 0,8).
##
## Ajustado otra vez el 23/10 en el ordenador de casa, al objetivo de Adam en
## 20 partidas: 15-16 en fácil, 8-10 en media y 2 en difícil. Antes salía 13 /
## 9 / 0 (en la nube daba 17 / 5 / 0 con el mismo código; seguramente porque
## los cálculos con decimales no dan igual en Windows y en Linux). Fácil: NÚCLEO CERO de 0,5 a
## 0,42 (perdía por tiempo contra él). Difícil: Kernel Panic de 0,8 a 0,55,
## NÚCLEO CERO de 0,75 a 0,6 y daño recibido de 1,1 a 1 (se perdía contra
## Kernel Panic y muriendo en la primera forma de NÚCLEO CERO). Ahora sale
## 15 / 9 / 2. Media no se tocó.
##
## Con 100 partidas por dificultad (23/10, en casa): fácil 78, media 36 y
## difícil 13; objetivo 75-80, 40-50 y unas 10. En media, 47 de las 64
## derrotas eran por tiempo contra NÚCLEO CERO: su vida bajó de 0,65 a 0,58
## (39) y a 0,5 (49). Fácil y difícil no se tocaron: 78 / 49 / 13.
##
## Sin class_name: se carga con preload, como embestida_horda.gd.

const DIFICULTADES := {
	"facil": {
		"nombre": "FÁCIL", "vida": 0.65, "vida_jefe": 0.65, "vida_jefe_final": 0.32, "vida_anclas": 0.65, "dano": 0.6, "huye": 1.0,
		"explicacion": "El malware tiene menos vida, hace menos daño y huye cuando llega el jefe.",
	},
	"media": {
		"nombre": "MEDIA", "vida": 0.7, "vida_jefe": 0.7, "vida_jefe_final": 0.45, "vida_anclas": 0.7, "dano": 0.85, "huye": 0.5,
		"explicacion": "La partida como la hemos equilibrado. La mitad de la horda huye cuando llega el jefe.",
	},
	"dificil": {
		"nombre": "DIFÍCIL", "vida": 1.0, "vida_jefe": 0.55, "vida_jefe_final": 0.6, "vida_anclas": 0.7, "dano": 1.0, "huye": 0.0,
		"explicacion": "El malware tiene más vida y hace más daño. La horda sigue cuando llega el jefe.",
	},
}


## La clave de la elegida. Si en las opciones hay algo raro, la media.
static func actual() -> String:
	var clave: String = GestorGuardado.opcion("dificultad")
	return clave if clave in DIFICULTADES else "media"


## Un dato de la elegida: dato("vida"), dato("dano"), dato("huye")...
static func dato(nombre: String) -> Variant:
	return DIFICULTADES[actual()][nombre]
