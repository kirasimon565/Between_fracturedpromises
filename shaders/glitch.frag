#version 460 core
#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

float random(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Create horizontal strips for the glitch
    float glitch = step(0.9, random(vec2(floor(uv.y * 20.0), uTime)));
    
    // Offset the red and blue channels
    float offset = 0.02 * glitch * sin(uTime * 10.0);
    
    float r = texture(uTexture, uv + vec2(offset, 0.0)).r;
    float g = texture(uTexture, uv).g;
    float b = texture(uTexture, uv - vec2(offset, 0.0)).b;
    
    fragColor = vec4(r, g, b, 1.0);
}
