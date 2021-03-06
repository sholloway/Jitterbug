require 'yaml'
require 'fileutils'
require 'sketch_helper'

if defined?(YAML::ENGINE) 
  YAML::ENGINE.yamler = 'syck' #for ruby 1.9.3. Don't know exactly yet what the bug is with psyck parser
end

module Jitterbug
	module Sketch
		LayersData = Struct.new(:layers,:layer_counter,:graphics_engine)

		class Controller
			include Jitterbug::Sketch::Validation
			attr_reader :options, :logger, :render_logger, :layers, :engine, :background
			
			def initialize(rendering_engine=nil,options={}) # by default relative to output_dir					
				@options = {
					:working_dir=>false, #must be set, by default everything else is relative to this.
					:layers_file=>"sketch.yml", 
					:scripts_dir=>"scripts", 
					:support_scripts => "lib", # ruby scripts dir to support the primary layer scripts
					:vendor => "vendor", #place third party dependencies here like gems
					:resources_dir=>"resources", #shaders, models, images, movies, filters and audio are relative to this by default
					:shaders_dir=>"shaders",
					:models_dir=>"models",
					:images_dir=>"images",
					:movies_dir=>"movies",
					:image_filters_dir=>"filters",				
					:audio_dir=>"audio",
					:output_dir=>"output",
					:image_output_dir=>"images", # by default relative to output_dir
					:video_output_dir=>"video", # by default relative to output_dir
					:data_output_dir=>"data",
					:trash => "trash",
					:layers_file_backup =>"sketch.yml.bak",
					:logs => "logs",
					:logger => true,
					:render_logger =>true,
					:env => nil
				} 		

				@options.merge!(options)

				if (@options[:working_dir] == false)
					raise StandardError.new("The working directory for the sketch must be set.")
				end

				@layers = {}
				@layer_counter = 0

				if @options[:logger] == true					  
					@logger = Jitterbug::Logging::JitterLogger.new(@options,"jitterbug.log")
				else					  
					@logger = @options[:logger]
				end

				unless rendering_engine.nil?
					@engine = rendering_engine				  
				end

				validate
				return  
			end	

			#I've got to really think throught the color management system. 
			#I want to be able to have symbols and strings for common names, but also RGBA, CYMK and HSBA.
			def background(color)
				@background = color
			end		
			
			#Load the layers file into memory.
			def load()		
				error("The layer file: #{@options[:working_dir]}/#{@options[:layers_file]} does not exist.", 
					!File.exist?("#{@options[:working_dir]}/#{@options[:layers_file]}"))

				file = File.open("#{@options[:working_dir]}/#{@options[:layers_file]}")
				parsed = YAML.load(file)
				file.close
				@layers = parsed.layers
				@layer_counter = parsed.layer_counter

				if parsed.graphics_engine.instance_of?(Jitterbug::GraphicsEngine::Engine)
					@engine = parsed.graphics_engine
			  	else #for ruby 1.9.3		    
			  		@engine = Jitterbug::GraphicsEngine::Engine.from_hash(parsed.graphics_engine)			    			    
			  	end	

				return self
			end
			
			# save to @filepath layer.yml
			# backup the existing layer.yml
			# overwrite the existing layer.yml		
			def save()				
				if File.exists?("#{@options[:working_dir]}/#{@options[:layers_file]}")
					FileUtils.cp("#{@options[:working_dir]}/#{@options[:layers_file]}",
						"#{@options[:working_dir]}/#{@options[:layers_file_backup]}") 
				end
				
				@engine.unbind
				data = LayersData.new(@layers,@layer_counter,@engine)
				File.open("#{@options[:working_dir]}/#{@options[:layers_file]}", "w") do |f| 				  
					yaml_str = data.to_yaml
					f.write(yaml_str) 
				end
				
				#save all scripts to disk
				layers{|current_layer| current_layer.script.save()}
				
				return self
			end
			
			def revert
				error("Could not revert. No backup file found.", 
					!File.exists?("#{@options[:working_dir]}/#{@options[:layers_file_backup]}"))
				FileUtils.mv("#{@options[:working_dir]}/#{@options[:layers_file]}","#{@options[:working_dir]}/temp.bak")
				FileUtils.cp("#{@options[:working_dir]}/#{@options[:layers_file_backup]}","#{@options[:working_dir]}/#{@options[:layers_file]}") 
				FileUtils.mv("#{@options[:working_dir]}/temp.bak","#{@options[:working_dir]}/#{@options[:layers_file_backup]}")
				load
				return self
			end
			
			# Selects the specified layer by name or id and copies the layer and associated script.
			# The cloned layer is then selected.
			def clone_layer(id,name=nil)
				original_layer = select(id)
				layer_name = (name.nil?)? original_layer.name : name
				create_new_layer(layer_name)	#this selects the new layer			
				new_layer = selected_layer
				FileUtils.cp original_layer.script.path, new_layer.script.path				
				save
				return self
			end
			
			alias :copy :clone_layer
			
			def to_s
				msg = "Sketch:"
				@layers.
				values.
				sort{ |a,b| a.order <=> b.order}.
				each{|layer| msg = msg + "\n\t"+layer.to_s}
				return msg
			end
			
			def delete_layer(id)
				select(id)
				delete_layers = []
				layers do |layer|
					if layer.active 
						FileUtils.mv layer.script.path, "#{@options[:working_dir]}/#{@options[:trash]}/#{File.basename(layer.script.path)}"
						delete_layers << layer.id
					end
				end				
				delete_layers.each{|dl| @layers.delete(dl)}
				return self
			end
			
			alias :delete :delete_layer
			
			def number_of_layers
				@layers.size
			end
			
			# Creates a new layer with the given name. Returns the layer's id.
			def create_new_layer(name)
				id = make_layer(name)
				make_script(id)
				select(id)
				return self
			end
			
			alias :add :create_new_layer
			
			def get_layer(id)
				error("The sketch does not contain the layer #{id}", !@layers.has_key?(id))
				return @layers[id]
			end
			
			# Select a specified layer. 
			# First tries to use the layer id, then the name.
			def select(id)						
				layers do |layer| 
					if layer.id == id
						layer.active = true						
					else
						layer.active = (layer.name.downcase == id.downcase)
					end					
				end				
				return @layers.values.find{|layer| layer.active == true}
			end
			
			def selected_layer
				@layers.values.find{|layer| layer.active == true}
			end

			# iterate over the layers in sorted order
			def layers(&block)
				@layers.
				values.
				sort{ |a,b| a.order <=> b.order}.
				each(&block)
			end
			
			# move the selected layer farther away from the viewer
			def move_farther_away
				layer = selected_layer()
				if layer.nil?
					return self
				end
				sorted_layers = @layers.values.sort{|a, b| a.order <=> b.order}
				index = sorted_layers.index{|a| a.id.eql?(layer.id)}				
				return if index.nil? || index == sorted_layers.size - 1
				top = sorted_layers[index+1].order				
				bottom = sorted_layers[index].order				
				sorted_layers[index].order = top
				sorted_layers[index + 1].order = bottom	
				return self
			end
			
			#brings the selected layer closer to the foreground
			def move_closer
				layer = selected_layer()
				if layer.nil?
					return self
				end
				sorted_layers = @layers.values.sort{|a, b| a.order <=> b.order}
				index = sorted_layers.index{|a| a.id.eql?(layer.id)}				
				return if index.nil? || index == sorted_layers.size - 1
				top = sorted_layers[index].order				
				bottom = sorted_layers[index-1].order				
				sorted_layers[index].order = bottom
				sorted_layers[index - 1].order = top	
				return self
			end
			
			def rename_layer(id, new_name)
				layer = get_layer(id)
				new_script = rename_script(id, new_name)
				layer.script.path = new_script
				layer.name = new_name
				return self
			end
			
			alias rename rename_layer
			
			def clean(type)
				case type
				when :trash
					clean_trash
				when :output
					clean_output										
				when :logs
					clean_logs
				when :all
					clean_logs
					clean_output
					clean_trash
				else
					raise StandardError.new "Layers Management does not have a clean type of #{type}"
				end
				return self
			end
			
			# YUCK. Refactor this method. Consider having composite validation rules for the renderer.
			# If I go that route, replace the current sketch load validation with the same pattern.
			def render					
				# Create a logger specific for rendering if one hasn't been set		
				if (@options[:render_logger] == true)
					@render_logger = Jitterbug::Logging::JitterLogger.new(@options,"render.log") 				  
				else
					@render_logger = @options[:render_logger]
				end

				# Validate the sketch size
				@render_logger.info "Prepping renderer."
				if @engine.assembled? 
					@engine.bind_sketch(self)
					@engine.render()  
				else
					raise StandardError.new("Could not render. The rendering engine is not fully assembled. Missing parts: #{@engine.missing_pieces}")
				end
				
				@render_logger.info "Rendering complete."
				return self
			end
			
			private
			def clean_trash
				FileUtils.remove_dir("#{@options[:working_dir]}/#{@options[:trash]}",:force=>true)
				FileUtils.mkdir("#{@options[:working_dir]}/#{@options[:trash]}")
			end

			def clean_output
				FileUtils.rm_rf("#{@options[:working_dir]}/#{@options[:output_dir]}")								
				FileUtils.mkdir_p("#{@options[:working_dir]}/#{@options[:output_dir]}/images")
				FileUtils.mkdir_p("#{@options[:working_dir]}/#{@options[:output_dir]}/video")
				FileUtils.mkdir_p("#{@options[:working_dir]}/#{@options[:output_dir]}/data")				
			end

			def clean_logs
				FileUtils.remove_dir("#{@options[:working_dir]}/#{@options[:logs]}",:force=>true)
				FileUtils.mkdir("#{@options[:working_dir]}/#{@options[:logs]}")
			end

			def validate				
				validate_working_dir(@options)
				validate_layers_file(@options)
				validate_sketch_dir(@options)
				validate_support_sketchs_dir(@options)
				validate_vendor_dir(@options)
				validate_resources_dir(@options)
				validate_output_dir(@options)
				validate_trash_dir(@options)
			end
			
			def make_layer(name)
				@layer_counter += 1
				id = "layer_#{@layer_counter}"
				@layers[id] = Layer.new do |l|
					l.name = name
					l.id = id 
					l.order = number_of_layers + 1
				end				
				return id
			end
			
			def make_script(id)		
				script_path = generate_script_path(get_layer(id).name)				
				FileUtils.touch(script_path)				
				get_layer(id).script = Script.new(File.expand_path(script_path))
			end
			
			def generate_script_path(name)				
				script_name = name.gsub(' ','_').downcase
				script_path = "#{@options[:working_dir]}/#{@options[:scripts_dir]}/#{script_name}.rb"
				count = 1
				original = script_name
				while File.exists?(script_path)			
					script_name = "#{original}_#{count}"
					script_path = "#{@options[:working_dir]}/#{@options[:scripts_dir]}/#{script_name}.rb"
					count += 1
				end		
				return script_path
			end
			
			def rename_script(id, new_name)
				new_script_path = generate_script_path(new_name)
				old_script_path = get_layer(id).script.path
				FileUtils.mv old_script_path, new_script_path 
				return new_script_path
			end			
		end
	end
end