#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uIntensity;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    vec4 color = texture(uTexture, uv);
    
    // Simple glow: Check brightness and bleed it
    float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec4 glow = vec4(0.0);
    
    if(brightness > 0.6) {
        glow = color * uIntensity;
    }
    
    fragColor = color + glow;
}
