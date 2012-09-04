#version 150 core

precision mediump int;
precision highp float;

uniform vec4 Diffuse;
out vec4 FragColor;

void main()
{
	FragColor = Diffuse;
}
