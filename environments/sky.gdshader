shader_type sky;

uniform vec3 horizonColor: source_color;
uniform vec3 skyColor: source_color;
uniform sampler2D skyTexture: source_color, filter_nearest;

void sky() {
	float col = clamp(EYEDIR.y / 0.05, 0.0, 1.0);
	vec3 finalColor = mix(horizonColor, skyColor, vec3(col));
	//COLOR = finalColor;
	//COLOR = texture(skyTexture, SKY_COORDS).rgb;
	COLOR = mix(horizonColor, skyColor, texture(skyTexture, SKY_COORDS).rgb);
}
