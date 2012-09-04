=begin
Planned rake tasks
  create_foxtrot
  run_foxtrot
  create_gui_app
  run_gui_app
  run_ruby_tests
  run_native_tests
  debug_with_gdb  
  
Help:
  On the command line run: rake -T 
  to see a list of all available commands
  
Application Structure
Compiled GUI Application Directory Structure
 Name.app
   Contents
     Info.plist
     MacOS
       the executible
     Resources
       all ruby code
       all non-localized images
       English.lproj 
         InfoPlist.strings
         Localizable.strings
         MainMenu.nib
     Frameworks
       all required frameworks
     

Compiled Terminal Application Directory Structure
 Name.app
   Contents
     MacOS
       the executible
     Resources
       all ruby code
     Frameworks
       all required frameworks

=end

#Application Meta-data
GUI_NAME 		= 'Jitterbug'
TERM_NAME   = 'Foxtrot'
COMPANY = 'mod89'
GUI_APP_VERSION = '1.0.0'
GUI_BUILD_VERSION = '1'
GUI_IDENTIFIER 	= "com.#{COMPANY}.#{GUI_NAME}"
TERM_IDENTIFIER = "com.#{COMPANY}.#{TERM_NAME}"

$: << '.' #for ruby 1.9
require 'build_scripts/debug_utilities'
require 'build_scripts/ruby_test_runner.rb'
require 'build_scripts/renderer_test_runner.rb'
require 'build_scripts/utilities'
require 'build_scripts/osx_terminal_framework'
require 'build_scripts/osx_terminal_app'
require 'build_scripts/native_tasks.rb'

task :default => :create_foxtrot

require 'rake/clean'
CLEAN.include('**/*.o','**/*.log')
CLOBBER.include("#{TERM_NAME}.app",
  "#{TERM_FRAMEWORK_NAME}.bundle")