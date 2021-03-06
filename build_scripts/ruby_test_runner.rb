require "rspec/core/rake_task"

desc "Run all ruby tests using rspec"
RSpec::Core::RakeTask.new(:tests) do |t|  
	ruby_options = "-I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../vendor")}\" -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../lib")}\""
  t.rspec_opts = %w[--color --format d]
  t.verbose = true
	t.pattern = "tests/**/*_spec.rb"
	t.ruby_opts = ruby_options 	
end

desc "Run all ruby tests using rspec that have been tagged with Focus"
RSpec::Core::RakeTask.new(:focused_tests) do |t|  
	#run all tests that have :focus=>true specified
	# e.g.
	# it "should do stuff", :focus=>true{run a test}
	ruby_options = "-I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../vendor")}\" -I\"#{File.join(File.expand_path(File.dirname(__FILE__)),"../lib")}\""
  t.rspec_opts = %w[--color --format d --tag focus]
  t.verbose = true
	t.pattern = "tests/**/*_spec.rb"
	t.ruby_opts = ruby_options 	
end