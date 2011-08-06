require 'easy_dir'
include EasyDir

module Jitterbug
	module Sketch
		@@dirs = {
			:sketch => { #replace :sketch dynamically with the sketch dir's name
				:layers => :yml,
				:scripts  => {
					:setup => :rb,
					:clean_up => :rb					
				},
				:lib => :dir,			
				:vendor => :dir,	
				:resources => {	
					:shaders => :dir,
					:models => :dir,
					:images => :dir,
					:movies => :dir,
					:filters => :dir,
					:audio => :dir,
					},
				:output	=> {
					:images => :dir,
					:video => :dir,
					:data => :dir
				},
				:trash => :dir,
				:logs => :dir
			}
		}	
		
		def create_sketch(name, dir)						
			if File.directory?("#{dir}/#{name}")	 				
				raise StandardError.new("The directory #{dir}/#{name} already exists.")
			end
			temp = @@dirs.clone
			sketch_dir = temp.delete(:sketch)
			temp[name] = sketch_dir			
			create_dirs(temp, dir)	
		end
	end
end