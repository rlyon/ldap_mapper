require File.dirname(__FILE__) + '/spec_helper'

describe "Net::LDAP extension: " do 
  it "should generate a ssha password with a salt" do
    salt = "1234abcd"
    Net::LDAP::Password.generate(:ssha, "password", salt).should == "{SSHA}2mO7Uxll0a1/7+sMOzb7hYXD5lsxMjM0YWJjZA=="
  end

  it "should generate a ssha without a salt" do
    ssha = Net::LDAP::Password.generate(:ssha, "password")
    ssha.should == check_password("password", ssha)
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
end