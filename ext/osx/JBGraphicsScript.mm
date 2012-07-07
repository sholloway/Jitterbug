#import <OpenGL/gl3.h>
#import <Foundation/Foundation.h>
#import "JBGraphicsScript.h"
#import "JBColor.h"

@implementation JBGraphicsScript
- (id)init
{	
    self = [super init];	
    if (self) {        		
		filter = @"Sweet Jesus I'm having a good day!";		
		script = @"Will there be a collision?";
		stateContext = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void) dealloc
{
	[script release];
	[filter release];
	[stateContext release];
	[super dealloc];
}

- (void) setScript: (NSString *) newScript
{
	script = newScript;
}

- (void) setFilter: (NSString *) newFilter
{
	filter = newFilter;
}

-(NSString *) getScript
{
	return script;
}

- (NSString *) getFilter
{
	return filter;
}

- (id)context
{
	return stateContext;
}

- (void)setContext:(id)hash
{
	stateContext = hash;
}

/* Low level functions for DSL to rely on*/
// Possibly use a message passing paridigm or command pattern to keep the size of this class low.
// Inheritance gets yucky.

// draws a background color.
- (void) clear
{		
	id script_context = [self context];
	NSAssert( script_context != Nil, @"The script_context became nil.");
	
	//Should be a JBColor object
	id color = [script_context fetch:@"background_color"]; 
	NSAssert(color != Nil, @"The background color was nil.");	
			
	if(color != Nil) 
	{			
		glClearColor([[color red] floatValue], [[color green] floatValue], [[color blue] floatValue], [[color alpha] floatValue]);		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 
	}else{
		// Logger should be defined on the ruby side.
		[[self logger] error:@"There was no :background_color in the script's context."];
	}
}

/*
typedef struct _jbVertex2F
{
	GLfloat x;
	GLfloat y;
} jbVertex2F;


- (void) drawPoint2DWithX:(float) x
	y:(float) y
{
	jbVertex2F point = (jbVertex2F) {x, y};
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	
	//should look up the states before doing this and restoring what they were, rather than just automatically turning them back on.	
	glDisable(GL_TEXTURE_2D);
	glVertexPointer(2, GL_FLOAT, 0, &point);	
	glDrawArrays(GL_POINTS, 0, 1);

	// restore default state
	glEnable(GL_TEXTURE_2D);	
}
*/

/*
2D points should have it's Z value be set to the layer's distance from the camera to provide future support for depth of field effects.
Create and manage one VBO for all points. 
Create and manage one set of shaders for all points by default. (Simple case)
//start with a simple flat structure. 
typedef struct _jbPoint{
	float x;
	float y;
	float z;
	float red;
	float green;
	float blue;
	float alpha;
	int size # the point size bound to gl_PointSize. Make sure glDisable(GL_PROGRAM_POINT_SIZE) & glEnable(GL_VERTEX_PROGRAM_POINT_SIZE) is called.
} jbPoint 


Things to manage:
Master points VBO, per layer. Only create if point() has been called. Only create once by default;
Load default shaders into memory on program start up.
Need a way to update the points position and size per frame if they change


*/

//this should be overriden by ruby script like sketch2d.rb
- (void) run{
	NSLog(@"Do not call JBGraphicsScript directly.");
}
@end