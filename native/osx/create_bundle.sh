#!/bin/sh

# need to think about the paths...
echo 'About to create make file.'
/usr/local/bin/macruby extconf.rb
echo 'Make file generated'
echo 'About to compile bundle'
make -f Makefile
echo 'Bundle compiled'

#copy to native/bin
