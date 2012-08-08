require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class SingleImageRenderLoop < RenderLoop
      def run_loop
        @logger.debug("SingleImageRenderLoop: beginnging run_loop")
        @engine[:frame_processor].process      
        @engine[:image_processor].raw_pixels = @engine[:frame_processor].raw_rendered_frame 
        root_dir = File.expand_path("#{sketch_options[:working_dir]}")
        @engine[:image_processor].path = "#{root_dir}/#{sketch_options[:output_dir]}/#{sketch_options[:image_output_dir]}"
        @engine[:image_processor].name = "frame1" #need to make this driven by the sketch...
        @engine[:image_processor].save_to_disk
        @logger.debug("SingleImageRenderLoop: ending run_loop")
      end
    end
  end
end