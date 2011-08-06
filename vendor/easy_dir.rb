require 'fileutils'

module EasyDir
	# Creates a directory structure based on the hash "dirs" in the "current_dir"
	def create_dirs(dirs,current_dir)		
		dirs.each_pair do |key, value|
			if value.class == Hash then
				make_dir(key,current_dir)				
				create_dirs(value,"#{current_dir}/#{key}")
			else 
				if value == :dir				
					make_dir(key,current_dir)									
				else
					make_file(key,value,current_dir)
				end
			end
		end
	end

	def make_dir(name, current_dir)		
		FileUtils.mkdir_p("#{current_dir}/#{name}")
	end

	def make_file(name,ext,current_dir)		
		FileUtils.touch("#{current_dir}/#{name}.#{ext}")
	end
end

#example
if __FILE__ == $PROGRAM_NAME
	include EasyDir
	dirs = {
		:sketch => {
			:layers => :yaml,
			:scripts  => {
				:setup => :rb,
				:clean_up => :rb,
				:background => :rb,
				:design => :rb
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
			}
		}
	}
	
	create_dirs(dirs, FileUtils.pwd)
end



