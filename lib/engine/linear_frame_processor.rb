require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    #Executes the frame in a single thread
    class LinearFrameProcessor < FrameProcessor
      attr_accessor :engine
      attr_reader :raw_rendered_frame
            
      def process
        #loop through all sketch layers
        #order should not matter until the composite step       
        self.layers do |layer|
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
  end
end