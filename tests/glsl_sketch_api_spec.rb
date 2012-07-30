Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe Jitterbug::GraphicsEngine::GLSLSketchAPI do
  describe "The API" do 
    before(:each) do 
      @api = Jitterbug::GraphicsEngine::GLSLSketchAPI.new
    end
    
    describe "Shape Functions" do
      it "should have a circle(x,y,r) method" 
      it "should have a rect(x,y,width,height) method" do
        @api.respond_to?(:rect).should == true
      end
    
      it "should have a rect_mode(mode) method"
      it "should have an ellipse() method"
    end
  
    describe "State Functions" do    
      #do I really need/want this?
      #does a layer have a background or does a sketch have a background?
      it "should have a background(color) method"    
      it "should have a fill(color) method"  
      it "should have a fill(material) method"  
      it "should have a fill(texture) method"  
      it "should have a stroke(color) method"  
      it "should have a program(name) method" 
      it "should have a show_direction method" 
      it "should have a font(font_type)method"
    end
  
    describe "Asset Management Functions" do 
      it "should have a load(model_name) method"  
      it "should have a load(texture_name) method"  
      it "should have a load(shader_name) method"
    end
  
    describe "Text functions" do
      it "should have a text(msg, x,y) method"  
    end
  
    describe "Color functions" do    
    end
  
    describe "Math functions" do 
      it "should have a perlin(seed) method"  
    end
  end

  describe "Functionality" do
    before(:each) do
      @test_dir = File.expand_path(File.dirname(__FILE__))
  		@full_dir = File.join(@test_dir,"test_sketch")
  		FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir	
  		@sketch_name = "test_sketch"		
      cmd = Jitterbug::Command::CreateGLSLImageSketch.new({:sketch_dir => @test_dir, :cmd_line_args => [@sketch_name], :output_dir => "output"})
      cmd.process
      
      @sketch = Sketch.new(nil,{:working_dir => @full_dir,:logger => @logger})
      @sketch.load
    end
    
    after(:each) do
      FileUtils.remove_dir(@full_dir,force=true) if File.directory? @full_dir		
    end
    
    describe "rect(x,y,width,height)" do
      describe "rectangle mode = " do
        it "should renderer a rectangle" do
          @sketch.engine[:render_loop].default_frame_output_name = "frame1"
          foreground = @sketch.select('Foreground')
          foreground.script.content = "rect(10,10,100,100)"
          @sketch.render
          File.exists?(File.join(@full_dir,"outputs","images","frame1.png")).should == true
        end
      end
    end
  end
end