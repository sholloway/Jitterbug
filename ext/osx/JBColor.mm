#import "JBColor.h"

@implementation JBColor
@synthesize r;
@synthesize g;
@synthesize b;
@synthesize a;

- (id) initWithColorRed:(float)red 
	green:(float)green 
	blue:(float)blue 
	alpha:(float)alpha
{
	self = [super init];
	if(self)
	{
		r = red;
		g = green;
		b = blue;
		a = alpha;
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}
@end