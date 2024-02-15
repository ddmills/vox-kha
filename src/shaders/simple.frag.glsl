#version 450

in vec2 vertUV;

uniform sampler2D myTextureSampler;

out vec4 fragColor;

void main() {
    vec4 tex = texture(myTextureSampler, vertUV);
    fragColor = tex;
}
