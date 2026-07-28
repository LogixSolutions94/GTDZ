// Route GTDZ : asphalte projeté en coordonnées monde XZ (déterministe, aucune
// dépendance aux normales/UV du mesh). Compatible gl_compatibility.
shader_type spatial;

uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float normal_strength = 0.0; // 0 = pas de normal map fournie
uniform float size_m = 7.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = world_pos.xz / size_m;
	ALBEDO = texture(tex, uv).rgb * tint.rgb;
	if (normal_strength > 0.01) {
		vec3 nm = texture(normal_tex, uv).rgb * 2.0 - 1.0;
		nm.xy *= normal_strength;
		vec3 n = normalize(cross(dFdx(world_pos), dFdy(world_pos)));
		vec3 perturbed = normalize(vec3(1.0, 0.0, 0.0) * nm.x + vec3(0.0, 0.0, 1.0) * nm.y + n * nm.z);
		NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
	}
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
