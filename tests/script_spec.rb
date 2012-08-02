Dir['./lib','./lib/**'].reject{|f| !File.directory?(f)}.map{|dir| $:.unshift(dir) }
Dir['./vendor/**/*.rb','./lib/**/*.rb'].map {|f| require f}

require "construct"

describe Jitterbug::Sketch::Script do
  include Construct::Helpers
  
  it "should load the content into memory" do
    within_construct do |dir|
      filename = "source.rb"
      contents = "puts 'hello world'"
      dir.file filename, contents
      filepath = File.expand_path(filename)
      script = Jitterbug::Sketch::Script.new(filepath)
      script.content.nil?.should == true
      script.load
      script.content.should == contents
    end
  end
  
  it "should save the content to the file path" do
    within_construct do |dir|
      filename = "source.rb"
      content = "puts 'another test'"
      dir.file filename, content
      filepath = File.expand_path(filename)
      script = Jitterbug::Sketch::Script.new(filepath)

      script.content="something different"
      script.save
      
      new_content = ''
      open(filename,'r'){|f| new_content = f.read}
      new_content.should == script.content
    end
  end
      
  it "should not override the file on save unless it's flagged as dirty" do
    within_construct do |dir|
      filename = "source.rb"
      content = "puts 'another test'"
      dir.file filename, content
      filepath = File.expand_path(filename)
      script = Jitterbug::Sketch::Script.new(filepath)

      script.content=nil
      script.save
      
      new_content = ''
      open(filename,'r'){|f| new_content = f.read}
      new_content.should == content
    end
  end
  
  it "should set dirty to false on load" do
    within_construct do |dir|
      filename = "source.rb"
      contents = "puts 'hello world'"
      dir.file filename, contents
      filepath = File.expand_path(filename)
      script = Jitterbug::Sketch::Script.new(filepath)
      script.dirty?.should == false
      script.content = "crazy bit of strange"
      script.dirty?.should == true
      script.load
      script.dirty?.should == false
    end
  end
end