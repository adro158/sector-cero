// Shader de la horda. Todos los enemigos de un tipo son un solo MultiMesh: una
// llamada de dibujo, una textura y este material. Lo que cambia de uno a otro
// lo pone el shader:
//
// - Animación: la textura es una tira de fotogramas en horizontal. Cada
//   enemigo elige el suyo con TIME y con su INSTANCE_ID, para que no se muevan
//   todos a la vez. Con fotogramas = 1 es un sprite quieto, como antes.
// - Destello: el enemigo se pone blanco un instante al recibir un golpe. La
//   intensidad, de 0 a 1, llega por enemigo en INSTANCE_CUSTOM.r, que rellena
//   el gestor de enemigos.
// - Glitch: de vez en cuando cada enemigo da un salto de lado y separa sus
//   colores, como una imagen corrupta. Cada enemigo tira su propio dado
//   (INSTANCE_ID entra en el azar) para que no lo hagan todos a la vez.
// - Aviso de embestida: los que embisten (el troyano) parpadean en rojo
//   mientras se preparan. Llega por enemigo en INSTANCE_CUSTOM.g: 1 mientras
//   avisa y 0 si no.
//
// Los valores pequeños van como divisiones por el fallo de este proyecto con
// los números que llevan un cero detrás del punto (ver suelo.gdshader).
shader_type canvas_item;

const float TIRADAS_POR_SEGUNDO = 6.0;
const float PROBABILIDAD = 8.0 / 100.0;
const float SALTO = 6.0;
const float PARPADEOS_POR_SEGUNDO = 10.0;
const vec3 COLOR_AVISO = vec3(1.0, 0.25, 0.3);

// Los pone el gestor de cada tipo en su copia del material.
uniform float fotogramas = 1.0;
uniform float fotogramas_por_segundo = 8.0;

// Un varying es un valor que vertex() calcula y fragment() recibe. Aquí son
// cosas de cada enemigo entero (su golpe, su glitch, su fotograma), así que
// valen lo mismo en todos los píxeles de su cuadrado.
varying float destello;
varying float glitch;
varying float aviso;
varying float fotograma;
// El color del vértice (el modulate del nodo), sin la textura: en fragment()
// se lee otra parte de la textura y hay que volver a multiplicarlo.
varying vec4 color_vertice;

float azar(float semilla) {
	return fract(sin(semilla * 12.9898) * 43758.5453);
}

void vertex() {
	destello = INSTANCE_CUSTOM.r;
	aviso = INSTANCE_CUSTOM.g;
	float tirada = azar(float(INSTANCE_ID) * 7.31 + floor(TIME * TIRADAS_POR_SEGUNDO));
	glitch = step(1.0 - PROBABILIDAD, tirada);
	VERTEX.x += glitch * (tirada - 0.5) * 2.0 * SALTO;
	// Todos cambian de fotograma al mismo ritmo, pero cada uno empieza en uno
	// distinto (el desfase): así no se mueven todos a la vez.
	float desfase = floor(azar(float(INSTANCE_ID) * 3.17) * fotogramas);
	fotograma = mod(floor(TIME * fotogramas_por_segundo) + desfase, fotogramas);
	color_vertice = COLOR;
}

void fragment() {
	// UV va de 0 a 1 en todo el cuadrado del enemigo, pero la textura es la
	// tira entera: el fotograma f ocupa de f / fotogramas a (f + 1) / fotogramas.
	// Por eso se suma el fotograma y se divide entre los que hay.
	vec2 uv = vec2((UV.x + fotograma) / fotogramas, UV.y);
	// En Godot 4, COLOR ya llega con la textura aplicada, pero leída con UV: el
	// fotograma 0. Por eso se lee aquí la que toca y se multiplica por el color
	// del vértice, que es lo que COLOR traía antes de la textura (y lo que
	// desvanece la horda al huir).
	vec4 color = texture(TEXTURE, uv) * color_vertice;
	if (glitch > 0.5) {
		// Rojo y azul se leen un poco desplazados: los colores se separan.
		vec2 separacion = vec2(TEXTURE_PIXEL_SIZE.x * 1.5, 0.0);
		color.r = texture(TEXTURE, uv + separacion).r;
		color.b = texture(TEXTURE, uv - separacion).b;
	}
	// Medio ciclo en rojo y medio con su color: un parpadeo rápido.
	float parpadeo = aviso * step(0.5, fract(TIME * PARPADEOS_POR_SEGUNDO));
	color.rgb = mix(color.rgb, COLOR_AVISO, parpadeo * 0.75);
	color.rgb = mix(color.rgb, vec3(1.0), destello);
	COLOR = color;
}
