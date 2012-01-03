#import <Foundation/Foundation.h>

@interface JBGraphicsScript : NSObject{
	NSString *script;
	NSString *filter;
	NSMutableDictionary *stateContext;
}
- (void) setScript: (NSString *) script;
- (NSString *) getScript;
- (void) setFilter: (NSString *) filter;
- (NSString *) getFilter;
- (void) run;
- (id)context;
- (void)setContext:(id)hash;
@end	