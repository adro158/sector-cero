// Suelo de placa base: fondo oscuro, rejilla de neón y, encima, pistas de
// circuito, vías y algún chip.
//
// Todo se calcula con la posición en el mundo y no con la del rectángulo: así
// el rectángulo puede ir siguiendo a la cámara mientras el dibujo se queda
// quieto en el suelo, y el mapa no se acaba nunca.
//
// Las pistas: el plano se divide en celdas y cada una tira un número al azar,
// siempre el mismo para esa celda. Según su valor lleva una pista horizontal,
// una vertical, una vía o un chip. Como las pistas cruzan la celda de lado a
// lado, las de celdas vecinas se empalman y forman líneas largas.
//
// Ojo: en este proyecto un número escrito como 0.05 llega al shader como 0.5
// (se pierde el cero de detrás del punto; comprobado con Godot 4.7.2 y el
// renderizador Compatibility). Por eso los valores pequeños van como
// divisiones, que sí salen bien, y los colores se fijan desde el material.
shader_type canvas_item;

uniform vec4 color_fondo : source_color = vec4(0.02, 0.03, 0.06, 1.0);
uniform vec4 color_rejilla : source_color = vec4(0.0, 0.8, 0.9, 0.3);
uniform float tamano_rejilla = 64.0;
uniform float grosor_rejilla = 1.5;
uniform float tamano_celda = 96.0;
uniform vec4 color_pista : source_color = vec4(0.1, 0.6, 0.45, 0.28);
uniform vec4 color_via : source_color = vec4(0.2, 0.9, 0.7, 0.55);
uniform vec4 color_chip : source_color = vec4(0.04, 0.06, 0.1, 0.92);
uniform vec4 color_borde_chip : source_color = vec4(0.25, 0.45, 0.6, 0.8);

varying vec2 posicion;

void vertex() {
	// MODEL_MATRIX lleva del rectángulo al mundo.
	posicion = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// Número pseudoaleatorio entre 0 y 1, siempre el mismo para la misma celda.
float azar(vec2 celda, float semilla) {
	return fract(sin(dot(celda + semilla, vec2(127.1, 311.7))) * 43758.5453);
}

// Mezcla una capa encima del color que ya hay, según la transparencia de la capa.
vec3 encima(vec3 debajo, vec4 capa) {
	return mix(debajo, capa.rgb, capa.a);
}

void fragment() {
	vec3 color = color_fondo.rgb;

	// mod da siempre un resultado positivo, también con posiciones negativas.
	vec2 rejilla = mod(posicion, tamano_rejilla);
	if (rejilla.x < grosor_rejilla || rejilla.y < grosor_rejilla) {
		color = encima(color, color_rejilla);
	}

	vec2 celda = floor(posicion / tamano_celda);
	// Coordenadas dentro de la celda, de -0.5 a 0.5, con el centro en 0.
	vec2 dentro = fract(posicion / tamano_celda) - 0.5;
	float grosor = 1.5 / tamano_celda;
	float tipo = azar(celda, 0.0);

	if (tipo < 0.3 && abs(dentro.y) < grosor) {
		color = encima(color, color_pista);
	} else if (tipo >= 0.3 && tipo < 0.6 && abs(dentro.x) < grosor) {
		color = encima(color, color_pista);
	}

	// Vía: un punto redondo en algunas pistas.
	if (tipo < 0.6 && azar(celda, 7.0) < 0.35 && length(dentro) < 1.0 / 20.0) {
		color = encima(color, color_via);
	}

	// Chip: un rectángulo oscuro con borde, en muy pocas celdas.
	if (tipo > 0.92) {
		vec2 mitad = vec2(0.28, 0.2);
		if (abs(dentro.x) < mitad.x && abs(dentro.y) < mitad.y) {
			float borde = 3.0 / 100.0;
			bool en_borde = abs(dentro.x) > mitad.x - borde || abs(dentro.y) > mitad.y - borde;
			color = encima(color, en_borde ? color_borde_chip : color_chip);
		}
	}

	COLOR = vec4(color, 1.0);
}
