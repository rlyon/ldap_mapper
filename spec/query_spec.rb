require File.dirname(__FILE__) + '/spec_helper'

describe "LdapMapper::Plugins::Query: " do
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

  it "should load all entries from an ldap search" do
    users = LdapFakeUser.all
    users.size.should == 27
  end

  it "should return a single object from find" do
    user = LdapFakeUser.find('aa729')
    user.username.should == "aa729"
    user.common_name.should == "Alexandra Adams"
    user.first_name.should == "Alexandra"
    user.last_name.should == "Adams"
    user.email.should == "alexandra@example.org"
    user.uid_number.should == 1000
  end

  it "should return an array of objects from where" do
    users = LdapFakeUser.where(username: "z*")
    users.size.should == 2

    user = users[0]
    user.username.should == "zz882"
    user.common_name.should == "Zana Zimmerman"
    user.first_name.should == "Zana"
    user.last_name.should == "Zimmerman"
    user.email.should == "zana@example.org"
    user.uid_number.should == 1025

    user = users[1]
    user.username.should == "zz883"
    user.common_name.should == "Zoro Zimmerman"
    user.first_name.should == "Zoro"
    user.last_name.should == "Zimmerman"
    user.email.should == "zoro@example.org"
    user.uid_number.should == 1026
  end

  it "should return an array of objects from where" do
    users = LdapFakeUser.where(username: "z*", uid_number: 1026)
    users.size.should == 1

    user = users[0]
    user.username.should == "zz883"
    user.common_name.should == "Zoro Zimmerman"
    user.first_name.should == "Zoro"
    user.last_name.should == "Zimmerman"
    user.email.should == "zoro@example.org"
    user.uid_number.should == 1026
  end

  it "should hace a dn created from the base and the set identifier" do
    user = LdapFakeUser.new
    user.username = "aa729"
    user.dn.should == "uid=aa729,ou=people,dc=example,dc=org"
  end

  it "should change the operation to :add if the attribute is nil before setting" do
    user = LdapFakeUser.new
    user.username = "Foo"
    user.operation(:username).should == :add
  end

  it "should change the operation to :modify if the attribute is not nil before setting" do
    user = LdapFakeUser.find("dd945")
    user.first_name = "Dot"
    user.operation(:first_name).should == :replace
  end

  it "should change the operation to :delete if the attribute is nil after setting" do
    user = LdapFakeUser.find("dd945")
    user.first_name = nil
    user.operation(:first_name).should == :delete
  end

  it "should save modifications made to a user" do
    user = LdapFakeUser.find("dd945")
    user.first_name.should == "Dorothy"

    user.first_name = "Dot"
    user.last_name = "Diggity"
    user.common_name = "Dot Diggity"
    user.email = "dot@example.org"
    user.uid_number = 9999
    user.primary_group = 1001
    user.password = "password"
    user.save

    user = LdapFakeUser.find("dd945")
    user.first_name.should == "Dot"
    user.last_name.should == "Diggity"
    user.common_name.should == "Dot Diggity"
    user.email = "dot@example.org"
    user.uid_number = 9999
    user.primary_group = 1001
    user.password = check_password("password", user.password)
  end

  it "should contain two groups" do
    groups = LdapFakeGroup.all
    groups.size.should == 2
  end

  it "should contain a members array in the sysad group" do
    group = LdapFakeGroup.find('admin')
    group.members.is_a?(Array).should == true
    group.members.size.should == 3
  end
  
  it "should set and save the members array in groups" do
    group = LdapFakeGroup.find('admin')
    group.members = group.members | ["dd945"]
    group.operation(:members).should == :replace
    group.save

    group = LdapFakeGroup.find('admin')
    group.members.size.should == 4
    group.members.include?("dd945").should == true
  end

  it "should return an empty array if there are no results returned." do
    groups = LdapFakeGroup.where(:common_name => "foogroup")
    groups.size.should == 0
  end

  it "should throw an exception it find has no results" do
    expect {
      user = LdapFakeUser.find("foouser")
    }.to raise_error(LdapMapper::RecordNotFound) { |e|
      e.message.should == "The requested record was not found."
    } 
  end

  it "should delete a record" do
    user = LdapFakeUser.find('dd945')
    user.delete
    expect {
      user = LdapFakeUser.find("dd945")
    }.to raise_error(LdapMapper::RecordNotFound) { |e|
      e.message.should == "The requested record was not found."
    }
  end
end