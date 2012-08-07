#import <OpenGL/gl3.h>
#import <Foundation/Foundation.h>

@interface JBRenderer : NSObject {	
	GLuint viewWidth;
	GLuint viewHeight;
	GLuint framebuffer;
	NSArray *layerScripts;
}

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;

//window-system-provided framebuffer
- (void) activateSystemFrameBuffer;
- (void) activateOffScreenFrameBuffer;
- (void) setFramebuffer:(GLuint)fbo;
@end