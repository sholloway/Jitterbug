require 'erb'

class GraphicsScript
  attr_accessor :filters, :context, :shaders, :models, :script, :proc
  def initialize(proc)
    @filters = ['histogram','linear','edge']
    @proc = proc
  end
  
  def render
    @proc.call
  end
end

class String
  def to_proc    
    eval "lambda{#{self}}"
  end
end

# I think this is superior
# The trick here, is passing the script to Obj-C++ and calling :render inside of that.
class GraphicsScript2
  attr_accessor :filters, :context, :shaders, :models, :script
  def initialize(script)
    @filters = ['histogram','linear','edge']
    @script = script
  end
  
  def render
    instance_eval(@script)
  end
end

describe 'GraphicsScript' do
  it 'should create a script object from a string' do 
    a = %{
      @filters.each{|f| puts f}
    }
    
    b = %{
      puts "different msg"
    }
    
    c = %{
      puts "yet another msg"
      puts "with multiple lines"
    }
        
    scripts = []
    #GraphicsScript.send(:define_method, :render, a.to_proc)    
    # scripts << GraphicsScript.new(a.to_proc)     
    # scripts << GraphicsScript.new(b.to_proc)      
    # scripts << GraphicsScript.new(c.to_proc)  
    
    scripts << GraphicsScript2.new(a)     
    scripts << GraphicsScript2.new(b)      
    scripts << GraphicsScript2.new(c)  
    scripts.map(&:render)
  end 
end