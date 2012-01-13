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
        #this needs to be in a config file to load this.
        # the tests should have a different config file to prevent relying on macruby.
        
        rendering_env = layer_manager.options[:env]
        if rendering_env.nil?
          raise StandardError.new "The rendering environment could not be found"
        end
        
        @boot_strap = rendering_env.bootstrap(@logger, layer_manager)         
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