//!PARAM angle
//!TYPE float
//!MINIMUM 0.0
//!MAXIMUM 6.283185307
0.0

//!HOOK OUTPUT
//!BIND HOOKED
//!DESC Vinyl circle crop + rotation

vec4 hook() {
    vec2  uv  = HOOKED_pos;
    float asp = HOOKED_size.x / HOOKED_size.y;
    float rad = 0.5 / max(1.0, asp);
    vec2  c   = uv - vec2(0.5);
    float r   = length(c);

    // Everything outside the disc → black
    if (r > rad) return vec4(0.0, 0.0, 0.0, 1.0);

    float t = r / rad;  // 0 = centre, 1 = rim
    float a = atan(c.y, c.x);

    // Vinyl groove ring – pure dark, returns immediately so the image
    // scaling below never affects it.
    if (t > 0.72) {
        float gr   = 0.5 + 0.5 * sin(t * 300.0);
        float sh   = 0.5 + 0.5 * sin(a * 2.0 + t * 10.0 + angle);
        float base = mix(0.10, 0.02, smoothstep(0.72, 1.0, t));
        return vec4(vec3(base + gr * sh * 0.05), 1.0);
    }

    // Centre spindle hole
    if (t < 0.036) return vec4(0.08, 0.08, 0.08, 1.0);

    // Rotate sampling UV by Lua-driven angle
    float cosA = cos(angle);
    float sinA = sin(angle);
    vec2  rot  = vec2(c.x * cosA - c.y * sinA,
                      c.x * sinA + c.y * cosA);

    // 1.5× zoom: dividing by 1.5 pulls sample points toward the image centre,
    // ensuring the cover art fills the label without sampling into black bars.
    vec4  col  = HOOKED_tex(rot / 1.2 + vec2(0.5));

    // Gentle fade towards the groove ring
    col.rgb *= mix(0.80, 1.0, smoothstep(0.72, 0.52, t));

    return col;
}
