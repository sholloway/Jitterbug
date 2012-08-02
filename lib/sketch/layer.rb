module Jitterbug
  module Sketch
    class Layer 
			attr_accessor :id,:visible, :order, :script, :active, :name
			attr_accessor :type #can be :two_dim, :three_dim
			def initialize				  
			  @visible = true
			  @active = false			  	 
			  @type = :two_dim			 
				yield self if block_given?
			end		

			def to_s
				"|#{(active)? '*':' '}|#{name} |#{(visible)? 'V' : 'X'}|#{id}|#{order}|"
			end
		end
  end
end