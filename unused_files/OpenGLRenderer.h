#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import "primatives.h"

//this is shit... How am I handling this in the FBOSpike?
static inline const char * GetGLErrorString(GLenum error)
{
	const char *str;
	switch( error )
	{
		case GL_NO_ERROR:
			str = "GL_NO_ERROR";
			break;
		case GL_INVALID_ENUM:
			str = "GL_INVALID_ENUM";
			break;
		case GL_INVALID_VALUE:
			str = "GL_INVALID_VALUE";
			break;
		case GL_INVALID_OPERATION:
			str = "GL_INVALID_OPERATION";
			break;		

		case GL_OUT_OF_MEMORY:
			str = "GL_OUT_OF_MEMORY";
			break;
		case GL_INVALID_FRAMEBUFFER_OPERATION:
			str = "GL_INVALID_FRAMEBUFFER_OPERATION";
			break;

		default:
			str = "(ERROR: Unknown Error Enum)";
			break;
	}
	return str;
}


@interface OpenGLRenderer : NSObject {	
	GLuint _defaultFBOName;
	GLfloat fovY;	
	JBTetrahydron *model;	
}

- (id) initWithDefaultFBO: (GLuint) defaultFBOName;
- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;

@end