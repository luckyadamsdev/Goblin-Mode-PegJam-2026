shader_type spatial;
render_mode blend_mul, cull_disabled;

uniform vec3 surface_normal;

uniform vec3 forward;

void vertex() {
	vec3 sideways = cross(forward, vec3(0.0, 1.0, 0.0));
	vec3 rotated_vertex = forward * VERTEX.y + sideways * VERTEX.x;
	float slopex = rotated_vertex.x * surface_normal.x;
	float slopez = rotated_vertex.z * surface_normal.z;
	VERTEX = rotated_vertex - vec3(0.0, slopex + slopez, 0.0);
}


void fragment() {
	float shadow_strength = max(0.0, length(UV - vec2(0.5)) * 2.0 * 1.4);
	ALBEDO = vec3(shadow_strength);
}

