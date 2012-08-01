Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

require './tests/scene_graph_helper'

RSpec.configure do |rs|
  rs.include SceneGraphHelpers
end

describe Jitterbug::GraphicsEngine::SceneGraph do
  describe "Statistic Collection" do
    
=begin
Build up a graph like this:
World
  Node (A)
    Node (D)
      CameraNode (G)
        Camera
      Node (H)
        GeometryNode (K) 
          Geometry
    Node (E)
      GeometryNode (I) 
        Geometry
      LightNode (J)
        Light
  Node (B)
    LightNode (F)
      Light
  Node (C)

  
Stats should be: (Count World node in Nodes Total & Group Nodes)
Nodes Total: 12 
Group Nodes: 7
Camera Nodes: 1
Light Nodes: 2
Geometry Nodes: 2
=end    
    before(:all) do
      @logger = Logger.new(STDOUT)
  		@logger.level = Logger::ERROR
  		@logger.datetime_format = "%H:%M:%S"
  		  		
      @scene_graph = Jitterbug::GraphicsEngine::SceneGraph.new
      @scene_graph.logger = @logger
      @scene_graph.init()
      
      build_scene_graph(@scene_graph)
    
      @stats = @scene_graph.collect_stats()
    end    
    
    it "should count the number of nodes total in the sketch" do
      @stats.total_node_count.should == 12
    end
    
    it "should count the number of transformation nodes in a sketch" do
      @stats.transformation_node_count.should == 7
    end
    
    it "should count the number of lights in a sketch" do
      @stats.light_node_count.should == 2
    end
    
    it "should count the number of cameras in a sketch" do
      @stats.camera_node_count.should == 1
    end
    
    it "should count the number of geometry nodes in a sketch" do
      @stats.geometry_node_count.should == 2
    end
  end
end