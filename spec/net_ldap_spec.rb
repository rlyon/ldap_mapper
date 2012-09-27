require File.dirname(__FILE__) + '/spec_helper'

describe "LdapMapper::Base: " do
  it "should generate a ssha password with a salt" do
    salt = "1234abcd"
    Net::LDAP::Password.generate(:ssha, "password", salt).should == "{SSHA}2mO7Uxll0a1/7+sMOzb7hYXD5lsxMjM0YWJjZA=="
  end

  it "should generate a ssha password without a salt" do
    ssha = Net::LDAP::Password.generate(:ssha, "password")
    ssha.should == check_password("password", ssha)
  end

  it "should generate a sha password" do
    sha = Net::LDAP::Password.generate(:sha, "password")
    sha.should == "{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g="
  end

  it "should generate a md5 password" do
    md5 = Net::LDAP::Password.generate(:md5, "password")
    md5.should == "{MD5}X03MO1qnZdYdgyfeuILPmQ=="
  end
end