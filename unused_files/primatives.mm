#import "primatives.h"

@implementation JBTetrahydron
GLfloat tetrahydronVerts[4][3] = {
   	{  1.0,  1.0,  1.0  },   /* index 0 */
    { -1.0, -1.0,  1.0  },   /* index 1 */
    { -1.0,  1.0, -1.0  },   /* index 2 */
    {  1.0, -1.0, -1.0  } }; /* index 3 */

GLfloat tetrahydronColors[4][3] = {
    {  1.0,  0.0,  0.0  },   /* Red */
    {  0.0,  1.0,  0.0  },   /* Green */
    {  0.0,  0.0,  1.0  }, 	 /* Blue */
    {  1.0,  1.0,  1.0  } }; /* White */

GLubyte tetrahydronIndices[4][3] = { 
	{0, 1, 2}, 	// face 1
	{0, 2 ,3},	// face 2
	{0, 3, 1}, 	// face 3
	{1, 2, 3}}; // face 4
	
- (id)init
{
    self = [super init];
    if (self) {
        //initialize members...
        
    }
    
    return self;
}

- (void)dealloc
{       	
    //should this occure first or last?
	free(tetrahydronVerts);
	free(tetrahydronColors);
	free(tetrahydronIndices);
    [super dealloc];
}

-(GLvoid *) vertices
{
	return tetrahydronVerts;
}

-(short) vertsSize
{
	return 12;
}

-(GLvoid *) colors
{
	return tetrahydronColors;
}

-(short)colorsSize
{
	return 12;
}

-(GLvoid *) indicies
{
	return tetrahydronIndices;
}

-(short)indiciesSize
{
	return 12;
}
@end