class_name DatosMejora
extends Resource

enum Efecto {
	DANO_ARMAS,
	CADENCIA_ARMAS,
	ALCANCE_ARMAS,
	VELOCIDAD_JUGADOR,
	VIDA_MAXIMA,
	NUEVA_ARMA,
}

@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var efecto: Efecto = Efecto.DANO_ARMAS
@export var valor: float = 0.15

## Solo para el efecto NUEVA_ARMA: el arma que se añade al elegir esta mejora.
@export var arma: DatosArma
