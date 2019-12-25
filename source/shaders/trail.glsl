uniform vec2 player_coords;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    float dist = distance(player_coords, screen_coords);

    if (mod(dist, 6.0f) > 3.0f) {
        if (mod(dist, 6.0f) > 3.0f) {
            return vec4(1.0f, 0.0f, dist / 200.0f, 1.0f);
        }
    }
    
    return vec4(0.0f);
}