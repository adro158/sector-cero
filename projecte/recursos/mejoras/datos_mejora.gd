class_name DatosMejora
extends Resource

enum Efecto {
	DANO_ARMAS,
	CADENCIA_ARMAS,
	ALCANCE_ARMAS,
	VELOCIDAD_JUGADOR,
	VIDA_MAXIMA,
	EVOLUCIONAR_ARMA,
	# Las nuevas, siempre al final: los .tres guardan el efecto como número y
	# meterlas en medio cambiaría el de las que ya existen.
	ADAPTACION_MALWARE,
	ESPERA_CAMBIO,
	RADIO_IMAN,
}

@export var nombre: String = ""
## Icono de 16x16 para la tarjeta y la columna de mejoras del HUD.
@export var icono: Texture2D
@export_multiline var descripcion: String = ""
@export var efecto: Efecto = Efecto.DANO_ARMAS
@export var valor: float = 0.15

@export_group("Solo evoluciones")
## La herramienta que evoluciona y en cuál se convierte.
@export var arma_base: DatosArma
@export var arma: DatosArma
## La evolución se ofrece cuando esta mejora se ha elegido nivel_requisito veces.
@export var requisito: DatosMejora
@export var nivel_requisito: int = 3
