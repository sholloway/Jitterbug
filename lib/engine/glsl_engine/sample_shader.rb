module Jitterbug
  module GraphicsEngine
    module GLSL
      #Consider this:
      #Take OpenGLRenderer from the unused_files and migrate it back in as an Obj-C abstract class. 
      #Then have SampleShader extend it. I should then be able to gradually move code from Obj-C to
      #Ruby and narrow down where the Pointer issues are.
      #Will have to wrap GLM calls with an Obj-C proxy if I want to call them from Ruby.
      #If I decide to do that, it would be better to have a seperate Repo dedicated to wrapping GLM
      #that builds as it's own bundle perhaps.
      class SampleShader < ShaderManager
        def initialize   
          @name = :sample_shader_manager     
        end
                   
        def register(renderer)
        end
        
        def checkout(renderer)
        end
        
        def draw(renderer)
          glClearColor(1.0, 0.0, 1.0, 1.0);gl_check;
        	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);gl_check;
        end
      end
    end
  end
end