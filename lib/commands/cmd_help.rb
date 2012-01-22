require 'command'
require 'resources'
module Jitterbug
  module Command
    class CmdHelp < Base
      def process
        msg = ''
        if ARGV.empty?
          usage = Jitterbug::Resources::Text::Main::Usage        
          examples = Jitterbug::Resources::Text::Main::Examples

          msg = %{
Usage:
#{usage}
                    
Examples:
#{examples}
          
}
        else
          cmd = ARGV.shift
          help = Jitterbug::CmdLineHelp.new          
          msg = help.process(cmd)
        end
        return CommandResponse.new(msg)
      end
    end 
  end
end