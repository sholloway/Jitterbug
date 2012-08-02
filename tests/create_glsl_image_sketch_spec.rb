Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe Jitterbug::Command::CreateGLSLImageSketch do
  #The problem is that the directory being created doesn't match what is expected. 
  #ARGV should not be used by the base class.
  before (:each) do
    @test_dir = File.expand_path(File.dirname(__FILE__))
		@full_dir = File.join(@test_dir,"test_sketch")
		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir	
		@sketch_name = "test_sketch"		
    cmd = Jitterbug::Command::CreateGLSLImageSketch.new({:sketch_dir => @test_dir, :cmd_line_args => [@sketch_name], :output_dir => "output"})
    cmd.process
    
    @sketch = Controller.new(nil,{:working_dir => @full_dir,:logger => @logger})
    @sketch.load
  end 
  
  after(:each) do		
		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir		
	end
  
  it "should build the engine with PNGImage part" do    
    @sketch.engine[:image_processor].instance_of?(Jitterbug::GraphicsEngine::PNGImage).should == true 
  end
  
  it "should build the engine with GLSLRenderer" do
    @sketch.engine[:renderer].instance_of?(Jitterbug::GraphicsEngine::GLSLRenderer).should == true
  end
  
  it "should build the engine with GLSLSketchAPI" do
    @sketch.engine[:sketch_api].instance_of?(Jitterbug::GraphicsEngine::GLSLSketchAPI).should == true
  end
  
  it "should build the engine with LinearFrameProcessor" do
    @sketch.engine[:frame_processor].instance_of?(Jitterbug::GraphicsEngine::LinearFrameProcessor).should == true
  end
  
  it "should build the engine with SingleImageRenderLoop" do      
    @sketch.engine[:render_loop].instance_of?(Jitterbug::GraphicsEngine::SingleImageRenderLoop).should == true
  end  
  
  it "should build the engine with the CoreImageLayerCompositor" do 
    @sketch.engine[:compositor].instance_of?(Jitterbug::GraphicsEngine::CoreImageLayerCompositor).should == true
  end
end