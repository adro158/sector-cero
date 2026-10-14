// Destello blanco al recibir un golpe, para los sprites de los élites y del
// jefe: el mismo que hace la horda (horda.gdshader), pero en un Sprite2D. Va
// en un shader y no en el modulate porque el modulate ya lo usan el aviso rojo
// del jefe y su latido morado.
//
// COLOR ya llega con la textura y el modulate aplicados: solo se mezcla con
// blanco, sin tocar la transparencia.
shader_type canvas_item;

// De 0 (su color) a 1 (blanco). Lo baja sprite_destello.gd después de cada golpe.
uniform float destello = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), destello);
}
