#import <OpenGL/gl3.h>
#import <Foundation/Foundation.h>

@interface JBRenderer : NSObject {	
	GLuint viewWidth;
	GLuint viewHeight;
	NSArray *layerScripts;
}

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;
- (void) setLayers:(NSArray *)scripts;
- (NSArray *) getLayers;
@end