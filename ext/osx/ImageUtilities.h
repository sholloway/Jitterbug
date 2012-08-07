//
//  ImageUtilities.h
//  FBOSpike
//
//  Created by Samuel Holloway on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageUtilities : NSObject {
@private
    
}

+ (long) calculateByteWidth: (long)imageWidth;
+ (void) createTIFFImageFileOnDesktop:(CGImageRef)imageRef;
+ (void) flipImageData: (void *)imageData 
            imageWidth:(long)imageWidth
            imageHeight:(long)imageHeight;
+ (CGImageRef) createRGBImageFromBufferData:(void *)imageData 
                                 imageWidth: (long)imageWidth
                                imageHeight:(long)imageHeight;
@end
