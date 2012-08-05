module Jitterbug
  module GraphicsEngine
    class GLSLRenderer < Renderer
      def render
        @logger.debug("GLSLRenderer: begining render")
        
        @logger.debug("GLSLRenderer: ending render")
      end
      
      #at this point we're macruby dependent... can't call with rspec
      def create_graphics_renderer
        @logger.debug "Creating OpenGL context."
=begin
        @app = NSApplication.sharedApplication
        @app.delegate = AppDelegate.new
        size = [0, 0, 1280, 768] #must pull this from layer_manager.options

        window = NSWindow.alloc.initWithContentRect(size,
            styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask,
            backing:NSBackingStoreBuffered,
            defer:false)
        window.title      = 'OS X: Jitterbug OpenGL Window'
        window.level      = NSModalPanelWindowLevel
        window.delegate   = @app.delegate

        #gut this...
        glview = JBOpenGLView.alloc.initWithFrame(size)
        @renderer = JBOfflineRenderer.alloc.init
        glview.setRenderer(@renderer)
        window.contentView.addSubview(glview)

        window.display
        window.orderFrontRegardless                                       
=end
      end   
    end
    
    class AppDelegate
      def applicationDidFinishLaunching(notification)    
      end

      def windowWillClose(notification)              
        exit
      end
    end
  end
end