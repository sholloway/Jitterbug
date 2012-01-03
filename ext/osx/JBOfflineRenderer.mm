#import "JBOfflineRenderer.h"
#import "JBGraphicsScript.h"

@implementation JBOfflineRenderer
- (id) init
{
	self = [super init];
	return self;
}

- (void) render
{
	//clear to red for the moment. This won't be here...
	glClearColor(1.0f, 0.0f, 0.0f, 1.0f); 
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	NSArray *layers = [self getLayers];
	for(JBGraphicsScript *layer in layers)
	{		
		[layer run];
		//put GLError checks here.	
		//glFlush();
		//glFinish();	
	}
	
	//put GLError checks here.
	
	//glFlush();	
	//glFinish();		
	//need a way to force the wait until all scripts are truly done with the OpenGL context?
}
@end