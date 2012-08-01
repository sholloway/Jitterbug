attribute vec2 a_position; //input. The vertex's position. X,Y
attribute vec4 a_vertex_color;
uniform vec2 u_resolution; //Input. The resolution of the rendering area to project to. Width x Height

varying lowp vec4 v_color;

void main() {
   // convert the rectangle from pixels to 0.0 to 1.0
   vec2 zeroToOne = a_position / u_resolution;

   // convert from 0->1 to 0->2
   vec2 zeroToTwo = zeroToOne * 2.0;

   // convert from 0->2 to -1->+1 (clipspace)
   vec2 clipSpace = zeroToTwo - 1.0;

   gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
   v_color = a_vertex_color;
}