shader_type canvas_item;

uniform float saturation : hint_range(0.0, 2.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

    float gray = dot(color, vec3(0.299, 0.587, 0.114));

    color = mix(vec3(gray), color, saturation);

    COLOR = vec4(color, 1.0);
}