#import <Foundation/Foundation.h>
@interface GLSLShaderManager : NSObject {	
	NSString *vertexShader;
	NSString *fragmentShader;
	GLint program;
	GLsizei vertexCount;
	GLsizeiptr positionSize;
	glm::vec2 *positionData;

	GLsizei elementCount;
	GLsizeiptr elementSize;
	GLushort *elementData;
	
	GLuint elementBufferName, arrayBufferName, vertexArrayName;
	GLint uniformMVP, uniformDiffuse, attribPosition;
	
	glm::vec2 rotationOrigin;
	glm::vec2 rotationCurrent;
	glm::vec2 tranlationOrigin;
	glm::vec2 tranlationCurrent;
	id<NSObject> geometryNode;
}

- (void)setVertexShader:(NSString *)str;
- (void)setFragmentShader:(NSString *)str;
- (void)setGeometryNode:(id<NSObject>)gnode;

//Rendering Methods
- (void) register:(id)ruby_renderer;
- (void) draw:(id)ruby_renderer;
- (void) checkout:(id)ruby_renderer;

- (bool) validateProgram:(GLint) program;
-(void) checkShaderCompileStatus:(GLint)shader shaderName:(NSString *)shaderName;
@end