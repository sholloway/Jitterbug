require File.join(File.expand_path(File.dirname(__FILE__)),"..","macos_jitterbug")
Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}