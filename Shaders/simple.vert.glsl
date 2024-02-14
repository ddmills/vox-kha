#version 450

uniform mat4 MVP;

in vec3 pos;
in vec3 col;

out vec3 vertColor;


void main() {
    gl_Position = MVP * vec4(pos, 2.0);
    vertColor = col;
}
