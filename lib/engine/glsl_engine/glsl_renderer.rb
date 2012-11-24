module Jitterbug
  module GraphicsEngine
    class GLSLRenderer < Renderer
      def render
        @logger.debug("GLSLRenderer: begining render")
        verify_inputs
        create_graphics_renderer
        launch_graphical_application
        @logger.debug("GLSLRenderer: ending render")
      end
      
      private
      def done_rendering(button)
        self.raw_rendered_frame = @view_renderer.renderedFrame
        button.window.close
        NSApplication.sharedApplication.stopModal
      end
      
      #This method is gigantic. Refactor
      def create_graphics_renderer
        @logger.debug "Creating OpenGL context."
        
        @app = NSApplication.sharedApplication
        @app.delegate = AppDelegate.new()
        size = [0, 0, self.width, self.height]
        @window = NSWindow.alloc.initWithContentRect(size,
            styleMask: (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSTexturedBackgroundWindowMask),
            backing: NSBackingStoreBuffered,
            defer: false)
        @window.title      = 'OS X: Jitterbug OpenGL Window'
        @window.level      = NSNormalWindowLevel
        @window.delegate   = AppDelegate.new() #this is probably a bug... Need to share the delegate?
        
        close_button = @window.standardWindowButton(NSWindowCloseButton,forStyleMask: NSClosableWindowMask)
        close_button.setEnabled(true)
        close_button.target = self
        close_button.action = "done_rendering:"

        view = JBOpenGLView.alloc.initWithFrame(size)
        view.setSize(self.width, height: self.height)
        @view_renderer = GLRenderer.new   
        @view_renderer.logger = @logger
        @view_renderer.geometry = @visible_geometry
        view.setRenderer(@view_renderer)
        
        @window.contentView.addSubview(view)
      end   
      
      def verify_inputs
        raise StandardError.new ("The width & height was not set on the sketch.") if (@width.nil? || @height.nil?)
      end
      
      def launch_graphical_application
        @window.display
        @window.orderFrontRegardless  
        NSApplication.sharedApplication.runModalForWindow(@window)
      end
    end
    
    class GLRenderer < ::JBRenderer      
      attr_accessor :logger, :geometry
      
      def initialize
        super
      end  
            
      #overrides the Obj-c method
      def render
        activateOffScreenFrameBuffer      
        glViewport(0, 0, width, height) #pull out of here        
        
        glClearColor(0.0, 1.0, 0.0, 0.0) #green but should come from sketch...
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)  
        
        unless @geometry.empty?        
          @geometry.each do |geo_node|
            puts "in the geometry loop"          
           # geo_node.geometry.shader_manager = BlackShit.new
            geo_node.geometry.shader_manager.draw(self)      
            puts "finished geometry loop"
          end
        end       
       
       glFinish()
       #looks like either the OpenGL context is not availible to non-children of JBRenderer or something wonky is happending with scope
       #or even possibly Garbage Collection.
       
        outputActiveFramebuffer
        glFinish()
        
        stop
=begin 
        #draw something to the screen (Just for the hell of it...)
        activateSystemFrameBuffer() 
        
        glClearColor(1.0, 0.0, 0.0, 0.0) #red
      	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      	glFlush
      	
      	#draw something else to my renderbuffer (This should be rendered to an image by PNGImage)
      	activateOffScreenFrameBuffer()
      	glClearColor(0.0, 1.0, 0.0, 0.0) #green
      	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      	glFlush  
      	
      	outputActiveFramebuffer  
      	# this doesn't fit the SingleImageRenderLoop design. That class should have this responsibility   	
      	# it should set how many frames to render
        
        stop 
=end
      end  
      
      #overrides the Obj-c method
      def setupShaders
        @geometry.each{|geometry_node| geometry_node.geometry.shader_manager.register(self)}          
      end
        
      def tearDownShaders
        @geometry.each{|geometry_node| geometry_node.geometry.shader_manager.checkout(self)} 
      end
      
      def check_shader_compile_status
        #figure out...
      end    
      
      def registry
        if @registry.nil?
          logger.debug('GLRenderer: Initializing the registry')
          @registry = {} 
        end
        return @registry
      end
          
    end
    
    class BlackShit < Jitterbug::GraphicsEngine::GLSL::ShaderManager
      def initialize
        super
        @name = :rect_2d_shader_manager
      end
      
      def draw(renderer)
        puts "about to make some black shit"
        glClearColor(0.0, 0.0, 0.0, 0.0)
      	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glFlush()
      end
    end
    
    
    class AppDelegate
      def initialize()
        
      end
      
      def applicationDidFinishLaunching(notification)    
      end
    end
  end
end