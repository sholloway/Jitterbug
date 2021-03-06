#import "GLView.h"
#include <OpenGL/OpenGL.h>

@interface GLView (PrivateMethods)
- (void) initGL;
- (void) drawView;
@end

@implementation GLView

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
    CVReturn result = [(GLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (id) initWithFrame:(NSRect)frameRect
{
	//need to go over each of these
	NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 
		24,		
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

- (void) initGL
{
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	// Init our renderer.  Use 0 for the defaultFBO which is appropriate for MacOS (but not iOS)
	_renderer = [[OpenGLRenderer alloc] initWithDefaultFBO:0];
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
	
	[_renderer render];
	
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) dealloc
{	
	
	[_renderer release];
	
	// Release the display link
	CVDisplayLinkRelease(displayLink);
	
	[super dealloc];
}
@end
