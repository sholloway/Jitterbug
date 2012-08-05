
module Jitterbug
  module GraphicsEngine
    class EnginePart
      attr_accessor :logger, :layers, :engine, :sketch_options, :width, :height
    end
    
    require 'scene_graph'
    
    class RenderLoop < EnginePart      
      attr_accessor :default_frame_output_name
      def run_loop    
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::RenderLoop directly.")          
      end
    end
    
    class FrameProcessor < EnginePart     
      attr_reader :raw_rendered_frame      
      
      def process
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::FrameProcessor directly.")       
      end
    end
    
    class Image < EnginePart
      attr_accessor :raw_pixels
                  
      def save_as(path)    
=begin
Core Image Notes:
Three main components:
  CIContext - CPU or GPU context to execute the filter on
  CIImage 
  CIFilter
  
Should also write meta data to the image. Date Stamp, Camera inputs? Sketch Name
=end    
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::Image directly.")
      end
    end
    
    class Renderer < EnginePart
      attr_accessor :camera, :raw_rendered_frame
      def initialize        
        @visible_lights = []
        @visible_geometry = []
        super()
      end
      
      def add_lights(lights)
        if (lights.instance_of?(Array))
          @visible_lights = @visible_lights + lights 
        else
          @visible_lights << lights
        end        
      end
      
      def add_geometry(geometry)
        if (geometry.instance_of?(Array))
          @visible_geometry = @visible_geometry + geometry 
        else
          @visible_geometry << geometry
        end        
      end
      
      def render
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::Renderer directly.")
      end
    end
        
    class Node
      # I might be able to support 2d & 3d by just having differnt transformation implementations.
      attr_accessor :transform_local, 
        :transform_world, 
        :render_state, #what are these states?
        :parent, #the parent of the node
        :position, #do I need this in addition to the transform world?
        :meta_data_hash,#catch all for storing meta data for animation or anything else
        :lable; #place holder for storing text that could be rendered. Possibly be better to just use meta_data_hash
        
      attr_reader :id, # a sketch unique integer
        :name, #a string
        :children; # array of children nodes
      
      def initialize(id,name)
        @id = id
        @name = name
        @parent = nil
        @children =  []
      end
      
      #needs to return some kind of shape to represent the bounding volume of the node and all of it's children      
      def boundary()
      end      
      
      def add_child(node)
        node.parent = self
        @children << node
      end
      
      # node_locator could be either id or name
      def detach_child(node_locator)
      end
    end
    
    class LightNode < Node      
      #GeometryNode's must be leaves
      def add_child
        raise Exception.new("LightNode cannont have children")
      end
    end
    
    class CameraNode < Node
      #GeometryNode's must be leaves
      def add_child
        raise Exception.new("CameraNode cannont have children")
      end
    end
    
    class GeometryNode < Node 
      attr_reader :geometry
      #GeometryNode's must be leaves
      def add_child
        raise Exception.new("GeometryNode cannont have children")
      end  
      
      def bind(geometry)
        @geometry = geometry
      end         
    end
    
    class Geometry
    end
    
    class SpatialDataPartition < EnginePart
  
      #don't think I need this...
      def construct(scene_graph)
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::SpatialDataPartition directly.")
      end
      
      def cull(culler)
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::SpatialDataPartition directly.")
      end
    end
    
    class SketchAPI < EnginePart      
      def bind(scene_graph)
        @scene_graph = scene_graph        
      end
      
      def run(layer)        
        begin
          @logger.debug("SketchAPI: About to evaluate layer: #{layer.name}")                      
          layer.script.load
          @logger.debug("SketchAPI:\n#{layer.script.content}")
          instance_eval(layer.script.content)
        rescue => e
          #put in logger
          @logger.error "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          @logger.error "An exception was raised while running layer #{layer.name}"
          @logger.error e.message
          e.backtrace.each{|error| @logger.error error}          
          @logger.error "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          raise StandardError.new("The user script '#{layer.name}' threw an error. Please see ./logs/render.log for details.")
        end
      end
      
      private
      def fetch_script(path)
        file = open(path,'r'){|f| f.read}
        return file
      end
    end
    
    class Culler < EnginePart
      attr_reader :visible_lights, 
        :visible_geometry, 
        :active_cameras; #should it be all active cameras or all cameras? Can there be more than one active camera?   
      def initialize()
        @visible_lights = []
        @visible_geometry = []
        @active_cameras = []
      end
    end
    
    class Camera < EnginePart
      attr_accessor :frustum     
    end
    
    class Frustum < EnginePart      
    end
    
    class LayerCompositor < EnginePart
      attr_reader :raw_rendered_frame      
      
      def add(frame, layer)
      end
      
      def composite
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::LayerCompositor directly.")
      end
    end
  end
end