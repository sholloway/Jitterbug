#import "GLView.h"
#import "OpenGLRenderer.h"

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


@implementation OpenGLRenderer
GLuint _viewWidth;
GLuint _viewHeight;
GLuint _defaultFBOName;


- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
	glViewport(0, 0, width, height);
	
	_viewWidth = width;
	_viewHeight = height;	
}

- (void) render
{	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
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
		
		_viewWidth = 100;
		_viewHeight = 100;
		

		//////////////////////////////
		// Load our character model //
		//////////////////////////////
	
	
		
		////////////////////////////////////
		// Load texture for our character //
		////////////////////////////////////
		
	
	
		
		////////////////////////////////////////////////////
		// Load and Setup shaders for character rendering //
		////////////////////////////////////////////////////
				
		
	
		////////////////////////////////////////////////
		// Set up OpenGL state that will never change //
		////////////////////////////////////////////////
		
		// Depth test will always be enabled
		glEnable(GL_DEPTH_TEST);
	
		// We will always cull back faces for better performance
		glEnable(GL_CULL_FACE);
		
		// Always use this clear color
		glClearColor(0.1f, 0.1f, 0.9f, 1.0f);
		
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

- (void) dealloc
{	
	[super dealloc];	//call last
}

@end