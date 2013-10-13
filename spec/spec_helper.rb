puts ENV['COVERAGE']
if ENV['COVERAGE'] == "true"
  require 'simplecov'
  FILTER_DIRS = ['spec', 'vendor']
 
  SimpleCov.start do
    FILTER_DIRS.each{ |f| add_filter f }
  end
end

require 'rubygems'
require 'bundler/setup'
require 'ldap_mapper'
require 'mocha/api'
require 'ladle'

class LdapFakeUser
  include LdapMapper::Base
  base "ou=people,dc=example,dc=org"
  identifier "uid"
  objectclass "top"
  objectclass "person"
  objectclass "organizationalPerson"
  objectclass "inetOrgPerson"
  objectclass "posixAccount"
  attribute :username,      :map => "uid"
  attribute :common_name,   :map => "cn"
  attribute :first_name,    :map => "givenName"
  attribute :last_name,     :map => "sn"
  attribute :uid_number,    :map => "uidNumber", :type => :integer
  attribute :email,         :map => "mail"
  attribute :password,      :map => "userPassword", :type => :password
end

class LdapTestUser
  include LdapMapper::Base
  base "ou=test,dc=example,dc=org"
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
