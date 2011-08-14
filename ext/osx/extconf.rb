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
$CFLAGS << ' -fobjc-gc -g '             #parms for the make file. Specifies enable garbage collection

create_makefile("macos_jitterbug")      #generate the make file to build the Objective-C Jitterbug bundle