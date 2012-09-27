require File.dirname(__FILE__) + '/spec_helper'

describe "Tools for Net::LDAP: " do 
  it "should return a hash of compressed values" do
    entry = Net::LDAP::Entry.from_single_ldif_string(
      %q{
dn: mydn
foo: foo
bar: bar
bar: baz}
    )
    LdapMapper::Tools.to_hash(entry, :compress => true).should == {'dn' => 'mydn', 'foo' => 'foo', 'bar' => ['bar','baz']}
  end

  it "should return a hash of values" do
    entry = Net::LDAP::Entry.from_single_ldif_string(
      %q{
dn: mydn
foo: foo
bar: bar
bar: baz}
    )
    LdapMapper::Tools.to_hash(entry).should == {'dn' => ['mydn'], 'foo' => ['foo'], 'bar' => ['bar','baz']}
  end
end