#include "PolyglotUtils.h"

@implementation PolyglotUtils

+ (unsigned long) findArrayByteSizeByFirstElementi: (int)firstElement andLength: (long)length
{
	return sizeof((int)firstElement) * length;
}

+ (unsigned long)sizeofChar
{
	return sizeof(char);
}

+ (void)sizeof
{
	NSLog(@"Size of char: %lx",sizeof(char));
	NSLog(@"Size of uint: %lx",sizeof(uint));
	NSLog(@"Size of short: %lx",sizeof(short));
	NSLog(@"Size of int: %lx",sizeof(int));
	NSLog(@"Size of long: %lx",sizeof(long));
	NSLog(@"Size of float: %lx", sizeof(float));
}
@end