#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>
#import "JBRenderer.h"

@interface JBOpenGLView : NSOpenGLView {
	CVDisplayLinkRef displayLink; 	//Use core video rather than a timer for controlling framerate.
	JBRenderer* _renderer; 											
}

- (void) setRenderer:(JBRenderer*) renderer;
@end