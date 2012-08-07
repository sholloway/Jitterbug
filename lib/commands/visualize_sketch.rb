require 'command'
module Jitterbug
  module Command
    class VisualizeSketch < Base
      def process
        lm = Jitterbug::Sketch::Controller.new(nil,{:working_dir => @options[:sketch_dir], 
          :output_dir => @options[:output_dir],
   			  :env => @options[:environment]}).
          load
        lm.logger.close        
        return CommandResponse.new(lm.to_s)
     end
   end 
  end
end