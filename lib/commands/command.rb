module Jitterbug
  module Command
   class Base
     def initialize(options={})
       @options = options
     end
     
     def process()
       throw CommandResponse.new(CommandResponse::Failure, "Do not initialize Jitterbug::Command::Base directly")
     end     
   end 
   
   class CommandResponse
     attr_reader :status, :message
     public 
      Failure = 0
      Success = 1     
      
      def initialize(msg, status = Success)
        @status = status
        @message = msg
      end
   end
  end
end


=begin
require 'command'
module Jitterbug
  module Command
    class Something < Base
      def process
        return CommandResponse.new("")
      end
    end 
  end
end
=end