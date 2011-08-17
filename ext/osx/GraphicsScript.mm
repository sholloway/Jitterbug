#import "GraphicsScript.h"

@implementation GraphicsScript
- (id)init
{
    self = [super init];
    if (self) {        
		filter = @"Sweet Jesus I'm having a good day!";
		script = @"Will there be a collision?";
    }
    
    return self;
}

- (void) dealloc
{
	[script release];
	[filter release];
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

- (void) run{}
@end