#import <Foundation/Foundation.h>
@interface GLSLNodeRenderer : NSObject {	
	id<NSObject> renderState;
	id<NSObject> geometryNode;
	NSString *vertexShader;
	NSString *fragmentShader;
	GLint program;
	GLint indicesCount;
	GLsizei vertexCount;
	GLsizeiptr positionSize;
	glm::vec2 *positionData;


	GLsizei elementCount;
	GLsizeiptr elementSize;
	GLushort *elementData;
	
	GLuint elementBufferName, arrayBufferName, vertexArrayName;
	GLint uniformMVP, uniformDiffuse, attribPosition;
}

-(void) bindGeometry:(id) glsl_geometry;
//Rendering Methods
- (void) register:(id)ruby_renderer;
- (void) draw:(id)ruby_renderer;
- (void) checkout:(id)ruby_renderer;

- (bool) validateProgram:(GLint) program;
- (void) checkShaderCompileStatus:(GLint)shader shaderName:(NSString *)shaderName;
@end