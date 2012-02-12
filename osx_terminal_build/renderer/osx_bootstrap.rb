module Jitterbug
  module Render
    module OSX
      class BootStrap
        def initialize(logger, layer_manager)
          @logger = logger
          @layer_manager = layer_manager
        end

        def create_graphics_renderer
          @logger.info "Creating OpenGL context."
         
=begin
          #I'm hopeful that the loading from terminal main will take care of this.
          framework 'Foundation'
          framework 'Cocoa'
          framework 'OpenGL'
          framework 'AppKit'          
          require 'macos_jitterbug' #Load the mac bundle under ext/bin. If this fails, we could try to compile it...             
=end

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

          glview = JBOpenGLView.alloc.initWithFrame(size)
          @renderer = JBOfflineRenderer.alloc.init
          glview.setRenderer(@renderer)
          window.contentView.addSubview(glview)

          window.display
          window.orderFrontRegardless                                       
        end
        
        def render
          @logger.info "Begining Rendering."
          @app.run
        end
        
        def process_layers
          @logger.info "Converting all of the layers to the right type of Sketch Layer."
          @sketch_layers = []

          #Need to do this back to front? Or do you delay the ordering till the final composit?
          #Possibly do a syntax check on the scripts at this point to help with debugging.
  			  @layer_manager.layers do |layer|
  			    next unless layer.visible
  			    if layer.type == :two_dim
  			      sketch_context = Jitterbug::Sketch::Context.new
              sketch_layer = Jitterbug::Sketch::Layer2d.new
              sketch_layer.logger = @logger
              sketch_layer.setContext sketch_context
              sketch_layer.name = layer.name
              sketch_layer.script = layer.script
              @sketch_layers << sketch_layer 			    
            end
  			  end
  			  
  			  @renderer.setLayers(@sketch_layers)
        end

        def load_shaders
          @logger.info "Loading all shaders."
          #try to use NSOperation and GCD
        end 

        def load_textures
          @logger.info "Loading all textures."
        end

        def load_models
          @logger.info "Loading all models."
        end

        def load_audio
          @logger.info "Loading all audio."
        end

        def load_video
          @logger.info "Loading all video."
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
end