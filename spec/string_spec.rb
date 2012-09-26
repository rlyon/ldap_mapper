require File.dirname(__FILE__) + '/spec_helper'

describe "String extension: " do 
  it "should return a alpha only string" do
    s = String.random(:length => 100, :charset => :alpha)
    (s =~ /^[a-zA-Z]+$/).should >= 0
    (s =~ /^[0-9]+$/).should be_nil
  end
  
  it "should return a uppercase alphanumeric only string" do
    s = String.random(:length => 100, :charset => :alnum_upper)
    (s =~ /^[0-9A-Z]+$/).should >= 0
    (s =~ /^[a-z]+$/).should be_nil
  end

  it "should return random strings" do
    String.random.should_not == String.random
    String.random.should_not == String.random
    String.random.should_not == String.random
    String.random.should_not == String.random
    String.random.should_not == String.random
  end
end