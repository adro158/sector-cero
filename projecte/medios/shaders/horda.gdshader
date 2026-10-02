// Shader de la horda. Hace las veces de animación, que un MultiMesh no puede
// tener porque todas sus instancias comparten una misma textura:
//
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

varying float destello;
varying float glitch;
varying float aviso;

float azar(float semilla) {
	return fract(sin(semilla * 12.9898) * 43758.5453);
}

void vertex() {
	destello = INSTANCE_CUSTOM.r;
	aviso = INSTANCE_CUSTOM.g;
	float tirada = azar(float(INSTANCE_ID) * 7.31 + floor(TIME * TIRADAS_POR_SEGUNDO));
	glitch = step(1.0 - PROBABILIDAD, tirada);
	VERTEX.x += glitch * (tirada - 0.5) * 2.0 * SALTO;
}

void fragment() {
	// En Godot 4, COLOR ya llega con la textura aplicada (el color del nodo
	// por el de la textura). Antes se volvía a multiplicar por la textura y
	// toda la horda salía más oscura que sus sprites.
	vec4 color = COLOR;
	if (glitch > 0.5) {
		// Rojo y azul se leen un poco desplazados: los colores se separan.
		vec2 separacion = vec2(TEXTURE_PIXEL_SIZE.x * 1.5, 0.0);
		color.r = texture(TEXTURE, UV + separacion).r;
		color.b = texture(TEXTURE, UV - separacion).b;
	}
	// Medio ciclo en rojo y medio con su color: un parpadeo rápido.
	float parpadeo = aviso * step(0.5, fract(TIME * PARPADEOS_POR_SEGUNDO));
	color.rgb = mix(color.rgb, COLOR_AVISO, parpadeo * 0.75);
	color.rgb = mix(color.rgb, vec3(1.0), destello);
	COLOR = color;
}
