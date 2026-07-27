// Route GTDZ : asphalte projeté en coordonnées monde XZ (déterministe, aucune
// dépendance aux normales/UV du mesh). Compatible gl_compatibility.
shader_type spatial;

uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float size_m = 7.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ALBEDO = texture(tex, world_pos.xz / size_m).rgb * tint.rgb;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
