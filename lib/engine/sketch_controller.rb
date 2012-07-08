require "engine_parts"
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
  end  
end