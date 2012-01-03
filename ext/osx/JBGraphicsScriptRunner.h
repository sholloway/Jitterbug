#import <Foundation/NSArray.h>
#import "JBGraphicsScript.h"

@interface JBGraphicsScriptRunner : NSObject{
	NSArray *scripts;
}
- (void) setScripts: (NSArray *)scripts;
- (void) run;
@end