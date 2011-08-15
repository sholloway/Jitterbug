#!/bin/sh
cd ext/osx
/usr/bin/rake clobber
/usr/bin/rake
cd ../../experiments
echo 'About to run OpenGL API harnness.'
macruby link.rb 
echo 'All done.'