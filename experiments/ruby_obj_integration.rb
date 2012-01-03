framework 'Foundation'
framework 'Cocoa'
framework 'OpenGL'
framework 'AppKit'
require File.join(File.expand_path(File.dirname(__FILE__)),"./../ext/bin/macos_jitterbug")

class MyGraphicsScript < GraphicsScript
  attr_accessor :script
  def initialize()
    super.alloc.init
    self
  end
  
  def run
    instance_eval(@script)
  end
end

mgs = MyGraphicsScript.new
src = %{
  setFilter("A")
  puts getFilter()
}
mgs.script = src

mgsB = MyGraphicsScript.new
srcB = %{
  setFilter("B")
  puts getFilter()
}
mgsB.script = srcB

mgsC = MyGraphicsScript.new
srcC = %{
  setFilter("C")
  puts getFilter()
}
mgsC.script = srcC

runner = GraphicsScriptRunner.alloc.init
runner.setScripts([mgs,mgsB, mgsC])
runner.run