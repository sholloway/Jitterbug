#import <OpenGL/gl3.h>
#import <Foundation/Foundation.h>

@interface JBRenderer : NSObject {	
	GLuint viewWidth;
	GLuint viewHeight;
	GLuint framebuffer;
	id parent;
	
	void* _framebufferImageRef;
}

- (void) setSize:(uint)width height:(uint)height;
- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) dealloc;

- (void) activateSystemFrameBuffer;
- (void) activateOffScreenFrameBuffer;
- (void) setFramebuffer:(GLuint)fbo;

- (void) outputActiveFramebuffer;
- (void) setParent: p;
- (id) getParent; 
- (void) stop;
- (void *) renderedFrame; //Must return id rather than CGImageRef since macruby doesn't recognize CGImage
- (const GLubyte*)glGetStringiShim:(GLuint) index;
- (int) width;
- (int) height;
+ (void)debug_this_sob;

// override in Ruby
- (void) render;
- (void) setupShaders;
- (void) tearDownShaders;


@end