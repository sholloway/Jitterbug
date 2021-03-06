require './tests/test_prep.rb'

require 'fileutils'
require 'logger'

include Jitterbug::Sketch::Validation
include Jitterbug::Sketch

describe Jitterbug::Sketch::Controller do
	before(:all) do 
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::DEBUG
		@logger.datetime_format = "%H:%M:%S" 
		
		@engine = Jitterbug::GraphicsEngine::Engine.new()

	    @engine[:image_processor] = Jitterbug::NullGraphicsEngine::NullImage.new
	    @engine[:renderer] = Jitterbug::NullGraphicsEngine::NullRenderer.new
	    @engine[:scene_graph] = Jitterbug::GraphicsEngine::SceneGraph.new
	    @engine[:spatial_data_partition] = Jitterbug::NullGraphicsEngine::NullSpatialPartition.new
	    @engine[:sketch_api] = Jitterbug::GraphicsEngine::SketchAPI.new
	    @engine[:culler] = Jitterbug::GraphicsEngine::Culler.new
	    @engine[:camera] = Jitterbug::GraphicsEngine::Camera.new
	    @engine[:frustum] = Jitterbug::GraphicsEngine::Frustum.new
	    @engine[:compositor] = Jitterbug::NullGraphicsEngine::NullLayerCompositor.new
	    @engine[:frame_processor] = Jitterbug::GraphicsEngine::LinearFrameProcessor.new
	    @engine[:render_loop] = Jitterbug::GraphicsEngine::SingleImageRenderLoop.new
	end
	
	describe "validation" do
		before(:each) do			
			@test_dir = File.expand_path(File.dirname(__FILE__))
			@full_dir = File.join(@test_dir,"validation_sketch")
			FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir	
			@sketch_name = "validation_sketch"
			
			cmd = Jitterbug::Command::CreateGLSLImageSketch.new({:sketch_dir => @test_dir, 
			:cmd_line_args => [@sketch_name], 
			:output_dir => "output"})
    	cmd.process
		end
		
		after(:each) do
			FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir		
		end		
		
		it "should error if a working dir is not specified" do
			expect{Controller.new(@engine,{:logger=>@logger})}.to raise_error "The working directory for the sketch must be set."
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to_not raise_error				
		end	
		
		it "should error if sketch.yml doesn't exist" do					
			FileUtils.rm("#{@full_dir}/sketch.yml")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The sketch.yml file could not be found in #{@full_dir}"
		end
		
		it "should error if script directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/scripts")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The script directory could not be found in #{@full_dir}"
		end
		
		it "should error if the support scripts directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/lib")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The support scripts directory could not be found in #{@full_dir}"
		end
		
		it "should error if the vendor directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/vendor")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The vendor directory could not be found in #{@full_dir}"
		end
		
		it "should error if the resources directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The resources directory could not be found in #{@full_dir}"
		end
		
		it "should error if the shaders directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources/shaders")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The shaders directory could not be found in #{@full_dir}/resources"
		end
		
		it "should error if the models directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources/models")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The models directory could not be found in #{@full_dir}/resources"
		end
		
		it "should error if the images directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources/images")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The images directory could not be found in #{@full_dir}/resources"
		end
		
		it "should error if the movies directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources/movies")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The movies directory could not be found in #{@full_dir}/resources"
		end
		
		it "should error if the image filters directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources/filters")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The image filters directory could not be found in #{@full_dir}/resources"
		end
		
		it "should error if the audio directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/resources/audio")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The audio directory could not be found in #{@full_dir}/resources"
		end
		
		it "should error if the output directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/output")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The output directory could not be found in #{@full_dir}"
		end
		
		it "should error if the image output directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/output/images")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The images output directory could not be found in #{@full_dir}/output"
		end
		
		it "should error if the video output directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/output/video")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The video output directory could not be found in #{@full_dir}/output"
		end
		
		it "should error if the data output directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/output/data")
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The data output directory could not be found in #{@full_dir}/output"
		end
		
		it "should error it the trash directory doesn't exist" do
			FileUtils.remove_dir("#{@full_dir}/trash")	
			expect{Controller.new(@engine,{:working_dir => @full_dir,:logger=>@logger})}.to raise_error "The trash directory could not be found in #{@full_dir}"
		end		
	end	
end