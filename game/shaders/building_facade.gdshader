// Shader de façades GTDZ : projette une texture de façade sur les murs et une
// texture de toit sur les surfaces horizontales, en coordonnées monde (pas
// besoin d'UV sur les meshes extrudés depuis OSM). Compatible gl_compatibility.
shader_type spatial;

uniform sampler2D facade_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D roof_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D facade_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D roof_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float normal_strength = 0.0; // 0 = pas de normal map fournie
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Taille en mètres couverte par une répétition de la texture (x = largeur, y = hauteur).
uniform vec2 facade_size_m = vec2(9.0, 9.0);
uniform float roof_size_m = 8.0;
// Fenêtres procédurales (les banques CC0 n'ont pas de façades avec fenêtres :
// on les dessine par-dessus l'enduit). Grille : un étage = 3 m.
uniform bool windows_enabled = true;
uniform vec2 window_cell_m = vec2(3.4, 3.0);
uniform vec4 window_rect_m = vec4(1.1, 1.0, 2.2, 2.4); // x_min, y_min, x_max, y_max dans la cellule
uniform vec3 window_color : source_color = vec3(0.24, 0.28, 0.34);

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// Normale géométrique exacte par dérivées écran : insensible aux normales
	// lissées/fusionnées du mesh (source de cisaillement sur les façades).
	vec3 n = normalize(cross(dFdx(world_pos), dFdy(world_pos)));
	vec3 col;
	vec3 tangent_ws;
	vec3 bitangent_ws;
	vec2 nm_uv;
	bool is_roof = abs(n.y) > 0.6;
	if (is_roof) {
		col = texture(roof_tex, world_pos.xz / roof_size_m).rgb;
		tangent_ws = vec3(1.0, 0.0, 0.0);
		bitangent_ws = vec3(0.0, 0.0, 1.0);
		nm_uv = world_pos.xz / roof_size_m;
	} else {
		// Coordonnée horizontale alignée sur la tangente du mur : aucune
		// déformation même sur les façades obliques ou courbes.
		vec2 nh = normalize(n.xz);
		float u = dot(world_pos.xz, vec2(nh.y, -nh.x));
		vec2 uv = vec2(u, -world_pos.y);
		col = texture(facade_tex, uv / facade_size_m).rgb;
		tangent_ws = vec3(nh.y, 0.0, -nh.x);
		bitangent_ws = vec3(0.0, -1.0, 0.0);
		nm_uv = uv / facade_size_m;

		// Rez-de-chaussée commerçant : plus sombre et légèrement chaud (0-3.2 m).
		if (world_pos.y < 3.2) {
			col *= vec3(0.82, 0.79, 0.75);
		} else if (windows_enabled) {
			vec2 cell = vec2(mod(u, window_cell_m.x), mod(world_pos.y, window_cell_m.y));
			bool in_window = cell.x > window_rect_m.x && cell.x < window_rect_m.z
				&& cell.y > window_rect_m.y && cell.y < window_rect_m.w;
			if (in_window) {
				// Encadrement clair de 12 cm autour de la vitre sombre.
				bool in_frame = cell.x < window_rect_m.x + 0.12 || cell.x > window_rect_m.z - 0.12
					|| cell.y < window_rect_m.y + 0.12 || cell.y > window_rect_m.w - 0.12;
				col = in_frame ? col * 1.08 : window_color;
			} else if (cell.y < window_rect_m.y && cell.y > window_rect_m.y - 0.1) {
				// Fine ombre d'appui sous la fenêtre.
				col *= 0.86;
			}
			// Bandeau de corniche à chaque étage (bande claire de 18 cm).
			float floor_pos = mod(world_pos.y, window_cell_m.y);
			if (floor_pos < 0.18) {
				col = mix(col, col * 1.14 + vec3(0.04), 0.8);
			}
		}
		// Salissure légère en pied de mur (remontées d'humidité, très Alger).
		if (world_pos.y < 0.5) {
			col *= mix(0.78, 1.0, world_pos.y * 2.0);
		}
	}
	ALBEDO = col * tint.rgb;
	if (normal_strength > 0.01) {
		vec3 nm_rgb;
		if (is_roof) {
			nm_rgb = texture(roof_normal, nm_uv).rgb;
		} else {
			nm_rgb = texture(facade_normal, nm_uv).rgb;
		}
		vec3 nm = nm_rgb * 2.0 - 1.0;
		nm.xy *= normal_strength;
		vec3 perturbed = normalize(tangent_ws * nm.x + bitangent_ws * nm.y + n * nm.z);
		NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
	}
	ROUGHNESS = 0.95;
	METALLIC = 0.0;
}
