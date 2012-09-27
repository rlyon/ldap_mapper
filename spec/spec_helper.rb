if ENV['COVERAGE']
  require 'simplecov'
  FILTER_DIRS = ['spec']
 
  SimpleCov.start do
    FILTER_DIRS.each{ |f| add_filter f }
  end
end

require 'rubygems'
require 'bundler/setup'
require 'ldap_mapper'
require 'mocha_standalone'

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

def check_password(password, ssha)
  salt = Base64.decode64(ssha.gsub(/^\{SSHA\}/, ''))[20..-1]
  Net::LDAP::Password.generate(:ssha, password, salt)
end

RSpec.configure do |config|
  config.mock_with        :mocha
end
