require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class SingleImageRenderLoop < RenderLoop
      def initialize(logger)
        super(logger)
      end
      
      def run_loop(sketch) 
        @engine[:frame_processor].process(sketch)        
        @engine[:image_processor].raw_pixels = @engine[:frame_processor].raw_rendered_frame 
        @engine[:image_processor].save_as(Image::RAW,"#{sketch.options[:working_dir]}/#{sketch.options[:output_dir]}/#{sketch.options[:image_output_dir]}/frame1.raw")
      end
    end
  end
end