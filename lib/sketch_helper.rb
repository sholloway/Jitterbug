module Jitterbug
	module Layers
		WORKING_DIR_MSG = "The working directory for the sketch must be set."
		LAYER_FILE_MSG = "The sketch.yml file could not be found in"
		SCRIPT_DIR_MSG = "The script directory could not be found in"
		SUPPORT_DIR_MSG = "The support scripts directory could not be found in"
		VENDOR_DIR_MSG = "The vendor directory could not be found in"
		RESOURCES_DIR_MSG = "The resources directory could not be found in"
		SHADERS_DIR_MSG = "The shaders directory could not be found in"
		MODELS_DIR_MSG = "The models directory could not be found in"
		IMAGES_DIR_MSG = "The images directory could not be found in"
		MOVIES_DIR_MSG = "The movies directory could not be found in"
		FILTERS_DIR_MSG = "The image filters directory could not be found in"
		AUDIO_DIR_MSG = "The audio directory could not be found in"
		OUTPUT_DIR_MSG = "The output directory could not be found in"
		IMAGE_OUTPUT_MSG = "The images output directory could not be found in"
		VIDEO_OUTPUT_MSG = "The video output directory could not be found in"
		DATA_OUTPUT_MSG = "The data output directory could not be found in"
		TRASH_DIR_MSG = "The trash directory could not be found in"
		
		def error(msg, test)
			if test				
				raise StandardError.new(msg) 
			end			
		end
		
		def validate_working_dir(options)
			#raise StandardError.new("The working directory for the sketch must be set.") if !options.has_key?(:working_dir) || options[:working_dir] == false
			error(WORKING_DIR_MSG, 
				!options.has_key?(:working_dir) || options[:working_dir] == false)
		end
		
		def validate_layers_file(options)
			error("#{LAYER_FILE_MSG} #{options[:working_dir]}", 
				!File.exists?("#{options[:working_dir]}/#{options[:layers_file]}"))
		end
		
		def validate_sketch_dir(options)
			error("#{SCRIPT_DIR_MSG} #{options[:working_dir]}", 
				!File.directory?("#{options[:working_dir]}/#{options[:scripts_dir]}"))
		end
		
		def validate_support_sketchs_dir(options)
			error("#{SUPPORT_DIR_MSG} #{options[:working_dir]}", 
				!File.directory?("#{options[:working_dir]}/#{options[:support_scripts]}"))
		end
		
		def validate_vendor_dir(options)
			error("#{VENDOR_DIR_MSG} #{options[:working_dir]}", 
				!File.directory?("#{options[:working_dir]}/#{options[:vendor]}"))
		end
		
		def validate_resources_dir(options)
			error("#{RESOURCES_DIR_MSG} #{options[:working_dir]}", 
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}"))
			validate_shaders_dir(options)
			validate_models_dir(options)
			validate_images_dir(options)
			validate_movies_dir(options)
			validate_image_filters_dir(options)
			validate_audio_dir(options)
		end
		
		def validate_shaders_dir(options)
			error("#{SHADERS_DIR_MSG} #{options[:working_dir]}/#{options[:resources_dir]}", 
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}/#{options[:shaders_dir]}"))
		end			
		
		def validate_models_dir(options)
			error("#{MODELS_DIR_MSG} #{options[:working_dir]}/#{options[:resources_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}/#{options[:models_dir]}"))
		end			
		
		def validate_images_dir(options)
			error("#{IMAGES_DIR_MSG} #{options[:working_dir]}/#{options[:resources_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}/#{options[:images_dir]}"))
		end
		
		def validate_movies_dir(options)
			error("#{MOVIES_DIR_MSG} #{options[:working_dir]}/#{options[:resources_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}/#{options[:movies_dir]}"))
		end
		
		def validate_image_filters_dir(options)
			error("#{FILTERS_DIR_MSG } #{options[:working_dir]}/#{options[:resources_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}/#{options[:image_filters_dir]}"))
		end
		
		def validate_audio_dir(options)
			error("#{AUDIO_DIR_MSG} #{options[:working_dir]}/#{options[:resources_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:resources_dir]}/#{options[:audio_dir]}"))
		end
		
		def validate_output_dir(options)
			error("#{OUTPUT_DIR_MSG} #{options[:working_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:output_dir]}"))
			validate_images_output_dir(options)
			validate_video_output_dir(options)
			validate_data_output_dir(options)
		end
		
		def validate_images_output_dir(options)
		  error("#{IMAGE_OUTPUT_MSG} #{options[:working_dir]}/#{options[:output_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:output_dir]}/#{options[:image_output_dir]}"))
		end
		
		def validate_video_output_dir(options)
			error("#{VIDEO_OUTPUT_MSG} #{options[:working_dir]}/#{options[:output_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:output_dir]}/#{options[:video_output_dir]}"))
		end
		
		def validate_data_output_dir(options)
			error("#{DATA_OUTPUT_MSG} #{options[:working_dir]}/#{options[:output_dir]}",
				!File.directory?("#{options[:working_dir]}/#{options[:output_dir]}/#{options[:data_output_dir]}"))
		end
		
		def validate_trash_dir(options)
			error("#{TRASH_DIR_MSG} #{options[:working_dir]}",
				!File.directory?("#{options[:working_dir]}/trash"))
		end
	end
end