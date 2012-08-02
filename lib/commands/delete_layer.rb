require 'command'
module Jitterbug
  module Command
    class DeleteLayer < Base
      def process
        unless ARGV.nil? || ARGV.empty?  			  
  			  lm = Jitterbug::Sketch::Controller.new(:working_dir => @options[:sketch_dir], 
            :output_dir => @options[:output_dir],
     			  :env => @options[:environment])
    			lm.load
    			ARGV.each{|layer_name| lm.delete(layer_name)}
    			lm.save
    			lm.logger.close
          return CommandResponse.new("Layer(s) where deleted")
        else
          msg = %{No layer was specified
#{Jitterbug::Resources::Text::Help::Delete}
          }
          return CommandResponse.new(CommandResponse::Failure, msg)
        end
      end
    end 
  end
end