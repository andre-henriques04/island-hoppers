shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int outline_width = 5;
uniform float alpha_threshold = 0.01;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    float outline = 0.0;

    // Sample in a circular pattern.
    for (int x = -outline_width; x <= outline_width; x++) {
        for (int y = -outline_width; y <= outline_width; y++) {

            // Ignore samples outside the circular radius.
            if (float(x * x + y * y) > float(outline_width * outline_width)) {
                continue;
            }

            vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE;

            float sample_alpha = texture(TEXTURE, UV + offset).a;

            outline = max(outline, sample_alpha);
        }
    }

    // Only draw outside the original texture.
    if (color.a <= alpha_threshold && outline > alpha_threshold) {
        COLOR = outline_color;
    } else {
        COLOR = color;
    }
}