shader_type spatial;
render_mode unshaded;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable;
uniform int minPixelDistance = 2;
uniform int maxPixelDistance = 10;
uniform float minFactor: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float maxFactor: hint_range(0.0, 1.0, 0.1) = 1.0;


void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float lerp(float a, float b, float factor) {
	return a * (1.0 - factor) + b * factor;
}

void fragment() {
	float aberrationFactor = abs(SCREEN_UV.r * 2.0 - 1.0) * abs(SCREEN_UV.g * 2.0 - 1.0);
	float pixelDistance = lerp(float(minPixelDistance), float(maxPixelDistance), aberrationFactor);
	float blendFactor = lerp(minFactor, maxFactor, aberrationFactor);

	float PIXEL_WIDTH = 1.0 / VIEWPORT_SIZE.x;
	float r = texture(SCREEN_TEXTURE, SCREEN_UV - vec2(PIXEL_WIDTH * float(pixelDistance), 0)).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(PIXEL_WIDTH * float(pixelDistance), 0)).g;

	vec3 screenColor = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	ALBEDO = vec3(screenColor.r * (1.0 - blendFactor) + r * blendFactor, screenColor.g * (1.0 - blendFactor) + g * blendFactor, screenColor.b);
}
