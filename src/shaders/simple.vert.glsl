#version 450

uniform mat4 MVP;

in vec3 pos;
in vec2 uv;

out vec2 vertUV;

void main() {
    gl_Position = MVP * vec4(pos, 2.0);
    vertUV = uv;
}
