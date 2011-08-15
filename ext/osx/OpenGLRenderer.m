#import "GLView.h"
#import "OpenGLRenderer.h"

#import "matrixUtil.h"
#import "vectorUtil.h"
//#import <glm/glm.hpp>

#define GetGLError()									\
{														\
	GLenum err = glGetError();							\
	while (err != GL_NO_ERROR) {						\
		NSLog(@"GLError %s set in File:%s Line:%d\n",	\
				GetGLErrorString(err),					\
				__FILE__,								\
				__LINE__);								\
		err = glGetError();								\
	}													\
}

#define ASPECT_RATIO 16.0/9.0

// Indicies to which we will set vertex array attibutes
// See buildVAO and buildProgram
enum {
	POS_ATTRIB_IDX,
	NORMAL_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX
};

@implementation OpenGLRenderer
GLuint viewWidth;
GLuint viewHeight;

GLuint _defaultFBOName;

GLuint vboId[3];  // ID of VBO for vertex arrays
GLuint vaoName;
GLuint shaderProgram;
GLfloat characterAngle;
GLint objectMvpUniformIdx;

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
	glViewport(0, 0, width, height);
	
	viewWidth = width;
	viewHeight = height;	
}

/*
Things to consider:
vboId is our VBO.
shaderProgram is our shader
*/
- (void) render
{	
	// Set up the modelview and projection matricies
	// The model matrix is used to describe where an object exists in the world. 
	// The view matrix is used to describe the vantage point of our view. 
	// The view matrix can be thought of as the position and angle of a camera used to take a picture. 
	// The projection matrix is used to give our view perspective such as making close objects appear larger than distant objects. 
	// The projection matrix also provides a field of view which can be thought of as a camera lens; you can decide to use a 
	// wide-angle lens or a telephoto lens. Multiplying these three matrices together and then with a object's 
	// vertex positions will provide us with a three dimensional view of the object.
	GLfloat modelView[16];
	GLfloat projection[16];
	GLfloat mvp[16];
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);GetGLError();

	// Use the program for rendering our character
	glUseProgram(shaderProgram);GetGLError();

	// Calculate the projection matrix
	mtxLoadPerspective(projection, 
		90, 									//fovY
		(float)viewWidth / (float)viewHeight, 	//aspect ratio
		0.1,									//near clipping plane
		100);									//far clipping plane

	// Calculate the modelview matrix to render our character 
	//  at the proper position and rotation
	mtxLoadTranslate(modelView, 
		0, 							//x translation
		0, 							//y translation
		-5);						//z translation

	mtxRotateYApply(modelView,characterAngle);
	// mtxRotateApply(modelView, 
	// 		characterAngle, 
	// 		0, 
	// 		0, 
	// 		1);
	
	// Multiply the modelview and projection matrix and set it in the shader
	mtxMultiply(mvp,	//ouput  
		projection, 
		modelView);
		
	// NSString *logMsg = [NSString stringWithFormat: @"%f",mvp[0]];
	// NSLog(logMsg);

	// Have our shader use the modelview projection matrix 
	// that we calculated above
	glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "mvpmatrix"), 1, GL_FALSE, mvp);GetGLError();
			
	// Cull back faces now that we no longer render 	
	glCullFace(GL_BACK);GetGLError();

	//draw the vbo to screen
	//glDrawElements(GL_TRIANGLE_STRIP, 6, GL_UNSIGNED_BYTE, 0); //draw with a strip
	glDrawElements(GL_TRIANGLES, [model indiciesSize], GL_UNSIGNED_BYTE, 0);//GL_TRIANGLES
	
	// glPointSize(5);
	// glDrawElements(GL_POINTS, 4, GL_UNSIGNED_BYTE, 0);
	
	//glFlush(); //test if I need this...
	//NSLog(@"Got here");
	characterAngle++;
	
	//exit(0); //just do it once for now...
}

- (id) initWithDefaultFBO: (GLuint) defaultFBOName
{
	if((self = [super init]))
	{
		NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
		
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
		/* Bind attribute index 0 (coordinates) to in_Position and attribute index 1 (color) to in_Color */
		/* Attribute locations must be setup before calling glLinkProgram. */
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
	    //glEnable(GL_CULL_FACE);GetGLError(); 		//I turned off because I don't have any normals specified...
	    
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
	}
	
	return self;
}

- (void) destroyProgram:(GLuint) prgName
{		
	if(0 == prgName)
	{
		return;
	}
	
	GLsizei shaderNum;
	GLsizei shaderCount;
	
	// Get the number of attached shaders
	glGetProgramiv(prgName, GL_ATTACHED_SHADERS, &shaderCount);
	
	GLuint* shaders = (GLuint*)malloc(shaderCount * sizeof(GLuint));
	
	// Get the names of the shaders attached to the program
	glGetAttachedShaders(prgName,
						 shaderCount,
						 &shaderCount,
						 shaders);
	
	// Delete the shaders attached to the program
	for(shaderNum = 0; shaderNum < shaderCount; shaderNum++)
	{
		glDeleteShader(shaders[shaderNum]);
	}
	
	free(shaders);
	
	// Delete the program
	glDeleteProgram(prgName);
	glUseProgram(0);
}

-(void)destroyVAO:(GLuint) vaoName
{
	GLuint index;
	GLuint bufName;
	
	// Bind the VAO so we can get data from it
	glBindVertexArray(vaoName);
	
	// For every possible attribute set in the VAO
	for(index = 0; index < 16; index++)
	{
		// Get the VBO set for that attibute
		glGetVertexAttribiv(index , GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, (GLint*)&bufName);
		
		// If there was a VBO set...
		if(bufName)
		{
			//...delete the VBO
			glDeleteBuffers(1, &bufName);
		}
	}
	
	// Get any element array VBO set in the VAO
	glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, (GLint*)&bufName);
	
	// If there was a element array VBO set in the VAO
	if(bufName)
	{
		//...delete the VBO
		glDeleteBuffers(1, &bufName);
	}
	
	// Finally, delete the VAO
	glDeleteVertexArrays(1, &vaoName);
	
	GetGLError();
}

- (void) dealloc
{	
	//glDeleteBuffers(1, &vboId);
	//need to clean up the shaders and buffers..
	[self destroyProgram:shaderProgram];
	[self destroyVAO:vaoName];
	[model release];
	[super dealloc];	//call last
}

@end