shader_type canvas_item;
uniform sampler2D existing_screen_texture: hint_screen_texture;

void fragment(){
	vec4 color = texture(existing_screen_texture, UV);
	COLOR = vec4(1.0 - color.rgb, color.a);
}