#load bundles
def load_shared_frameworks  
  frameworks_path = NSBundle.mainBundle.privateFrameworksPath.fileSystemRepresentation  
  Dir.glob(File.join(frameworks_path, '*.bundle')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|    
    require(File.join(frameworks_path,path))
  end
end

# Loading all the Ruby project files.
def load_lib
  main = File.basename(__FILE__, File.extname(__FILE__))
  resources_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation  
  Dir.glob(File.join(resources_path,'lib','**/*.{rb,rbo}')).uniq.each do |path|
    if path != __FILE__
     require(path)
    end
  end
end

def load_osx_terminal_build  
  main = File.basename(__FILE__, File.extname(__FILE__))
  resources_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation  
  Dir.glob(File.join(resources_path,'osx_terminal_build','**/*.{rb,rbo}')).uniq.each do |path|   
    require(path)    
  end  
end

def load_ruby_vendors 
  main = File.basename(__FILE__, File.extname(__FILE__))
  resources_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation 
  Dir.glob(File.join(resources_path,'vendor','*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|    
    require(File.join(resources_path,'vendor',path))    
  end  
end

load_shared_frameworks
load_ruby_vendors
load_osx_terminal_build
load_lib

=begin
require 'trollop'
require 'create_sketch'
require 'layers.rb'
require 'cmd_line_help'
=end

include Jitterbug::Sketch

global_opts = Trollop::options do
	version "Jitterbug 0.0.1 (c) 2011 Samuel Holloway"
	banner <<-EOS
Jitterbug is a graphical application designed for rapidly creating sketches in 2D and 3D.
	
Usage:
	jitterbug [options] <filename>+
	
where [options] are:	
EOS
	opt :dir, "Directory that contains the sketch", :short => "-d", :default => "."
	opt :output, "Directory that all output is rendered to", :short  => "-o", :default => "output"
end

cmd = ARGV.shift
if cmd.nil?
  help = %{
Jitterbug is a graphical application designed for rapidly creating sketches in 2D and 3D.    

For help, type
jitterbug help
  }
  puts help
  exit
end

sketch_name = ARGV.first
sketch_dir = global_opts[:dir]
begin
  active_env = Jitterbug::Env::OSXEnv.new()
	cmd_opts = case cmd.downcase.to_sym
		when :create 						
			create_sketch(sketch_name, sketch_dir)
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}/#{sketch_name}", :output_dir => global_opts[:output],:env=>active_env)				
			lm.create_new_layer("Background")				
			lm.create_new_layer("Foreground")				
			lm.save
			lm.logger.close
			puts "created sketch: #{sketch_dir}/#{sketch_name}"
		when :viz #jitterbug  viz sketch_dir
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			lm.logger.close
			puts lm.to_s
		when :select
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			layer_id = ARGV.first
			lm.select(layer_id)			
			lm.save
			lm.logger.close
		when :add
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			ARGV.each{|layer_name| lm.add(layer_name)}
			lm.save
			lm.logger.close
		when :revert
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			lm.revert
			lm.logger.close
		when :move		
			direction = ARGV.shift
			case direction.downcase.to_sym				
				when :closer
					lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
					lm.load					
					lm.move_closer
					lm.save
					lm.logger.close
				when :away
					lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
					lm.load					
					lm.move_farther_away
					lm.save
					lm.logger.close
				else
					Trollop::die "Unknown subcommand #{direction.inspect}.\nMove can only be followed by closer or away.\njitterbug -d sketch move up layer_name"
				end			
		when :clean
			type = ARGV.shift
			if type.nil?
			  type = :all
		  end
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			case type.downcase.to_sym
				when :trash
					lm.clean(:trash)
				when :output
					lm.clean(:output)
				when :logs
				  lm.clean(:logs)
				when :all
					lm.clean(:trash)
					lm.clean(:output)
					lm.clean(:logs)
				else
					lm.logger.close
					Trollop::die "Unknown subcommand #{type.inspect}.\nClean can only be followed by trash or output.\njitterbug -d clean trash"
				end
				lm.logger.close
		when :delete			
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			ARGV.each{|layer_name| lm.delete(layer_name)}
			lm.save
			lm.logger.close
		when :copy
      id = ARGV.shift
      lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
      lm.load
      if ARGV.empty? 
        lm.copy(id)
      else
        name = ARGV.shift
        lm.copy(id,name)
      end
      lm.save
			lm.logger.close
		when :rename
		  if ARGV.size != 2
		    puts %{\tRenaming a layer requires a layer and new name be specified.
  Example
    jitterbug rename my_layer as_new_name
	      }
		    exit
	    end
	    lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			lm.rename(ARGV.shift,ARGV.shift)
			lm.save
			lm.logger.close
		when :render
			lm = Jitterbug::Layers::LayersManager.new(:working_dir => "#{sketch_dir}", :output_dir => global_opts[:output],:env=>active_env)
			lm.load
			lm.render
			lm.logger.close
		when :help
      if ARGV.empty?
        usage = %{
  jitterbug -h/--version
  jitterbug -d/--dir
  jitterbug -o/--output
  jitterbug [options] [command] [args]}
        
        examples = %{
  jitterbug -d sketch_path create foo   creates the sketch at the directory sketch_path",
  jitterbug viz                         visualizes the sketch",
  jitterbug add Blue                    adds a layer named Blue to a sketch in the working directory",        
  jitterbug help                        displays this message",
  jitterbug help commands               show list of commands",
  jitterbug help <COMMAND>              show help on COMMAND"}
        puts "Usage:"
        puts usage
        puts "\n\n"
        puts "Examples:"
        puts examples
        puts ""
      else
        cmd = ARGV.shift
        help = Jitterbug::CmdLineHelp.new
        help.process(cmd)
      end
		else			
			Trollop::die "unknown subcommand #{cmd.inspect}"
		end
rescue => e
	puts e.message
	puts e.backtrace #this shouldn't occur on shipped version. Perhaps should only be enabled on -v?
end