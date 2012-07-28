require "rspec/core/rake_task"

desc "Run all image output based tests (requires OpenImageIO to be installed)"
RSpec::Core::RakeTask.new(:image_tests) do |t|  
	ruby_options = "-I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../vendor")}\" -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../lib")}\""
  t.rspec_opts = %w[--color --format d]
  t.verbose = true
	t.pattern = "render_tests/**/*_spec.rb"
	t.ruby_opts = ruby_options 	
end