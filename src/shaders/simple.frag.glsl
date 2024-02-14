#version 450

in vec3 vertColor;
in vec2 vertUV;

uniform sampler2D myTextureSampler;

out vec4 fragColor;

void main() {
    vec4 tex = texture(myTextureSampler, vertUV);
    fragColor = vec4(mix(vertColor, tex.rgb, 0.5), tex.a);
}
