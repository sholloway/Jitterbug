module Jitterbug
  module GraphicsEngine
    class SketchController
      def initialize(sketch, options={})
        @sketch = sketch
        @engine = {:renderer => Renderer.new(@sketch.logger),
          :scene_graph => SceneGraph.new(@sketch.logger),
          :spatial_data_partition => SpatialDataPartition.new(@sketch.logger),
          :sketch_api => SketchAPI.new(@sketch.logger),
          :culler => Culler.new(@sketch.logger),
          :camera => Camera.new(@sketch.logger),
          :frustum => Frustum.new(@sketch.logger),
          :compositor => LayerCompositor.new(@sketch.logger),
          :frame_processor => FrameProcessor.new(@sketch.logger),
          :render_loop => RenderLoop.new(@sketch.logger)}
        @engine.merge!(options)
        
        # possibly validate that we've got all the nessacary components by check the ancestory of all the engine pieces?
      end
      
      #how to best abstract this loop? Perhaps tease out the concept of a "frame". Then there
      #would be a seperete concept of a frame being rendered and a loop.
      def render()
        #bind components as needed        
        @engine[:camera].frustum = @engine[:frustum]   
        
        #this is shit... 
        @engine[:frame_processor].engine = @engine
        @engine[:render_loop].engine = @engine
        
        @engine[:render_loop].run_loop(@sketch)   
      end
    end
    
    #this is what you would implement for various rendering loops
    class RenderLoop
      attr_accessor :engine
      def initialize(logger)
        @logger = logger
      end
      
      
      def run_loop(sketch) 
        #use an image library to generate RAW, TIFF, PNG, JPEG, GIF...       
      end
    end
    
    class SingleImageRenderLoop < RenderLoop
      def initialize(logger)
        super(logger)
      end
      
      def run_loop(sketch) 
        @engine[:frame_processor].process(sketch)
        pixels = @engine[:frame_processor].raw_rendered_frame
        image = Image.new(pixels)
        image.save_as(Image::RAW,"#{sketch.options[:working_dir]}/#{sketch.options[:output_dir]}/#{sketch.options[:image_output_dir]}/frame1.raw")
      end
    end
    
    
    class FrameProcessor
      attr_accessor :engine
      attr_reader :raw_rendered_frame
      def initialize(logger)
        @logger = logger
      end
      
      def process(sketch)
        #loop through all sketch layers
        #order should not matter until the composite step       
        sketch.layers do |layer|
          # api should execute the script to build the Scene Graph
          @engine[:sketch_api].bind(@engine[:scene_graph])
          @engine[:sketch_api].run(layer)          
          
          # The scene graph should build up the SDS
          @engine[:spatial_data_partition].construct(@engine[:scene_graph])
          
          
          # The Culler should leverage the SDS to determine the viewable objects and lights
          @engine[:spatial_data_partition].cull(@engine[:culler])
          
          # The renderer should render the viewable objects and generate an image for the layer
          @engine[:renderer].camera = @engine[:camera]
          @engine[:renderer].add_lights(@engine[:culler].visible_lights)
          @engine[:renderer].add_geometry(@engine[:culler].visible_geometry)          
          @engine[:renderer].render()
          
          # Store the image along with compositing filter chain at the layer compositor
          frame = @engine[:renderer].raw_rendered_frame
          @engine[:compositor].add(frame, layer) # add image filter chain to Layer class
        end
        
        # The Layer Compositor should generate a single image from the stack of images
        @engine[:compositor].composite()
        
        # Should output
        @raw_rendered_frame = @engine[:compositor].raw_rendered_frame
      end
    end
    
    class Image
      RAW = 0
      JPEG = 1
            
      def initialize(raw_pixels)
        @raw_pixels = raw_pixels
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
      
      def construct(scene_graph)
      end
      
      def cull(culler)
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
      end
    end
  end  
end