require File.dirname(__FILE__) + '/spec_helper'

describe "Time extension: " do
  it "should convert time to epoch days" do
    Time.at(1348617600).to_epoch_days.should == 15609
  end
end