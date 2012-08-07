require 'command'
require 'resources'

module Jitterbug
  module Command
    class RenameLayer < Base
      def process
        if ARGV.size != 2
  		    return CommandResponse.new(Jitterbug::Resources::Text::Main::Rename)  		    
  	    end
  	    lm = Jitterbug::Sketch::Controller.new(nil,{:working_dir => @options[:sketch_dir], 
          :output_dir => @options[:output_dir],
   			  :env => @options[:environment]})
  			lm.load
  			original_name = ARGV.shift
  			new_name = ARGV.shift
  			lm.rename(original_name, new_name)
  			lm.save
  			lm.logger.close
        return CommandResponse.new("The layer #{original_name} was renamed to #{new_name}")
      end
    end 
  end
end