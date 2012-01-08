require 'renderer/osx/sketch2d'
require 'renderer/osx/sketch_context'

#need a way to document all of the symbols that the context will accept.
# :background_color for example or :background

describe "2D Rendering API Definitions" do 
  before(:each) do        
    @context = Jitterbug::Sketch::Context.new
    @sketch_layer = Jitterbug::Sketch::Layer2d.new
    @sketch_layer.setContext @context
  end
    
  describe "Shape Functions" do
    it "should have a circle(x,y,r) method" 
    it "should have a rect(x,y,width,height) method"
    it "should have a rect_mode(mode) method"
    it "should have a ellipse() method"
  end
  
  describe "State Functions" do
    it 'should have a context method' do
      @sketch_layer.should respond_to(:context)
    end
    
    it "should have a background(color) method" do 
      @sketch_layer.should respond_to(:background).with(1).argument  
    end
    
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

=begin
  I can initialize GraphicsScript directly.
  I can initialize NSArray.
  I can initialize MyGraphicsScript in a non-spec script.
  
  I cannot initialize MyGraphicsScript in a spec.
=end
