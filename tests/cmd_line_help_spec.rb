Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

describe Jitterbug::CmdLineHelp do
  before(:all) do 
    @help = Jitterbug::CmdLineHelp.new
  end
  
  it "should provide an error message for commands not handled" do 
    @help.process("bad command").should == "no help for command bad command"
  end
  
  it "should provide a help message for the arguement commands" do 
    @help.process("commands").should == Jitterbug::Resources::Text::Help::Command    
  end
  
  it "should provide a help message for the arguement create" do 
    @help.process("create").should == Jitterbug::Resources::Text::Help::Create    
  end
  
  it "should provide a help message for the arguement viz" do 
    @help.process("viz").should == Jitterbug::Resources::Text::Help::Viz    
  end
  
  it "should provide a help message for the arguement select" do 
    @help.process("select").should == Jitterbug::Resources::Text::Help::Select    
  end
  it "should provide a help message for the arguement add" do 
    @help.process("add").should == Jitterbug::Resources::Text::Help::Add    
  end
  it "should provide a help message for the arguement revert" do 
    @help.process("revert").should == Jitterbug::Resources::Text::Help::Revert    
  end
  it "should provide a help message for the arguement move" do 
    @help.process("move").should == Jitterbug::Resources::Text::Help::Move    
  end
  it "should provide a help message for the arguement clean" do 
    @help.process("clean").should == Jitterbug::Resources::Text::Help::Clean    
  end
  it "should provide a help message for the arguement delete" do 
    @help.process("delete").should == Jitterbug::Resources::Text::Help::Delete    
  end
  it "should provide a help message for the arguement copy" do 
    @help.process("copy").should == Jitterbug::Resources::Text::Help::Copy    
  end
  it "should provide a help message for the arguement rename" do 
    @help.process("rename").should == Jitterbug::Resources::Text::Help::Rename    
  end
  it "should provide a help message for the arguement render" do 
    @help.process("render").should == Jitterbug::Resources::Text::Help::Render    
  end 
end