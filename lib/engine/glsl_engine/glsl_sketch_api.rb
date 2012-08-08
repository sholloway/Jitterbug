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
        
    module RectangleModes
      CORNER = 0 # upper left corner and width, height
    end
    
    module Color
      module ColorModes
        RGB = 0
        HSB = 1
        CYMK = 2
      end
      
      #don't know what I want to do yet... RGB could be the base...
      class Base   
        #have a method here that makes sense to the scene graph?     
      end
      
      class RGB < Base
        attr_accessor :red, :green, :blue, :alpha
        def initialize(red, green, blue,alpha)
          super 
          @red = red
          @green = green
          @blue = blue
          @alpha = alpha         
        end
      end
    end
    
    class RenderState      
      attr_accessor :current_fill_color, :current_stroke_color, :rect_mode, :color_mode, :enable_stroking, :enable_fill
      
      def initialize
        @enable_stroking = true
        @enable_fill = true
        @color_mode = Color::ColorModes::RGB
        @rect_mode = RectangleModes::CORNER
      end      
      
      def stroke?
        @enable_stroking
      end
      
      def fill?
        @enable_fill
      end
    end
            
    # Let's shoot for not having any knowledge of OpenGL outside of the renderer
    # Consider spliting functionality into modules and include them here.
    # Would be nice to have the equivalent of a header file for the API
    class GLSLSketchAPI < SketchAPI
      attr_reader :render_state
      def initialize()
        super
        @rect_counter = 0
        @render_state = RenderState.new
      end
      
      # generate a color object based on the current color mode.
      # For color mode RGB the inputs are Red, Green, Blue, Alpha from (0 to 255)
      def color(*args)
        @logger.debug("GLSLSketchAPI: begin color")
        @logger.debug("GLSLSketchAPI: current color_mode: #{@render_state.color_mode}")
        #need to use factories rather than if/else and case statements. 
        #this pattern will be repeated on other api methods.
        color = 
        case @render_state.color_mode
        when Jitterbug::GraphicsEngine::Color::ColorModes::RGB then
          #need to handle both color names and explicit values.
          #also need to handle 0-1 and 0-255 ranges
          #for the moment just handle 4 args. 0-255
          @logger.debug("GLSLSketchAPI: color - got in RGB color mode")
          Color::RGB.new(args[0],args[1],args[2],args[3])  
        else 
          @logger.error("Invalid color mode in color(). It was #{@render_state.color_mode}")
          raise StandardError.new("Invalid color mode in color(). It was #{@render_state.color_mode}")  
        end   
        @logger.debug("GLSLSketchAPI: begin color") 
        @logger.debug("GLSLSketchAPI: color generated: #{color}")     
        return color        
      end
      
      def fill(color)
        @logger.debug("GLSLSketchAPI: begin fill")   
        raise StandardError.new("The input color was nil.") if color.nil?
        raise StandardError.new("The input color must be a descendent of Jitterbug::Color::Base. Rather it was: #{color.class}") unless color.class.ancestors.include?(Jitterbug::GraphicsEngine::Color::Base)
        @render_state.current_fill_color = color
        @render_state.enable_fill = true
        @logger.debug("GLSLSketchAPI: end color")   
      end
      
      def no_fill()
        @render_state.enable_fill = false
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