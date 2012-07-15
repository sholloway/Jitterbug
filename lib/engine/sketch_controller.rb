require "engine_parts"
module Jitterbug
  module GraphicsEngine
    class SketchController
      def initialize(sketch, options={})
        @sketch = sketch
        @engine = {:renderer => Renderer.new,
          :scene_graph => SceneGraph.new,
          :spatial_data_partition => SpatialDataPartition.new,
          :sketch_api => SketchAPI.new,
          :culler => Culler.new,
          :camera => Camera.new,
          :frustum => Frustum.new,
          :compositor => LayerCompositor.new,
          :frame_processor => FrameProcessor.new,
          :render_loop => RenderLoop.new}
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