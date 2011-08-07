framework 'Cocoa'
framework 'OpenGL'

require 'mkmf'                          #Part standard ruby library. Creates make files
$CFLAGS << ' -fobjc-gc -g '             #parms for the make file. Specifies Objective-C
create_makefile("macos_jitterbug")      #generate the make file to build the Objective-C Jitterbug bundle