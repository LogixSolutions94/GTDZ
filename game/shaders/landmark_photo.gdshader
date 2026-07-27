// Monument GTDZ : photo réelle enroulée en projection cylindrique autour du
// bâtiment (adapté aux façades courbes type Grande Poste). Compatible gl_compatibility.
shader_type spatial;

uniform sampler2D photo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D roof_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec2 center_xz = vec2(0.0, 0.0);   // centre du bâtiment (coords monde XZ)
uniform float radius_m = 26.0;             // rayon moyen de la façade
uniform float angle_offset = 0.0;          // calage horizontal (radians)
uniform vec2 photo_size_m = vec2(46.0, 23.7);
uniform float roof_size_m = 8.0;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 n = normalize(cross(dFdx(world_pos), dFdy(world_pos)));
	vec3 col;
	if (abs(n.y) > 0.6) {
		col = texture(roof_tex, world_pos.xz / roof_size_m).rgb;
	} else {
		float ang = atan(world_pos.x - center_xz.x, world_pos.z - center_xz.y) + angle_offset;
		vec2 uv = vec2(ang * radius_m / photo_size_m.x, -world_pos.y / photo_size_m.y);
		col = texture(photo, uv).rgb;
	}
	ALBEDO = col;
	ROUGHNESS = 0.95;
	METALLIC = 0.0;
}
