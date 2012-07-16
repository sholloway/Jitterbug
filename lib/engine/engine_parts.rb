module Jitterbug
  module GraphicsEngine
    class EnginePart
      attr_accessor :logger, :layers, :engine, :sketch_options
    end
    
    class RenderLoop < EnginePart      
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
      RAW = 0
      JPEG = 1
      attr_accessor :raw_pixels
                  
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
        
    class SceneGraph < EnginePart   
      #reset the SG     
      def init()
      end
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
    
    class Culler < EnginePart
      attr_reader :visible_lights, :visible_geometry      
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