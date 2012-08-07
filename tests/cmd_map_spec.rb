Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe Jitterbug::Command::Map do
  before(:all) do
   @map = Jitterbug::Command::Map.commandline_map
  end
  
  it 'should map :create to Jitterbug::Command::CreateSketch' do
    @map[:create].should be Jitterbug::Command::CreateGLSLImageSketch
  end
  
  it 'should map :viz => Jitterbug::Command::VisualizeSketch' do
    @map[:viz].should be Jitterbug::Command::VisualizeSketch
  end
  
  it 'should map :select => Jitterbug::Command::SelectLayer' do
    @map[:select].should be Jitterbug::Command::SelectLayer
  end
  
  it 'should map :add => Jitterbug::Command::AddLayer' do
    @map[:add].should be Jitterbug::Command::AddLayer
  end
  
  it 'should map :revert => Jitterbug::Command::RevertSketch' do
    @map[:revert].should be Jitterbug::Command::RevertSketch
  end
  
  it 'should map :move => Jitterbug::Command::MoveLayer' do
    @map[:move].should be Jitterbug::Command::MoveLayer
  end
  
  it 'should map :clean => Jitterbug::Command::CleanSketch' do
    @map[:clean].should be Jitterbug::Command::CleanSketch
  end
  
  it 'should map :delete => Jitterbug::Command::DeleteLayer' do
    @map[:delete].should be Jitterbug::Command::DeleteLayer
  end
  
  it 'should map :copy => Jitterbug::Command::CopyLayer' do
    @map[:copy].should be Jitterbug::Command::CopyLayer
  end
  
  it 'should map :rename => Jitterbug::Command::RenameLayer' do
    @map[:rename].should be Jitterbug::Command::RenameLayer
  end
  
  it 'should map :render => Jitterbug::Command::RenderSketch' do
    @map[:render].should be Jitterbug::Command::RenderSketch
  end
    
  it 'should map :help => Jitterbug::Command::CmdHelp' do
    @map[:help].should be Jitterbug::Command::CmdHelp
  end  
  
  it 'should return Jitterbug::Command::MissingCmd for missing keys' do
    @map[:does_not_exist].should be Jitterbug::Command::MissingCmd
  end
end