require 'engine_parts'
module Jitterbug
  module GraphicsEngine
    class GLSLGeometry < Jitterbug::GraphicsEngine::Geometry
      attr_reader :program, :vertices, :indicies, :render_state, :shader_manager
      
      def initialize(program, vertices, indicies)
        @program = program
        @vertices = vertices
        @indicies = indicies
      end33
      
      def render_state=(rs)
        @render_state = rs.clone
        @render_state.freeze
      end
      
      def shader_manager=sm
        @shader_manager = sm
      end
      
      def to_s
        %{
Program: #{program}
Vertices: #{vertices}
Render State: #{render_state}
Shader Manager: #{shader_manager}  
        }
      end
    end
    
    module GLSL
      class ShaderManager     
        attr_reader :name, :geometry_node
        def initialize   
          #REFACTOR - make this a method that must be overridden, rather than a member
          #REFACTOR - add the Render Logger
          @name = "DO NOT USE SHADER MANAGER DIRECTLY"  
          @geometry_node = nil    
        end
                   
        def register(renderer)
          raise StandardError.new("Shader cannot be registered! Do not instantiate Jitterbug::GraphicsEngine::GLSL::ShaderManager directly.")
        end
        
        def checkout(renderer)
          raise StandardError.new("Shader cannot be checked out! Do not instantiate Jitterbug::GraphicsEngine::GLSL::ShaderManager directly.")
        end
        
        def draw(renderer)
          raise StandardError.new("Shader cannot be drawn! Do not instantiate Jitterbug::GraphicsEngine::GLSL::ShaderManager directly.")
        end
        
        def geometry_node=(gn)
          @geometry_node = gn
        end
          
        alias :setGeometryNode :geometry_node=
        
        protected
        def gl_check
          err = GL_NO_ERROR
          err = glGetError()
          raise StandardError.new "OpenGL error(hex): #{err.to_s(16)}" unless err == GL_NO_ERROR
        end
      end
      
      class Rect2DShader < ShaderManager
        def initialize
          super
          @name = :rect_2d_shader_manager
        end        

        def register(renderer)
          #example
          #const char* code = "shader string";
          #int len = strlen(code);
          #glShaderSource(obj, 1, (const char**)&code, &len);
          #do vert shader
          unless renderer.registry().key?(geometry_node.program.vertex_shader_path)
            @vert_shader = glCreateShader(GL_VERTEX_SHADER);gl_check;
            vert_shader_str = geometry_node.program.vertex_shader
            vs_p = Pointer.new(:string,1)
            vs_p[0] = vert_shader_str.UTF8String #convert Ruby String/NSString to char*
            glShaderSource(@vert_shader,1, vs_p, nil);gl_check;
            glCompileShader(@vert_shader);gl_check;         
            check_shader_compile_status(@vert_shader,geometry_node.program.vertex_shader_path)
            renderer.registry[geometry_node.program.vertex_shader_path] = @vert_shader
          end
          
          #do the frag shader
          unless renderer.registry.key?(geometry_node.program.fragment_shader_path)
            @frag_shader = glCreateShader(GL_FRAGMENT_SHADER);gl_check;
            frag_shader_str = geometry_node.program.frag_shader
            fs_p = Pointer.new(:string,1)
            fs_p[0] = frag_shader_str.UTF8String
            glShaderSource(@frag_shader,1, fs_p, nil);gl_check;
            glCompileShader(@frag_shader);gl_check;
            check_shader_compile_status(@frag_shader,geometry_node.program.fragment_shader_path)
            renderer.registry[geometry_node.program.fragment_shader_path] = @frag_shader
          end
          
          #create the program
          unless renderer.registry.key?(name)
            @program = glCreateProgram();gl_check;
            glAttachShader(@program,@vert_shader);gl_check;
            glAttachShader(@program,@frag_shader);gl_check;
            glBindFragDataLocationEXT(@program, 0, "FragColor");gl_check;
            glLinkProgram(@program);gl_check;
            check_program_linking(@program)
            renderer.registry[name] = @program
          end
          
            #look up where the vertex data needs to go.
           positionLocation = glGetAttribLocation(renderer.registry[name],"a_position");gl_check;
           raise StandardError.new("Could not find shader input a_position") if positionLocation == -1      
         
           # lookup uniforms           
           @resolutionLocation = glGetUniformLocation(renderer.registry[name],"u_resolution");gl_check;    
           raise StandardError.new("Could not find shader input u_resolution") if @resolutionLocation == -1  
             
           @colorLocation = glGetUniformLocation(renderer.registry[name],"v_color");gl_check;           
           raise StandardError.new("Could not find shader input v_color") if @colorLocation == -1      
         
           # Create a VBO to store the vertices position data
           #this should also be conditional like the Program
           @vbo = Pointer.new(:uint)
           glGenBuffers(1,@vbo);gl_check;
           glBindBuffer(GL_ARRAY_BUFFER, @vbo[0]);gl_check;           
            @verts = Pointer.new(:float, geometry_node.vertices.length)
            (0..geometry_node.vertices.length-1).each{|index| @verts[index] = geometry_node.vertices[index];}
            verts_byte_size = PolyglotUtils.findArrayByteSizeByFirstElementi(@verts[0], andLength: geometry_node.vertices.length)
            glBufferData(GL_ARRAY_BUFFER, 4*geometry_node.vertices.length, @verts, GL_STATIC_DRAW);gl_check;
           glBindBuffer(GL_ARRAY_BUFFER, 0);
                    
          #attach the VBO to a VAO            
           @vao = Pointer.new(:uint)
           glGenVertexArrays(1, @vao);gl_check;
           glBindVertexArray(@vao[0]);gl_check;
         		glBindBuffer(GL_ARRAY_BUFFER, @vbo[0]);gl_check;         		
       		
         		#enable the a_position Vert shader attribute
            offset = Pointer.new(:int)
            offset[0] = 0
            glEnableVertexAttribArray(positionLocation);gl_check;            
            glVertexAttribPointer(positionLocation, 2, GL_FLOAT, GL_FALSE, 0, offset);gl_check;            
         	 glBindVertexArray(0);gl_check;
        end
        
        def checkout(renderer)
          glDeleteShader(renderer.registry[geometry_node.program.vertex_shader_path]) if glIsShader(renderer.registry[geometry_node.program.vertex_shader_path])
          glDeleteShader(renderer.registry[geometry_node.program.fragment_shader_path]) if glIsShader(renderer.registry[geometry_node.program.fragment_shader_path])
          glDeleteProgram(renderer.registry[name]) if glIsProgram(renderer.registry[name])
          
        end
        
        #need to think through if this design can handle instancing
        def draw(renderer)            
          #make sure we're rendering the correct layer
          glClearColor(1.0, 1.0, 1.0, 1.0);gl_check;
        	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);gl_check;
           
           # Draw the rectangle.
           glBindVertexArray(@vao[0]);gl_check;  
            #debug
            glLinkProgram(@program);gl_check;
            check_program_linking(@program)
            glUseProgram(@program);gl_check;
            
            # set the resolution           
            glUniform2f(@resolutionLocation,renderer.width, renderer.height);gl_check;

             # Set the fill color 
             glUniform4f(@colorLocation, geometry_node.render_state.current_fill_color.red/255.0,
              geometry_node.render_state.current_fill_color.green/255.0,
              geometry_node.render_state.current_fill_color.blue/255.0,
              geometry_node.render_state.current_fill_color.alpha/255.0);gl_check;
            
            glDrawArrays(GL_TRIANGLES, 0, 6);gl_check;
            
           glBindVertexArray(0);gl_check;
           glUseProgram(0);gl_check;
        end
        
        private
        def check_program_linking(program)
          status = Pointer.new(:int)
          glGetProgramiv(program, GL_LINK_STATUS, status);gl_check;
        	if status == GL_FALSE
            log_buffer = Pointer.new(:char, 1000)
            char_size = PolyglotUtils.sizeofChar
            size = 1000*char_size
            log_length = Pointer.new(:int)
        		glGetProgramInfoLog(program, size, log_length, log_buffer);gl_check;
        		puts "The program #{name}'s log file is:"
            str = NSString.stringWithCString(log_buffer, encoding:NSASCIIStringEncoding)
            puts str
        	else
        	  log_buffer = Pointer.new(:char, 1000)
            char_size = PolyglotUtils.sizeofChar
            size = 1000*char_size
            log_length = Pointer.new(:int)
        		glGetProgramInfoLog(program, size, log_length, log_buffer);gl_check;
        		puts "The program was OK. #{name}'s log file is:"
            str = NSString.stringWithCString(log_buffer, encoding:NSASCIIStringEncoding)
            puts str
            
        		glValidateProgram(program);gl_check;
        		glGetProgramInfoLog(program, size, log_length, log_buffer);
        		if log_length[0] > 0
        		  str = NSString.stringWithCString(log_buffer, encoding:NSASCIIStringEncoding)
        			puts "OpenGL Program Validation results"
        			puts str
        		end
      	  end
        end
        
        def check_shader_compile_status(shader,shader_file)
          status = Pointer.new(:int)
          glGetShaderiv(shader,	GL_COMPILE_STATUS,status);gl_check;
          if status == GL_FALSE
            log_buffer = Pointer.new(:char, 1000)
            char_size = PolyglotUtils.sizeofChar
            size = 1000*char_size
            log_length = Pointer.new(:int)
            glGetShaderInfoLog(shader,size,log_length,log_buffer)
            puts "The shader #{shader_file}'s error log is:"
            str = NSString.stringWithCString(log_buffer, encoding:NSASCIIStringEncoding)
            puts str
          end
        end
              
      end
    end
  end
end  