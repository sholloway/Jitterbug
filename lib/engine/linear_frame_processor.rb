require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    #Executes the frame in a single thread
    class LinearFrameProcessor < FrameProcessor
      attr_accessor :engine
      attr_reader :raw_rendered_frame
            
      def process
        @logger.debug("LinearFrameProcessor: beginning process")
        #loop through all sketch layers
        #order should not matter until the composite step   
        @logger.debug("LinearFrameProcessor: layers are #{self.layers}")    
        self.layers.each do |layer|
          @logger.debug("LinearFrameProcessor: process layer #{layer.name}")
          # api should execute the script to build the Scene Graph

          #Reset the scene graph. Create another FrameProcessor if other behavior is needed.
          @engine[:scene_graph].init() 
          
          #generate the scene
          @engine[:sketch_api].bind(@engine[:scene_graph])
          @engine[:sketch_api].run(layer)          
          
          if @logger.debug?
            #travers the graph and find # of lights, cameras and geometry and any other stats I can think of.
            stats = @engine[:scene_graph].collect_stats
            @logger.debug("LinearFrameProcessor: SceneGraph now contains:")
            @logger.debug("LinearFrameProcessor: #{stats.total_node_count} nodes")
            @logger.debug("LinearFrameProcessor: #{stats.transformation_node_count} transformation nodes")
            @logger.debug("LinearFrameProcessor: #{stats.light_node_count} light nodes")
            @logger.debug("LinearFrameProcessor: #{stats.camera_node_count} camera nodes")
            @logger.debug("LinearFrameProcessor: #{stats.geometry_node_count} geometry nodes")
          end
          
          #partition the scene
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
        @logger.debug("LinearFrameProcessor: ending process")
      end
    end
  end
end