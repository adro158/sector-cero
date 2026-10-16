extends RefCounted

## Las tres dificultades. La media es el juego tal como estaba equilibrado en
## la v0.9, salvo que ahora la horda se queda cuando llega el jefe (decisión de
## Adam, bitácora, sesión 11). La elegida se guarda en las opciones
## (GestorGuardado) y la partida la lee al empezar.
##
## - vida: multiplica la vida de la horda, los élites y el jefe.
## - dano: multiplica el daño que recibe el jugador.
## - horda_huye: si al llegar el jefe la horda que queda se va.
##
## Medido con el simulador el 13/10/2026, 10 partidas en cada una: fácil, 10
## victorias; media, 1 (4 si la horda huyera, como en la v0.9: quedarse la
## horda es lo que la endurece); difícil, ninguna, y en la mitad no llega al
## jefe. Con la fase 2 y el jefe final (16/10/2026): fácil, 5; media y
## difícil, ninguna. El equilibrio se hace al final, con el juego terminado
## (decisión de Adam).
##
## Sin class_name: se carga con preload, como embestida_horda.gd.

const DIFICULTADES := {
	"facil": {
		"nombre": "FÁCIL", "vida": 0.7, "dano": 0.6, "horda_huye": true,
		"explicacion": "El malware tiene menos vida, hace menos daño y huye cuando llega el jefe.",
	},
	"media": {
		"nombre": "MEDIA", "vida": 1.0, "dano": 1.0, "horda_huye": false,
		"explicacion": "La partida como la hemos equilibrado. La horda sigue cuando llega el jefe.",
	},
	"dificil": {
		"nombre": "DIFÍCIL", "vida": 1.2, "dano": 1.3, "horda_huye": false,
		"explicacion": "El malware tiene más vida y hace más daño. La horda sigue cuando llega el jefe.",
	},
}


## La clave de la elegida. Si en las opciones hay algo raro, la media.
static func actual() -> String:
	var clave: String = GestorGuardado.opcion("dificultad")
	return clave if clave in DIFICULTADES else "media"


## Un dato de la elegida: dato("vida"), dato("dano"), dato("horda_huye")...
static func dato(nombre: String) -> Variant:
	return DIFICULTADES[actual()][nombre]
