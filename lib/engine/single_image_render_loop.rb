require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class SingleImageRenderLoop < RenderLoop
      def run_loop
        @logger.debug("SingleImageRenderLoop: beginnging run_loop")
        @engine[:frame_processor].process      
        @engine[:image_processor].raw_pixels = @engine[:frame_processor].raw_rendered_frame 
        @engine[:image_processor].save_as("#{sketch_options[:working_dir]}/#{sketch_options[:output_dir]}/#{sketch_options[:image_output_dir]}/frame1.raw")
        @logger.debug("SingleImageRenderLoop: ending run_loop")
      end
    end
  end
end