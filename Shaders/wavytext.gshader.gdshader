shader_type canvas_item;

uniform float height = 0.01;
uniform float frequency = 15.0;
uniform float speed = 2.0;

void fragment() {
    float wave = sin(UV.x * frequency + TIME * speed) * height;
    vec2 new_uv = UV + vec2(0.0, wave);
    
    COLOR = texture(TEXTURE, new_uv) * COLOR;
}
