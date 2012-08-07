require 'command'
module Jitterbug
  module Command
    class RevertSketch < Base
      def process
        lm = Jitterbug::Sketch::Controller.new(nil,{:working_dir => @options[:sketch_dir], 
          :output_dir => @options[:output_dir],
   			  :env => @options[:environment]})
  			lm.load
  			lm.revert 
  			lm.logger.close 			
        return CommandResponse.new("Sketch was reverted")
      end
    end 
  end
end