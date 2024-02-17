#version 450

uniform mat4 MVP;

in vec3 pos;

void main() {
    gl_Position = MVP * vec4(pos, 1.0);
}
