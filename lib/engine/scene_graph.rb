module Jitterbug
  module GraphicsEngine          
          SceneGraphStats = Struct.new(:total_node_count, :transformation_node_count, :light_node_count, :camera_node_count, :geometry_node_count)  
          
=begin
    A recursive traversal is used to calculate transformations. The return path is used to calculate the world bounds
=end
        class SceneGraph < EnginePart   
          attr_reader :node_counter

          WORLD_NAME = "Midgard"

          def initialize()
            super
            @node_counter = 0
          end

          #reset the SG     
          def init()
            @logger.debug("SceneGraph: init was called")
            @node_counter = 0
            @world = Node.new(increment_node_counter(), WORLD_NAME)  #need to set the location to 0,0,0 I think. 
          end

          def world_node()
            return @world
          end

          #Find the first node with the node id or node name matching node_locator
          def find(node_locator)
            # if node_locator is a number search by id, otherwise search by name
          end

          def increment_node_counter()
            @node_counter += 1
            return @node_counter
          end

          def collect_stats
            @logger.debug("SceneGraph: Beginning collect stats")
            # I want a visitor pattern implementation of a breadth first traversal that takes a block
            # Implement naive way, then refactor into visitor
            # Don't use recursion
            stats = SceneGraphStats.new(0,0,0,0,0)
            return stats if (world_node().nil?)

            breadth_first_traversal([world_node()], lambda {|current_node| stat_collector(current_node, stats);})
            return stats
          end
          
          # Breadth first tree traversal of the scene graph. Executes the lambda "visitor" for every node.
          # Usage Example:
          # breadth_first_traversal([world_node()], lambda {|current_node| stat_collector(current_node, stats);})
          def breadth_first_traversal(stack, visitor)
            @logger.debug("SceneGraph: Beginning breadth_first_traversal")
            while (!stack.empty?) 
              current_node = stack.shift
              visitor.call(current_node) 
              unless current_node.children.nil?
                current_node.children.each{|child| stack.push(child)}
              end
            end
            @logger.debug("SceneGraph: Ending breadth_first_traversal")
          end

          private
          def stat_collector(node, stats)
            @logger.debug("SceneGraph: Beginning stat_collector")
            return if node.nil?

            stats.total_node_count +=1 

            case node.class.to_s
            when "Jitterbug::GraphicsEngine::Node" then stats.transformation_node_count += 1
            when "Jitterbug::GraphicsEngine::LightNode" then stats.light_node_count += 1
            when "Jitterbug::GraphicsEngine::CameraNode" then stats.camera_node_count += 1
            when "Jitterbug::GraphicsEngine::GeometryNode" then stats.geometry_node_count +=1
            else 
              @logger.error("SceneGraph: stat_collector() - A node of unknown type was added to the scene graph. It was type #{node.class}")
            end
            @logger.debug("SceneGraph: Ending stat_collector")
          end
        end
    
  end
end