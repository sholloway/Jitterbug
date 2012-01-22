require 'command'
module Jitterbug
  module Command
    class MissingCmd < Base
      def process        
        return CommandResponse.new("Unknown subcommand")
      end
    end 
  end
end