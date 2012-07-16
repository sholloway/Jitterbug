require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class SingleImageRenderLoop < RenderLoop
      def run_loop
        @engine[:frame_processor].process      
        @engine[:image_processor].raw_pixels = @engine[:frame_processor].raw_rendered_frame 
        @engine[:image_processor].save_as(Image::RAW,"#{sketch_options[:working_dir]}/#{sketch_options[:output_dir]}/#{sketch_options[:image_output_dir]}/frame1.raw")
      end
    end
  end
end