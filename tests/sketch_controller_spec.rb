Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

require 'fileutils'
require 'logger'

include Jitterbug::Layers
include Jitterbug::Sketch

describe Jitterbug::GraphicsEngine::SketchController do
  before(:all) do 
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::DEBUG
		@logger.datetime_format = "%H:%M:%S" 
	end
	
	before(:each) do
			@test_dir = File.expand_path(File.dirname(__FILE__))
			@full_dir = File.join(@test_dir,"validation_sketch")
			FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir	
			@sketch_name = "validation_sketch"
			create_sketch(@sketch_name, @test_dir)	
			@sketch = Sketch.new(:working_dir => @full_dir,:logger=>@logger)	
			@sketch.create_new_layer("Background").create_new_layer("Foreground")		
		end
		
	after(:each) do		
		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir		
	end
	
  it "should do some shit" do    
    sm = Jitterbug::GraphicsEngine::SketchController.new(@sketch)
    sm.render()
  end
  
  it "should render a single image" do
    sm = Jitterbug::GraphicsEngine::SketchController.new(@sketch, {:render_loop => Jitterbug::GraphicsEngine::SingleImageRenderLoop.new(@logger)})
    sm.render()
    
    #assert that the image frame1.raw was created
    File.exists?("#{@full_dir}/output/images/frame1.raw").should == true
  end
end