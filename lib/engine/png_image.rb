module Jitterbug
  module GraphicsEngine
    #after this is working, pull up most of this up into a ImageIO abstract class.
    class PNGImage < Image
      def initialize
        @extension = 'png'
      end
      
      def save_to_disk()    
        @logger.debug("PNGImage: beginning save_as")
        raise StandardError.new("The raw_pixels was not set") if @raw_pixels.nil?
       # raise StandardError.new("PNGImage requires raw_pixels to be a CGImageRef instance.\nIt was an instance of #{@raw_pixels.class}.") if !@raw_pixels.instance_of? CGImageRef
        
        image_ref = createRGBImageFromBufferData(@raw_pixels, 
          self.engine[:camera].width, 
          self.engine[:camera].height);
        
        myImageDest = CGImageDestinationCreateWithURL(NSURL.fileURLWithPath("#{path}/#{name}.#{extension}",false),
          "public.png", #encoding to use
          1, nil);
        
        CGImageDestinationAddImage(myImageDest, image_ref, nil)
        CGImageDestinationFinalize(myImageDest)

        @logger.debug("PNGImage: ending save_as")
      end
      
      private
      def createRGBImageFromBufferData(imageData, imageWidth, imageHeight)  
         #turns out the BridgeSupport definition for the color space stuff is at:
         #/System/Library/Frameworks/CoreGraphics.framework/Resources/BridgeSupport/CoreGraphics.bridgesupport
         #should just have to load the CoreGraphics framework...
         framework 'CoreGraphics'
         framework 'Quartz'
         cSpace = CGColorSpaceCreateWithName (::KCGColorSpaceGenericRGB);
          #NSAssert( cSpace != NULL, @"CGColorSpaceCreateWithName failure");

          bitmap = CGBitmapContextCreate(imageData, 
                                                      imageWidth, imageHeight, 
                                                      8, ImageUtilities.calculateByteWidth(imageWidth),
                                                      cSpace,        
                                                      ::KCGImageAlphaNoneSkipFirst | ::KCGBitmapByteOrder32Little );# XRGB Little Endian
      

          #NSAssert( bitmap != NULL, @"CGBitmapContextCreate failure");

          # Get rid of color space
          #CFRelease(cSpace);

          # Make an image out of our bitmap; does a cheap vm_copy of the  
          # bitmap
          image = CGBitmapContextCreateImage(bitmap);
          #NSAssert( image != NULL, @"CGBitmapContextCreate failure");

          # Get rid of bitmap
          #CFRelease(bitmap);

          return image;
      end
    end
  end
end