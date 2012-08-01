require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class CoreImageLayerCompositor < LayerCompositor
      def initialize
        super
      end
      
      def composite
        @logger.debug("CoreImageLayerCompositor: beginning composite")
        @logger.debug("CoreImageLayerCompositor: implement composit logic")
        @logger.debug("CoreImageLayerCompositor: ending composite")
      end
    end
  end
end