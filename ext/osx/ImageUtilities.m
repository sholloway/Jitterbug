//
//  ImageUtilities.m
//  FBOSpike
//
//  Created by Samuel Holloway on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageUtilities.h"


@implementation ImageUtilities

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

/*
Calculate the number of bytes in the width of an image for BGRA format.
*/
+ (long) calculateByteWidth: (long)imageWidth
{
    long byteWidth = imageWidth * 4;  //4 bytes per pixel (BGRA)
    byteWidth = (byteWidth + 3) & ~3; //Align to 4 bytes
    return byteWidth;
}

// Create a TIFF file on the desktop from our data buffer
+ (void) createTIFFImageFileOnDesktop:(CGImageRef)imageRef
{
    // glReadPixels writes things from bottom to top, but we
    // need a top to bottom representation, so we must flip
    // the buffer contents.
    //[self flipImageData:imageData byteWidth:bw];
    
    // Create a Quartz image from our pixel buffer bits
    //CGImageRef imageRef = [self createRGBImageFromBufferData:imageData byteWidth:bw];
    //NSAssert( imageRef != 0, @"cgImageFromPixelBuffer failed");
    
    // Make full pathname to the desktop directory
    NSString *desktopDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDesktopDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)  
    {
        desktopDirectory = [paths objectAtIndex:0];
    }
    
    NSMutableString *fullFilePathStr = [NSMutableString stringWithString:desktopDirectory];
    NSAssert( fullFilePathStr != nil, @"stringWithString failed");
    [fullFilePathStr appendString:@"/ScreenSnapshot.tiff"];
    
    NSString *finalPath = [NSString stringWithString:fullFilePathStr];
    NSAssert( finalPath != nil, @"stringWithString failed");
    
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)finalPath,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    NSAssert( url != 0, @"CFURLCreateWithFileSystemPath failed");
    // Save our screen bits to an image file on disk
    
    // Save the image to the file
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, CFSTR("public.tiff"), 1, nil);
    NSAssert( dest != 0, @"CGImageDestinationCreateWithURL failed");
    
    // Set the image in the image destination to be `image' with
    // optional properties specified in saved properties dict.
    CGImageDestinationAddImage(dest, imageRef, nil);
    
    bool success = CGImageDestinationFinalize(dest);
    NSAssert( success != 0, @"Image could not be written successfully");
    
    CFRelease(dest);    
    CFRelease(url);
}

+ (void) flipImageData: (void *)imageData 
    imageWidth:(long)imageWidth 
    imageHeight:(long)imageHeight
{
    long top, bottom;
    void * buffer;
    void * topP;
    void * bottomP;
    void * base;
    long rowBytes;
    
    top = 0;
    bottom = imageHeight - 1;
    base = imageData;
    rowBytes = [ImageUtilities calculateByteWidth:imageWidth];
    buffer = malloc(rowBytes);
    NSAssert( buffer != nil, @"malloc failure");
    
    while ( top < bottom )
    {
        topP = (void *)((top * rowBytes) + (intptr_t)base);
        bottomP = (void *)((bottom * rowBytes) + (intptr_t)base);
        
        /*
         * Save and swap scanlines.
         *
         * This code does a simple in-place exchange with a temp buffer.
         * If you need to reformat the pixels, replace the first two bcopy()
         * calls with your own custom pixel reformatter.
         */
        bcopy( topP, buffer, rowBytes );
        bcopy( bottomP, topP, rowBytes );
        bcopy( buffer, bottomP, rowBytes );
        
        ++top;
        --bottom;
    }
    free( buffer );
}

+ (CGImageRef)createRGBImageFromBufferData:(void *)imageData 
                                imageWidth: (long)imageWidth
                                imageHeight:(long)imageHeight                                
{
    CGColorSpaceRef cSpace = CGColorSpaceCreateWithName (kCGColorSpaceGenericRGB);
    NSAssert( cSpace != NULL, @"CGColorSpaceCreateWithName failure");
    
    CGContextRef bitmap = CGBitmapContextCreate(imageData, 
                                                imageWidth, imageHeight, 
                                                8, [ImageUtilities calculateByteWidth:imageWidth],
                                                cSpace,  
#if __BIG_ENDIAN__
                                                kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Big /* XRGB Big Endian */);
#else
    kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little /* XRGB Little Endian */);
#endif                   
    
    NSAssert( bitmap != NULL, @"CGBitmapContextCreate failure");
    
    // Get rid of color space
    CFRelease(cSpace);
    
    // Make an image out of our bitmap; does a cheap vm_copy of the  
    // bitmap
    CGImageRef image = CGBitmapContextCreateImage(bitmap);
    NSAssert( image != NULL, @"CGBitmapContextCreate failure");
    
    // Get rid of bitmap
    CFRelease(bitmap);
    
    return image;
}
@end
