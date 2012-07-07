module Jitterbug
  module Sketch
    class Layer2d < JBGraphicsScript
      attr_accessor :script # The user defined script's path. 
      attr_accessor :name, :logger
      
      # The SketchContext that is passed from sketch to sketch.
      def initialize    
        super.alloc.init          
        self
      end

      def run
        begin
          @logger.info("About to evaluate layer: #{@name}")
          script_content = fetch_script
          @logger.info("#{script_content}")
          instance_eval(script_content)
        rescue => e
          #put in logger
          @logger.error "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          @logger.error "An exception was raised while running layer #{@name}"
          @logger.error e.message
          e.backtrace.each{|error| @logger.error error}          
          @logger.error "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          raise StandardError.new("The user script '#{@name}' threw an error. Please see ./logs/render.log for details.")
        end
      end
      
      #Sets the current background clear color and clears the screen with it.
      def background(color)
        #need to validate the color
        context[:background_color] = color
        clear #defined in Objective-C++ on JBGraphicsScript.mm
      end
      
      #Creates an rgba color scaled (0.0-1.0).
      def color(red, green, blue, alpha)     
        return RBColor.new(red, green, blue, alpha)   
        #return JBColor.alloc.initWithColorRed(red.to_f,green:green.to_f, blue:blue.to_f, alpha:alpha.to_f)
      end
      
      def fill(color)
        context[:fill_color] = color
      end
      
      #figure out batching vs on demand drawing
      #draw with the active color, set by fill()
      # for now, just support batch mode.
      def point(x,y,z=nil)
       
      end
      
      def point_size(size)
        context[:point_size] = size
      end
      
      private
      def fetch_script
        file = ''
        open(@script,'r'){|f| file = f.read}
        return file
      end
    end
    
    class RBColor
      attr_accessor :red, :green, :blue, :alpha
      def initialize(red, green, blue, alpha)
        @red = red.to_f
        @green = green.to_f
        @blue = blue.to_f
        @alpha = alpha.to_f
      end
    end
  end
end