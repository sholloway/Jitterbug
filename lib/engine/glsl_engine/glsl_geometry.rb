require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class GLSLGeometry < Jitterbug::GraphicsEngine::Geometry
      attr_reader :program, :verticies, :render_state
      
      def initialize(program, verticies)
        @program = program
        @vertices = verticies
      end
      
      def render_state=(rs)
        @render_state = rs.clone
        @render_state.freeze
      end
    end
  end
end  