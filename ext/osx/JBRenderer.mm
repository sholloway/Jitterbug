#import "JBRenderer.h"
@implementation JBRenderer
- (id) init
{
	viewWidth = 0;
	viewHeight = 0;
	return self;
}

- (void) setFramebuffer:(GLuint)fbo
{
	framebuffer = fbo;
}

- (void) activateSystemFrameBuffer
{
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void) activateOffScreenFrameBuffer
{
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
}

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
	glViewport(0, 0, width, height);
	
	viewWidth = width;
	viewHeight = height;	
}

- (void) render
{
	//override
}

- (void) dealloc
{	
	[layerScripts release];
	[super dealloc];
}
@end