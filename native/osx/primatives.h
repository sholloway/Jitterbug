#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
@interface JBTetrahydron : NSObject{	
}
-(GLvoid *) vertices;
-(GLvoid *) colors;
-(GLvoid *) indicies; //faces
-(short) vertsSize;
-(short) colorsSize;
-(short) indiciesSize;
@end