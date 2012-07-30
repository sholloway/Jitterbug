Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe "Image Generation with GLSL" do
  before (:each) do
    @test_dir = File.expand_path(File.dirname(__FILE__))
		@full_dir = File.join(@test_dir,"test_sketch")
		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir	
		@sketch_name = "test_sketch"		
    cmd = Jitterbug::Command::CreateGLSLImageSketch.new({:sketch_dir => @test_dir, :cmd_line_args => [@sketch_name], :output_dir => "output"})
    cmd.process
    
    @sketch = Jitterbug::Layers::Sketch.new(nil,{:working_dir => @full_dir,:logger => @logger})
    @sketch.load
  end 
  
  after(:each) do		
		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir		
	end
  
  it "should render rectangles" do
    @sketch.engine[:render_loop].default_frame_output_name = "rectangle_sample"
    @sketch.width = 400
    @sketch.height = 500
    @sketch.background(:white) 
    foreground = @sketch.select('Foreground') #should be empty
    
    #This is a real problem, since this is pointing to the script path.
    #could make script a domain object. struct(:path,:contents)
    #need a way to load the text into memory and be able to easily set the contents programatically for testing.
    foreground.script.content = %{   
      fill(:red)
      stroke(:black)
      stroke_weight(3)
      rect_mode(CORNER)    
      rect(80,90,100,200)  
    }
    @sketch.save #need to change to recursively call save() on all the scripts. Take into account the script.contents being nil and not overwriting.
    @sketch.render
    expected_image = File.join(@full_dir,'expected_images/rects.png')
    recieved_image = File.join(@full_dir,"outputs/image/#{@sketch.engine[:render_loop].default_frame_output_name}.png")
    
    %x{idiff #{expected_image} #{recieved_image}}
    $?.exitstatus.should == 0
  end
end