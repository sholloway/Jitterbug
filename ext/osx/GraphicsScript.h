#import <Foundation/Foundation.h>

@interface GraphicsScript : NSObject{
	NSString *script;
	NSString *filter;
}
- (void) setScript: (NSString *) script;
- (NSString *) getScript;
- (void) setFilter: (NSString *) filter;
- (NSString *) getFilter;
- (void) run;
@end	