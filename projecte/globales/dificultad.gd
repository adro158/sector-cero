extends RefCounted

## Las tres dificultades. La media es el juego tal como estaba equilibrado en
## la v0.9, salvo que ahora la horda se queda cuando llega el jefe (decisión de
## Adam, bitácora, sesión 11). La elegida se guarda en las opciones
## (GestorGuardado) y la partida la lee al empezar.
##
## - vida: multiplica la vida de la horda, los élites y el jefe del minuto 10.
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
## Sin class_name: se carga con preload, como embestida_horda.gd.

const DIFICULTADES := {
	"facil": {
		"nombre": "FÁCIL", "vida": 0.65, "vida_jefe_final": 0.4, "vida_anclas": 0.65, "dano": 0.6, "huye": 1.0,
		"explicacion": "El malware tiene menos vida, hace menos daño y huye cuando llega el jefe.",
	},
	"media": {
		"nombre": "MEDIA", "vida": 0.7, "vida_jefe_final": 0.75, "vida_anclas": 0.7, "dano": 0.85, "huye": 0.5,
		"explicacion": "La partida como la hemos equilibrado. La mitad de la horda huye cuando llega el jefe.",
	},
	"dificil": {
		"nombre": "DIFÍCIL", "vida": 1.0, "vida_jefe_final": 0.75, "vida_anclas": 0.7, "dano": 1.1, "huye": 0.0,
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
