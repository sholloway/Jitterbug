require 'create_sketch'
require 'visualize_sketch'
require 'select_layer'
require 'add_layer'
require 'revert_sketch'
require 'move_layer'
require 'clean_sketch'
require 'delete_layer'
require 'copy_layer'
require 'rename_layer'
require 'render_sketch'
require 'cmd_help'
require 'missing_cmd'

module Jitterbug
  module Command
    class Map
      def Map.commandline_map
        @@commands = {:create => Jitterbug::Command::CreateSketch,
          :viz => Jitterbug::Command::VisualizeSketch,
          :select => Jitterbug::Command::SelectLayer,
          :add => Jitterbug::Command::AddLayer,
          :revert => Jitterbug::Command::RevertSketch,
          :move => Jitterbug::Command::MoveLayer,
          :clean => Jitterbug::Command::CleanSketch,
          :delete => Jitterbug::Command::DeleteLayer,
          :copy => Jitterbug::Command::CopyLayer,
          :rename => Jitterbug::Command::RenameLayer,
          :render => Jitterbug::Command::RenderSketch,
          :help => Jitterbug::Command::CmdHelp}
        @@commands.default = Jitterbug::Command::MissingCmd
        return @@commands
      end
    end    
  end
end