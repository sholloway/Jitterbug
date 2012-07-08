module Jitterbug
  module GraphicsEngine
    class RenderLoop
      attr_accessor :engine
      def initialize(logger)
        @logger = logger
      end      
      
      def run_loop(sketch)    
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::RenderLoop directly.")          
      end
    end
    
    class FrameProcessor
      attr_accessor :engine
      attr_reader :raw_rendered_frame
      def initialize(logger)
        @logger = logger
      end
      
      def process(sketch)
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::FrameProcessor directly.")       
      end
    end
    
    class Image
      RAW = 0
      JPEG = 1
      attr_accessor :raw_pixels
            
      def initialize(logger)
        @logger = logger
      end
            
      def save_as(type,path)    
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
    
    class Renderer
      attr_accessor :camera, :raw_rendered_frame
      def initialize(logger)
        @logger = logger
        @visible_lights = []
        @visible_geometry = []
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
        
    class SceneGraph
      def initialize(logger)
        @logger = logger
      end
      
      def init()
      end
    end
    
    class SpatialDataPartition
      def initialize(logger)
        @logger = logger
      end
      
      #don't think I need this...
      def construct(scene_graph)
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::SpatialDataPartition directly.")
      end
      
      def cull(culler)
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::SpatialDataPartition directly.")
      end
    end
    
    class SketchAPI
      def initialize(logger)
        @logger = logger
      end
      
      def bind(scene_graph)
        @scene_graph = scene_graph
      end
      
      def run(layer)        
        begin
          @logger.info("About to evaluate layer: #{layer.name}")            
          @logger.info("#{layer.script}")
          script_content = fetch_script(layer.script)
          instance_eval(script_content)
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
        file = ''
        open(path,'r'){|f| file = f.read}
        return file
      end
    end
    
    class Culler
      attr_reader :visible_lights, :visible_geometry
      def initialize(logger)
        @logger = logger
      end
    end
    
    class Camera
      attr_accessor :frustum
      def initialize(logger)
        @logger = logger
      end
    end
    
    class Frustum
      def initialize(logger)
        @logger = logger
      end
    end
    
    class LayerCompositor
      attr_reader :raw_rendered_frame
      def initialize(logger)
        @logger = logger
      end
      
      def add(frame, layer)
      end
      
      def composite
        raise Exception.new("Do not instantiate Jitterbug::GraphicsEngine::LayerCompositor directly.")
      end
    end
  end
end