#This will requires 'macgem install dispatch'
# https://github.com/gunn/dispatch
#This can only be run by macruby.
require 'dispatch' #wraps GCD
map_reduce = (0..1_000_000).p_mapreduce(0){|n| Math.sqrt(n)} 
puts map_reduce