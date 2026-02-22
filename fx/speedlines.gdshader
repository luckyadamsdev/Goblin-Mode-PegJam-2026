shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;


uniform vec3 velocity = vec3(0.0, 0.0, 1.0);

uniform sampler2D noise_texture:repeat_enable;

void vertex() {
	float noise_offset = texture(noise_texture, UV + vec2(0.0, TIME * 1.5)).r;
	vec3 local_velocity = inverse(MODEL_NORMAL_MATRIX) * velocity;
	VERTEX -= velocity * noise_offset * COLOR.r * 0.1;
}

void fragment() {
	float noise_offset = texture(noise_texture, UV * vec2(1.0, 0.5) + vec2(0.0, TIME * 1.0)).r;
	ALPHA = noise_offset * (1.0 - abs(COLOR.r - 0.5) * 2.0) * 0.4;
}
