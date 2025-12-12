shader_type spatial;
render_mode unshaded;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	screen_color = vec3((screen_color.r + screen_color.g + screen_color.b) / 3.0);
	if (screen_color.r < 0.1) {
		ALBEDO = vec3(0);
	}
	else {
		ALBEDO = screen_color.rgb;
	}
}
