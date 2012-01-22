require 'command'
require 'create_sketch_helper'
 
module Jitterbug
  module Command
   class CreateSketch < Base
     include Jitterbug::Sketch
     def process
       sketch_name = ARGV.first
       sketch_dir = @options[:sketch_dir]       
       create_sketch(sketch_name, sketch_dir)
 			 lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}/#{sketch_name}", 
 			  :output_dir => @options[:output_dir],
 			  :env => @options[:environment]).
 			  create_new_layer("Background").
 			  create_new_layer("Foreground").				
        save
        lm.logger.close
        return CommandResponse.new("created sketch: #{sketch_dir}/#{sketch_name}")
     end
   end 
  end
end