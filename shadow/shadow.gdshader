shader_type spatial;
render_mode blend_mul, cull_disabled, unshaded;

uniform vec3 shadow_colour:source_color = vec3(0.6, 0.7, 0.8);

uniform vec3 surface_normal;

uniform vec3 forward;

uniform float shadow_mult = 1.0;

uniform float pan_value = 0.0;

uniform float speed = 0.0;

uniform sampler2D noise_texture:repeat_enable;

void vertex() {
	vec3 sideways = cross(forward, vec3(0.0, 1.0, 0.0));
	vec3 rotated_vertex = forward * VERTEX.y + sideways * VERTEX.x;
	float slopex = rotated_vertex.x * surface_normal.x * 1.05;
	float slopez = rotated_vertex.z * surface_normal.z * 1.05;
	VERTEX = rotated_vertex - vec3(0.0, slopex + slopez, 0.0);
}


void fragment() {
	float noise_offset = texture(noise_texture, UV + vec2(0.0, -pan_value * 0.5 / 2.7)).r;
	vec2 uv = UV + vec2(0.0, noise_offset * 0.2 * clamp(speed * 0.02, 0.0, 1.0));
	float shadow_strength = (1.0 - pow(max(0.0, length(uv - vec2(0.5)) * 2.6), 5.2)) * shadow_mult;
	ALBEDO = mix(vec3(1.0), shadow_colour, shadow_strength);
}

