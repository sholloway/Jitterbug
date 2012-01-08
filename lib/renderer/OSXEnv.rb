module Jitterbug
  module Env
    class OSXEnv
      def bootstrap(logger,layer_manager)
        Jitterbug::Render::OSX::BootStrap.new(logger, layer_manager)  
      end
    end
  end
end