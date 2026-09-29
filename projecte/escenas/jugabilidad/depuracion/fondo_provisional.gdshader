// Fondo provisional de placa base: pistas de circuito, vías y algún chip sobre
// una base transparente, para que la rejilla de la arena de Alan siga viéndose
// debajo. Se quita cuando la arena tenga su fondo definitivo.
//
// El plano se divide en celdas. Cada celda tira un número al azar, siempre el
// mismo para esa celda, y según su valor lleva una pista horizontal, una
// vertical, una vía o un chip. Como las pistas cruzan la celda de lado a lado,
// las de celdas vecinas se empalman y forman líneas largas.
//
// Ojo: en este proyecto un número escrito como 0.05 llega al shader como 0.5
// (se pierde el cero de detrás del punto; comprobado con Godot 4.7.2 y
// renderizador Compatibility). Por eso los valores pequeños van como
// divisiones, que sí salen bien, y los colores se fijan desde el material.
shader_type canvas_item;

uniform float tamano_celda = 96.0;
uniform vec4 color_pista : source_color = vec4(0.1, 0.6, 0.45, 0.28);
uniform vec4 color_via : source_color = vec4(0.2, 0.9, 0.7, 0.55);
uniform vec4 color_chip : source_color = vec4(0.04, 0.06, 0.1, 0.92);
uniform vec4 color_borde_chip : source_color = vec4(0.25, 0.45, 0.6, 0.8);

// Posición en píxeles dentro del rectángulo, que coincide con el mundo: así el
// dibujo no se mueve con la cámara.
varying vec2 posicion;

void vertex() {
	posicion = VERTEX;
}

// Número pseudoaleatorio entre 0 y 1, siempre el mismo para la misma celda.
float azar(vec2 celda, float semilla) {
	return fract(sin(dot(celda + semilla, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 celda = floor(posicion / tamano_celda);
	// Coordenadas dentro de la celda, de -0.5 a 0.5, con el centro en 0.
	vec2 dentro = fract(posicion / tamano_celda) - 0.5;
	float grosor = 1.5 / tamano_celda;
	float tipo = azar(celda, 0.0);

	vec4 color = vec4(0.0);

	if (tipo < 0.3 && abs(dentro.y) < grosor) {
		color = color_pista;
	} else if (tipo >= 0.3 && tipo < 0.6 && abs(dentro.x) < grosor) {
		color = color_pista;
	}

	// Vía: un punto redondo al final de algunas pistas.
	if (tipo < 0.6 && azar(celda, 7.0) < 0.35 && length(dentro) < 1.0 / 20.0) {
		color = color_via;
	}

	// Chip: un rectángulo oscuro con borde, en muy pocas celdas.
	if (tipo > 0.92) {
		vec2 mitad = vec2(0.28, 0.2);
		if (abs(dentro.x) < mitad.x && abs(dentro.y) < mitad.y) {
			float borde = 3.0 / 100.0;
			bool en_borde = abs(dentro.x) > mitad.x - borde || abs(dentro.y) > mitad.y - borde;
			color = en_borde ? color_borde_chip : color_chip;
		}
	}

	COLOR = color;
}
