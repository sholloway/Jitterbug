require 'delegate'
module Jitterbug
  module Sketch
    class Context < DelegateClass(Hash)
      States = [
        :background_color #the color to clear to.
        ]
      
      def initialize
        super({})
      end
      
      #should only take symbols
      def []=(k,v)
        validate(k)
        __getobj__[k] = v
      end
      
      #some madness to make obj-c happy with handling symbols.
      def fetch(key)
        sym = key.to_sym
        return __getobj__[sym]       
      end
      
      def validate(key)
        raise Exception.new("The sketch state #{key} is not valid.\nThe only valid states are:\n#{States}") unless States.include?(key)
      end
    end
  end
end