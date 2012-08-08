module Jitterbug
  module GraphicsEngine
    class GLSLRenderer < Renderer
      def render
        @logger.debug("GLSLRenderer: begining render")
        create_graphics_renderer
        @logger.debug("GLSLRenderer: ending render")
      end
      
      private
      def done_rendering(sender)
        self.raw_rendered_frame = @view_renderer.renderedFrame # I worry about getting a reference. Might need to do a copy...
        sender.window.close
        NSApplication.sharedApplication.stopModal
      end
      
      #This method is gigantic. Refactor
      def create_graphics_renderer
        @logger.debug "Creating OpenGL context."
        
        @app = NSApplication.sharedApplication
        @app.delegate = AppDelegate.new()
        
        if (@width.nil? || @height.nil?)
          @logger.error("The width & height was not set on the sketch.")
          return
        end
        
        size = [0, 0, self.width, self.height] 

        window = NSWindow.alloc.initWithContentRect(size,
            styleMask: (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSTexturedBackgroundWindowMask),
            backing: NSBackingStoreBuffered,
            defer: false)
        window.title      = 'OS X: Jitterbug OpenGL Window'
        window.level      = NSNormalWindowLevel
        window.delegate   = AppDelegate.new()
        
        close_button = window.standardWindowButton(NSWindowCloseButton,forStyleMask: NSClosableWindowMask)
        close_button.setEnabled(true)
        close_button.target = self
        close_button.action = "done_rendering:"

        begin
          view = JBOpenGLView.alloc.initWithFrame(size)
          view.setSize(self.width, height: self.height)
          @view_renderer = GLRenderer.new   
          @view_renderer.logger = @logger
          view.setRenderer(@view_renderer)
          
          #view.logger = @logger
          window.contentView.addSubview(view)
        
          window.display
          window.orderFrontRegardless  

          #this blocks the macruby thread
          NSApplication.sharedApplication.runModalForWindow(window)   
        rescue => error
          @logger.error(error.message)
        end
      end   
    end
    
    class GLRenderer < ::JBRenderer      
      attr_accessor :logger
      
      def initialize
        super
        @current_frame = 0
      end  
            
      def render
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