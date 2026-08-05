shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    COLOR = vec4(vec3(1.0) - color.rgb, color.a);
}