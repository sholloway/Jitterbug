module Jitterbug
  module GraphicsEngine
    @@rect_counter = 0
        
    ShaderParameter = Struct.new(:parameter_type, :parameter_name)
    class GLSLShaderProgram
      attr_reader :vertex_shader_path,:fragment_shader_path, :program_parameters
      
      def initialize(vertex_shader_path, fragment_shader_path,program_parameters=[])
        @vertex_shader_path = vertex_shader_path
        @fragment_shader_path = fragment_shader_path     
        @program_parameters = program_parameters   
      end
      
      def add_uniform(name)
        @program_parameters << ShaderParameter.new(:attribute, name)
        return self
      end
      
      def add_attribute(name)
        @program_parameters << ShaderParameter.new(:uniform, name)
        return self
      end
    end
    
    module ColorModes
      RGB = 0
      HSB = 1
    end
    
    module RectangleModes
      CORNER = 0 # upper left corner and width, height
    end
    
    class RenderState      
      attr_accessor :current_fill_color, :current_stroke_color, :rect_mode, :color_mode
      
      def initialize
        @enable_stroking = true
        @enable_fill = true
        @color_mode = ColorModes::RGB
        @rect_mode = RectangleModes::CORNER
        #got to figure out colors...
      end      
      
      def stroke?
        @enable_stroking
      end
      
      def fill?
        @enable_fill
      end
    end
        
    #let's shoot for not having any knowledge of OpenGL outside of the renderer
    class GLSLSketchAPI < SketchAPI
      
      def initialize()
        super
        @rect_counter = 0
        @render_state = RenderState.new
      end
      
      # Draw a rectangle
      # Ignore rect_mode until entire pipe line is functioning
      def rect(x,y,width,height)
        @logger.debug("GLSLSketchAPI: rect() was called")
        #build a program
        vert_shader = "shaders/glsl/rect2d.vert"
        fragment_shader = "shaders/glsl/rgba_solid_color.frag"
        
        program = GLSLShaderProgram.new(vert_shader, fragment_shader).
          add_attribute(:a_position).
          add_attribute(:a_vertex_color). 
          add_uniform(:u_resolution).
          add_uniform(:v_color)          
        
        #generate rectangle (CORNER_MODE)

        x1 = x;
        x2 = x + width;
        y1 = y;
        y2 = y + height;

        vertices = [
          x1, y1,
          x2, y1,
          x1, y2,
          x1, y2,
          x2, y1,
          x2, y2]

        #manipulate the scene graph
        geo_node = Jitterbug::GraphicsEngine::GeometryNode.new(@scene_graph.increment_node_counter(), "rectangle #{incr_rect_counter}")        
        geometry = Jitterbug::GraphicsEngine::GLSLGeometry.new(program, vertices)
  
        geometry.render_state = @render_state        
        geo_node.bind(geometry)

        #need to think through groups controlled by the script. Maybe a begin/end or block
        @scene_graph.world_node().add_child(geo_node)        
      end
      
      private
      def incr_rect_counter()
        @rect_counter += 1
        return @rect_counter
      end
    end
  end
end