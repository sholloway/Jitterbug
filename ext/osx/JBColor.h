#import <Foundation/Foundation.h>

@interface JBColor : NSObject
{
@public
	float r,g,b,a;
}
@property float r;
@property float g;
@property float b;
@property float a;

- (id) initWithColorRed:(float)red 
	green:(float)green 
	blue:(float)blue 
	alpha:(float)alpha;
@end