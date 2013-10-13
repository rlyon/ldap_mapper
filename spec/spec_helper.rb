puts ENV['COVERAGE']
if ENV['COVERAGE'] == "true"
  require 'simplecov'
  FILTER_DIRS = ['spec']
 
  SimpleCov.start do
    FILTER_DIRS.each{ |f| add_filter f }
  end
end

require 'rubygems'
require 'bundler/setup'
require 'ldap_mapper'
require 'mocha/api'
# require 'net/ldap'

# @fake_entry = Net::LDAP::Entry.new('uid=fake,ou=people,dc=example,dc=com')
# @fake_entry['uid'] = "fake"
# @fake_entry['cn'] = "Fake User"
# @fake_entry['givenname'] = "Fake"
# @fake_entry['sn'] = "User"
# @fake_entry['mail'] = "fake@example.com"
# @fake_entry['uidnumber'] = "1000"
# @fake_entry['shadowlastchange'] = "15609"
# @fake_entry['userPassword'] = "{SSHA}2mO7Uxll0a1/7+sMOzb7hYXD5lsxMjM0YWJjZA==" # password

class LdapFakeUser
  include LdapMapper::Base
  base "ou=people,dc=example,dc=com"
  identifier "uid"
  objectclass "posixAccount"
  objectclass "shadowAccount"
  objectclass "inetOrgPerson"
  attribute :username,      :map => "uid"
  attribute :common_name,   :map => "cn"
  attribute :first_name,    :map => "givenname"
  attribute :last_name,     :map => "sn"
  attribute :email,         :map => "mail"
  attribute :uid_number,    :map => "uidnumber", :type => :integer
  attribute :last_change,   :map => "shadowlastchange", :type => :epoch_days
  attribute :password,      :map => "userPassword", :type => :password
end

class LdapTestUser
  include LdapMapper::Base
  base "ou=test,dc=example,dc=com"
  objectclass "posixAccount"
  objectclass "shadowAccount"
  objectclass "inetOrgPerson"
  attribute :username,      :map => "uid"
  attribute :common_name,   :map => "cn"
  attribute :email,         :map => "mail"
  attribute :uid_number,    :map => "uidNumber", :type => :integer
  attribute :group_number,  :map => "gidNumber", :type => :integer
  attribute :last_change,   :map => "shadowLastChange", :type => :epoch_days
  attribute :password,      :map => "userPassword", :type => :password
end

# class Net::LDAP::Mock
#   def initialize(ldif)
#     @ds = Net::LDAP::Dataset.read_ldif(File.open('./spec/files/testusers.ldif'))
#   end

#   def where
#     nil
#   end
# end

def check_password(password, ssha)
  salt = Base64.decode64(ssha.gsub(/^\{SSHA\}/, ''))[20..-1]
  Net::LDAP::Password.generate(:ssha, password, salt)
end

RSpec.configure do |config|
  config.mock_with        :mocha
end
