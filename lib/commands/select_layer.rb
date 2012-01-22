require 'command'
module Jitterbug
  module Command
    class SelectLayer < Base
      def process
        lm = Jitterbug::Layers::LayersManager.new(:working_dir => @options[:sketch_dir], 
   			  :output_dir => @options[:output_dir],
   			  :env => @options[:environment])  	
   			layer_id = ARGV.first		  			
  			lm.load.
  			  select(layer_id)
  			lm.save
  			lm.logger.close
        return CommandResponse.new("Layer #{layer_id} selected")
      end
    end 
  end
end