#import "JBRenderer.h"
@implementation JBRenderer
- (id) init
{
	viewWidth = 0;
	viewHeight = 0;
	return self;
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

- (void) setLayers:(NSArray *)scripts
{
	layerScripts = scripts;
}

- (NSArray *) getLayers
{
	return layerScripts;
}

- (void) dealloc
{	
	[layerScripts release];
	[super dealloc];
}
@end