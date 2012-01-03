#!/usr/bin/ruby -w
#need to figure out how to support multiple ruby shebangs for supporting both windows and OS X

def run_fast
	init_log
	load_src_to_path
	load_vendors	
  add_extensions_to_search_path
  require File.join(File.expand_path(File.dirname(__FILE__)),"lib/main")
end

def init_log	
end

def load_src_to_path 	
  $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"lib"))
end

def load_vendors 	
	$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"vendor"))
  ruby_dirs = Dir.glob("vendor/**/lib"). 
    reject{|file| !File.directory?(file)}.
    map{|dir| File.join(File.expand_path(File.dirname(__FILE__)),dir)}    
    ruby_dirs.each{|d| $:.unshift(d)}
end

def add_extensions_to_search_path
  $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)),"ext/bin"))
end
	
if __FILE__ == $PROGRAM_NAME
	run_fast
end