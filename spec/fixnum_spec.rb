require File.dirname(__FILE__) + '/spec_helper'

describe "Fixnum extension: " do
  it "should convert epoch seconds to epoch days" do
    15609.epoch_days.should == Time.at(1348617600)
  end
end