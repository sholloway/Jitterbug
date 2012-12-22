#include <glm/glm.hpp>
#import "GLSLCameraHelper.h"

@implementation GLSLCameraHelper
- (id) initWithCamera:(id)ruby_camera {
	self = [super init];
	self->camera = ruby_camera;
	return self;
}

-(float) fovY{
	return [(NSNumber *)[self->camera fovy] floatValue];
}

-(float) aspectRatio{
	return [self width]/[self height];
}

-(float) nearClippingPane{
	return [(NSNumber *)[self->camera near_clipping_pane] floatValue];
}

-(float) farClippingPane{
	return [(NSNumber *)[self->camera far_clipping_pane] floatValue];
}

-(int) width{
	return [(NSNumber *)[self->camera width] intValue];
}

-(int) height{
	return [(NSNumber *)[self->camera height] intValue];
}

-(glm::vec3) position{
	NSArray *pos = (NSArray *)[self->camera position_point];
	float x = [(NSNumber *)[pos objectAtIndex:0] floatValue];
	float y = [(NSNumber *)[pos objectAtIndex:1] floatValue];
	float z = [(NSNumber *)[pos objectAtIndex:2] floatValue];
	return glm::vec3(x,y,z);
}

-(glm::vec3) target{
	NSArray *aim = (NSArray *)[self->camera target_point];
	float x = [(NSNumber *)[aim objectAtIndex:0] floatValue];
	float y = [(NSNumber *)[aim objectAtIndex:1] floatValue];
	float z = [(NSNumber *)[aim objectAtIndex:2] floatValue];
	return glm::vec3(x,y,z);
}
-(glm::vec3) up{
	NSArray *up_dir = (NSArray *)[self->camera up_vector];
	float x = [(NSNumber *)[up_dir objectAtIndex:0] floatValue];
	float y = [(NSNumber *)[up_dir objectAtIndex:1] floatValue];
	float z = [(NSNumber *)[up_dir objectAtIndex:2] floatValue];
	return glm::vec3(x,y,z);
}
@end