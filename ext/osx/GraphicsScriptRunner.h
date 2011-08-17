#import <Foundation/NSArray.h>
#import "GraphicsScript.h"

@interface GraphicsScriptRunner : NSObject{
	NSArray *scripts;
}
- (void) setScripts: (NSArray *)scripts;
- (void) run;
@end