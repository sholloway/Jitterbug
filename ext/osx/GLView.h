#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>
#import "OpenGLRenderer.h"

@interface GLView : NSOpenGLView {
	CVDisplayLinkRef displayLink; 	//Use core video rather than a timer for controlling framerate.
	OpenGLRenderer* _renderer; 		//worry about this delegation after the build stuff is figured out... 
									//Should probably be something like JitterbugRender or something that ruby extends...
}

@end
