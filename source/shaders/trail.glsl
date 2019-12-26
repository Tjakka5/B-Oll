uniform float originX;
uniform float originY;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    float dist = distance(vec2(originX, originY), screen_coords);

    float alpha = 0.1f;
    if (mod(dist, 4.0f) > 2.0f) {
        alpha = 0.8f;
    }
    
    return vec4(dist / 150.0f, 0.0f, 1.0f, alpha);
}
