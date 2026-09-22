shader_type canvas_item;

uniform vec4 color_fondo : source_color = vec4(0.02, 0.03, 0.06, 1.0);
uniform vec4 color_linea : source_color = vec4(0.0, 0.85, 0.95, 0.35);
uniform float tamano_rejilla = 48.0;
uniform float grosor_linea = 1.5;

void fragment() {
    // Usamos el tamaño real del ColorRect mediante su textura de render o escala UV
    // En Godot 4 CanvasItem, SCREEN_PIXEL_SIZE o UV multiplicado por el tamaño absoluto funciona directo
    vec2 pos = UV * (1.0 / SCREEN_PIXEL_SIZE);
    // Para asegurar independencia de zoom, calculamos respecto a píxeles locales:
    vec2 rejilla = mod(UV * vec2(2000.0, 1200.0), tamano_rejilla);

    float linea_x = step(rejilla.x, grosor_linea);
    float linea_y = step(rejilla.y, grosor_linea);
    float patron = clamp(linea_x + linea_y, 0.0, 1.0);

    COLOR = mix(color_fondo, color_linea, patron);
}