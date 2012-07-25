require 'engine_parts'

#These parts are here to assist in testing and for using pass throughs on the Engine. For example
#It a user might not want to use a SpatialDataPartition but the engine requires one. So a NullSpatialDataPartion 
#can be used.
module Jitterbug
  module NullGraphicsEngine
    class NullRenderer < Jitterbug::GraphicsEngine::Renderer
      def initialize
        super
      end
      
      def render        
      end
    end
    
    class NullSpatialDataPartition < Jitterbug::GraphicsEngine::SpatialDataPartition
      def initialize
        super
      end
      
      def construct(scene_graph)        
      end
      
      def cull(culler)     
        #should return all geometry   
      end
    end
    
    class NullLayerCompositor < Jitterbug::GraphicsEngine::LayerCompositor
      def initialize
        super
      end
      
      def composite        
      end
    end
    
    class NullImage < Jitterbug::GraphicsEngine::Image
      def initialize
        super
      end
      
      def save_as(path)
      end
    end
  end
end