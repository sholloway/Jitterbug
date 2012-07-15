require 'command'
require 'create_sketch_helper'

module Jitterbug
  module Command
   class CreateSketch < Base
     include Jitterbug::Sketch
     def process
      sketch_name = ARGV.first
      sketch_dir = @options[:sketch_dir]       
      create_sketch(sketch_name, sketch_dir)
       
      #should I have Engine classes that wrap the core engines or have files...
      
      engine = Jitterbug::GraphicsEngine::Engine.new()

      engine[:image_processor] = Jitterbug::NullGraphicsEngine::NullImage.new
      engine[:renderer] = Jitterbug::NullGraphicsEngine::NullRenderer.new
      engine[:scene_graph] = Jitterbug::GraphicsEngine::SceneGraph.new
      engine[:spatial_data_partition] = Jitterbug::NullGraphicsEngine::NullSpatialDataPartition.new
      engine[:sketch_api] = Jitterbug::GraphicsEngine::SketchAPI.new
      engine[:culler] = Jitterbug::GraphicsEngine::Culler.new
      engine[:camera] = Jitterbug::GraphicsEngine::Camera.new
      engine[:frustum] = Jitterbug::GraphicsEngine::Frustum.new
      engine[:compositor] = Jitterbug::NullGraphicsEngine::NullLayerCompositor.new
      engine[:frame_processor] = Jitterbug::GraphicsEngine::LinearFrameProcessor.new
      engine[:render_loop] = Jitterbug::GraphicsEngine::SingleImageRenderLoop.new                      

      puts "ok - newing up engine"
 		  lm = Jitterbug::Layers::Sketch.new(engine,{:working_dir => "#{sketch_dir}/#{sketch_name}", 
 			  :output_dir => @options[:output_dir],
 			  :env => @options[:environment]}).
 			  create_new_layer("Background").
 			  create_new_layer("Foreground").				
        save
        lm.logger.close
        return CommandResponse.new("created sketch: #{sketch_dir}/#{sketch_name}")
     end
   end 
  end
end