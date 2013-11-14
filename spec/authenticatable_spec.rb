require File.dirname(__FILE__) + '/spec_helper'

describe "LdapMapper::Plugins::Authenticatable" do
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

  it "should store the allowed authentication attributes" do
    LdapAuthenticatableUser.auth_allowed.sort.should == [:email, :username]
  end

  it "should authenticate using the default identifier" do
    LdapAuthenticatableUser.authenticate("aa729", "smada").should be_true
  end

  it "should fail to authenticate using the default identifier and a bad password" do
    LdapAuthenticatableUser.authenticate("aa729", "badpassword").should be_false
  end

  it "should fail to authenticate using the default identifier and a bad user" do
    LdapAuthenticatableUser.authenticate("aa726", "smada").should be_false
  end

  it "should authenticate with an email address" do
    LdapAuthenticatableUser.authenticate_by(attr: :email, value: 'alexandra@example.org', password: 'smada').should be_true
  end

  it "should not authenticate with a attribute not on the allowed list" do
    expect {
      LdapAuthenticatableUser.authenticate_by(attr: :common_name, value: 'Alexandra Adams', password: 'smada')
    }.to raise_error(LdapMapper::NotAuthorizedError) { |e|
      e.message.should == "Unable to authenticate using common_name."
    }
  end
end