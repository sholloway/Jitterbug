require 'command'
require 'easy_dir'

module Jitterbug
  module Command
    class CreateSketch < Base
      include EasyDir
      @@dirs = {
        :sketch => { 
         :sketch => :yml,
         :scripts  => {
          :setup => :rb,
          :clean_up => :rb					
          },
          :lib => :dir,			
          :vendor => :dir,	
          :resources => {	
            :shaders => :dir,
            :models => :dir,
            :images => :dir,
            :movies => :dir,
            :filters => :dir,
            :audio => :dir,
            },
            :output	=> {
              :images => :dir,
              :video => :dir,
              :data => :dir
              },
              :trash => :dir,
              :logs => :dir
            }
          }


      def process
        sketch_name = @options[:cmd_line_args].first 
        sketch_dir = @options[:sketch_dir]       
        create_sketch(sketch_name, sketch_dir)  
        copy_resources(sketch_name, sketch_dir)          
        engine = build_engine()
        lm = Jitterbug::Sketch::Controller.new(engine,{:working_dir => "#{sketch_dir}/#{sketch_name}", 
          :output_dir => @options[:output_dir],
          :env => @options[:environment]}).
        create_new_layer("Background").
        create_new_layer("Foreground").				
        save
        lm.logger.close
        return CommandResponse.new("created sketch: #{sketch_dir}/#{sketch_name}")
      end

      protected
      def create_sketch(name, dir)						
        if File.directory?("#{dir}/#{name}")	 				
          raise StandardError.new("The directory #{dir}/#{name} already exists.")
        end
        temp = @@dirs.clone
        sketch_dir = temp.delete(:sketch)
        temp[name] = sketch_dir			
        create_dirs(temp, dir)	
      end

      def build_engine
        engine = Jitterbug::GraphicsEngine::Engine.new()

        engine[:image_processor] = Jitterbug::NullGraphicsEngine::NullImage.new
        engine[:renderer] = Jitterbug::NullGraphicsEngine::NullRenderer.new
        engine[:scene_graph] = Jitterbug::GraphicsEngine::SceneGraph.new
        engine[:spatial_data_partition] = Jitterbug::NullGraphicsEngine::NullSpatialPartition.new
        engine[:sketch_api] = Jitterbug::GraphicsEngine::SketchAPI.new
        engine[:culler] = Jitterbug::GraphicsEngine::Culler.new
        engine[:camera] = Jitterbug::GraphicsEngine::Camera.new
        engine[:frustum] = Jitterbug::GraphicsEngine::Frustum.new
        engine[:compositor] = Jitterbug::NullGraphicsEngine::NullLayerCompositor.new
        engine[:frame_processor] = Jitterbug::GraphicsEngine::LinearFrameProcessor.new
        engine[:render_loop] = Jitterbug::GraphicsEngine::SingleImageRenderLoop.new                      
        return engine
      end

      def copy_resources(sketch_name, sketch_dir) 
      end
    end 

    class CreateGLSLImageSketch < CreateSketch
      protected
      def build_engine
        engine = Jitterbug::GraphicsEngine::Engine.new()

        engine[:image_processor] = Jitterbug::GraphicsEngine::PNGImage.new
        engine[:renderer] = Jitterbug::GraphicsEngine::GLSLRenderer.new
        engine[:scene_graph] = Jitterbug::GraphicsEngine::SceneGraph.new
        engine[:spatial_data_partition] = Jitterbug::NullGraphicsEngine::NullSpatialPartition.new
        engine[:sketch_api] = Jitterbug::GraphicsEngine::GLSLSketchAPI.new
        engine[:culler] = Jitterbug::GraphicsEngine::Culler.new
        engine[:camera] = Jitterbug::GraphicsEngine::Camera.new
        engine[:frustum] = Jitterbug::GraphicsEngine::Frustum.new
        engine[:compositor] = Jitterbug::GraphicsEngine::CoreImageLayerCompositor.new
        engine[:frame_processor] = Jitterbug::GraphicsEngine::LinearFrameProcessor.new
        engine[:render_loop] = Jitterbug::GraphicsEngine::SingleImageRenderLoop.new                      
        return engine
      end   

      def copy_resources(sketch_name, sketch_dir)  
        copy_shaders(sketch_name, sketch_dir)  
      end  

      def copy_shaders(sketch_name, sketch_dir) 
        #2 scenarios
        #I'm in a UT
        
        #I'm running the app        
        dest_path = "#{sketch_dir}/#{sketch_name}"
        full_dest_path = File.expand_path(dest_path)        
        resources_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation  
        Dir["#{resources_path}/shaders/glsl/**/*.*"].each{|file| FileUtils.cp file, "#{full_dest_path}/resources/shaders/#{File.basename(file)}", :verbose => true; puts "Trying to cp #{file}"}                 
      end
    end
  end
end