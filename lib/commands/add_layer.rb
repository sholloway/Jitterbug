require 'command'
module Jitterbug
  module Command
    class AddLayer < Base
      def process
         unless ARGV.nil? || ARGV.empty?
    		    command_options[:new_layers] = ARGV.dup
      		  lm = Jitterbug::Sketch::Controller.new(:working_dir => @options[:sketch_dir], 
              :output_dir => @options[:output_dir],
       			  :env => @options[:environment])
      			lm.load
      			@options[:new_layers].each{|layer_name| lm.add(layer_name)}
      			lm.save
      			lm.logger.close
            return CommandResponse.new("Layer(s) added")
    	    else	      
    	      msg = %{No layer name was specified.
#{Jitterbug::Resources::Text::Help::Add}
  	        } 
  	        return CommandResponse.new(CommandResponse::Failure, msg)   	       
          end
      end
    end 
  end
end