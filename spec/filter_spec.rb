require File.dirname(__FILE__) + '/spec_helper'

describe "LdapMapper::Filter: " do
  it "should return a simple filter for eq" do
    filter = LdapMapper::Filter.eq('uid', 'rlyon')
    filter.to_s.should == '(uid=rlyon)'
  end

  it "should return a simple filter for lte" do
    filter = LdapMapper::Filter.lte('uid', 'rlyon')
    filter.to_s.should == '(uid<=rlyon)'
  end

  it "should return a simple filter for gte" do
    filter = LdapMapper::Filter.gte('uid', 'rlyon')
    filter.to_s.should == '(uid>=rlyon)'
  end

  it "should chain filters with and" do
    filter1 = LdapMapper::Filter.eq('uid', 'rlyon')
    filter2 = LdapMapper::Filter.eq('uid', 'jimbob')
    filter = LdapMapper::Filter.and(filter1,filter2)
    filter.to_s.should == '(&(uid=rlyon)(uid=jimbob))'
  end

  it "should chain filters more than two with and" do
    filter1 = LdapMapper::Filter.eq('uid', 'rlyon')
    filter2 = LdapMapper::Filter.eq('uid', 'jimbob')
    filter3 = LdapMapper::Filter.eq('uid', 'jugs')
    filter = LdapMapper::Filter.and(filter1,filter2,filter3)
    filter.to_s.should == '(&(uid=rlyon)(uid=jimbob)(uid=jugs))'
  end

  it "should chain filters more than two with or" do
    filter1 = LdapMapper::Filter.eq('uid', 'rlyon')
    filter2 = LdapMapper::Filter.eq('uid', 'jimbob')
    filter3 = LdapMapper::Filter.eq('uid', 'jugs')
    filter = LdapMapper::Filter.or(filter1,filter2,filter3)
    filter.to_s.should == '(|(uid=rlyon)(uid=jimbob)(uid=jugs))'
  end

  it "should chain filters with or" do
    filter1 = LdapMapper::Filter.eq('uid', 'rlyon')
    filter2 = LdapMapper::Filter.eq('uid', 'jimbob')
    filter = LdapMapper::Filter.or(filter1,filter2)
    filter.to_s.should == '(|(uid=rlyon)(uid=jimbob))'
  end

  it "should apply the 'not' filter" do
    filter1 = LdapMapper::Filter.eq('uid', 'rlyon')
    filter = LdapMapper::Filter.not(filter1)
    filter.to_s.should == '(!(uid=rlyon))'
  end

end