require 'command'
module Jitterbug
  module Command
    class CopyLayer < Base
      def process
        id = ARGV.shift
        lm = Jitterbug::Sketch::Controller.new(nil,{:working_dir => @options[:sketch_dir], 
          :output_dir => @options[:output_dir],
   			  :env => @options[:environment]})
        lm.load
        if ARGV.empty? 
          lm.copy(id)
        else
          name = ARGV.shift
          lm.copy(id,name)
        end
        lm.save
  			lm.logger.close
        return CommandResponse.new("Layer #{id} was copied")
      end
    end 
  end
end