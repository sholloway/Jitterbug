module Jitterbug
  module Render
    class BootStrap
      def initialize(logger)
        @logger = logger        
      end
      
      # Determine what implementation to link against and what kind of render to use.
      # This is where the multithreaded loading of all assets should occure.
      def lace_up(layer_manager)
        # how do I determine that I'm running macruby?
        require 'renderer/osx/bootstrap'
        @boot_strap = Jitterbug::Render::OSX::BootStrap.new(@logger, layer_manager) 
        @boot_strap.create_graphics_renderer
        @boot_strap.process_layers
        @boot_strap.load_shaders
        @boot_strap.load_textures
        @boot_strap.load_models
        @boot_strap.load_audio
        @boot_strap.load_video
      end
      
      def render
        @boot_strap.render
      end      
      
    end
  end
end