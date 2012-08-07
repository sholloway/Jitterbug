#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>
#import "JBRenderer.h"

@interface JBOpenGLView : NSOpenGLView {
	CVDisplayLinkRef displayLink; 	//Use core video rather than a timer for controlling framerate.
	JBRenderer* _renderer; 
	GLuint framebuffer, renderbuffer;
	GLuint imageWidth, imageHeight;											
}

- (void) setRenderer:(JBRenderer*) renderer;
- (void) setSize:(GLuint) width height:(GLuint) height;
- (void) pause;
@end