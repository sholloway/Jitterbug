Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe Jitterbug::GraphicsEngine::Engine do
  it "should initialize empty" do
    engine = Jitterbug::GraphicsEngine::Engine.new
    engine.size.should == 0
  end
  
  describe "assembled?" do
    it "should return true when all the pieces have been added" do
      engine = Jitterbug::GraphicsEngine::Engine.new
      engine.assembled?.should_not == true
      
      pieces = Jitterbug::GraphicsEngine::Engine::Pieces
       
      pieces[0,pieces.size - 1].each do |piece|      
        engine[piece] = Jitterbug::GraphicsEngine::Engine::EngineMap[piece].new
        engine.assembled?.should_not == true
      end      
      
      engine[pieces.last] = Jitterbug::GraphicsEngine::Engine::EngineMap[pieces.last].new
      engine.assembled?.should == true
    end    
  end
  
  describe "validation" do
    it "should not allow engine pieces to be set to nil" do
      expect{Jitterbug::GraphicsEngine::Engine::Pieces.each{|piece| engine[piece] = nil} }.to raise_error
    end
    
    it "should validate all pieces" do
      engine = Jitterbug::GraphicsEngine::Engine.new
      expect{Jitterbug::GraphicsEngine::Engine::Pieces.each{|piece| engine[piece] = Jitterbug::GraphicsEngine::Engine::EngineMap[piece].new} }.to_not raise_error
    end
    
    it "should throw an exception on invalid key" do
      engine = Jitterbug::GraphicsEngine::Engine.new
      expect{engine[:bad_piece] = "not nil"}.to raise_error
    end    
    
    it "should only accept symbols as keys" do
      engine = Jitterbug::GraphicsEngine::Engine.new
      expect{engine[Jitterbug::GraphicsEngine::Engine::Pieces.first.to_s] = Jitterbug::GraphicsEngine::Engine::EngineMap[Jitterbug::GraphicsEngine::Engine::Pieces.first].new}.to raise_error
    end
    
    class BadPart
    end
    
    class GoodPart < Jitterbug::GraphicsEngine::Renderer
    end
    it "should not allow an engine piece to be set that doesn't descend" do
      engine = Jitterbug::GraphicsEngine::Engine.new
      expect{engine[:renderer] = GoodPart.new}.to_not raise_error
      expect{engine[:renderer] = BadPart.new}.to raise_error
    end
  end
end