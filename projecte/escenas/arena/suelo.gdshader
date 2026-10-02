// Suelo de placa base hecho con baldosas de pixel art: pulsos de datos que
// recorren las pistas, LEDs que parpadean, chips que brillan y ventiladores.
//
// Igual que antes, todo se calcula con la posición en el mundo y no con la del
// rectángulo: el rectángulo sigue a la cámara y el dibujo se queda quieto en el
// suelo, así que el mapa no se acaba nunca.
//
// Baldosas: el plano se divide en casillas de 256x256 y cada una tira un número
// al azar, siempre el mismo para esa casilla, que elige uno de los doce
// dibujos del atlas (suelo_placa.png: 4 columnas x 3 filas de dibujos). Todos
// tienen las pistas que tocan el borde en las mismas posiciones, así que
// encajan entre ellos sin costuras, se pongan como se pongan.
//
// Pulsos: la máscara (suelo_placa_mascara.png) marca las pistas que llevan
// datos. Rojo: cuánto se ilumina ese píxel. Verde: cuánto camino lleva
// recorrido la pista en ese punto (su "fase"). Azul: si la pista va en
// horizontal (0) o en vertical (1). Un punto de luz avanza por las fases y
// parece que los datos viajan por la placa. Cuánto ha avanzado lo dice
// avance_pulsos, que actualiza arena.gd (así la velocidad puede cambiar
// durante la partida sin que los pulsos salten de sitio).
//
// Efectos: la tercera textura (suelo_placa_efectos.png) dice qué es cada
// píxel con el azul: LED (1), aspa de ventilador (2/3) o brillo de chip (1/3).
// Rojo y verde son datos de ese efecto (ver cada caso abajo).
//
// Ojo: en este proyecto un número escrito como 0.05 llega al shader como 0.5.
// Por eso aquí no hay ningún número con un cero justo detrás del punto, y los
// valores ajustables se fijan desde el material (suelo.tres).
shader_type canvas_item;

uniform sampler2D baldosas : filter_nearest, repeat_disable;
uniform sampler2D mascara : filter_nearest, repeat_disable;
uniform sampler2D efectos : filter_nearest, repeat_disable;
uniform float tamano_baldosa = 256.0;
// Cuántos dibujos tiene el atlas a lo ancho y a lo alto.
uniform float columnas = 4.0;
uniform float filas = 3.0;

uniform vec4 color_pulso : source_color = vec4(0.3, 0.9, 1.0, 1.0);
uniform float intensidad_pulso = 1.2;
// Cuánto han avanzado los pulsos, en baldosas. Lo actualiza arena.gd.
uniform float avance_pulsos = 0.0;
// Largo de la estela del pulso, en fracción de baldosa.
uniform float longitud_pulso = 0.2;

// Parpadeos por segundo de un LED normal.
uniform float velocidad_leds = 0.8;
uniform vec4 color_brillo : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform float intensidad_brillo = 0.7;
// Aspas que pasan por un punto cada segundo.
uniform float velocidad_ventilador = 3.0;

varying vec2 posicion;

void vertex() {
	// MODEL_MATRIX lleva del rectángulo al mundo.
	posicion = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// Número pseudoaleatorio entre 0 y 1, siempre el mismo para la misma casilla.
float azar(vec2 casilla, float semilla) {
	return fract(sin(dot(casilla + semilla, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 casilla = floor(posicion / tamano_baldosa);
	// Dónde cae el píxel dentro de su baldosa, de 0 a 1.
	vec2 dentro = fract(posicion / tamano_baldosa);

	// Qué dibujo del atlas le toca a esta casilla.
	float dibujo = floor(azar(casilla, 3.0) * columnas * filas);
	vec2 esquina = vec2(mod(dibujo, columnas), floor(dibujo / columnas));
	vec2 uv = (esquina + dentro) / vec2(columnas, filas);

	vec3 color = texture(baldosas, uv).rgb;
	vec4 marca = texture(mascara, uv);
	vec4 efecto = texture(efectos, uv);

	if (efecto.b > 0.8) {
		// LED: se enciende y se apaga. El rojo cambia su ritmo y el verde el
		// momento, para que cada LED vaya a su aire.
		float ritmo = 0.5 + efecto.r * 1.5;
		float momento = efecto.g + azar(casilla, 5.0);
		float encendido = step(0.35, fract(TIME * velocidad_leds * ritmo + momento));
		color *= 0.25 + 0.75 * encendido;
	} else if (efecto.b > 0.5) {
		// Aspas del ventilador: el verde es el ángulo alrededor del centro y el
		// rojo la distancia al centro (curva un poco las aspas). Hay 7 aspas
		// que giran con el tiempo.
		float aspa = fract(efecto.g * 7.0 + efecto.r * 0.35 - TIME * velocidad_ventilador);
		color *= aspa < 0.5 ? 1.5 : 0.45;
	} else if (efecto.b > 0.2) {
		// Brillo alrededor de los chips: sube y baja despacio, como si respiraran.
		float respira = 0.5 + 0.5 * sin(TIME * 2.0 + azar(casilla, 7.0) * 6.28);
		color += color_brillo.rgb * efecto.r * respira * intensidad_brillo;
	}

	if (marca.r > 0.0) {
		// Cada fila de baldosas (pistas horizontales) o columna (pistas
		// verticales) tiene su propio retraso, para que no latan todas a la vez.
		// Se usa la fila o la columna entera, y no la casilla, para que el pulso
		// pase de una baldosa a la siguiente sin saltos.
		float retraso;
		if (marca.b > 0.5) {
			retraso = azar(vec2(casilla.x, 0.0), 9.0);
		} else {
			retraso = azar(vec2(0.0, casilla.y), 9.0);
		}
		// La fase se guardó como un byte (0-255) que da la vuelta a los 256 píxeles.
		float fase = marca.g * 255.0 / 256.0;
		// Distancia por detrás de la cabeza del pulso: 0 en la cabeza.
		float detras = fract(avance_pulsos + retraso - fase);
		float pulso = 1.0 - smoothstep(0.0, longitud_pulso, detras);
		color += color_pulso.rgb * pulso * marca.r * intensidad_pulso;
	}

	COLOR = vec4(color, 1.0);
}
