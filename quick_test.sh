#!/bin/sh
cd native/osx
sh ./create_bundle.sh
cd ../../experiments
echo 'About to run OpenGL API harnness.'
macruby link.rb 
echo 'All done.'