#version 150 core
precision mediump float;
uniform lowp vec4 v_color; // Input - Color RGBA (0-1)
out vec4 FragColor;

void main() {
   FragColor = v_color;
}