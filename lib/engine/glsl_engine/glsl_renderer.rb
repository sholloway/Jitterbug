module Jitterbug
  module GraphicsEngine
    class GLSLRenderer < Renderer
      def render
        @logger.debug("GLSLRenderer: begining render")
        @rendering = true
        create_graphics_renderer
        @logger.debug("GLSLRenderer: ending render")
      end
      
      private
      def done_rendering()
        @rendering = false
      end
      
      #at this point we're macruby dependent... can't call with rspec
      def create_graphics_renderer
        @logger.debug "Creating OpenGL context."
        
        @app = NSApplication.sharedApplication
        @app.delegate = AppDelegate.new(method(:done_rendering))
        
        if (@width.nil? || @height.nil?)
          @logger.error("The width & height was not set on the sketch.")
          return
        end
        
        size = [0, 0, @width, @height] 

        window = NSWindow.alloc.initWithContentRect(size,
            styleMask:NSTitledWindowMask | NSClosableWindowMask,
            backing:NSBackingStoreBuffered,
            defer:false)
        window.title      = 'OS X: Jitterbug OpenGL Window'
        window.level      = NSNormalWindowLevel #NSModalPanelWindowLevel
        window.delegate   = @app.delegate

        #gut this...
        #create the render entirely in ruby to get it working. Then re-implement by droping down to Obj-C++
=begin        
        glview = JBOpenGLView.alloc.initWithFrame(size)
        @renderer = JBOfflineRenderer.alloc.init
        glview.setRenderer(@renderer)
        window.contentView.addSubview(glview)
=end
        begin
          view = JBOpenGLView.alloc.initWithFrame(size)
          view_renderer = GLRenderer.new
          view.setRenderer(view_renderer)
          
          #view.logger = @logger
          window.contentView.addSubview(view)
        
          window.display
          window.orderFrontRegardless  
        
          while(@rendering)
            #wait for window to close
          end
        rescue => error
          @logger.error(error.message)
        end
        
        #need some kind of callback so the main thread will wait until the window has been closed.                                     
      end   
    end
    
    require File.join(File.expand_path(File.dirname(__FILE__)),"..","..","..","macos_jitterbug")
    class GLRenderer < ::JBRenderer      
      def render
          glClearColor(0.0, 0.0, 1.0, 0.0)
        	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        	glFlush
      end
    end
    
    class AppDelegate
      def initialize(callback)
        @callback = callback
      end
      
      def applicationDidFinishLaunching(notification)    
      end

      def windowWillClose(notification)              
        #exit
        @callback.call
      end
    end
  end
end