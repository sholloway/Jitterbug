require 'init_utilities'
require 'resources'
require 'cmd_map'
include Jitterbug::Init

load_shared_frameworks
load_ruby_code

global_opts = Trollop::options do
	version Jitterbug::Resources::Text::Main::Version
	banner Jitterbug::Resources::Text::Main::Banner	
	opt :dir, Jitterbug::Resources::Text::Main::DirOption, :short => "-d", :default => "."
	opt :output, Jitterbug::Resources::Text::Main::OutputOption, :short  => "-o", :default => "output"
end

cmd = ARGV.shift
if cmd.nil?
  help = Jitterbug::Resources::Text::Main::NoArgs
  puts help
  exit
end

command_options = {:sketch_dir => global_opts[:dir], 
  :output_dir => global_opts[:output],
  :environment => Jitterbug::Env::OSXEnv.new(),
  :cmd_line_args => ARGV.clone}
  
begin  
  commands = Jitterbug::Command::Map.commandline_map    
  command_stmt = cmd.downcase.to_sym  
  command = commands[command_stmt]
  response = command.new(command_options).process 
  #could possibly pass ARGV as a param to cmd.process, then cmd would just expect an array. 15 touch points
  #would prefer to pass it throught the constructor, however that is currently taking an options hash
  puts response.message 
rescue => e
	puts e.message
	puts e.backtrace #this shouldn't occur on shipped version. Perhaps should only be enabled on -v?
end