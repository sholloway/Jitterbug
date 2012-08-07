require 'command'
module Jitterbug
  module Command
    class CleanSketch < Base
      def process
        clean_type = ARGV.shift
  			if clean_type.nil?
  			  clean_type = :all
  		  end  			
        lm = Jitterbug::Sketch::Controller.new(nil,{:working_dir => @options[:sketch_dir], 
          :output_dir => @options[:output_dir],
   			  :env => @options[:environment]})
  			case clean_type.downcase.to_sym
  				when :trash
  					lm.clean(:trash)
  				when :output
  					lm.clean(:output)
  				when :logs
  				  lm.clean(:logs)
  				when :all
  					lm.clean(:trash).clean(:output).clean(:logs)
  				else
  					lm.logger.close
  					CommandResponse.new(CommandResponse::Failure,"Unknown subcommand #{type.inspect}.\nClean can only be followed by trash or output.\njitterbug -d clean trash")
  				end
  				lm.logger.close
        return CommandResponse.new("Sketch was cleaned")
      end
    end 
  end
end