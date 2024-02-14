#version 450

in vec3 pos;

uniform mat4 MVP;

void main() {
    gl_Position = MVP * vec4(pos, 2.0);
}
