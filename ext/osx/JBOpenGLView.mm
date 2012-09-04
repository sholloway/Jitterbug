#import "JBOpenGLView.h"
#include <OpenGL/gl3.h>

@interface JBOpenGLView (PrivateMethods)
- (void) initGL;
- (void) drawView;
@end

//https://developer.apple.com/library/mac/#qa/qa1385/_index.html
@implementation JBOpenGLView
- (void) setRenderer:(JBRenderer*) renderer
{
	_renderer = renderer;
	[_renderer setSize:imageWidth height:imageHeight];
	[_renderer setFramebuffer:framebuffer];
	[_renderer setParent:self];
}

- (void) setSize:(GLuint) width height:(GLuint) height
{
	imageWidth = width;
	imageHeight = height;
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
	// There is no autorelease pool when this method is called 
	// because it will be called from a background thread
	// It's important to create one or you will leak objects
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self drawView];
	
	[pool release];
	return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, 
                                      const CVTimeStamp* now, 
                                      const CVTimeStamp* outputTime, 
                                      CVOptionFlags flagsIn, 
                                      CVOptionFlags* flagsOut, 
                                      void* displayLinkContext)
{
    CVReturn result = [(JBOpenGLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (id) initWithFrame:(NSRect)frameRect
{
	//Try this eventually to help with aliasing
	// [NSOpenGLPFAAccelerated,
	//    NSOpenGLPFADoubleBuffer,
	 //   NSOpenGLPFADepthSize, 24,
	  //  NSOpenGLPFAAlphaSize, 8,
	 //   NSOpenGLPFAColorSize, 32,
	  //  NSOpenGLPFANoRecovery,
	  //  kCGLPFASampleBuffers, 1, kCGLPFASamples, 2,
	  //  0]
	//need to go over each of these
	NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize,24,		
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,	// Must specify the 3.2 Core Profile to use OpenGL 3.2	
		0
	};
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	if (!pf)
	{ 
		NSLog(@"No OpenGL pixel format"); //Need to find a way to share the logger between Obj-C and Ruby.
	}
	
	self = [super initWithFrame:frameRect pixelFormat:[pf autorelease]];
	
	return self;
}

- (void) prepareOpenGL
{
	[super prepareOpenGL];
	
	
	// Make all the OpenGL calls to setup rendering  
	//  and build the necessary rendering objects
	[self initGL];
	[self initCV];
	
}

//prep Core Video
- (void) initCV
{
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
	// Set the display link for the current renderer
	CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	
	// Activate the display link
	CVDisplayLinkStart(displayLink);
}

- (void) pause
{
	CVDisplayLinkStop(displayLink);
}

- (void) initGL
{
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];	
	//[self printHardwareSpecs];	
	[self setupBuffers];
	[self setupShaders];
}

- (void) setupShaders
{
	[_renderer setupShaders];
}

//Set up a renderbuffer to write the frame to.
//This renderbuffer will provide the pixels for the Compositor
- (void) setupBuffers
{
	//Set up a FBO with one renderbuffer attachment
    //create FBO
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    //create RBO to render RGBA to
    glGenRenderbuffers(1, &renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, 
                             GL_RGBA8,                      
                             imageWidth, imageHeight);
    
    //Attach the renderbuffer to a framebuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, 
                              GL_COLOR_ATTACHMENT0,  
                              GL_RENDERBUFFER, 
                              renderbuffer);

	GLenum status;
	status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	NSAssert1(status == GL_FRAMEBUFFER_COMPLETE, @"The Renderbuffer is not ready to draw. Status was: %i", status); //is the renderbuffer ready for use?
	   	
}

- (void) printHardwareSpecs
{
	NSLog(@"%s", glGetString(GL_RENDERER)); 
	NSLog(@"OpenGL %s", glGetString(GL_VERSION));

	//How many FBO's can I have?
    int numFBOs;
    glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS_EXT, &numFBOs);
    NSLog(@"Number of FBO's supported: %d", numFBOs);
}

- (void) reshape
{	
	[super reshape];
	
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	NSRect rect = [self bounds];
	
	[_renderer resizeWithWidth:rect.size.width AndHeight:rect.size.height];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) drawView
{	 
	[[self openGLContext] makeCurrentContext];

	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	@try{
		[_renderer render];		
	}
	@catch(NSException *exception){
		NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
		[NSApp terminate: nil];
	}
	
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) dealloc
{	
	[_renderer release];
	
	//make sure this is the propper context
    [[self openGLContext] makeCurrentContext];

    //clean up all FBO's
    glDeleteFramebuffersEXT(1, &framebuffer);

    //delete all RBO's
    glDeleteRenderbuffersEXT(1, &renderbuffer);

    //delete all models
    
	
	// Release the display link
	CVDisplayLinkRelease(displayLink);
	
	[super dealloc];
}
@end