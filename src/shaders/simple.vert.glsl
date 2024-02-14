#version 450

uniform mat4 MVP;

in vec3 pos;
in vec3 col;
in vec2 uv;

out vec3 vertColor;
out vec2 vertUV;

void main() {
    gl_Position = MVP * vec4(pos, 2.0);
    vertColor = col;
    vertUV = uv;
}
