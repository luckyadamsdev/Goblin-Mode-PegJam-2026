shader_type spatial;
render_mode blend_add, unshaded, cull_disabled;

uniform float sparkle_size = 0.5;

uniform vec3 sparkle_colour:source_color = vec3(0.6, 0.7, 0.8);

uniform sampler2D sparkle_animation:filter_nearest, repeat_enable;

uniform float sparkle_speed = 2.0;

void vertex() {
	float animation_scale = 1.0;// texture(sparkle_animation, vec2(TIME * sparkle_speed + COLOR.r, 0.5)).r;
	float move_offset = 0.0;//mod(TIME * 1.0 + COLOR.r, 1.0);
	//animation_scale *= 1.0 - abs(move_offset - 0.5) * 2.0;
	vec4 world_pos = VIEW_MATRIX * (MODEL_MATRIX * vec4(VERTEX, 1.0));// + vec4(0.0, 0.0, 3.0, 0.0) * move_offset);
	world_pos.xy += vec2(UV.x, UV.y * -1.0) * sparkle_size;// * animation_scale;
	POSITION = PROJECTION_MATRIX * world_pos;
	//COLOR = CUSTOM0;
}

void fragment() {
	ALBEDO = sparkle_colour;
}
