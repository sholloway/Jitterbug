#include <OpenGL/gl3.h>
#include <glm/glm.hpp>
//#include <glm/gtc/matrix_projection.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#import "GLSLNodeRenderer.h"

#define getGLError()									\
{														\
	GLenum err = glGetError();							\
	while (err != GL_NO_ERROR) {						\
		NSLog(@"GLError %u set in File:%s Line:%d\n",	\
				err,					\
				__FILE__,								\
				__LINE__);								\
		err = glGetError();								\
	}													\
}

@implementation GLSLNodeRenderer
- (id) init
{
	self = [super init];
			
	NSLog(@"About to create vectors");
	rotationCurrent = glm::vec2(0.f);
	rotationOrigin = glm::vec2(0.f);
	tranlationOrigin = glm::vec2(0.f, 4.f);
	tranlationCurrent = glm::vec2(0.f, 4.f);
	NSLog(@"Done initializing GLSLNodeRenderer");
	return self;
}

- (void) dealloc
{
	//put my stuff here
	[super dealloc];
}

- (void)setVertexShader:(NSString *)str
{	
	NSLog(@"About to set Vertex Shader");
	self->vertexShader = str;
}

- (void)setFragmentShader:(NSString *)str
{
	NSLog(@"About to set Fragment Shader");
	self->fragmentShader = str;
}

- (void)setGeometryNode:(id<NSObject>)gnode
{
	self->geometryNode = gnode;
}

- (void) register:(id)ruby_renderer
{
	NSLog(@"About to register the OpenGL components");
	//Create the mesh
	
	vertexCount = 4;	
	//id verticies = [self->geometryNode vertices];
	//vertexCount = [(NSNumber *)[verticies length] integerValue];
	
	NSLog(@"About to create position array");
	positionSize = vertexCount * sizeof(glm::vec2);
	positionData = (glm::vec2 *)malloc(positionSize);
	positionData[0] = glm::vec2(-1.0f,-1.0f);
	positionData[1] = glm::vec2( 1.0f,-1.0f);
	positionData[2] = glm::vec2( 1.0f, 1.0f);
	positionData[3] = glm::vec2(-1.0f, 1.0f);
	
	NSLog(@"About to create element array");
	elementCount = 6;
	elementSize = elementCount * sizeof(GLushort);
	elementData = (GLushort *)malloc(elementSize);
	elementData[0] = 0;
	elementData[1] = 1;
	elementData[2] = 2;
	elementData[3] = 2;
	elementData[4] = 3;
	elementData[5] = 0;
	
	//load the shaders
	GLint vertShader = glCreateShader(GL_VERTEX_SHADER);getGLError();	
//GLAPI void APIENTRY glShaderSource (GLuint shader, GLsizei count, const GLchar* *string, const GLint *length);
//glShaderSource(shader, 1, &source, NULL);
	const GLchar *vsource = (GLchar *)[self->vertexShader cStringUsingEncoding:NSASCIIStringEncoding];
	glShaderSource(vertShader,1, &vsource, NULL);getGLError();
	glCompileShader(vertShader);getGLError();         
	[self checkShaderCompileStatus:vertShader shaderName:@"Vertext Shader"];
	
	GLint fragShader = glCreateShader(GL_FRAGMENT_SHADER);getGLError();
	const GLchar *fsource = (GLchar *)[self->fragmentShader cStringUsingEncoding:NSASCIIStringEncoding];
	glShaderSource(fragShader,1, &fsource, NULL);getGLError();
	glCompileShader(fragShader);getGLError();
	[self checkShaderCompileStatus:fragShader shaderName:@"Fragment Shader"];
	
	//create the program
 	program = glCreateProgram();getGLError();
	glAttachShader(self->program,vertShader);getGLError();
	glAttachShader(self->program,fragShader);getGLError();
	glBindFragDataLocation(self->program, 0, "FragColor");getGLError();
	glLinkProgram(self->program);getGLError();
	[self validateProgram:self->program];

	self->uniformMVP = glGetUniformLocation(self->program, "MVP");getGLError();
	self->uniformDiffuse = glGetUniformLocation(self->program, "Diffuse");getGLError();
	self->attribPosition = glGetAttribLocation(self->program, "Position");getGLError();
	
	glUseProgram(self->program);
		//set the color from the current fill color
		id<NSObject> renderState = [self->geometryNode render_state];
		id<NSObject> fillColor = [renderState current_fill_color];
		float red = [[fillColor red] floatValue];
		float green = [[fillColor green] floatValue];
		float blue = [[fillColor blue] floatValue];
		float alpha = [[fillColor alpha] floatValue];
		glUniform4fv(uniformDiffuse, 1, &glm::vec4(red, 
			green, 
			blue, 
			alpha)[0]);
	glUseProgram(0);
	
	//set up VBO's and VAO
	glGenBuffers(1, &elementBufferName);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBufferName);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, elementSize, elementData, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	glGenBuffers(1, &arrayBufferName);
    glBindBuffer(GL_ARRAY_BUFFER, arrayBufferName);
    glBufferData(GL_ARRAY_BUFFER, positionSize, positionData, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	getGLError();
	
	// Build a vertex array object	
	glGenVertexArrays(1, &vertexArrayName);
    glBindVertexArray(vertexArrayName);
		glBindBuffer(GL_ARRAY_BUFFER, arrayBufferName);
		glVertexAttribPointer(attribPosition, 2, GL_FLOAT, GL_FALSE, 0, 0);
		glEnableVertexAttribArray(attribPosition);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBufferName);
	glBindVertexArray(0);

	getGLError();
}

