require File.dirname(__FILE__) + '/spec_helper'

describe "LdapMapper::Base: " do
  before(:all) do
    LDAP_MAPPER_HOST="localhost"
    LDAP_MAPPER_PORT=389
    LDAP_MAPPER_ADMIN="cn=manager,dc=example,dc=com"
    LDAP_MAPPER_ADMIN_PASSWORD="mysupersecretpassword"
  end

  before(:each) do
    @user = LdapTestUser.new
  end

  it "should dynamically create setter methods" do
    @user.public_methods.include?(:"username=").should == true
    @user.public_methods.include?(:"common_name=").should == true
    @user.public_methods.include?(:"email=").should == true
    @user.public_methods.include?(:"uid_number=").should == true
    @user.public_methods.include?(:"group_number=").should == true
    @user.public_methods.include?(:"last_change=").should == true
    @user.public_methods.include?(:"password=").should == true
  end

  it "should dynamically create getter methods" do
    @user.public_methods.include?(:"username").should == true
    @user.public_methods.include?(:"common_name").should == true
    @user.public_methods.include?(:"email").should == true
    @user.public_methods.include?(:"uid_number").should == true
    @user.public_methods.include?(:"group_number").should == true
    @user.public_methods.include?(:"last_change").should == true
    @user.public_methods.include?(:"password").should == true
    @user.public_methods.include?(:"password_encrypted").should == true
  end

  it "should dynamically create the mapper methods" do
    @user.public_methods.include?(:"username_mapping").should == true
    @user.public_methods.include?(:"common_name_mapping").should == true
    @user.public_methods.include?(:"email_mapping").should == true
    @user.public_methods.include?(:"uid_number_mapping").should == true
    @user.public_methods.include?(:"group_number_mapping").should == true
    @user.public_methods.include?(:"last_change_mapping").should == true
    @user.public_methods.include?(:"password_mapping").should == true

    @user.username_mapping.should == "uid"
    @user.common_name_mapping.should == "cn"
    @user.email_mapping.should == "mail"
    @user.uid_number_mapping.should == "uidNumber"
    @user.group_number_mapping.should == "gidNumber"
    @user.last_change_mapping.should == "shadowLastChange"
    @user.password_mapping.should == "userPassword"
  end

  it "should dynamically create the ldap value converters" do
    @user.public_methods.include?(:"username_convert").should == true
    @user.public_methods.include?(:"common_name_convert").should == true
    @user.public_methods.include?(:"email_convert").should == true
    @user.public_methods.include?(:"uid_number_convert").should == true
    @user.public_methods.include?(:"group_number_convert").should == true
    @user.public_methods.include?(:"last_change_convert").should == true
    @user.public_methods.include?(:"password_convert").should == true
  end

  it "should be able to convert the values to what ldap expects" do
    @user.username = "testuser"
    @user.username_convert.is_a?(String).should == true
    @user.username_convert.should == "testuser"
    @user.uid_number = "1000"
    @user.uid_number_convert.is_a?(String).should == true
    @user.uid_number_convert.should == "1000"
    @user.last_change = "15609"
    @user.last_change_convert.is_a?(String).should == true
    @user.last_change_convert.should == "15609"
    @user.password = "password"
    @user.password_convert.should == check_password("password", @user.password_encrypted)
  end

  it "should have a class method 'attributes' that is an array of all the attributes" do
    LdapTestUser.attributes.is_a?(Array).should == true
    LdapTestUser.attributes.should == [:username,:common_name,:email,:uid_number,:group_number,:last_change,:password]
  end

  it "should set the instance attributes hash when the accessor methods are called" do
    @user.username = "testuser"
    @user.common_name = "Test User"
    @user.email = "testuser@example.com"
    @user.uid_number = 1000
    @user.group_number = 1000
    @user.last_change = 15609
    @user.attributes.should == {
      :username => "testuser", 
      :common_name => "Test User", 
      :email => "testuser@example.com", 
      :uid_number => 1000, 
      :group_number => 1000,
      :last_change => Time.at(1348617600)
    }
  end

  it "should return the correct values from the getter methods" do
    @user.username = "testuser"
    @user.common_name = "Test User"
    @user.email = "testuser@example.com"
    @user.uid_number = 1000
    @user.group_number = 1000
    @user.last_change = 15609
    @user.username.should == "testuser"
    @user.common_name.should == "Test User"
    @user.email.should == "testuser@example.com"
    @user.uid_number.should == 1000
    @user.group_number.should == 1000
    @user.last_change.should == Time.at(1348617600)
  end

  it "should convert values to :type in setter methods" do
    @user.uid_number = "1000"
    @user.uid_number.is_a?(Integer).should == true
    @user.last_change = "15609"
    @user.last_change.is_a?(Time).should == true
  end

  it "should be able to return a hash containing mapped and converted attributes" do
    @user.username = "testuser"
    @user.common_name = "Test User"
    @user.email = "testuser@example.com"
    @user.uid_number = 1000
    @user.group_number = 1000
    @user.last_change = Time.at(1348617600)
    @user.mapped_and_converted_attributes.should == {
      "uid" => "testuser",
      "cn" => "Test User",
      "mail" => "testuser@example.com",
      "uidNumber" => "1000",
      "gidNumber" => "1000",
      "shadowLastChange" => "15609"
    }
  end

  it "should only return non-nil attributes when mapped and converted" do
    @user.username = "testuser"
    @user.common_name = "Test User"
    @user.mapped_and_converted_attributes.should == {
      "uid" => "testuser",
      "cn" => "Test User"
    }
  end

  it "should import attributes" do
    imported = {
      "uid" => "testuser",
      "cn" => "Test User",
      "mail" => "testuser@example.com",
      "uidNumber" => "1000",
      "gidNumber" => "1000",
      "shadowLastChange" => "15609"
    }
    @user.import_attributes(imported).should == true
    @user.attributes.should == {
      :username => "testuser", 
      :common_name => "Test User", 
      :email => "testuser@example.com", 
      :uid_number => 1000, 
      :group_number => 1000,
      :last_change => Time.at(1348617600)
    }
  end

  it "should import attributes from a Net::LDAP::Entry object" do
    user = LdapFakeUser.new
    entry = Net::LDAP::Dataset.read_ldif(File.open('./spec/files/testusers.ldif')).to_entries.first
    user.import_attributes(entry)
    user.username.should == "mock"
    user.common_name.should == "Mock User"
    user.first_name.should == "Mock"
    user.last_name.should == "User"
    user.email.should == "mock@example.com"
    user.last_change.should == Time.at(1348617600)
    user.uid_number == 1000
  end

  it "should allow an epoch_days type to accept Time and Integer (or somthing that can be casted to an Integer)" do
    @user.last_change = "15609"
    @user.last_change.should == Time.at(1348617600)
    @user.last_change = 15609
    @user.last_change.should == Time.at(1348617600)
    @user.last_change = Time.at(1348617600)
    @user.last_change.should == Time.at(1348617600)
  end

  it "should only set the encrypted password if the password is already hashed" do
    @user.password = "{SSHA}2mO7Uxll0a1/7+sMOzb7hYXD5lsxMjM0YWJjZA=="
    @user.password.should == nil
    @user.password_encrypted.should == "{SSHA}2mO7Uxll0a1/7+sMOzb7hYXD5lsxMjM0YWJjZA=="
  end

  it "should set the password and also encrypt if the password is not hashed" do
    @user.password = "password"
    @user.password.should == "password"
    check_password("password", @user.password_encrypted)
  end

  it "should contain the object class information" do
    LdapTestUser.objectclasses.should == ["posixAccount","shadowAccount","inetOrgPerson"]
  end
end