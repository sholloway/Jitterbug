precision mediump float;
varying lowp vec4 v_color; // Input - Color RGBA (0-1)

void main() {
   gl_FragColor = v_color;
}