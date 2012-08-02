module Jitterbug
  module Sketch
    class Script
		  attr_accessor :path
		  attr_reader :content
		  def initialize(path=nil)
		    @dirty = false
		    @path = path
	    end
	    
	    def content=(new_script_content)
	      unless new_script_content.nil? || new_script_content.empty?
          @dirty = true
          @content = new_script_content
        end
      end
      
	    def save
	      if dirty?
	        open(@path,'w'){|f| f << @content}
        end
	      @dirty = false	      
      end
      
      def load
        if (File.exists?(@path))
          @content = fetch_script
          @dirty = false
        else
          raise Exception.new("Bad path on Layer's Script. #{@path} could not be found.")
        end
      end
      
      def dirty?
        @dirty
      end
      
      private
      def fetch_script
        file = ''
        open(@path,'r'){|f| file = f.read}
        return file
      end
	  end
  end
end