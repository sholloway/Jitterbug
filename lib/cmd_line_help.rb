module Jitterbug
  class CmdLineHelp
    Command = %{
  Jitterbug commands are:

  create    Creates a new sketch
  add       Adds a layer to the sketch
  select    Selects a layer
  move      Moves a layer
  copy      Copies a layer
  rename    Renames a layer
  delete    Deletes a layer
  revert    Replaces the current layer.yml file with it's backup
  clean     Empties the trash
  viz       Visualizes the current layer stack
  render    Renders the layer stack to the output directory

    }
    Create = %{
  Summary:            
    Creates a new sketch.

  Usage:
    jitterbug [options] create [name]

  Options:
    -d/--dir  The directory to create the sketch in

    }
    Viz = %{
  Summary:            
    Displays the layer stack.

  Usage:
    jitterbug [options] viz

  Options:
    -d/--dir  The full path to the sketch directory.
      
    }
    Select = %{
  Summary:            
    Selects a layer given it's name or id.

  Usage:
    jitterbug [options] select [name]

  Options:
    -d/--dir  The directory the sketch is in.

    }
    Add =  %{
  Summary:            
    Adds a layer to an existing sketch.
    Multiple layers can be added by providing their names or ids in a space seperated list.

  Usage:
    jitterbug [options] add [layer name]
    jitterbug [options] add [layer_name_1 layer_name_2 layer_name_3]

  Options:
    -d/--dir  The directory the sketch is in.
      
    }
    Revert = %{
  Summary:            
    Restores the layer stack from the layer.yml.bak file. 
    WARNING!!! This cannot be undone.

  Usage:
    jitterbug [options] restore

  Options:
    -d/--dir  The directory the sketch is in.

    }
    Move =  %{
  Summary:            
    Moves the selected layer up or down in the stack or rather 
    closer or away from the camera.

  Usage:
    jitterbug [options] move closer
    jitterbug [options] move away

  Options:
    -d/--dir  The directory the sketch is in.

    }
    Clean = %{
  Summary:            
    Empties the trash bin 
    WARNING!!! This cannot be undone.

  Usage:
    jitterbug [options] clean [subcommand]

  Options:
    -d/--dir      The directory the sketch is in.
    -o/--output   The output directory.

  Subcommands
    trash         Empties the trash directory
    output        Empties the output directory
    logs          Empties the logs directory
    all           Empties both the trash and output

    }
    Delete = %{
  Summary:            
    Deletes a layer specified by it's name or id. 
    Multiple layers can be deleted by providing their names or ids in a space seperated list.

  Usage:
    jitterbug [options] delete [layer name]
    jitterbug [options] delete [layer_name_1 layer_name_2 layer_name_3]

  Options:
    -d/--dir  The directory the sketch is in.            

    }
    Copy = %{
  Summary:            
    Copies a layer specified by it's name or id. 
    You can specify the new layer's name. If no name is given the new layer is named
    with the same name as the existing layer, but with an incremented layer id.

  Usage:
    jitterbug [options] copy [layer name]
    jitterbug [options] copy [layer_name] [new_layer_name]

  Options:
    -d/--dir  The directory the sketch is in.            
    }
    Rename =  %{
  Summary:
    Renames a layer specified by it's name or id.

  Usage:
    jitterbug [options] rename [layer_name] [new_name]

  Options:
    -d/--dir  The directory the sketch is in.   

    }
    Render = %{
  Summary:            
    Renders the layer stack to the output directory

  Usage:
    jitterbug [options] render

  Options:
    -d/--dir      The directory the sketch is in.
    -o/--output   The output directory.            
    }
    def initalize()
    end
    
    def process(cmd)
      case cmd.downcase.to_sym
      when :commands
        puts Command
      when :create
        puts Create
      when :viz
        puts Viz
      when :select
        puts Select
      when :add
        puts Add
      when :revert
        puts Revert
      when :move
        puts Move
      when :clean
        puts Clean
      when :delete
        puts Delete
      when :copy
        puts Copy
      when :rename
        puts Rename
      when :render
        puts Render
      else
        puts "no help for command #{cmd}"  
        exit
      end
    end
  end
end