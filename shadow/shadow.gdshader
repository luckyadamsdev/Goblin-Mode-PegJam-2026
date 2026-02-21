shader_type spatial;
render_mode blend_mul, cull_disabled;

void fragment() {
	float shadow_strength = max(0.0, length(UV - vec2(0.5)) * 2.0 * 1.4);
	ALBEDO = vec3(shadow_strength);
}

