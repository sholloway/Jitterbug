#import "JBRenderer.h"
#import <OpenGL/gl3.h>
#import "ImageUtilities.h"

@implementation JBRenderer
- (id) init
{
	viewWidth = 0;
	viewHeight = 0;
	return self;
}

- (int) width
{
	return viewWidth;
}

- (int) height
{
	return viewHeight;
}

- (void) setParent: p;
{
	parent = p;
}

- (id) getParent
{
	return parent;
}

- (void) stop
{
	[parent pause]; //stop rendering
	[[parent window] performClose:self]; //close the window
}

- (void) setFramebuffer:(GLuint)fbo
{
	framebuffer = fbo;
}

- (void) checkFBO
{
	GLenum status;
	status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	NSAssert1(status == GL_FRAMEBUFFER_COMPLETE, @"The Renderbuffer is not ready to draw. Status was: %i", status); 
}

- (void) activateSystemFrameBuffer
{
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
	NSLog(@"activateSystemFrameBuffer");
	[self checkFBO];
}

- (void) activateOffScreenFrameBuffer
{
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glBindFramebuffer(GL_READ_FRAMEBUFFER, framebuffer);
	NSLog(@"activateOffScreenFrameBuffer");
	[self checkFBO];
}

- (void) setSize:(uint)width height:(uint)height
{
	viewWidth = width;
	viewHeight = height;
}

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height
{
	glViewport(0, 0, width, height);
	
	viewWidth = width;
	viewHeight = height;	
}

// Is there a similar concept to Abstract Class in Obj-C?
// Perhaps I should only have the header file for JBRender.
- (void) render
{
	//override
}

- (void) setupShaders
{
	//override 	
}

- (void) tearDownShaders
{
	//override
}

+ (void)debug_this_sob
{
	GLenum theError = GL_NO_ERROR;
    theError = glGetError();
    NSAssert1(theError == GL_NO_ERROR, @"OpenGL error 0x%04X", theError);
}

//only used internally
- (const GLubyte*)glGetStringiShim:(GLuint) index
{
	return glGetStringi(GL_EXTENSIONS,index);
}

- (void) outputActiveFramebuffer
{		
	long byteWidth = [ImageUtilities calculateByteWidth:viewWidth];        
    void *pixels = malloc(byteWidth*viewHeight); 
    
	GLenum status;
	status = glCheckFramebufferStatus(GL_READ_FRAMEBUFFER);
	NSAssert1(status == GL_FRAMEBUFFER_COMPLETE, @"The Renderbuffer is not ready to read. Status was: %i", status); 
	
    //set up pixel alignment to force 4-byte alignment
    //glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);

    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glPixelStorei(GL_PACK_ROW_LENGTH, 0);
    glPixelStorei(GL_PACK_SKIP_ROWS, 0);
    glPixelStorei(GL_PACK_SKIP_PIXELS, 0);

	glReadPixels( 0,0, //lower left corner of a rectangular block of pixels
                  viewWidth, viewHeight, //width and height of image
                  GL_BGRA, //format of the pixel data
                  GL_UNSIGNED_INT_8_8_8_8_REV, //data type of the pixel data
                  pixels); //output
	[JBRenderer debug_this_sob];
	
	
    //glPopClientAttrib();
	
    
    //dump the pixels into an image and save to the file system.
    [ImageUtilities flipImageData:pixels 
                      imageWidth:viewWidth 
                      imageHeight:viewHeight];
    
    //try doing all of this in Ruby to get pass pointer/casting issues
				_framebufferImageRef = pixels;
	/*
    _framebufferImageRef = [ImageUtilities createRGBImageFromBufferData:pixels 
                                        imageWidth:viewWidth 
                                        imageHeight:viewHeight];
	
	NSLog(@"Inside JBRenderer the _framebufferImageRef is %@", _framebufferImageRef);
    NSAssert(_framebufferImageRef != 0, @"cgImageFromPixelBuffer failed");
    */

	
    //[ImageUtilities createTIFFImageFileOnDesktop:imageRef];

    //CGImageRelease(imageRef);
    //free(pixels);
}

//is this going to leak on Macruby?
- (void *) renderedFrame
{
	return _framebufferImageRef;
}

- (void) dealloc
{	
	[self tearDownShaders];
	[super dealloc];
}
@end