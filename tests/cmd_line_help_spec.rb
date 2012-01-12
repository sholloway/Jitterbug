Dir['./vendor/**/*.rb'].map {|f| puts f; require f}
Dir['./lib/**/*.rb'].map {|f| puts f; require f}

describe Jitterbug::CmdLineHelp do
  before(:all) do 
    @help = Jitterbug::CmdLineHelp.new
  end
  
  it "should provide an error message for commands not handled" do 
    @help.process("bad command").should == "no help for command bad command"
  end
  
  it "should provide a help message for the arguement commands" do 
    @help.process("commands").should == Jitterbug::CmdLineHelp::Command    
  end
  
  it "should provide a help message for the arguement create" do 
    @help.process("create").should == Jitterbug::CmdLineHelp::Create    
  end
  
  it "should provide a help message for the arguement viz" do 
    @help.process("viz").should == Jitterbug::CmdLineHelp::Viz    
  end
  
  it "should provide a help message for the arguement select" do 
    @help.process("select").should == Jitterbug::CmdLineHelp::Select    
  end
  it "should provide a help message for the arguement add" do 
    @help.process("add").should == Jitterbug::CmdLineHelp::Add    
  end
  it "should provide a help message for the arguement revert" do 
    @help.process("revert").should == Jitterbug::CmdLineHelp::Revert    
  end
  it "should provide a help message for the arguement move" do 
    @help.process("move").should == Jitterbug::CmdLineHelp::Move    
  end
  it "should provide a help message for the arguement clean" do 
    @help.process("clean").should == Jitterbug::CmdLineHelp::Clean    
  end
  it "should provide a help message for the arguement delete" do 
    @help.process("delete").should == Jitterbug::CmdLineHelp::Delete    
  end
  it "should provide a help message for the arguement copy" do 
    @help.process("copy").should == Jitterbug::CmdLineHelp::Copy    
  end
  it "should provide a help message for the arguement rename" do 
    @help.process("rename").should == Jitterbug::CmdLineHelp::Rename    
  end
  it "should provide a help message for the arguement render" do 
    @help.process("render").should == Jitterbug::CmdLineHelp::Render    
  end 
end