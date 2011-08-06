require 'jitter_logger'
require 'speach_therapist'

module Jitterbug
	module Graphics
		class OpenGLRenderer
			def initialize(layer_manager)
				@lm = layer_manager
			end
			
			
=begin
This must be concurrent.

First render all layer's in their own thread using programable pipeline
#Perform image filter chain on each layer
#Composit the layers
#write to various outputs

setup
@layer_manager.layers do |layer|
	thread = Thread.new do |t|
		framebuffer = instance.eval(layer.script)
		layer.image = process_filter_chain(layer)
	end
	thread.start
	layer.image = in memory image rendered
end

wait for all threads

final_fb = composite(all_layers)
save_to_image(final_fb)

cleanup

=end
			def render	
			  therapist = Jitterbug::Speach::Therapist.new		
			  therapist.say "Sir, I am about to start rendering."	
				@logger = Jitterbug::Logging::JitterLogger.new(@lm.options,"render.log")
				@logger.info "ho ha!"				
				therapist.say "Rendering is complete. Look in the output directory."
			end
		end
	end
end