# require 'layers_helper'
require 'yaml'
require 'fileutils'
# require 'jitter_logger'
# require 'renderer/bootstrap'

module Jitterbug
	module Layers
		class Layer 
			attr_accessor :id,:visible, :order, :script, :active, :name
			attr_accessor :type #can be :two_dim, :three_dim
			def initialize				  
			  @visible = true
			  @active = false			  	 
			  @type = :two_dim			 
				yield self if block_given?
			end		

			def to_s
				"|#{(active)? '*':' '}|#{name} |#{(visible)? 'V' : 'X'}|#{id}|#{order}|"
			end
		end
		
		LayersData = Struct.new(:layers,:layer_counter)
		
		class LayersManager
			include Jitterbug::Layers
			attr_reader :options, :logger
			def initialize(options={}) # by default relative to output_dir					
					@options = {
						:working_dir=>false, #must be set, by default everything else is relative to this.
						:layers_file=>"layers.yml", 
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
						:layers_file_backup =>"layer.yml.bak",
						:logs => "logs",
						:logger => true} #allow mocking of the logger
					@options.merge!(options)
					@layers = {}
					@layer_counter = 0
					
					if @options[:logger] == true
						@logger = Jitterbug::Logging::JitterLogger.new(@options,"jitterbug.log")
					else
						@logger = @options[:logger]
					end
					
					validate
			end			
			
			def load()		
				error("The layer file: #{@options[:working_dir]}/#{@options[:layers_file]} does not exist.", 
					!File.exist?("#{@options[:working_dir]}/#{@options[:layers_file]}"))
					
				file = File.open("#{@options[:working_dir]}/#{@options[:layers_file]}")
				parsed = YAML.load(file)
				file.close
				@layers = parsed.layers
				@layer_counter = parsed.layer_counter
			end
			
			# save to @filepath layer.yml
			# backup the existing layer.yml
			# overwrite the existing layer.yml		
			def save()				
				if File.exists?("#{@options[:working_dir]}/#{@options[:layers_file]}")
					FileUtils.cp("#{@options[:working_dir]}/#{@options[:layers_file]}",
						"#{@options[:working_dir]}/#{@options[:layers_file_backup]}") 
				end
				
				data = LayersData.new(@layers,@layer_counter)
				File.open("#{@options[:working_dir]}/#{@options[:layers_file]}", "w") {|f| f.write(data.to_yaml) } 
			end
			
			def revert
				error("Could not revert. No backup file found.", 
					!File.exists?("#{@options[:working_dir]}/#{@options[:layers_file_backup]}"))
				
				FileUtils.cp("#{@options[:working_dir]}/#{@options[:layers_file_backup]}",
				"#{@options[:working_dir]}/#{@options[:layers_file]}") 
				load
			end
			
			# Selects the specified layer by name or id and copies the layer and associated script.
			def clone_layer(id,name=nil)
				selected_layer = select(id)
				layer_name = (name.nil?)? selected_layer.name : name
				new_layer_id = create_new_layer(layer_name)
				new_layer = get_layer(new_layer_id)
				FileUtils.cp selected_layer.script, new_layer.script
				select(new_layer_id)
				save
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
						FileUtils.mv layer.script, "#{@options[:working_dir]}/#{@options[:trash]}/#{File.basename(layer.script)}"
						delete_layers << layer.id
					end
				end				
				delete_layers.each{|dl| @layers.delete(dl)}
			end
			
			alias :delete :delete_layer
			
			def number_of_layers
				@layers.size
			end
			
			# Creates a new layer with the given name. Returns the layer's id.
			def create_new_layer(name)
				id = make_layer(name)
				make_script(id)
				return id
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
				return if layer.nil?
				sorted_layers = @layers.values.sort{|a, b| a.order <=> b.order}
				index = sorted_layers.index{|a| a.id.eql?(layer.id)}				
				return if index.nil? || index == sorted_layers.size - 1
				top = sorted_layers[index+1].order				
				bottom = sorted_layers[index].order				
				sorted_layers[index].order = top
				sorted_layers[index + 1].order = bottom	
			end
			
			#brings the selected layer closer to the foreground
			def move_closer
				layer = selected_layer()
				return if layer.nil?
				sorted_layers = @layers.values.sort{|a, b| a.order <=> b.order}
				index = sorted_layers.index{|a| a.id.eql?(layer.id)}				
				return if index.nil? || index == sorted_layers.size - 1
				top = sorted_layers[index].order				
				bottom = sorted_layers[index-1].order				
				sorted_layers[index].order = bottom
				sorted_layers[index - 1].order = top	
			end
			
			def rename_layer(id, new_name)
				layer = get_layer(id)
				new_script = rename_script(id, new_name)
				layer.script = new_script
				layer.name = new_name
			end
			
			alias rename rename_layer
			
			def clean(type)
				case type
					when :trash
						FileUtils.remove_dir("#{@options[:working_dir]}/#{@options[:trash]}",force=true)
						FileUtils.mkdir("#{@options[:working_dir]}/#{@options[:trash]}")
					when :output						
						path = "#{@options[:working_dir]}/#{@options[:output_dir]}/**/*".gsub('\\','/')										
						Dir.glob(path).
							reject{|file| File.directory?(file)}.
							each{|file| FileUtils.rm(file,:force => true)}
					when :logs
					  FileUtils.remove_dir("#{@options[:working_dir]}/#{@options[:logs]}",force=true)
						FileUtils.mkdir("#{@options[:working_dir]}/#{@options[:logs]}")
					else
						raise StandardError.new "Layers Management does not have a clean type of #{type}"
				end
			end
			
			def render							
				@logger = Jitterbug::Logging::JitterLogger.new(@options,"render.log")
				@logger.info "Prepping renderer."											 				
				bootstrap = Jitterbug::Render::BootStrap.new(@logger) 
				bootstrap.lace_up(self)						 
			  bootstrap.render 			  				
				@logger.info "Rendering complete."
			end
			
			private
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
				get_layer(id).script = File.expand_path(script_path)
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
				old_script_path = get_layer(id).script
				FileUtils.mv old_script_path, new_script_path 
				return new_script_path
			end
			
		end
	end
end