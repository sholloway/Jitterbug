require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class CoreImageLayerCompositor < LayerCompositor      
      def composite
        @logger.debug("CoreImageLayerCompositor: beginning composite")

        #need to do alpha compositing here. #Just the first frame rendered at the moment
        @raw_rendered_frame = @frames[0][0] #I bet this is breaking it.
        puts "Inside the CoreImageLayerCompositor all the frames are: #{@frames}"
        puts "Inside the CoreImageLayerCompositor the raw_rendered_frame is: #{@raw_rendered_frame}" 
        @logger.debug("CoreImageLayerCompositor: ending composite")
      end
    end
  end
end