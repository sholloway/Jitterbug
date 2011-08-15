=begin
What might be nice, is if I have a common set of headers at the Native level and then each OS has it's own implementation.
It might be better to use C++ for the mac implementation if that's the case...
native
  include
  osx - Objective-C?
  windows - C++
  linux - C++
=end
framework 'Cocoa'
framework 'OpenGL'

require 'mkmf'                          #Part standard ruby library. Creates make files

#generate the full path?
#$CFLAGS << ' -x c++ '       #parms for the make file. Specifies enable garbage collection and use C++ headers
=begin
path = File.join(File.expand_path(File.dirname(__FILE__)),"../vendor/glm-0.9.2.3")
dir_config('glm',idefault=path,ldefault=nil)
if have_header('glm/glm.hpp')  
  find_header('glm/glm.hpp')
else
  puts "Could not load OpenGL Mathmatics headers."
  exit(-1)
end
=end
path = File.join(File.expand_path(File.dirname(__FILE__)),"../bin")
puts path
find_library("opengl_glm.bundle", nil, path) # I don't think this works with bundles

$CFLAGS << " -fobjc-gc -g " 
create_makefile("macos_jitterbug")      #generate the make file to build the Objective-C Jitterbug bundle