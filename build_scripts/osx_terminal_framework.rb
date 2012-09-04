#Compile everything in ext as a framework to be used by the terminal application. This will be called by the Rakefile.

#this must match the main method in ext/bundle.m or you'll get a missing symbol error at runtime.
TERM_FRAMEWORK_NAME = 'macos_jitterbug' 

TERM_FRAMEWORK_SRC = FileList['ext/osx/*.mm','ext/osx/*.m','osx_terminal_build/bundle.m']
TERM_FRAMEWORK_TARGET = TERM_FRAMEWORK_SRC.ext('o')
TERM_FRAMEWORK_COMPILER = 'clang'
TERM_FRAMEWORKS_DEPENDENCIES = "-framework CoreGraphics -framework OpenGL -framework Foundation -framework Cocoa -framework Macruby -framework AppKit" 
TERM_MACRUBY = "/Library/Frameworks/MacRuby.framework/Headers"
TERM_STATIC_INCLUDES = './ext/vendor/glm-0.9.2.3' 
TERM_INCLUDES = %{-Iext -I#{TERM_MACRUBY} -I#{TERM_STATIC_INCLUDES} }

TERM_COMPILE_LANG_OPTS = "-ObjC++ -fobjc-gc"
TERM_LINK_LANG_OPTS = "-ObjC++ -fobjc-gc -flat_namespace"
TERM_DEBUG_OPTS = "-undefined suppress"
TERM_ARCH_OPTS = "-arch x86_64"
TERM_LIBS = "-L. -L/Library/Frameworks/MacRuby.framework/Macruby"
TERM_RUBY_BUNDLE = "-I#{TERM_MACRUBY}/ruby.h -I#{TERM_MACRUBY}/ruby/defines.h -I#{TERM_MACRUBY}/ruby/config.h"

rule '.o' => '.mm' do |t|  
  puts "compiling #{t.name}"
  sh %{#{TERM_FRAMEWORK_COMPILER} #{TERM_ARCH_OPTS} #{TERM_COMPILE_LANG_OPTS} #{TERM_FRAMEWORKS_DEPENDENCIES} #{TERM_INCLUDES} -d -g -c -pipe -o #{t.name} #{t.source}}
end

rule '.o' => '.m' do |t|  
  puts "compiling #{t.name}"
  sh %{#{TERM_FRAMEWORK_COMPILER} #{TERM_ARCH_OPTS} -ObjC -fobjc-gc #{TERM_FRAMEWORKS_DEPENDENCIES} #{TERM_INCLUDES} -d -g -c -pipe -o #{t.name} #{t.source}}
end

#create the Framework
file "#{TERM_FRAMEWORK_NAME}.bundle" => TERM_FRAMEWORK_TARGET do  
  puts "compiling #{TERM_FRAMEWORK_NAME}.bundle"
  sh %{#{TERM_FRAMEWORK_COMPILER} #{TERM_ARCH_OPTS} #{TERM_LINK_LANG_OPTS} #{TERM_FRAMEWORKS_DEPENDENCIES} #{TERM_LIBS} -pipe -v -bundle -o #{TERM_FRAMEWORK_NAME}.bundle #{TERM_FRAMEWORK_TARGET}}
end

task :create_osx_terminal_framework => ["#{TERM_FRAMEWORK_NAME}.bundle"] do
  puts "should be done creating the terminal framework"
end