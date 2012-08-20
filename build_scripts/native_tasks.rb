desc "Display the Image I/O formats"
task :list_image_io_support do
  framework "Quartz"
  puts "Image I/O Input Formats:"
  can_read_from = CGImageSourceCopyTypeIdentifiers()
  CFShow(can_read_from)
  puts " "

  puts "Image I/O Output Formats:"
  can_write_to = CGImageDestinationCopyTypeIdentifiers()
  CFShow(can_write_to)
end

desc "Display the curent OpenGL info"
task :list_opengl_info do
  require File.join(File.expand_path(File.dirname(__FILE__)),"..","macos_jitterbug")
  require 'logger'  
  framework 'Foundation'
  framework 'Cocoa'
  framework 'AppKit'
  framework 'OpenGL'
  
  class DebugRenderer < JBRenderer      
    attr_accessor :logger

    def initialize
      super
      @current_frame = 0
    end  

    #overrides the Obj-c method
    def render
      #draw something to the screen (Just for the hell of it...)
      activateSystemFrameBuffer() 

      glClearColor(1.0, 0.0, 0.0, 0.0) #red
    	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    	glFlush 	

      puts "OpenGL Vendor: #{glGetString(GL_VENDOR)}"
      puts "Renderer #{glGetString(GL_RENDERER)}"
      puts "OpenGL Version: #{glGetString(GL_VERSION)}"
      puts "GLSL Version: #{glGetString(GL_SHADING_LANGUAGE_VERSION)}"
      puts
      fetch_stat_i(GL_MAX_COLOR_ATTACHMENTS_EXT,"Number of FBO's supported")
      fetch_stat_i(GL_MAX_DRAW_BUFFERS,"The maximum number of simultaneous outputs that may be written in a fragment shader")
    
      fetch_stat_i(GL_MAX_VIEWPORT_DIMS,'GL_MAX_VIEWPORT_DIMS')
      
      #fetch_stat_i(GL_MAX_DUALSOURCE_DRAW_BUFFERS)
      fetch_stat_i(GL_MAX_ELEMENTS_INDICES,'GL_MAX_ELEMENTS_INDICES')
      fetch_stat_i(GL_MAX_ELEMENTS_VERTICES,'GL_MAX_ELEMENTS_VERTICES')
      
      fetch_stat_i(GL_MAX_FRAGMENT_UNIFORM_COMPONENTS,'GL_MAX_FRAGMENT_UNIFORM_COMPONENTS')
      fetch_stat_i(GL_MAX_FRAGMENT_UNIFORM_BLOCKS,'GL_MAX_FRAGMENT_UNIFORM_BLOCKS')
      fetch_stat_i(GL_MAX_FRAGMENT_INPUT_COMPONENTS,'GL_MAX_FRAGMENT_INPUT_COMPONENTS')
      fetch_stat_i(GL_MAX_RENDERBUFFER_SIZE,'GL_MAX_RENDERBUFFER_SIZE')

      fetch_stat_i(GL_MAX_VERTEX_ATTRIBS,'GL_MAX_VERTEX_ATTRIBS')
      fetch_stat_i(GL_MAX_VERTEX_OUTPUT_COMPONENTS,'GL_MAX_VERTEX_OUTPUT_COMPONENTS')
      fetch_stat_i(GL_MAX_GEOMETRY_UNIFORM_COMPONENTS,'GL_MAX_GEOMETRY_UNIFORM_COMPONENTS')
      fetch_stat_i(GL_MAX_VERTEX_UNIFORM_BLOCKS,'GL_MAX_VERTEX_UNIFORM_BLOCKS')
      fetch_stat_i(GL_MAX_GEOMETRY_UNIFORM_BLOCKS,'GL_MAX_GEOMETRY_UNIFORM_BLOCKS')
      fetch_stat_i(GL_MAX_GEOMETRY_INPUT_COMPONENTS,'GL_MAX_GEOMETRY_INPUT_COMPONENTS')
      fetch_stat_i(GL_MAX_GEOMETRY_OUTPUT_COMPONENTS,'GL_MAX_GEOMETRY_OUTPUT_COMPONENTS')
      
#      GL_POINT_SIZE_RANGE #won't work with default method of calling glGetIntegerv   
      stop 
    end  
    
    def fetch_stat_i(constant,msg=nil)
      value = Pointer.new(:int)
      glGetIntegerv(GL_MAX_DRAW_BUFFERS, value)    
      puts "#{(msg.nil?)? constant : msg}: #{value[0]}"
    end
    
    #overrides the Obj-c method
    def setupShaders

    end
  end

  class AppDelegate
    def initialize()

    end

    def applicationDidFinishLaunching(notification)    
    end
  end
  
  def done_rendering(button)    
    button.window.close
    NSApp.stop(0)
  end
  
  def create_gui
    logger = Logger.new(STDOUT)
  	logger.level = Logger::ERROR
  	logger.datetime_format = "%H:%M:%S"
	
    app = NSApplication.sharedApplication
    app.delegate = AppDelegate.new()
    width = 100
    height = 100
    size = [0, 0, width, height]
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

    view = JBOpenGLView.alloc.initWithFrame(size)
    view.setSize(width, height: height)
    view_renderer = DebugRenderer.new   
    view_renderer.logger = logger
    view.setRenderer(view_renderer)  
    window.contentView.addSubview(view)
  
    window.display
    window.orderFrontRegardless 
    NSApp.run
  end

  create_gui
end

desc "Display the supported OpenGL extensions"
task :list_opengl_extensions do
  require File.join(File.expand_path(File.dirname(__FILE__)),"..","macos_jitterbug")
  require 'logger'  
  framework 'Foundation'
  framework 'Cocoa'
  framework 'AppKit'
  framework 'OpenGL'
  
  class DebugRenderer < JBRenderer      
    attr_accessor :logger

    def initialize
      super
      @current_frame = 0
    end  

    #overrides the Obj-c method
    def render
      activateSystemFrameBuffer() 

      glClearColor(1.0, 0.0, 0.0, 0.0) #red
    	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    	glFlush
    	
    	numext = Pointer.new(:int)
    	glGetIntegerv(GL_NUM_EXTENSIONS, numext);
      puts "Found #{numext[0]} GL_EXTENSIONS"
      (0..numext[0]-1).each do |index|
        puts glGetStringiShim(index)
      end  
      debug_this_sob

      stop 
    end  

    #overrides the Obj-c method
    def setupShaders

    end
  end

  class AppDelegate
    def initialize()

    end

    def applicationDidFinishLaunching(notification)    
    end
  end
  
  def done_rendering(button)    
    button.window.close
    NSApp.stop(0)
  end
  
  def create_gui
    logger = Logger.new(STDOUT)
  	logger.level = Logger::ERROR
  	logger.datetime_format = "%H:%M:%S"
	
    app = NSApplication.sharedApplication
    app.delegate = AppDelegate.new()
    width = 100
    height = 100
    size = [0, 0, width, height]
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

    view = JBOpenGLView.alloc.initWithFrame(size)
    view.setSize(width, height: height)
    view_renderer = DebugRenderer.new   
    view_renderer.logger = logger
    view.setRenderer(view_renderer)  
    window.contentView.addSubview(view)
  
    window.display
    window.orderFrontRegardless 
    NSApp.run
  end

  create_gui
end