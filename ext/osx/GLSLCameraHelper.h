#import <Foundation/Foundation.h>
@interface GLSLCameraHelper : NSObject{
	id<NSObject> camera;
}

- (id) initWithCamera:(id)ruby_camera;
-(float) fovY;
-(float) aspectRatio;
-(float) nearClippingPane;
-(float) farClippingPane;
-(int) width;
-(int) height;
-(glm::vec3) position;
-(glm::vec3) target;
-(glm::vec3) up;
@end