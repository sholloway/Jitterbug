require 'command'
module Jitterbug
  module Command
    class RenderSketch < Base
      def process
        lm = Jitterbug::Sketch::Controller.new(:working_dir => @options[:sketch_dir], 
          :output_dir => @options[:output_dir],
   			  :env => @options[:environment])
  			lm.load
  			lm.render
  			lm.logger.close
        return CommandResponse.new("Sketch has been rendered")
      end
    end 
  end
end