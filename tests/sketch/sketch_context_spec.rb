require 'renderer/osx/sketch2d'

describe Jitterbug::Sketch::Context do
  it "should raise error if key is not an accepted state" do 
    context = Jitterbug::Sketch::Context.new
    expect{context[:crap] = "dookie"}.to raise_error 
  end
  
  it "should accept :background_color" do
    context = Jitterbug::Sketch::Context.new
    expect{context[:background_color] = :red}.to_not raise_error
  end
end