module SceneGraphHelpers
  def build_scene_graph(scene_graph)
    scene_graph.init()
  
    scene_graph.world_node()
    node_a = Jitterbug::GraphicsEngine::Node.new(scene_graph.increment_node_counter(),"Node A")
    node_b = Jitterbug::GraphicsEngine::Node.new(scene_graph.increment_node_counter(),"Node B")
    node_c = Jitterbug::GraphicsEngine::Node.new(scene_graph.increment_node_counter(),"Node C")
  
    node_d = Jitterbug::GraphicsEngine::Node.new(scene_graph.increment_node_counter(),"Node D")
    node_e = Jitterbug::GraphicsEngine::Node.new(scene_graph.increment_node_counter(),"Node E")
    node_f = Jitterbug::GraphicsEngine::LightNode.new(scene_graph.increment_node_counter(),"Node F")
  
    node_g = Jitterbug::GraphicsEngine::CameraNode.new(scene_graph.increment_node_counter(),"Node G")
    node_h = Jitterbug::GraphicsEngine::Node.new(scene_graph.increment_node_counter(),"Node H")
    node_i = Jitterbug::GraphicsEngine::GeometryNode.new(scene_graph.increment_node_counter(),"Node I")
    node_j = Jitterbug::GraphicsEngine::LightNode.new(scene_graph.increment_node_counter(),"Node J")
  
    node_k = Jitterbug::GraphicsEngine::GeometryNode.new(scene_graph.increment_node_counter(),"Node K")      

    scene_graph.world_node().add_child(node_a)
    scene_graph.world_node().add_child(node_b)
    scene_graph.world_node().add_child(node_c)
    node_a.add_child(node_d)
    node_a.add_child(node_e)

    node_b.add_child(node_f)
  
    node_d.add_child(node_g)
    node_d.add_child(node_h)
  
    node_e.add_child(node_i)
    node_e.add_child(node_j)
  
    node_h.add_child(node_k)
  end
end