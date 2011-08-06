require "rspec/core/rake_task"
@ruby_options = ""

task :default => [:run_rspec]
#task :run_rspec => [:load_src_to_path,:load_vendors]

task :load_src_to_path do  		
  #$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"lib"))
  @ruby_options = "#{@ruby_options} -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"lib")}\""
end

task :load_vendors do  	
	@ruby_options = "#{@ruby_options} -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"vendor")}\""
	#$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"vendor"))
=begin
  ruby_dirs = Dir.glob("vendor/**/lib"). 
    reject{|file| !File.directory?(file)}.
    map{|dir| File.join(File.expand_path(File.dirname(__FILE__)),dir)}    
    ruby_dirs.each{|d| $:.unshift(d)}
=end
end
	
desc "Run all tests"
RSpec::Core::RakeTask.new(:run_rspec) do |t|  
	@ruby_options = "#{@ruby_options} -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"lib")}\""
	@ruby_options = "#{@ruby_options} -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"vendor")}\""
  t.rspec_opts = %w[--color]
  t.verbose = false
	t.pattern = "tests/**/*_spec.rb"
	t.ruby_opts = @ruby_options 
end	

