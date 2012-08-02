require 'command'
module Jitterbug
  module Command
    class MoveLayer < Base
      def process
        direction = ARGV.shift
        case direction.downcase.to_sym				
  				when :closer
  					lm = Jitterbug::Sketch::Controller.new(:working_dir => @options[:sketch_dir], 
              :output_dir => @options[:output_dir],
       			  :env => @options[:environment])
  					lm.load					
  					lm.move_closer
  					lm.save
  					lm.logger.close
  				when :away
  					lm = Jitterbug::Sketch::Controller.new(:working_dir => @options[:sketch_dir], 
              :output_dir => @options[:output_dir],
       			  :env => @options[:environment])
  					lm.load					
  					lm.move_farther_away
  					lm.save
  					lm.logger.close
  				else
  					CommandResponse.new(CommandResponse::Failure, "Unknown subcommand #{direction.inspect}.\nMove can only be followed by closer or away.\njitterbug -d sketch move up layer_name")
  				end
        return CommandResponse.new("The layer was moved #{direction}")
      end
    end 
  end
end