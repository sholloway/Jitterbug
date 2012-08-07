#import <OpenGL/gl3.h>
#import <Foundation/Foundation.h>

@interface JBRenderer : NSObject {	
	GLuint viewWidth;
	GLuint viewHeight;
	GLuint framebuffer;
	NSArray *layerScripts;
	id parent;
}

- (void) setSize:(uint)width height:(uint)height;
- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;

//window-system-provided framebuffer
- (void) activateSystemFrameBuffer;
- (void) activateOffScreenFrameBuffer;
- (void) setFramebuffer:(GLuint)fbo;

- (void) outputActiveFramebuffer;
- (void) setParent: p;
- (void) stop;
@end