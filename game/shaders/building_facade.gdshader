// Shader de façades GTDZ : projette une texture de façade sur les murs et une
// texture de toit sur les surfaces horizontales, en coordonnées monde (pas
// besoin d'UV sur les meshes extrudés depuis OSM). Compatible gl_compatibility.
shader_type spatial;

uniform sampler2D facade_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D roof_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Taille en mètres couverte par une répétition de la texture (x = largeur, y = hauteur).
uniform vec2 facade_size_m = vec2(9.0, 9.0);
uniform float roof_size_m = 8.0;
// Fenêtres procédurales (les banques CC0 n'ont pas de façades avec fenêtres :
// on les dessine par-dessus l'enduit). Grille : un étage = 3 m.
uniform bool windows_enabled = true;
uniform vec2 window_cell_m = vec2(2.8, 3.0);
uniform vec4 window_rect_m = vec4(0.75, 1.05, 2.05, 2.55); // x_min, y_min, x_max, y_max dans la cellule
uniform vec3 window_color : source_color = vec3(0.16, 0.19, 0.24);

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(world_normal);
	vec3 col;
	if (abs(n.y) > 0.6) {
		col = texture(roof_tex, world_pos.xz / roof_size_m).rgb;
	} else {
		// Projection selon l'axe horizontal dominant de la façade.
		float u = (abs(n.x) > abs(n.z)) ? world_pos.z : world_pos.x;
		vec2 uv = vec2(u, -world_pos.y);
		col = texture(facade_tex, uv / facade_size_m).rgb;

		if (windows_enabled && world_pos.y > 0.4) {
			vec2 cell = vec2(mod(u, window_cell_m.x), mod(world_pos.y, window_cell_m.y));
			bool in_window = cell.x > window_rect_m.x && cell.x < window_rect_m.z
				&& cell.y > window_rect_m.y && cell.y < window_rect_m.w;
			if (in_window) {
				// Encadrement clair de 12 cm autour de la vitre sombre.
				bool in_frame = cell.x < window_rect_m.x + 0.12 || cell.x > window_rect_m.z - 0.12
					|| cell.y < window_rect_m.y + 0.12 || cell.y > window_rect_m.w - 0.12;
				col = in_frame ? col * 1.08 : window_color;
			}
		}
	}
	ALBEDO = col * tint.rgb;
	ROUGHNESS = 0.95;
	METALLIC = 0.0;
}
