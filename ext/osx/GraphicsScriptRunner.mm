#import "GraphicsScriptRunner.h"

@implementation GraphicsScriptRunner
- (id)init
{
    self = [super init];
    if (self) {        
		
    }
    
    return self;
}

- (void) dealloc
{
	if (scripts)
	{
		[scripts release];
	}
		
	[super dealloc];
}

- (void) setScripts: (NSArray *) newScripts
{
	scripts = newScripts;
}

- (void) run
{
	if (!scripts){
		//need to raise an exception or something
		return;
	}
	
	for (GraphicsScript *script in scripts)
	{
		//need to some how get access to the jitterbug log
		//but diagnostics before and after. Also have an individual log for each script.
		[script run];
	}
}
@end