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


// Possibly use a message passing paridigm or command pattern to keep the size of this class low.
// Inheritance gets yucky.
- (void) clear
{		
	id script_context = [self context];
	NSAssert( script_context != Nil, @"The script_context became nil.");
	
	//Should be a JBColor object
	id color = [script_context fetch:@"background_color"]; 
	NSAssert(color != Nil, @"The background color was nil.");
	// NSAssert([color isKindOfClass: [JBColor class]] == YES, @"The background color was not an instance of JBColor.");
			
	if(color != Nil) 
	{			
		// NSLog(@"Color was not nil and is JBColor instance."); Seems to work if this is uncommented.
		//otherwise it's a seg fault.
		glClearColor([[color red] floatValue], [[color green] floatValue], [[color blue] floatValue], [[color alpha] floatValue]);
		// glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 
	}else{
		// Logger should be defined on the ruby side.
		[[self logger] error:@"There was no :background_color in the script's context."];
	}
}

//this should be overriden by ruby script like sketch2d.rb
- (void) run{
	NSLog(@"Do not call JBGraphicsScript directly.");
}
@end