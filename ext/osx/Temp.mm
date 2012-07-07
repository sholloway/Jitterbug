/*
////////////////////////////////////////////////////
// Build all of our and setup initial state here  //
// Don't wait until our real time run loop begins //
////////////////////////////////////////////////////

_defaultFBOName = defaultFBOName;
characterAngle = 0;

//////////////////////////////
// Load our character model //
//////////////////////////////
model = [[JBTetrahydron alloc] init];	

glGenVertexArrays(1, &vaoName);GetGLError(); 
glBindVertexArray(vaoName);GetGLError(); 	
glGenBuffers(3, vboId);GetGLError(); 	 	
glBindBuffer(GL_ARRAY_BUFFER, vboId[0]);GetGLError();  	

//handle the vertices vbo
glBufferData(GL_ARRAY_BUFFER, [model vertsSize] * sizeof(GLfloat), [model vertices], GL_STATIC_DRAW);GetGLError();		
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);GetGLError(); 
glEnableVertexAttribArray(0);GetGLError(); 

//Now handle the colors vbo.
glBindBuffer(GL_ARRAY_BUFFER, vboId[1]);GetGLError();
glBufferData(GL_ARRAY_BUFFER, [model colorsSize] * sizeof(GLfloat), [model colors], GL_STATIC_DRAW);GetGLError();
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);GetGLError();		
glEnableVertexAttribArray(1);GetGLError();

//now handle the indicies		
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboId[2]);GetGLError();	    
glBufferData(GL_ELEMENT_ARRAY_BUFFER, [model indiciesSize] * sizeof(GLubyte), [model indicies], GL_STATIC_DRAW);GetGLError();


////////////////////////////////////
// Load texture for our character //
////////////////////////////////////


////////////////////////////////////////////////////
// Load and Setup shaders for character rendering //
////////////////////////////////////////////////////
GLchar *vertShader = "#version 150 \n"						
"in  vec3 in_Position;\n"
"in  vec3 in_Color;\n"
"out vec3 ex_Color;\n"
"uniform mat4 mvpmatrix;\n"
"void main(void) {\n"
"    // Since we are using flat lines, our input only had two points: x and y.\n"		
"    gl_Position = mvpmatrix*vec4(in_Position, 1.0);\n"		
"    ex_Color = in_Color;\n"
"}\n";


GLchar *fragShaderStr = "#version 150 \n"					
"// It was expressed that some drivers required this next line to function properly\n"
"precision highp float;\n"
"in  vec3 ex_Color;\n"
"out vec4 fragColor;\n"
"void main(void) {\n"
"    // Pass through our original color with full opacity.\n"
"    fragColor = vec4(ex_Color,1.0);\n"
"}\n";


//////////////////////////////////////
// Specify and compile VertexShader //
//////////////////////////////////////	
shaderProgram = glCreateProgram();		

GLint logLength, status;
GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);	
glShaderSource(vertexShader, 1, (const GLchar **)&(vertShader), NULL);
glCompileShader(vertexShader);
glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &logLength);

if (logLength > 0) 
{
	GLchar *log = (GLchar*) malloc(logLength);
	glGetShaderInfoLog(vertexShader, logLength, &logLength, log);
	NSLog(@"Vertex Shader compile log:%s\n", log);
	free(log);
}

glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);
if (status == 0)
{
	NSLog(@"Failed to compile vertex shader:\n%s\n", vertShader);
	exit(-1);
}

glAttachShader(shaderProgram, vertexShader);
//Bind attribute index 0 (coordinates) to in_Position and attribute index 1 (color) to in_Color 
//Attribute locations must be setup before calling glLinkProgram. 
glBindAttribLocation(shaderProgram, 0, "in_Position");
glBindAttribLocation(shaderProgram, 1, "in_Color");

/////////////////////////////////////////
// Specify and compile Fragment Shader //
/////////////////////////////////////////	
GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);	
glShaderSource(fragShader, 1, (const GLchar **)&(fragShaderStr), NULL);
glCompileShader(fragShader);
glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, &logLength);
if (logLength > 0) 
{
	GLchar *log = (GLchar*)malloc(logLength);
	glGetShaderInfoLog(fragShader, logLength, &logLength, log);
	NSLog(@"Frag Shader compile log:\n%s\n", log);
	free(log);
}

glGetShaderiv(fragShader, GL_COMPILE_STATUS, &status);
if (status == 0)
{
	NSLog(@"Failed to compile frag shader:\n%s\n", fragShaderStr);
	exit(-1);
}		

// Attach the fragment shader to our program
glAttachShader(shaderProgram, fragShader);


//////////////////////
// Link the program //
//////////////////////

glLinkProgram(shaderProgram);GetGLError();
glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logLength);GetGLError();
if (logLength > 0)
{
	GLchar *log = (GLchar*)malloc(logLength);
	glGetProgramInfoLog(shaderProgram, logLength, &logLength, log);GetGLError();
	NSLog(@"Program link log:\n%s\n", log);
	free(log);
}

glGetProgramiv(shaderProgram, GL_LINK_STATUS, &status);GetGLError();
if (status == 0)
{
	NSLog(@"Failed to link program");
	exit(-1);
}

glValidateProgram(shaderProgram);GetGLError();
glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logLength);GetGLError();
if (logLength > 0)
{
	GLchar *log = (GLchar*)malloc(logLength);
	glGetProgramInfoLog(shaderProgram, logLength, &logLength, log);GetGLError();
	NSLog(@"Program validate log:\n%s\n", log);
	free(log);
}

glGetProgramiv(shaderProgram, GL_VALIDATE_STATUS, &status);GetGLError();
if (status == 0)
{
	NSLog(@"Failed to validate program");
	return 0;
}

glUseProgram(shaderProgram);GetGLError(); //Load the shader into the rendering pipeline		

/////////////////////////////////////////////////////////////////////////////////////
		
//do I actually need this?
// glPixelStorei(GL_UNPACK_ALIGNMENT, 4);GetGLError();      // 4-byte pixel alignment

// enable /disable features
//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);GetGLError();
//glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
//glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
glEnable(GL_DEPTH_TEST);GetGLError(); //enable zbufffer ordering
//glEnable(GL_LIGHTING);GetGLError();
//glEnable(GL_TEXTURE_2D);GetGLError();
//glEnable(GL_CULL_FACE);GetGLError(); 		//I turned this off because I don't have any normals specified...

glClearStencil(0);GetGLError();                          // clear stencil buffer
glClearDepth(1.0f);GetGLError();                         // 0 is near, 1 is far
glDepthFunc(GL_LEQUAL);GetGLError(); //look this up	
	
////////////////////////////////////////////////
// Set up OpenGL state that will never change //
////////////////////////////////////////////////		
	
// Always use this clear color
glClearColor(1.0f, 1.0f, 1.0f, 1.0f);

// Draw our scene once without presenting the rendered image.
// This is done in order to pre-warm OpenGL
// We don't need to present the buffer since we don't actually want the 
// user to see this, we're only drawing as a pre-warm stage
[self render];	

// Check for errors to make sure all of our setup went ok
GetGLError();
*/