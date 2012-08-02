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
    
    class NullSpatialPartition < Jitterbug::GraphicsEngine::SpatialDataPartition
      def initialize
        super
      end
      
      def construct(scene_graph)   
        @scene_graph = scene_graph     
      end
      
      def cull(culler)     
        #should return all geometry 
        @logger.debug("NullSpatialPartition: begining cull")  
        #traverse and grab all of the geometry nodes, light nodes, and camera nodes
        @scene_graph.breadth_first_traversal([@scene_graph.world_node()],lambda{|current_node| keep_everything(current_node,culler)})        
        @logger.debug("implement traversal to grab lights and geometry from scene graph")
        @logger.debug("NullSpatialPartition: ending cull")  
      end
      
      private
      def keep_everything(current_node,culler)
        case current_node.class.to_s
        when "Jitterbug::GraphicsEngine::LightNode" then culler.visible_lights << current_node
        when "Jitterbug::GraphicsEngine::CameraNode" then culler.active_cameras << current_node
        when "Jitterbug::GraphicsEngine::GeometryNode" then culler.visible_geometry << current_node
        else 
          @logger.error("NullSpatialPartition: keep_everything() - A node of unknown type was added to the scene graph. It was type #{current_node.class}")
        end
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