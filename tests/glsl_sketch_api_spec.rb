framework 'Foundation'
framework 'Cocoa'
framework 'AppKit'
framework 'OpenGL'

#require File.join(File.expand_path(File.dirname(__FILE__)),"..","macos_jitterbug")


Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe Jitterbug::GraphicsEngine::GLSLSketchAPI, :focus=>true do
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
      it "should have a fill(color) method" do
        @api.respond_to?(:fill).should == true
      end  
      it "should have a fill(material) method"  
      it "should have a fill(texture) method"  
      
      it "should have a no_fill method" do
        @api.respond_to?(:no_fill).should == true
      end
      
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
      it "should have a color method" do
        @api.respond_to?(:color).should == true
      end   
    end
  
    describe "Math functions" do 
      it "should have a perlin(seed) method"  
    end
  end

  describe "Functionality" do
    before(:each) do
      @logger = Logger.new(STDOUT)
  		@logger.level = Logger::DEBUG
  		@logger.datetime_format = "%H:%M:%S"
  		  		
      @sketch_api = Jitterbug::GraphicsEngine::GLSLSketchAPI.new
      @scene_graph = Jitterbug::GraphicsEngine::SceneGraph.new
      
      #manually bind together
      width, height = 400, 300
      @sketch_api.width = width
      @sketch_api.height = height
      @sketch_api.logger = @logger
      @scene_graph.width = width
      @scene_graph.height = height
      @scene_graph.logger = @logger
      @sketch_api.bind(@scene_graph)      
    end
    
    after(:each) do
      
    end
    
    describe "rect(x,y,width,height)" do
      describe "rectangle mode = CORNER" do
        it "should renderer a rectangle"
                #@scene_graph.world_node.children.count.should == 1
      end
    end
    
    describe "fill" do
      it "should set the render state current fill color" do 
        script = mock(:content => 'fill(color(0,10,20,255))', :load=>nil)
        layer = mock(:script=>script, :name=>'test layer')

        @sketch_api.run(layer)

        color = @sketch_api.render_state.current_fill_color
        color.red.should == 0
        color.green.should == 10
        color.blue.should == 20
        color.alpha.should == 255
        color.instance_of?(Jitterbug::GraphicsEngine::Color::RGB).should == true
      end
      
      it "should raise an exception if the color is nil"  do
        script = mock(:content => 'fill(nil)', :load=>nil)
        layer = mock(:script=>script, :name=>'test layer')

        expect{@sketch_api.run(layer)}.to raise_error       
      end
      
      it "should raise an exception if the color is not descended from the color base class", :focus=>true do
        broken_script = %{
          class BadColor
          end
          
          fill(BadColor.new)
        }
        script = mock(:content => broken_script, :load=>nil)
        layer = mock(:script=>script, :name=>'test layer')

        expect{@sketch_api.run(layer)}.to raise_error
        
        correct_script = %{
          class GoodColor < Jitterbug::GraphicsEngine::Color::Base
          end
          
          fill(GoodColor.new)
        }
        script = mock(:content => correct_script, :load=>nil)
        layer = mock(:script=>script, :name=>'test layer')

        expect{@sketch_api.run(layer)}.to_not raise_error
      end
    end
    
    describe "color" do
      describe "rgb" do
        it "should handle color names"
        it "should handle ranges of 0 to 1"
        it "should handle ranges of 0 to 255"
        it "should not allow mixing of ranges"      
      end
    end
  end
end