require 'resources'
module Jitterbug
  class CmdLineHelp    
    def initialize
      @help = {:commands => Jitterbug::Resources::Text::Help::Command,
        :create => Jitterbug::Resources::Text::Help::Create, 
        :viz => Jitterbug::Resources::Text::Help::Viz, 
        :select => Jitterbug::Resources::Text::Help::Select,
        :add => Jitterbug::Resources::Text::Help::Add,
        :revert => Jitterbug::Resources::Text::Help::Revert,
        :move => Jitterbug::Resources::Text::Help::Move,
        :clean => Jitterbug::Resources::Text::Help::Clean,
        :delete => Jitterbug::Resources::Text::Help::Delete,
        :copy => Jitterbug::Resources::Text::Help::Copy,
        :rename => Jitterbug::Resources::Text::Help::Rename,
        :render => Jitterbug::Resources::Text::Help::Render}
    end
     
    def process(cmd)
      command = cmd.downcase.to_sym
      return @help.key?(command) ? @help[command] : "no help for command #{cmd}"
    end
  end
end