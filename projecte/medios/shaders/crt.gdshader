// Filtro de monitor CRT a pantalla completa: líneas de barrido, colores
// ligeramente separados y bordes más oscuros. Lee lo que ya se ha dibujado en
// pantalla (hint_screen_texture) y lo devuelve retocado, así que afecta a todo
// lo que hay por debajo de su capa: el juego y la interfaz.
shader_type canvas_item;

uniform sampler2D pantalla : hint_screen_texture, filter_linear;
// Cuánto oscurecen las líneas de barrido, de 0 a 1.
uniform float intensidad_lineas = 0.18;
// Separación de los canales rojo y azul, en píxeles.
uniform float separacion_color = 1.2;
// Cuánto se oscurecen las esquinas.
uniform float vineta = 0.45;
// El tema de color del pase (de Alan, 19/11; premios.gd): la pantalla se tiñe
// de ese color, como un monitor de fósforo. Con fuerza_tinte a 0, nada.
uniform vec4 tinte : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fuerza_tinte = 0.0;

void fragment() {
	vec2 desplazamiento = vec2(separacion_color * SCREEN_PIXEL_SIZE.x, 0.0);
	vec3 color;
	color.r = texture(pantalla, SCREEN_UV + desplazamiento).r;
	color.g = texture(pantalla, SCREEN_UV).g;
	color.b = texture(pantalla, SCREEN_UV - desplazamiento).b;

	// Una línea oscura cada dos píxeles de la pantalla real.
	float linea = 0.5 + 0.5 * sin(FRAGCOORD.y * PI);
	color *= 1.0 - intensidad_lineas * linea;

	// Viñeta: más oscuro cuanto más lejos del centro.
	float distancia = length(SCREEN_UV - 0.5) * 1.4;
	color *= 1.0 - vineta * distancia * distancia * distancia;

	// El tema: el brillo de cada píxel, en el color del tinte (1.6: para que no
	// se oscurezca al quitarle el color).
	float brillo = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, brillo * tinte.rgb * 1.6, fuerza_tinte);

	COLOR = vec4(color, 1.0);
}
