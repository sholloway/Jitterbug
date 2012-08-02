Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

require './tests/scene_graph_helper'

RSpec.configure do |rs|
  rs.include SceneGraphHelpers
end

describe Jitterbug::NullGraphicsEngine::NullSpatialPartition do
  describe "cull" do 
    before(:each) do
      @logger = Logger.new(STDOUT)
  		@logger.level = Logger::ERROR
  		@logger.datetime_format = "%H:%M:%S"
  		  		
      @scene_graph = Jitterbug::GraphicsEngine::SceneGraph.new
      @scene_graph.logger = @logger
      @scene_graph.init()
      
      build_scene_graph(@scene_graph)
      
      @sp = Jitterbug::NullGraphicsEngine::NullSpatialPartition.new
      @sp.logger = @logger
      @sp.construct(@scene_graph)      
      
      @culler = Jitterbug::GraphicsEngine::Culler.new
      @culler.logger = @logger
      @sp.cull(@culler)
    end
    
    it "should include all geometry" do
      @culler.visible_geometry.count.should == 2
    end
    
    it "should include all lights" do 
      @culler.visible_lights.count.should == 2
    end
    
    it "should include all cameras" do 
      @culler.active_cameras.count.should == 1
    end
  end
end