- (bool) validateProgram:(GLint) prog
{
	if(!prog)
		return false;

	glValidateProgram(prog);
	GLint result = GL_FALSE;
	glGetProgramiv(prog, GL_VALIDATE_STATUS, &result);

	if(result == GL_FALSE)
	{
		NSLog(@"Validate program");
		int infoLogLength;
		glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &infoLogLength);
		char logBuffer[infoLogLength];
		glGetProgramInfoLog(prog, infoLogLength, NULL, &logBuffer[0]);
		NSLog(@"%@", [NSString stringWithUTF8String:logBuffer]);
	}

	return result == GL_TRUE;
}

-(void) checkShaderCompileStatus:(GLint)shader shaderName:(NSString *)shaderName
{
	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);getGLError();
	if (status == GL_FALSE)
	{		
		GLint logLineCount;
		GLchar *error;
		
		glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &logLineCount );
		if (logLineCount > 0)
		{
			glGetShaderInfoLog(shader, logLineCount, NULL, (error = (char *)calloc( 1, logLineCount)));
			NSLog(@"The shader %@ error log is:",shaderName);
			NSLog(@"%@",[NSString stringWithCString:error encoding:NSASCIIStringEncoding]);
			free(error);
		}
	}	
}

- (void) draw:(id)ruby_renderer
{
	NSLog(@"About to render the scene");
	// Compute the MVP (Model View Projection matrix)
	glm::mat4 projection = glm::perspective(45.0f, 4.0f / 3.0f, 0.1f, 100.0f);
	glm::mat4 viewTranslate = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f, -self->tranlationCurrent.y));
	glm::mat4 viewRotateX = glm::rotate(viewTranslate, self->rotationCurrent.y, glm::vec3(-1.f, 0.f, 0.f));
	glm::mat4 view = glm::rotate(viewRotateX, self->rotationCurrent.x, glm::vec3(0.f, 1.f, 0.f));
	glm::mat4 model = glm::mat4(1.0f);
	glm::mat4 mvp = projection * view * model;

	// Set the display viewport
	glViewport(0, 0, 640, 480);

	// Clear color buffer with black
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	// Bind program
	glUseProgram(self->program);

	// Set the value of MVP uniform.
	glUniformMatrix4fv(uniformMVP, 1, GL_FALSE, &mvp[0][0]);

	// Bind vertex array & draw 
	glBindVertexArray(vertexArrayName);
		glDrawElements(GL_TRIANGLES, elementCount, GL_UNSIGNED_SHORT, 0);
	glBindVertexArray(0);

	// Unbind program
	glUseProgram(0);

	getGLError();
}

- (void) checkout:(id)ruby_renderer
{
	glDeleteVertexArrays(1, &self->vertexArrayName);
	glDeleteBuffers(1, &self->arrayBufferName);
	glDeleteBuffers(1, &self->elementBufferName);
	glDeleteProgram(self->program);
	getGLError();
}
@end