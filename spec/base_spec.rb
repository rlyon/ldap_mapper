require File.dirname(__FILE__) + '/spec_helper'

describe "LdapMapper::Base: " do
  it_behaves_like "ActiveModel"
  
  before(:all) do
    @ldap_server = Ladle::Server.new(
      :quiet => true,
      :port => 3897,
      :ldif => "./spec/files/test.ldif",
      :custom_schemas => %w(org.apache.directory.server.core.schema.bootstrap.NisSchema),
      :tmpdir => "./spec/tmp"
    ).start
  end

  after(:all) do
    @ldap_server.stop if @ldap_server
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
    # @user.public_methods.include?(:"password_encrypted").should == true
  end

  it "should dynamically create the mappings back to LDAP" do
    @user.mappings[:username].should == 'uid'
    @user.mappings[:common_name].should == 'cn'
    @user.mappings[:email].should == 'mail'
    @user.mappings[:uid_number].should == 'uidnumber'
    @user.mappings[:group_number].should == 'gidnumber'
    @user.mappings[:last_change].should == 'shadowlastchange'
    @user.mappings[:password].should == 'userpassword'
  end

  # it "should dynamically create the ldap value converters" do
  #   @user.public_methods.include?(:"username_convert").should == true
  #   @user.public_methods.include?(:"common_name_convert").should == true
  #   @user.public_methods.include?(:"email_convert").should == true
  #   @user.public_methods.include?(:"uid_number_convert").should == true
  #   @user.public_methods.include?(:"group_number_convert").should == true
  #   @user.public_methods.include?(:"last_change_convert").should == true
  #   @user.public_methods.include?(:"password_convert").should == true
  # end

  it "should be able to convert the values to what ldap expects" do
    @user.username = "testuser"
    @user.username.should == "testuser"
    @user.uid_number = "1000"
    @user.uid_number.should == 1000
    @user.last_change = "15609"
    @user.last_change.should == Time.at(1348617600)
    @user.password = "password"
    @user.password.should == check_password("password", @user.password)
  end

  it "should set all attribute values to nil on initialization" do
    @user.username.should == nil
    @user.common_name.should == nil
    @user.email.should == nil
    @user.uid_number.should == nil
    @user.group_number.should == nil
    @user.last_change.should == nil
    @user.password.should == nil
  end

  it "should set all ldap ops to :noop on initialization" do
    %w{username common_name email uid_number group_number last_change password}.each do |attr|
      @user.operation(:"#{attr}").should == :noop
    end
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
    @user.last_change = Time.at(1348617600)
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

  it "should allow an epoch_days type to accept Time and Integer (or somthing that can be casted to an Integer)" do
    @user.last_change = "15609"
    @user.last_change.should == Time.at(1348617600)
    @user.last_change = 15609
    @user.last_change.should == Time.at(1348617600)
    @user.last_change = Time.at(1348617600)
    @user.last_change.should == Time.at(1348617600)
  end

  it "should contain the object class information" do
    LdapTestUser.objectclasses.should == ["posixAccount","shadowAccount","inetOrgPerson"]
  end
end
