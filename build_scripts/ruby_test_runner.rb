require "rspec/core/rake_task"

desc "Run all ruby tests using rspec"
RSpec::Core::RakeTask.new(:run_ruby_tests) do |t|  
	ruby_options = "-I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../vendor")}\" -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../lib")}\""
  t.rspec_opts = %w[--color --format d]
  t.verbose = true
	t.pattern = "tests/**/*_spec.rb"
	t.ruby_opts = ruby_options 	
end

desc "Run all ruby tests using rspec"
RSpec::Core::RakeTask.new(:test) do |t|  
	ruby_options = "-I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../vendor")}\" -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../lib")}\""
  t.rspec_opts = %w[--color --format d]
  t.verbose = true
	t.pattern = "tests/**/layers_validation_spec.rb"
	t.ruby_opts = ruby_options 	
end